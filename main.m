%% high-order (2) azimuthal polarization

clear all
clear classes
% close all
clc

lambda = 0.633;
NA = 0.95;

rMin = -1.0;        % размеры области, при необходимости надо увеличить
rMax = 1.0;
discretization = 100;

%%%%%%%%%%%%%%%%%%%%%% Варьируемые параметры

mVort = 5;    % ТЗ вихря, проверьте следующие значения: -5, 5 и 3 
delta = pi/8; % ширина препятствия, проверьте два значения pi/8 и pi/16

%%%%%%%%%%%%%%%%%%%%%% <- Варьируемые параметры

r2 = circularPar(lambda, NA, 'right'); % объект r2 будет отвечать за искаженный вихрь
r2.mVortex = mVort;
r2.alphaMax = 2*pi - delta/2;  % искажение вносится путем уменьшения максимального угла интегрирования (т.е. эмуляция секторной диафрагмы)
r2.alphaMin = delta/2;  % для симметрии  
r2 = r2.setRBorders(rMin, rMax, discretization);
r2 = r2.plotIntensityFocus();