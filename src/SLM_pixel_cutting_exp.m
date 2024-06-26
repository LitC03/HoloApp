% Testing using smaller spatial frequencies
clear 
close all


large_target = double(imread('..\img\tgt\circ_01442_scaling_centered_75_hor_separation.bmp'));
dims = size(large_target);
pitch = 9.2e-6;
beam_diam = 20e-3;
GS_reps = 30;

step = 50;
reps = 10;

for a=step:step:step*reps
    win = centerCropWindow2d(dims,dims - a);
    cropped_image = imcrop(large_target,win);
    dims_img = size(cropped_image);

    slm_beam_rad = round(beam_diam/(2*pitch)); 
    [slmX, slmY] = meshgrid(-round(dims_img(2)/2):round(dims_img(2)/2)-1,-round(dims_img(1)/2):round(dims_img(1)/2)-1); 
    slmR = sqrt(slmX.^2 + slmY.^2);
    beam_gauss = exp(-2*slmR.^2/slm_beam_rad^2);
    % imagesc(beam_gauss)
    % clim([0 1])

    small_phase = GS_routine(cropped_image,beam_gauss,GS_reps);

    wrapped_phase = wrapTo2Pi(small_phase);

    padded_phase = padarray(wrapped_phase,[a a]./2,0,'both');
    slm_phase = pad_to_SLM(padded_phase,[1152 1920]);

    slm_phase = slm_phase.*255./(2*pi);

    uint8_phase = uint8(slm_phase);

    % imwrite(uint8_phase,['..\img\out\2_circles_75_hor_separation_cut_',num2str(a),'.bmp'])

    % imagesc(slm_phase)
end