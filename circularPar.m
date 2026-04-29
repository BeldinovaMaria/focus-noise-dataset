classdef circularPar < debay2DGeneral
    %ABGMODE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        mVortex = 0;    % without vortex by default
        aCircE = 1;
        bCircE = 1i;
        aCircH = -1i;
        bCircH = 1;
    end
    
    methods
        % constructor
        function obj = circularPar(lambda, NA, varargin)
            obj.lambda = lambda;
            obj.kWave = 2*pi/lambda;
            obj.NA = NA;
            obj.thetaMax = asin(NA/obj.refrMedia);
            for ii = 1:nargin-2
                if strcmp(varargin(ii), 'linear x')
                    obj.aCircE = 1;
                    obj.bCircE = 0;
                    obj.aCircH = 0;
                    obj.bCircH = 1;
                end
                if strcmp(varargin(ii), 'linear y')
                    obj.aCircE = 0;
                    obj.bCircE = 1;
                    obj.aCircH = -1;
                    obj.bCircH = 0;
                end
                if strcmp(varargin(ii), 'right')
                    obj.aCircE = 1;
                    obj.bCircE = 1i;
                    obj.aCircH = -1i;
                    obj.bCircH = 1;
                end
                if strcmp(varargin(ii), 'left')
                    obj.aCircE = 1;
                    obj.bCircE = -1i;
                    obj.aCircH = 1i;
                    obj.bCircH = 1;
                end        
            end
        end
        % <- constructor

        % calc amplitude E in focal point
        function obj = calcAmpExFocus(obj)
            ampEx = zeros(obj.rNum, obj.rNum);
            rNum = obj.rNum;
            parfor k = 1:rNum
                for kk = 1:rNum
                    [r, psi] = obj.calcrpsi(obj.rCoord(kk), obj.rCoord(k));
                    ampEx(k,kk) = ampEx(k,kk) + integral2(@(theta, phi)underintEx(obj, theta, r, obj.zCross, psi, phi, obj.aCircE, obj.bCircE), obj.thetaMin, obj.thetaMax, obj.alphaMin, obj.alphaMax);
                end
            end
            obj.ampExFocus = ampEx;
        end
        function obj = calcAmpEyFocus(obj)
            ampEy = zeros(obj.rNum, obj.rNum);
            rNum = obj.rNum;
            parfor k = 1:rNum
                for kk = 1:rNum
                    [r, psi] = obj.calcrpsi(obj.rCoord(kk), obj.rCoord(k));
                    ampEy(k,kk) = ampEy(k,kk) + integral2(@(theta, phi)underintEy(obj, theta, r, obj.zCross, psi, phi, obj.aCircE, obj.bCircE), obj.thetaMin, obj.thetaMax, obj.alphaMin, obj.alphaMax);
                end
            end
            obj.ampEyFocus = ampEy;
        end
        function obj = calcAmpEzFocus(obj)
            ampEz = zeros(obj.rNum, obj.rNum);
            rNum = obj.rNum;
            parfor k = 1:rNum
                for kk = 1:rNum
                    [r, psi] = obj.calcrpsi(obj.rCoord(kk), obj.rCoord(k));
                    ampEz(k,kk) = ampEz(k,kk) + integral2(@(theta, phi)underintEz(obj, theta, r, obj.zCross, psi, phi, obj.aCircE, obj.bCircE), obj.thetaMin, obj.thetaMax, obj.alphaMin, obj.alphaMax);
                end
            end
            obj.ampEzFocus = ampEz;
        end           
        % <- calc amplitude E in focal point        
        
        % calc H in focal spot
        function obj = calcAmpHxFocus(obj)
            ampHx = zeros(obj.rNum, obj.rNum);
            rNum = obj.rNum;
            parfor k = 1:rNum
                for kk = 1:rNum
                    [r, psi] = obj.calcrpsi(obj.rCoord(kk), obj.rCoord(k));
                    ampHx(k,kk) = ampHx(k,kk) + integral2(@(theta, phi)underintHx(obj, theta, r, obj.zCross, psi, phi, obj.aCircH, obj.bCircH), obj.thetaMin, obj.thetaMax, obj.alphaMin, obj.alphaMax);
                end
            end
            obj.ampHxFocus = ampHx;
        end
        function obj = calcAmpHyFocus(obj)
            ampHy = zeros(obj.rNum, obj.rNum);
            rNum = obj.rNum;
            parfor k = 1:rNum
                for kk = 1:rNum
                    [r, psi] = obj.calcrpsi(obj.rCoord(kk), obj.rCoord(k));
                    ampHy(k,kk) = ampHy(k,kk) + integral2(@(theta, phi)underintHy(obj, theta, r, obj.zCross, psi, phi, obj.aCircH, obj.bCircH), obj.thetaMin, obj.thetaMax, obj.alphaMin, obj.alphaMax);
                end
            end
            obj.ampHyFocus = ampHy;
        end
        function obj = calcAmpHzFocus(obj)
            ampHz = zeros(obj.rNum, obj.rNum);
            rNum = obj.rNum;
            parfor k = 1:rNum
                for kk = 1:rNum
                    [r, psi] = obj.calcrpsi(obj.rCoord(kk), obj.rCoord(k));
                    ampHz(k,kk) = ampHz(k,kk) + integral2(@(theta, phi)underintHz(obj, theta, r, obj.zCross, psi, phi, obj.aCircH, obj.bCircH), obj.thetaMin, obj.thetaMax, obj.alphaMin, obj.alphaMax);
                end
            end
            obj.ampHzFocus = ampHz;
        end                   
        % <- calc H in focal spot



        
 %%%%%%%%%%%%%%%%%%%%%%%%% sections along x-axis
        % calc amplitude E along x-axis
        function obj = calcAmpExSecX(obj)
%             disp('point 4');
            ampEx = zeros(1, obj.rNum);
            for kk = 1:obj.rNum
                [r, psi] = obj.calcrpsi(obj.rCoord(kk), eps);       % костыль - надо бы ноль вместо eps
                ampEx(1,kk) = ampEx(1,kk) + integral2(@(theta, phi)underintEx(obj, theta, r, obj.zCross, psi, phi, obj.aCircE, obj.bCircE), 0, obj.thetaMax, 0, obj.alphaMax);
%                 disp(kk);
%                 disp(r);
            end
            obj.ampExSecX = ampEx;
        end
        function obj = calcAmpEySecX(obj)
            ampEy = zeros(1, obj.rNum);
            for kk = 1:obj.rNum
                [r, psi] = obj.calcrpsi(obj.rCoord(kk), eps);
                ampEy(1,kk) = ampEy(1,kk) + integral2(@(theta, phi)underintEy(obj, theta, r, obj.zCross, psi, phi, obj.aCircE, obj.bCircE), 0, obj.thetaMax, 0, obj.alphaMax);
            end
            obj.ampEySecX = ampEy;
        end
        function obj = calcAmpEzSecX(obj)
            ampEz = zeros(1, obj.rNum);
            for kk = 1:obj.rNum
                [r, psi] = obj.calcrpsi(obj.rCoord(kk), eps);
                ampEz(1,kk) = ampEz(1,kk) + integral2(@(theta, phi)underintEz(obj, theta, r, obj.zCross, psi, phi, obj.aCircE, obj.bCircE), 0, obj.thetaMax, 0, obj.alphaMax);
            end
            obj.ampEzSecX = ampEz;
        end           
        % <- calc amplitude E along x-axis     
        
        % calc H along x-axis
        function obj = calcAmpHxSecX(obj)
            ampHx = zeros(1, obj.rNum);
            for kk = 1:obj.rNum
                [r, psi] = obj.calcrpsi(obj.rCoord(kk), eps);
                ampHx(1,kk) = ampHx(1,kk) + integral2(@(theta, phi)underintHx(obj, theta, r, obj.zCross, psi, phi, obj.aCircH, obj.bCircH), 0, obj.thetaMax, 0, obj.alphaMax);
            end
            obj.ampHxSecX = ampHx;
        end
        function obj = calcAmpHySecX(obj)
            ampHy = zeros(1, obj.rNum);
            for kk = 1:obj.rNum
                [r, psi] = obj.calcrpsi(obj.rCoord(kk), eps);
                ampHy(1,kk) = ampHy(1,kk) + integral2(@(theta, phi)underintHy(obj, theta, r, obj.zCross, psi, phi, obj.aCircH, obj.bCircH), 0, obj.thetaMax, 0, obj.alphaMax);
            end
            obj.ampHySecX = ampHy;
        end
        function obj = calcAmpHzSecX(obj)
            ampHz = zeros(1, obj.rNum);
            for kk = 1:obj.rNum
                [r, psi] = obj.calcrpsi(obj.rCoord(kk), eps);
                ampHz(1,kk) = ampHz(1,kk) + integral2(@(theta, phi)underintHz(obj, theta, r, obj.zCross, psi, phi, obj.aCircH, obj.bCircH), 0, obj.thetaMax, 0, obj.alphaMax);
            end
            obj.ampHzSecX = ampHz;
        end
        % <- calc H along x-axis
        %%%%%%%%%%%%%%%%%%%%%%%%% <- sections along x-axis


        % calc amplitude E in YZ plane
        function obj = calcAmpExYZ(obj)
            ampEx = zeros(obj.rNum, obj.zNum);
            for k = 1:obj.rNum
                for kk = 1:obj.zNum
                    [r, psi] = obj.calcrpsi(0, obj.rCoord(k));
                    ampEx(k,kk) = ampEx(k,kk) + integral2(@(theta, phi)underintEx(obj, theta, r, obj.zCoord(kk), psi, phi, obj.aCircE, obj.bCircE), obj.thetaMin, obj.thetaMax, obj.alphaMin, obj.alphaMax);
                end
            end
            obj.ampExYZ = ampEx;
        end
        function obj = calcAmpEyYZ(obj)
            ampEy = zeros(obj.rNum, obj.zNum);
            for k = 1:obj.rNum
                for kk = 1:obj.zNum
                    [r, psi] = obj.calcrpsi(0, obj.rCoord(k));
                    ampEy(k,kk) = ampEy(k,kk) + integral2(@(theta, phi)underintEy(obj, theta, r, obj.zCoord(kk), psi, phi, obj.aCircE, obj.bCircE), obj.thetaMin, obj.thetaMax, obj.alphaMin, obj.alphaMax);
                end
            end
            obj.ampEyYZ = ampEy;
        end
        function obj = calcAmpEzYZ(obj)
            ampEz = zeros(obj.rNum, obj.zNum);
            for k = 1:obj.rNum
                for kk = 1:obj.zNum
                    [r, psi] = obj.calcrpsi(0, obj.rCoord(k));
                    ampEz(k,kk) = ampEz(k,kk) + integral2(@(theta, phi)underintEz(obj, theta, r, obj.zCoord(kk), psi, phi, obj.aCircE, obj.bCircE), obj.thetaMin, obj.thetaMax, obj.alphaMin, obj.alphaMax);
                end
            end
            obj.ampEzYZ = ampEz;
        end           
        % <- calc amplitude E in YZ plane
        
        % calc H in YZ plane
        function obj = calcAmpHxYZ(obj)
            ampHx = zeros(obj.rNum, obj.zNum);
            for k = 1:obj.rNum
                for kk = 1:obj.zNum
                    [r, psi] = obj.calcrpsi(0, obj.rCoord(k));
                    ampHx(k,kk) = ampHx(k,kk) + integral2(@(theta, phi)underintHx(obj, theta, r, obj.zCoord(kk), psi, phi, obj.aCircH, obj.bCircH), obj.thetaMin, obj.thetaMax, obj.alphaMin, obj.alphaMax);
                end
            end
            obj.ampHxYZ = ampHx;
        end
        function obj = calcAmpHyYZ(obj)
            ampHy = zeros(obj.rNum, obj.zNum);
            for k = 1:obj.rNum
                for kk = 1:obj.zNum
                    [r, psi] = obj.calcrpsi(0, obj.rCoord(k));
                    ampHy(k,kk) = ampHy(k,kk) + integral2(@(theta, phi)underintHy(obj, theta, r, obj.zCoord(kk), psi, phi, obj.aCircH, obj.bCircH), obj.thetaMin, obj.thetaMax, obj.alphaMin, obj.alphaMax);
                end
            end
            obj.ampHyYZ = ampHy;
        end
        function obj = calcAmpHzYZ(obj)
            ampHz = zeros(obj.rNum, obj.zNum);
            for k = 1:obj.rNum
                for kk = 1:obj.zNum
                    [r, psi] = obj.calcrpsi(0, obj.rCoord(k));
                    ampHz(k,kk) = ampHz(k,kk) + integral2(@(theta, phi)underintHz(obj, theta, r, obj.zCoord(kk), psi, phi, obj.aCircH, obj.bCircH), obj.thetaMin, obj.thetaMax, obj.alphaMin, obj.alphaMax);
                end
            end
            obj.ampHzYZ = ampHz;
        end                   
        % <- calc H in YZ plane


        
    end
end

