% Sets parameters and generates arrays for holoApp
function config = setParams(config, nCol, nRow, focal_mm, beamDiam, gaussSigma)

% Setup some geometry
beamDiam = beamDiam * 1e-3;
slmDim = [1152 1920]; % No of pixels in SLM
camDim = [2054 2456]; % No of pixels in Camera. Q: What camera??
camPix = 3.45e-6; % Distance between centres of camera pixels (pitch)
slmPix = 9.2e-6; % Distance between centres of SLM pixels 
lambda = 1.064e-6; % Wavelength of light
slmDiam = slmDim(1) * slmPix; % maximum diameter of beam for the SLM
focal = focal_mm *1e-3; % Focal length

% Calculate Airy disk size and corresponding FFT array sizes
% airy = 1.22*(lambda*focal)/beamDiam;
% airyPix = airy/camPix;
wavesPerPix = slmPix/lambda;

% Q: What does this mean, physically??
mapDiam = 1/(camPix/focal)/wavesPerPix; % = focal/(camPix*wavesPerPix) = fλ/(camPix*slmPix)

mapDim = round([mapDiam mapDiam]);

% Q: What is this?
apRad = round(slmDim(1)*beamDiam/slmDiam/2);


mapRad = round(mapDiam/2); %Map radius
apPaddingY = ceil(mapRad-slmDim(1)/2); % size difference between slm and the map
apPaddingX = ceil(mapRad-slmDim(2)/2);
if apPaddingX < 0
    apPaddingX = 0;
end
if apPaddingY < 0
    apPaddingY = 0;
end

% Set some configuration parameters
config.nCol = nCol;
config.nRow = nRow;
config.focal_mm = focal_mm;
config.beamDiam = beamDiam;
config.gaussSigma = gaussSigma;
config.slmDim = slmDim;
config.camDim = camDim;
config.camPix = camPix;
config.slmPix = slmPix;
config.mapDim = mapDim;
config.mapDiam = mapDiam;
config.mapRad = mapRad;
config.apRad = apRad;
config.apPaddingX = apPaddingX;
config.apPaddingY = apPaddingY;

