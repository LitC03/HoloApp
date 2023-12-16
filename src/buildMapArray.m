% Builds mapping arrays for holoApp

function [SLM, totInten, totPhase, fftArr, sceneGeom, beamShift, beamGauss] = ...
    buildMapArray(config)

% Make geometry grids and resize them to consistent dimensions
[X,Y] = meshgrid(-config.mapRad: config.mapRad);
X = imresize(X, [config.mapDim(1) config.mapDim(2)]);
Y = imresize(Y, [config.mapDim(1) config.mapDim(2)]);
ap = X*0.0;
rad = sqrt(X.^2+Y.^2);
ap(rad < config.apRad) = 1;

% Build the SLM arrays and calculate beam shifts
[slmX, slmY] = meshgrid(-round(config.slmDim(2)/2):round(config.slmDim(2)/2)-1, ...
               -round(config.slmDim(1)/2):round(config.slmDim(1)/2)-1); 
slmR = sqrt(slmX.^2 + slmY.^2);
SLM = genSLMzones(config.slmDim, config.nCol, config.nRow);
beamShift = [[vertcat(SLM.zones.centX)]'-round(config.slmDim(2)/2); ...
            [vertcat(SLM.zones.centY)]'-round(config.slmDim(1)/2)];
slmAp = ones(config.slmDim(1), config.slmDim(2));
slmInten = slmAp;
slmPhase = slmAp*0+1;
slmPad = padarray(slmAp, [config.apPaddingY config.apPaddingX], 0, 'both');
slmPad = imresize(slmPad, [config.mapDim(1) config.mapDim(2)]);

% Build array for displaying the SLM and beam geometry
sceneGeom = slmPad + ap;

% Create a Gaussian beam to place on the SLM display for visualization 
gaussSigma = config.gaussSigma;
beamGauss = exp(-slmR.^2/gaussSigma^2);
slmInten = slmInten .* beamGauss;

% Make intensity and phase arrays and resize them for consistency 
intenArr = padarray(slmInten, [config.apPaddingY config.apPaddingX], 0, 'both');
phArr = padarray(slmPhase, [config.apPaddingY config.apPaddingX], 0, 'both');
intenArr= imresize(intenArr, [config.mapDim(1) config.mapDim(2)]);
phArr = imresize(phArr, [config.mapDim(1) config.mapDim(2)]);
totInten = intenArr * 0.0;
totPhase = phArr * 0.0;
fftArr = intenArr.*exp(1i*phArr);
