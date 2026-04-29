classdef RichWolf
    %RICHWOLF Summary of this class goes here
    %   Detailed explanation goes here

    properties

        % physical constants
        lambda;         % wavelength of the focused light (in mum)
        kWave;          % wavenumber
        refrMedia = 1.0;    % refraction index of media (air by default)
        z0 = 376.730313668; % impedance of free space
        % <- physical constants

        % lens characteristics
        NA;                 % numerical aperture of the lens
        thetaMin = 0.0;     % minimal polar angle (zero by default, i.e. no angular mask)
        thetaMax;           % maximum polar angle (defined by NA: NA = refrMedia * sin(thetaMax))
        alphaMin = 0.0;     % minimal azimuthal angle (zero by default)
        alphaMax = 2*pi;    % maximum azimuthal angle (2pi by default, i.e. no sector mask)
        apodizationType = 'aplanatic'   % apodization function of the focusing lens (aplanatic lens by default)
                                        % possible types are: 'aplanatic', 'diffractive', ...
        % <- lens characteristics

        % source characteristics
        mode = 'plane'      % distribution of amplitude of the input beam (uniform distribution by default)
                            % possible types are: 'plane', 'gaussian', ...
        
        % <- source characteristics

        % calcluated area
        rMin = -1;     % "r" used for transverse distributions
        rMax = 1;
        rNum = 100;
        rCoord;
        zCross = 0;         % z coordinate of transverse intensity calculation (z=0 - focal plane by default)

        zMin = -10;     % "z" used for longitudinal distributions
        zMax = 10;
        zNum = 100;
        zCoord;
        % <- calcluated area

        % %%%%%%%% distributions in focus (2D) %%%%%%%%
        intensityFocus;
        intExFocus
        intEyFocus
        intEzFocus

        intensityHFocus;
        intHxFocus
        intHyFocus
        intHzFocus

        ampExFocus
        ampEyFocus
        ampEzFocus

        ampHxFocus
        ampHyFocus
        ampHzFocus

        pxFocus     % Poynting x-component
        pyFocus
        pzFocus

        % %%%%%%%% <- distribution in focus %%%%%%%%
    end

    methods(Static)
        
        function [r, psi] = calcrpsi(x,y)   % это почему-то работает быстрее стандартной функции cart2pol
            r = (x.^2 + y.^2).^0.5;
            if y >= 0 && x >= 0
                psi = atan(y./x);
            elseif y > 0 && x <= 0
                psi = atan(y./x) + pi;
            elseif y < 0 && x < 0
                psi = atan(y./x) + pi;
            elseif y <= 0 && x >= 0
                psi = atan(y./x) + 2*pi;
            end
        end

        function typicalFigMod1D(obj, varargin)        % standart modification of my figures
            isAlong = false;
            isPoynting = false;
            for ii = 1:nargin-1
                if strcmp(varargin(ii), 'along')
                    isAlong = true;
                elseif strcmp(varargin(ii), 'Poynting')
                    isPoynting = true;
                end
            end
            if isAlong
                L1 = xlabel('z, \mum');
            else
                L1 = xlabel('x, \mum');
            end
            if isPoynting
                L2 = ylabel('P_z, arb. un.');
            else
                L2 = ylabel('Intensity, arb. un.');
            end
            modiffigures(gcf, gca);
            modiflabels([L1 L2]);
        end

        function typicalFigMod2D(obj, varargin)        % standart modification of my figures
            isAlong = false;
            isLaser = false;
            for ii = 1:nargin-1
                if strcmp(varargin(ii), 'along')
                    isAlong = true;
                elseif strcmp(varargin(ii), 'laser')
                    isLaser = true;
                end
            end
            colorbar;
            if isLaser == true
                if obj.lambda < 0.500
                    temp = hot;
                    bluemap = [temp(:,3), temp(:,2), temp(:,1)];
                    colormap(bluemap);
                elseif and(obj.lambda>=0.500, obj.lambda<0.560)
                    temp = hot;
                    greenmap = [temp(:,2), temp(:,1), temp(:,3)];
                    colormap(greenmap);
                else
                    colormap('hot');
                end
            end
            axis xy;
            if and(abs(obj.rMin)==abs(obj.rMax), not(isAlong))
                axis square
            end
            if isAlong
                L1 = xlabel('z, \mum');
            else
                L1 = xlabel('x, \mum');
            end
            L2 = ylabel('y, \mum');
            modiffigures(gcf, gca);
            modiflabels([L1 L2]);
        end
    end

    methods

        % constructor
        function obj = RichWolf()
            obj.rCoord = linspace(obj.rMin, obj.rMax, obj.rNum);    % in mum
            obj.zCoord = linspace(obj.zMin, obj.zMax, obj.zNum);    % in mum
        end
        % <- constructor

        % %%%%%%%%%%%%%%%%% setters %%%%%%%%%%%%%%%%%
        function obj = setThetaMin(obj, thetaMin)
            obj.thetaMin = thetaMin;
        end
        function obj = setNA(obj, NA, refrMedia)
            obj.NA = NA;
            obj.refrMedia = refrMedia;
            obj.thetaMax = asin(NA/refrMedia);
        end
        function obj = setThetaMax(obj, thetaMax, refrMedia)
            obj.thetaMax = thetaMax;
            obj.NA = refrMedia * sin(thetaMax);
            obj.refrMedia = refrMedia;
        end
        function obj = setRBorders(obj, rMin, rMax, rNum)
            obj.rMin = rMin;
            obj.rMax = rMax;
            obj.rNum = rNum;
            obj.rCoord = linspace(rMin, rMax, rNum);
        end
        function obj = setZBorders(obj, zMin, zMax, zNum)
            obj.zMin = zMin;
            obj.zMax = zMax;
            obj.zNum = zNum;
            obj.zCoord = linspace(zMin, zMax, zNum);
        end
        % <-- %%%%%%%%%%%%%%%%% setters %%%%%%%%%%%%%%%%%

        % stubs for calculation of amplitudes (calclulated differently for specific input field)
        function obj = calcAmpExFocus(obj)
        end
        function obj = calcAmpEyFocus(obj)
        end
        function obj = calcAmpEzFocus(obj)
        end
        function obj = calcAmpHxFocus(obj)
        end
        function obj = calcAmpHyFocus(obj)
        end
        function obj = calcAmpHzFocus(obj)
        end
        % <- stubs for calculation of amplitudes


% ============ in focus (or generally transverse plane) ============
        % calc intensity in focal point
        function obj = calcIntensityFocus(obj)
            if isempty(obj.intExFocus)
                obj = obj.calcIntExFocus();
            end
            if isempty(obj.intEyFocus)
                obj = obj.calcIntEyFocus();
            end
            if isempty(obj.intEzFocus)
                obj = obj.calcIntEzFocus();
            end
            obj.intensityFocus  = obj.intExFocus + obj.intEyFocus + obj.intEzFocus;
        end
        function obj = calcIntExFocus(obj)
            if isempty(obj.ampExFocus)
                obj = obj.calcAmpExFocus();
            end
            obj.intExFocus = obj.ampExFocus.*conj(obj.ampExFocus);
        end
        function obj = calcIntEyFocus(obj)
            if isempty(obj.ampEyFocus)
                obj = obj.calcAmpEyFocus();
            end
            obj.intEyFocus = obj.ampEyFocus.*conj(obj.ampEyFocus);
        end
        function obj = calcIntEzFocus(obj)
            if isempty(obj.ampEzFocus)
                obj = obj.calcAmpEzFocus();
            end
            obj.intEzFocus = obj.ampEzFocus.*conj(obj.ampEzFocus);
        end
        % <- calc intensity in focal point

        % calc intensity H in focal point
        function obj = calcIntensityHFocus(obj)
            if isempty(obj.intHxFocus)
                obj = obj.calcIntHxFocus();
            end
            if isempty(obj.intHyFocus)
                obj = obj.calcIntHyFocus();
            end
            if isempty(obj.intHzFocus)
                obj = obj.calcIntHzFocus();
            end            
            obj.intensityHFocus  = obj.intHxFocus + obj.intHyFocus + obj.intHzFocus;
        end
        function obj = calcIntHxFocus(obj)
            if isempty(obj.ampHxFocus)
                obj = obj.calcAmpHxFocus();
            end            
            obj.intHxFocus = obj.ampHxFocus.*conj(obj.ampHxFocus);
        end
        function obj = calcIntHyFocus(obj)
            if isempty(obj.ampHyFocus)
                obj = obj.calcAmpHyFocus();
            end
            obj.intHyFocus = obj.ampHyFocus.*conj(obj.ampHyFocus);
        end
        function obj = calcIntHzFocus(obj)
            if isempty(obj.ampHzFocus)
                obj = obj.calcAmpHzFocus();
            end   
            obj.intHzFocus = obj.ampHzFocus.*conj(obj.ampHzFocus);
        end
        % <- calc intensity H in focal point

        % calc Poynting components in focal point
        function obj = calcPoyntingFocus(obj)
            obj = obj.calcPoyntingXFocus();
            obj = obj.calcPoyntingYFocus();
            obj = obj.calcPoyntingZFocus();
        end
        function obj = calcPoyntingXFocus(obj)
            if isempty(obj.ampEyFocus)
                obj = obj.calcAmpEyFocus();
            end
            if isempty(obj.ampHzFocus)
                obj = obj.calcAmpHzFocus();
            end
            if isempty(obj.ampEzFocus)
                obj = obj.calcAmpEzFocus();
            end
            if isempty(obj.ampHyFocus)
                obj = obj.calcAmpHyFocus();
            end
            obj.pxFocus = real(obj.ampEyFocus.*conj(obj.ampHzFocus) - obj.ampEzFocus.*conj(obj.ampHyFocus));
        end
        function obj = calcPoyntingYFocus(obj)
            if isempty(obj.ampEzFocus)
                obj = obj.calcAmpEzFocus();
            end
            if isempty(obj.ampHxFocus)
                obj = obj.calcAmpHxFocus();
            end
            if isempty(obj.ampExFocus)
                obj = obj.calcAmpExFocus();
            end
            if isempty(obj.ampHzFocus)
                obj = obj.calcAmpHzFocus();
            end            
            obj.pyFocus = real(obj.ampEzFocus.*conj(obj.ampHxFocus) - obj.ampExFocus.*conj(obj.ampHzFocus));
        end
        function obj = calcPoyntingZFocus(obj)
            if isempty(obj.ampExFocus)
                obj = obj.calcAmpExFocus();
            end
            if isempty(obj.ampHyFocus)
                obj = obj.calcAmpHyFocus();
            end
            if isempty(obj.ampEyFocus)
                obj = obj.calcAmpEyFocus();
            end
            if isempty(obj.ampHxFocus)
                obj = obj.calcAmpHxFocus();
            end  
            obj.pzFocus = real(obj.ampExFocus.*conj(obj.ampHyFocus) - obj.ampEyFocus.*conj(obj.ampHxFocus));
        end
        % <- calc Poynting components in focal point

        % %%%%%%%%%%%%%%%%% plotters %%%%%%%%%%%%%%%%%
            % ============ in focus (or generally transverse plane) ============
                % intensity
        function obj = plotIntensityFocus(obj)
            if isempty(obj.intensityFocus)
                obj = obj.calcIntensityFocus();
            end
            figure;
            imagesc(obj.rCoord, obj.rCoord, obj.intensityFocus)
            obj.typicalFigMod2D(obj);
        end
        function obj = plotIxFocus(obj)
            if isempty(obj.intExFocus)
                obj = obj.calcIntExFocus();
            end
            figure;
            imagesc(obj.rCoord, obj.rCoord, obj.intExFocus)
            obj.typicalFigMod2D(obj);
        end
        function obj = plotIyFocus(obj)
            if isempty(obj.intEyFocus)
                obj = obj.calcIntEyFocus();
            end
            figure;
            imagesc(obj.rCoord, obj.rCoord, obj.intEyFocus)
            obj.typicalFigMod2D(obj);
        end
        function obj = plotIzFocus(obj)
            if isempty(obj.intEzFocus)
                obj = obj.calcIntEzFocus();
            end
            figure;
            imagesc(obj.rCoord, obj.rCoord, obj.intEzFocus)
            obj.typicalFigMod2D(obj);
        end
                % <- intensity

                % magnetic intensity
        function obj = plotIntensityHFocus(obj)
            if isempty(obj.intensityHFocus)
                obj = obj.calcIntensityHFocus();
            end
            figure;
            imagesc(obj.rCoord, obj.rCoord, obj.intensityHFocus)
            obj.typicalFigMod2D(obj);
        end
        function obj = plotIxHFocus(obj)
            if isempty(obj.intHxFocus)
                obj = obj.calcIntHxFocus();
            end
            figure;
            imagesc(obj.rCoord, obj.rCoord, obj.intHxFocus)
            obj.typicalFigMod2D(obj);
        end
        function obj = plotIyHFocus(obj)
            if isempty(obj.intHyFocus)
                obj = obj.calcIntHyFocus();
            end
            figure;
            imagesc(obj.rCoord, obj.rCoord, obj.intHyFocus)
            obj.typicalFigMod2D(obj);
        end
        function obj = plotIzHFocus(obj)
            if isempty(obj.intHzFocus)
                obj = obj.calcIntHzFocus();
            end
            figure;
            imagesc(obj.rCoord, obj.rCoord, obj.intHzFocus)
            obj.typicalFigMod2D(obj);
        end
                % <- magnetic intensity
        
                % Poynting
        function obj = plotPoyntingFocus(obj)
            obj = plotPoyntingXFocus(obj);
            obj = plotPoyntingYFocus(obj);
            obj = plotPoyntingZFocus(obj);
        end
        function obj = plotPoyntingXFocus(obj)
            if isempty(obj.pxFocus)
                obj = obj.calcPoyntingXFocus();
            end
            figure;
            imagesc(obj.rCoord, obj.rCoord, real(obj.pxFocus));
            obj.typicalFigMod2D(obj);
        end
        function obj = plotPoyntingYFocus(obj)
            if isempty(obj.pyFocus)
                obj = obj.calcPoyntingYFocus();
            end
            figure;
            imagesc(obj.rCoord, obj.rCoord, real(obj.pyFocus));
            obj.typicalFigMod2D(obj);
        end
        function obj = plotPoyntingZFocus(obj)
            if isempty(obj.pzFocus)
                obj = obj.calcPoyntingZFocus();
            end
            figure;
            imagesc(obj.rCoord, obj.rCoord, real(obj.pzFocus));
            obj.typicalFigMod2D(obj);
        end
                % <-  Poynting

        function L = source(obj, theta, phi)
            if strcmp(obj.mode, 'plane')
                L = 1;
            end
        end

        function T = apodization(obj, theta)
            if strcmp(obj.apodizationType, 'aplanatic')
                T = (cos(theta)).^(0.5);      % apodization function for aplanatic lens
            elseif  strcmp(obj.apodizationType, 'diffractive')
                T = (cos(theta)).^(-1.5);      % apodization function for flat difractive lens 
            end
        end

    end
end