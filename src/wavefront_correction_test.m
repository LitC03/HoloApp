% Trying wavefront correction with SLM onto MMFs
clear 

SLM_wavelength = string(532);
slm_dims = [1920, 1152];

square_dims= [1152,1152];

% phase_map = zeros(slm_dims);
square_phase = zeros(square_dims);

possible_modes = zeros(1,10);
neccesary_pixels = zeros(1,10);

factors=[1 factor(1152)];

for a=1:length(factors)
    possible_modes(a)=2^(2*(a-1));
    neccesary_pixels(a)=  1152/prod(factors(1:a),"all");
end

selection = 3;
num_modes= possible_modes(selection);
pixel_per_mode = neccesary_pixels(selection);
pixel_per_dim = 1152/pixel_per_mode;
figure(1);


for a=1:pixel_per_dim
    for b = 1:pixel_per_dim
        square_phase(pixel_per_mode*(a-1)+1:pixel_per_mode*a,pixel_per_mode*(b-1)+1:pixel_per_mode*b)=1;
        % Save image
        phase_map = padarray(square_phase,round([0 384]),0,'both');
        imagesc(phase_map);
        pbaspect([1920,1152,1])
        pause(0.5)
        % Reset phase
        square_phase(pixel_per_mode*(a-1)+1:pixel_per_mode*a,pixel_per_mode*(b-1)+1:pixel_per_mode*b)=0;
    end    

end

%% Connecting to SLM
bit_depth = 12; %bit depth = 8 for small 512, 12 for 1920
num_boards_found = libpointer('uint32Ptr', 0);
constructed_okay = libpointer('int32Ptr', 0);
is_nematic_type = 1;
RAM_write_enable = 1;
use_GPU = 0;
SLM_connected=false;
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
if constructed_okay ~= 1
    disp('SDK NOT constructed ok.')
end

disp(['Num boards: ', num2str(num_boards_found.val)])

if num_boards_found.val > 0
    SLM_connected = true;
    disp('Blink SDK was successfully constructed');
    SLMconnectedLamp.Color = [112, 209, 109]./255;
end

if num_boards_found.val > 0
    disp(['Found ',num2str(num_boards_found.val),' SLM controller(s)'])
    board_number =1;
    disp('Getting SLM information.')
    height = calllib('Blink_C_wrapper', 'Get_image_height', board_number);
    width = calllib('Blink_C_wrapper', 'Get_image_width', board_number);
    depth = calllib('Blink_C_wrapper', 'Get_image_depth', board_number); % = bits per pixel
    Bytes = depth/8;
    ImageOne = libpointer('uint8Ptr', zeros(width*height*Bytes,1)); 
    
    SLM_phase = phase.*255./(2*pi);

    %% Send info to SLM
    disp('Loading LUT.')
    if strcmp(SLM_wavelength,'532')
        calllib('Blink_C_wrapper', 'Load_LUT_file', board_number, 'C:\\Program Files\\Meadowlark Optics\\Blink OverDrive Plus\\LUT Files\\slm6661_at532_PCIe.LUT');
        WFC = double(imread('..\lib\slm6661_at532_WFC.bmp'));
    else
        calllib('Blink_C_wrapper', 'Load_LUT_file', board_number, 'C:\\Program Files\\Meadowlark Optics\\Blink OverDrive Plus\\LUT Files\\slm6661_at1064_PCIe.LUT');
        WFC = double(imread('..\lib\slm6661_at1064_WFC.bmp'));
    end
    ImageOne.value = uint8(mod(SLM_phase' + WFC',256));
    calllib('Blink_C_wrapper', 'Write_image', board_number, ImageOne, width*height*Bytes, wait_For_Trigger, flip_immediate, OutputPulseImageFlip, OutputPulseImageRefresh, timeout_ms);
    calllib('Blink_C_wrapper', 'ImageWriteComplete', board_number, timeout_ms);  
    disp('You should see something on your focal plane now :)')
else
    disp('Not connected to SLM!')
end

if SLM_connected
    calllib('Blink_C_wrapper', 'Delete_SDK');
    disp('Deleting SDK and closing app')
    if libisloaded('Blink_C_wrapper')
        unloadlibrary('Blink_C_wrapper');
    end
    
    if libisloaded('ImageGen')
        unloadlibrary('ImageGen');
    end
else
    disp('No SDK present.')
end