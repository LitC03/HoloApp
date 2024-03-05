% Create a point and move it around
close all
clear

%% Diameter of point and init. location
% min_diam = 9.2e-6; % equivalent to pitch of SLM
pitch = 9.2e-6;
diam = 0.1e-3; % Diameter of desired point
offset = [100,+100]; % +: right and down, -: left and up
dims = [1152,1920];
centre = [961,577];


%% Canvas
% [slmX, slmY] = meshgrid(-round(dims(2)/2):round(dims(2)/2)-1, ...
%                -round(dims(1)/2):round(dims(1)/2)-1); 
% slmR = sqrt(slmX.^2 + slmY.^2);
diam_in_pixels = round(diam/pitch);

tgt_img = zeros([dims 3]);
imshow(tgt_img)

I = insertShape(tgt_img,'filled-circle',[centre+offset round(diam_in_pixels/2)],'ShapeColor',[1,1,1],Opacity=1);
imshow(I)