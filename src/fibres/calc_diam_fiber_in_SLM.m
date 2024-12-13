clear
close all
% ffmpeg -i limit_v150_h130.avi -c:v mpeg4 -q:v 2 limit_v150_h130.avi 
% Determine coordinates

step = [10,10];          % [v, h] steps
v_lims = [150,380];
h_lims = [130,380];
v = v_lims(1):step(1):v_lims(2);
h = h_lims(1):step(2):h_lims(2);

% Directory with files:
vid_dir = "C:\Users\lito\OneDrive - Imperial College London\Documents 1\Yo\Education\PhD\HoloApp\img\vids\new\mp4 files\";

% create grid with those coordinates
[x,y] = meshgrid(h,v);
% Get the names of the videos:
for a=150
    for b=130
        % Load a video
        name_video = strcat("limit_v",num2str(a),"_h",num2str(b),".mp4");
        vidObj = VideoReader(strcat(vid_dir,'',name_video));
        % Create 3D matrix with all frames
        allFrames = double(read(vidObj,[1 100]));
        
        % Average every frame
        grey=squeeze(mean(allFrames,3));

       disp(size(grey))

        clear vidObj
    end
end



% Choose the frame that has the highest mean value
% Alocate that pixel to the corresponding coordinate
% plot the resulting image
