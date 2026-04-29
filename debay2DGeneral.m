classdef debay2DGeneral < RichWolf
    %DEBAY Summary of this class goes here
    %   Detailed explanation goes here
    % continuos polarization and SPP
    
    properties

    end

    methods(Static)
        
        function m = mMatrixEx(theta, phi, a, b)
            p11 = 1 + cos(phi).*cos(phi) .* (cos(theta) - 1);
            p12 = sin(phi) .* cos(phi) .* (cos(theta)-1);
            m = p11 .* a + p12 .* b;
        end
        function m = mMatrixEy(theta, phi, a, b)
            p21 = sin(phi) .* cos(phi) .* (cos(theta)-1);
            p22 = 1 + sin(phi).*sin(phi) .* (cos(theta)-1);
            m = p21 .* a + p22 .* b;
        end
        function m = mMatrixEz(theta, phi, a, b)
            p31 = -1 * sin(theta) .* cos(phi);
            p32 = -1 * sin(theta) .* sin(phi);
            m = p31 .* a + p32 .* b;
        end
        
        function m = mMatrixHx(theta, phi, a, b)
            p11 = 1 + cos(phi).*cos(phi) .* (cos(theta) - 1);
            p12 = sin(phi) .* cos(phi) .* (cos(theta)-1);
            m = p11 .* a + p12 .* b;
        end
        function m = mMatrixHy(theta, phi, a, b)
            p21 = sin(phi) .* cos(phi) .* (cos(theta)-1);
            p22 = 1 + sin(phi).*sin(phi) .* (cos(theta)-1);
            m = p21 .* a + p22 .* b;
        end
        function m = mMatrixHz(theta, phi, a, b)
            p31 = -1 * sin(theta) .* cos(phi);
            p32 = -1 * sin(theta) .* sin(phi);
            m = p31 .* a + p32 .* b;
        end
    end
    
    methods
        % Ex calc
        function Ex = underintEx(obj, theta, r, z, psi, phi, a, b)
            Ex = underinteq(obj, theta, phi, z, r, psi);
            Ex = Ex .* obj.mMatrixEx(theta, phi, a, b);    % expression under integral
            Ex = -1i * Ex;      % not correct factor => should be -1i * focalLength / lambda
        end
        % <- Ex calc
        
        % Ey calc
        function Ey = underintEy(obj, theta, r, z, psi, phi, a, b)
            Ey = underinteq(obj, theta, phi, z, r, psi);
            Ey = Ey .* obj.mMatrixEy(theta, phi, a, b);    % expression under integral
            Ey = -1i * Ey;
        end
        % <- Ey calc
        
        % Ez calc
        function Ez = underintEz(obj, theta, r, z, psi, phi, a, b)
            Ez = underinteq(obj, theta, phi, z, r, psi);
            Ez = Ez .* obj.mMatrixEz(theta, phi, a, b);    % expression under integral
            Ez = -1i * Ez;
        end        
        % <- Ez calc
        
        % Hx calc
        function Hx = underintHx(obj, theta, r, z, psi, phi, a, b)
            Hx = underinteq(obj, theta, phi, z, r, psi);
            Hx = Hx .* obj.mMatrixHx(theta, phi, a, b);    % expression under integral
            Hx = -1i * Hx;      % not correct factor => should be -1i * focalLength / lambda / impedansFreeSpace
        end
        % <- Hx calc
        
        % Hy calc
        function Hy = underintHy(obj, theta, r, z, psi, phi, a, b)
            Hy = underinteq(obj, theta, phi, z, r, psi);
            Hy = Hy .* obj.mMatrixHy(theta, phi, a, b);    % expression under integral
            Hy = -1i * Hy;
        end
        % <- Hy calc        
        
        % Hz calc
        function Hz = underintHz(obj, theta, r, z, psi, phi, a, b)
            Hz = underinteq(obj, theta, phi, z, r, psi);
            Hz = Hz .* obj.mMatrixHz(theta, phi, a, b);    % expression under integral
            Hz = -1i * Hz;
        end        
        % <- Hz calc      

        function undeq = underinteq(obj, theta, phi, z, r, psi)     % the equal part under the RW-integral for different components
            T = obj.apodization(theta);
            L = obj.source(theta, phi);
            L = L .* exp(1i*phi*obj.mVortex);   % use in the case of SPP (it is an additional SPP, not connected with LG-mode)
            undeq = sin(theta) .* exp(1i*obj.kWave*ones(size(theta)) .* (z*cos(theta) + r * sin(theta) .* cos(phi-psi)) ) .* T .* L; % uniform source
        end
    end
end


