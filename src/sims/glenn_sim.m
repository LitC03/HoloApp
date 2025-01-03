%% Modelling Glenn's exp
clear
close all
%% Homogeneous propagation medium 
% create the computational grid
Nx = 250;            % number of grid points in the x direction
Ny = 250;            % number of grid points in the y direction
Nz = 100;            % number of grid points in the z direction
dx = 0.1e-3;        % grid point spacing in the x direction [m]
dy = 0.1e-3;        % grid point spacing in the y direction [m]
dz = 0.1e-3;        % grid point spacing in the z direction [m]
kgrid = kWaveGrid(Nx, dx, Ny, dy, Nz, dz);

% define the properties of the propagation medium
medium.sound_speed = 1500;  % [m/s]
medium.alpha_coeff = 0.75;  % [dB/(MHz^y cm)]
medium.alpha_power = 1.5;
medium.density = 1;

%% Determine length of simulation (create time array)
% t_end = 2e-6;       % [s]
% kgrid.makeTime(medium.sound_speed, [], t_end);

% Or you can use this method:
Nt = 2000;          % num of steps
dt = 2e-9;          % [s] delay between simulation steps

kgrid.setTime(Nt, dt);

%% Source
% define a square source element



%% Time series
img1=imread('SLMtarget_circ_parts12.png');
img2=imread('SLMtarget_circ_parts22.png');
img3=imread('SLMtarget_circ_parts32.png');
img4=imread('SLMtarget_circ_parts42.png');

% source_radius = 50;  % [grid points]
img_offset=25;
source.p_mask = zeros(Nx, Ny, Nz);
source.p_mask(img_offset:size(img1,1)+img_offset-1,img_offset:size(img1,2)+img_offset-1, 5) = 1;
figure;
voxelPlot(source.p_mask)
%%

offset = 60e-9;               % [s]
pulse_length = 6e-9;          % [s]
canvas = zeros(Nx,Ny);


repeat_of_imgs = round(pulse_length/dt);
frames_delay = round(offset/dt);

time_series_3D = zeros(size(img1,1),size(img1,2),length(kgrid.t_array));
img_stack = zeros(size(img1,1),size(img1,2),4);
img_stack(:,:,1)= normalize(img1,"range");
img_stack(:,:,2)= normalize(img2,"range");
img_stack(:,:,3)= normalize(img3,"range");
img_stack(:,:,4)= normalize(img4,"range");

for a=1:4
    time_point=1+((a-1)*(frames_delay));
    for b=1:repeat_of_imgs
        time_series_3D(:,:,b+time_point-1) = 5*img_stack(:,:,a);
    end
end

flattened_t_series = reshape(time_series_3D,[],Nt);
% source.p_mask = time_series_3D(img_offset:size(img1,1)+img_offset-1,img_offset:size(img1,2)+img_offset-1,b+time_point-1)
source.p = flattened_t_series;
% 
% figure(10)
% for a=1:length(kgrid.t_array)
%     imagesc(time_series_3D(:,:,a))
% 
%     pause(0.1);
% end
% % Need to normalise image from 0 to 1 for the simulation
% canvas(img_offset:size(img,1)+img_offset-1,img_offset:size(img,2)+img_offset-1) = ;

% % smooth the source
% source.p = filterTimeSeries(kgrid, medium, source.p);

%% Defining the sensor

% define a series of Cartesian points to collect the data
        % [m]
sensor.mask = zeros(Nx,Ny,Nz);
sensor.mask(:,:,20) = 1;

%% Run simulation
% input arguments
input_args = {'DisplayMask', source.p_mask, 'DataCast', 'single','RecordMovie', false, 'MovieName', 'glenns4'};
% run the simulation
sensor_data = kspaceFirstOrder3D(kgrid, medium, source, sensor, input_args{:});
%% Display pressure field across time

figure;
% imagesc(squeeze(sensor_data(1).p(5,:,:)),[-1 1]); % For rectangular sensor.
imagesc(sensor_data,[-1 1]);
colormap(getColorMap);
ylabel('Sensor Position');
xlabel('Time Step');
colorbar;