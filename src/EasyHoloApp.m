% Easy holoapp
clear
% close all

%% Get initial parameters
dims = [1152,1920]; % SLM dimensions
beam_diam = 11.5e-3; % Beam diameter
slmPix = 9.2e-6; % SLM pitch
n_iter = 10; % No of iterations for GS routine
out_name = 'phase';

% Target image
% img=imread('..\img\tgt\SLMtarget_ICL5.png');
% img=imread('..\img\tgt\SLMtarget_num4.png');
img=imread('..\img\tgt\SLMtarget_circ_parts4.png');
img=mean(img,3);
colormap gray

%% Build illumination map: get the illumination on the SLM
slm_beam_rad = round(beam_diam/(2*slmPix)); 
[slmX, slmY] = meshgrid(-round(dims(2)/2):round(dims(2)/2)-1, ...
               -round(dims(1)/2):round(dims(1)/2)-1); 
slmR = sqrt(slmX.^2 + slmY.^2);
beamGauss = exp(-2*slmR.^2/slm_beam_rad^2); % formula from https://www.edmundoptics.co.uk/knowledge-center/application-notes/lasers/gaussian-beam-propagation/

%% Resize target image if necessary
dim_img = size(img);

if ~all(dim_img>dims)
    log_arr = dim_img<=dims;

    if log_arr(1)
        padY = dims(1)-dim_img(1);
    else
        disp('Image will be cut in y axis');
    end

    if log_arr(2)
        padX = dims(2)-dim_img(2);
    else
        disp('Image will be cut in x axis');
    end
end

tgt = padarray(img,round([padY padX]./2),0,'both');
tgt = resize(tgt,dims);

%% Use illumination map to emply the GS routine
[phase] = GS_routine(tgt,beamGauss,n_iter);

figure(1)
imagesc(abs(fft2(beamGauss.*exp(1i.*phase))));
figure(2)
h=imagesc(phase);
%% Save SLM phase map on machine
imwrite(phase,['..\img\out\',out_name,'.bmp'])
%% Connect with SLM and use the phase map wanted

bit_depth = 12; %bit depth = 8 for small 512, 12 for 1920
num_boards_found = libpointer('uint32Ptr', 0);
constructed_okay = libpointer('int32Ptr', 0);
is_nematic_type = 1;
RAM_write_enable = 1;
use_GPU = 0;
max_transients = 10;
wait_For_Trigger = 0; % This feature is user-settable; use 1 for 'on' or 0 for 'off'
flip_immediate = 0; % Only supported on the 1024
timeout_ms = 5000;
SDK = struct();

OutputPulseImageFlip = 0;
OutputPulseImageRefresh = 0;
reg_lut = libpointer('string');


if ~libisloaded('Blink_C_wrapper')
   loadlibrary('../lib/Blink_C_wrapper.dll', '../lib/Blink_C_wrapper.h');
end
if ~libisloaded('ImageGen')
    loadlibrary('../lib/ImageGen.dll', '../lib/ImageGen.h');
end
disp('Libraries loaded.')
disp('Trying to connect')

disp('Trying to create SDK.')
calllib('Blink_C_wrapper', 'Create_SDK', bit_depth, num_boards_found, constructed_okay, is_nematic_type, RAM_write_enable, use_GPU, max_transients, reg_lut); 
if app.constructed_okay ~= 1
    disp('SDK not constructed ok.')
    errMsg = calllib('Blink_C_wrapper', 'Get_last_error_message');
    disp(errMsg)
end

sprintf('Num boards: %i', num_boards_found)

if num_boards_found >= 0
    disp('Blink SDK was successfully constructed');
    % app.SLMConnectedLamp.Color = [0, 1, 0];
    board_number = 1;
    
    fprintf('Found %u SLM controller(s)\n', num_boards_found);
    
    disp('Getting SLM information.')
    height = calllib('Blink_C_wrapper', 'Get_image_height', board_number);
    width = calllib('Blink_C_wrapper', 'Get_image_width', board_number);
    depth = calllib('Blink_C_wrapper', 'Get_image_depth', board_number); %bits per pixel
    Bytes = depth/8;
    sprintf('The image height is %d bits.', height)
    sprintf('The image width is %d bits.', width)
    sprintf('The image depth is %d bits.', depth)
    sprintf('A pixel is %d bytes', Bytes)
    
    % SDK.init = 1;
    % SDK.board_number = 1;
    % SDK.height = height;
    % SDK.width = width;
    % SDK.depth = depth;
    % SDK.bytes = Bytes;
    % SDK.wait_For_Trigger = wait_For_Trigger;
    % SDK.flip_immediate = flip_immediate;
    % SDK.OutputPulseImageFlip = OutputPulseImageFlip;
    % SDK.OutputPulseImageRefresh = OutputPulseImageRefresh;
    % SDK.timeout_ms = timeout_ms;
    
    %allocate arrays for our images
    ImageOne = libpointer('uint8Ptr', zeros(width*height*Bytes,1));
    ImageTwo = libpointer('uint8Ptr', zeros(width*height*Bytes,1));
    WFC = libpointer('uint8Ptr', zeros(width*height*Bytes,1));
    disp('Loading LUT.')
    calllib('Blink_C_wrapper', 'Load_LUT_file', board_number, 'C:\\Program Files\\Meadowlark Optics\\Blink OverDrive Plus\\LUT Files\\slm6254_at1064_PCIe.LUT');
    disp('Writing blank image.')
    calllib('Blink_C_wrapper', 'Write_image', board_number, ImageOne, width*height*Bytes, wait_For_Trigger, flip_immediate, OutputPulseImageFlip, OutputPulseImageRefresh, timeout_ms);
    calllib('Blink_C_wrapper', 'ImageWriteComplete', board_number, timeout_ms);  
end