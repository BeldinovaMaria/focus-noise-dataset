%% Generate noisy images for one class (focus intensity)
% Creates ~500 augmented images for a single class based on intensityFocus.
% Class = absolute value of the topological charge |mVortex|:
% images for +absM and -absM are merged into the same class folder.

clear all
clear classes
clc

% -------- Base model parameters (class definition) --------
lambda = 0.633;
NA = 0.95;
rMin = -1.0;
rMax = 1.0;
discretization = 100;

% Class parameters
absM = 5;          % |mVortex|, expected range 1..8
delta = pi/8;

% Number of generated images for this class
numImages = 500;

% -------- Prepare class output folder --------
projectRoot = pwd;
datasetRoot = fullfile(projectRoot, 'generated_focus_noise_dataset');
className = sprintf('class_absM_%d', absM);
classFolder = fullfile(datasetRoot, className);

if ~exist(datasetRoot, 'dir')
    mkdir(datasetRoot);
end
if ~exist(classFolder, 'dir')
    mkdir(classFolder);
end

% -------- Calculate base focus intensity for +absM and -absM --------
signList = [1, -1];
baseImages = cell(1, numel(signList));
for sIdx = 1:numel(signList)
    r2 = circularPar(lambda, NA, 'right');
    r2.mVortex = signList(sIdx) * absM;
    r2.alphaMax = 2*pi - delta/2;
    r2.alphaMin = delta/2;
    r2 = r2.setRBorders(rMin, rMax, discretization);
    r2 = r2.calcIntensityFocus();

    b = real(r2.intensityFocus);
    b = b - min(b(:));
    if max(b(:)) > 0
        b = b ./ max(b(:));
    end
    baseImages{sIdx} = b;
end

% -------- Generate noisy images --------
rng('shuffle');
cmap = getViridisMap(256);
for idx = 1:numImages
    % Alternate signs so that +absM and -absM are equally represented
    sIdx = mod(idx - 1, numel(signList)) + 1;
    mVort = signList(sIdx) * absM;
    img = baseImages{sIdx};

    % Gaussian noise with random strength
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

    % Re-normalize and clip to [0, 1]
    img = img - min(img(:));
    maxVal = max(img(:));
    if maxVal > 0
        img = img ./ maxVal;
    end
    img = min(max(img, 0), 1);

    rgbImage = ind2rgb(uint8(img * 255) + 1, cmap);
    outName = sprintf('img_%04d_m%+d.png', idx, mVort);
    imwrite(rgbImage, fullfile(classFolder, outName));
end

fprintf('Generated %d noisy images in folder:\n%s\n', numImages, classFolder);

function cmap = getViridisMap(n)
% Fallback viridis approximation (works without extra toolboxes/functions).
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
