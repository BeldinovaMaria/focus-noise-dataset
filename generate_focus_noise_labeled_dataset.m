%% Generate labeled viridis dataset for multiple classes
% Class = absolute value of the topological charge |mVortex| in {1, ..., 8}.
% Positive and negative charges (+m and -m) are merged into one class.
% delta in {pi/8, pi/16}
% numImagesPerVariant images per (sign, delta) combination,
% i.e. 2 signs * 2 deltas * numImagesPerVariant images per class

clear all
clear classes
clc

% -------- Base model parameters --------
lambda = 0.633;
NA = 0.95;
rMin = -1.0;
rMax = 1.0;
discretization = 100;
numImagesPerVariant = 25;   % per (sign, delta) -> 100 images per class

% Requested classes: |mVortex| = 1..8, both signs merged into one class
absMList = 1:8;
signList = [1, -1];
deltaList = [pi/8, pi/16];

% -------- Output folders --------
projectRoot = pwd;
datasetRoot = fullfile(projectRoot, 'generated_focus_noise_dataset');
if ~exist(datasetRoot, 'dir')
    mkdir(datasetRoot);
end

% Colormap (viridis-like, no external dependency)
cmap = getViridisMap(256);

% -------- Generate data --------
rng('shuffle');
totalSaved = 0;

for aIdx = 1:numel(absMList)
    absM = absMList(aIdx);

    className = sprintf('class_absM_%d', absM);
    classFolder = fullfile(datasetRoot, className);
    if ~exist(classFolder, 'dir')
        mkdir(classFolder);
    end

    % Label shows only |mVortex|, the sign is not part of the class
    labelText = sprintf('|mVortex|=%d', absM);
    imgIdx = 0;

    for sIdx = 1:numel(signList)
        mVort = signList(sIdx) * absM;

        for dIdx = 1:numel(deltaList)
            delta = deltaList(dIdx);

            r2 = circularPar(lambda, NA, 'right');
            r2.mVortex = mVort;
            r2.alphaMax = 2*pi - delta/2;
            r2.alphaMin = delta/2;
            r2 = r2.setRBorders(rMin, rMax, discretization);
            r2 = r2.calcIntensityFocus();

            baseImage = real(r2.intensityFocus);
            baseImage = baseImage - min(baseImage(:));
            if max(baseImage(:)) > 0
                baseImage = baseImage ./ max(baseImage(:));
            end

            for idx = 1:numImagesPerVariant
                img = addNoise(baseImage);
                rgbImage = ind2rgb(uint8(img * 255) + 1, cmap);
                rgbLabeled = addLabelToImage(rgbImage, labelText);

                % Sign and delta are kept only in the file name (for reference)
                imgIdx = imgIdx + 1;
                outName = sprintf('img_%03d_m%+d_delta_%s.png', imgIdx, mVort, ...
                    strrep(deltaToText(delta), '/', ''));
                imwrite(rgbLabeled, fullfile(classFolder, outName));
                totalSaved = totalSaved + 1;
            end
        end
    end
end

fprintf('Generated %d images in folder:\n%s\n', totalSaved, datasetRoot);

function img = addNoise(baseImage)
img = baseImage;

% Gaussian noise
sigmaGauss = 0.005 + (0.06 - 0.005) * rand();
img = img + sigmaGauss * randn(size(img));

% Multiplicative (speckle-like) noise
sigmaMult = 0.00 + (0.08 - 0.00) * rand();
img = img .* (1 + sigmaMult * randn(size(img)));

% Sparse impulse noise (salt & pepper style)
impulseProb = 0.001 + (0.02 - 0.001) * rand();
mask = rand(size(img));
img(mask < impulseProb/2) = 0;
img(mask > 1 - impulseProb/2) = 1;

% Normalize to [0, 1]
img = img - min(img(:));
maxVal = max(img(:));
if maxVal > 0
    img = img ./ maxVal;
end
img = min(max(img, 0), 1);
end

function rgbOut = addLabelToImage(rgbIn, labelText)
% Draws label directly onto image by rendering in an off-screen figure.
fig = figure('Visible', 'off', 'Color', 'white', 'Position', [100 100 512 560]);
ax = axes('Parent', fig);
image(ax, rgbIn);
axis(ax, 'image');
axis(ax, 'off');
hold(ax, 'on');
text(ax, 6, size(rgbIn, 1)-6, labelText, ...
    'Color', 'w', ...
    'BackgroundColor', 'k', ...
    'FontSize', 10, ...
    'FontName', 'Arial', ...
    'Interpreter', 'none', ...
    'VerticalAlignment', 'bottom', ...
    'Margin', 2);
frame = getframe(ax);
rgbOut = frame2im(frame);
close(fig);
end

function txt = deltaToText(delta)
if abs(delta - pi/8) < 1e-12
    txt = 'pi/8';
elseif abs(delta - pi/16) < 1e-12
    txt = 'pi/16';
else
    txt = sprintf('%0.6f', delta);
end
end

function cmap = getViridisMap(n)
anchors = [
    0.267004, 0.004874, 0.329415;
    0.253935, 0.265254, 0.529983;
    0.163625, 0.471133, 0.558148;
    0.134692, 0.658636, 0.517649;
    0.477504, 0.821444, 0.318195;
    0.993248, 0.906157, 0.143936
];

x = linspace(0, 1, size(anchors, 1));
xq = linspace(0, 1, n);
cmap = zeros(n, 3);
for ch = 1:3
    cmap(:, ch) = interp1(x, anchors(:, ch), xq, 'pchip');
end
cmap = min(max(cmap, 0), 1);
end
