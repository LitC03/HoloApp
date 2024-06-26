% Testing SLM resolution
% clear
close all

%% Initialise variables
SLM_dims = [1152 1920];
pixel_magn = [2 2]; % pixel magnification
pitch = 9.2e-6;
pitch_magn = 0.5; % pitch magnification
beam_diam = 20e-3;
reps = 50;

% %% Set matrices
% normal_SLM_surf = zeros(SLM_dims);
% pix_augm_surf = zeros(SLM_dims.*pixel_magn);
% pitch_augm_surf = zeros(SLM_dims);

%% Get irradiation patterns
f = figure(1);
f.Position = [1932.333333333333,-244.3333333333333,497.3333333333333,177.3333333333333];

%Normal SLM
slm_beam_rad = round(beam_diam/(2*pitch)); 
[slmX, slmY] = meshgrid(-round(SLM_dims(2)/2):round(SLM_dims(2)/2)-1,-round(SLM_dims(1)/2):round(SLM_dims(1)/2)-1); 
slmR = sqrt(slmX.^2 + slmY.^2);
beam_gauss_normal = exp(-2*slmR.^2/slm_beam_rad^2);

subplot(1,3,1)
imshow(beam_gauss_normal)

% pixel augmented
slm_beam_rad = round(beam_diam/(2*pitch)); 
[slmX, slmY] = meshgrid(-(round(SLM_dims(2)/2)*pixel_magn(1)):(round(SLM_dims(2)/2)*pixel_magn(1))-1, ...
    -(round(SLM_dims(1)/2)*pixel_magn(2)):(round(SLM_dims(1)/2)*pixel_magn(2))-1); 
slmR = sqrt(slmX.^2 + slmY.^2);
beam_gauss_pix_augm = exp(-2*slmR.^2/slm_beam_rad^2);

subplot(1,3,2)
imshow(beam_gauss_pix_augm)


% pitch reduction
slm_beam_rad = round(beam_diam/(2*pitch*pitch_magn)); 
[slmX, slmY] = meshgrid(-(round(SLM_dims(2)/2)/pitch_magn):(round(SLM_dims(2)/2)/pitch_magn)-1, ...
    -(round(SLM_dims(1)/2)/pitch_magn):(round(SLM_dims(1)/2)/pitch_magn)-1); 
slmR = sqrt(slmX.^2 + slmY.^2);
beam_gauss_pitch_augm = exp(-2*slmR.^2/slm_beam_rad^2);

subplot(1,3,3)
imshow(beam_gauss_pitch_augm)

%% Set target
% target_normal = double(imread('..\img\tgt\circ_0144_scaling_75hor_offset.bmp'));
% target_normal = double(imread('..\img\tgt\SLMtarget_ICL5_scaled_2.bmp'));
target_normal = double(imread('..\img\tgt\circ_0144_scaling_75hor_offset_rect.bmp'));
target_pix_aug = padarray(target_normal,round((size(beam_gauss_pix_augm)-size(target_normal))./2),0,'both');
target_pitch_aug = imresize(target_normal,SLM_dims/pitch_magn);

%% Do the Gerchbert-Saxton routine
phase_normal = GS_routine(target_normal,beam_gauss_normal,reps);
phase_pix_aug = GS_routine(target_pix_aug,beam_gauss_pix_augm,reps);
phase_pitch_aug = GS_routine(target_pitch_aug,beam_gauss_pitch_augm,reps);

%% Output estimate
f=figure(2);
f.Position = [2417,-9,1302,278];

est_normal = log(abs(fft2(beam_gauss_normal.*exp(1i.*phase_normal))));
est_pix = log(abs(fft2(beam_gauss_pix_augm.*exp(1i.*phase_pix_aug))));
est_pitch = log(abs(fft2(beam_gauss_pitch_augm.*exp(1i.*phase_pitch_aug))));

% est_normal = abs(fft2(beam_gauss_normal.*exp(1i.*phase_normal)));
% est_pix = abs(fft2(beam_gauss_pix_augm.*exp(1i.*phase_pix_aug)));
% est_pitch = abs(fft2(beam_gauss_pitch_augm.*exp(1i.*phase_pitch_aug)));

% est_normal = real(fft2(beam_gauss_normal.*exp(1i.*phase_normal)));
% est_pix = real(fft2(beam_gauss_pix_augm.*exp(1i.*phase_pix_aug)));
% est_pitch = real(fft2(beam_gauss_pitch_augm.*exp(1i.*phase_pitch_aug)));

subplot(1,3,1)
imagesc(est_normal)
colormap(gray)
clim([-10 15])
% clim([0 18e4])

% imshow(est_normal)
title('Normal')

subplot(1,3,2)
imagesc(est_pix)
xlim([480 1440]*pixel_magn(1))
ylim([288 864]*pixel_magn(2))
clim([-10 15])
% clim([0 18e4])
% imshow(est_pix)
title('Pixel augmentation')

subplot(1,3,3)
imagesc(est_pitch)
clim([-10 15])
% imshow(est_pitch)
% clim([0 18e4])
title('Pitch reduction')