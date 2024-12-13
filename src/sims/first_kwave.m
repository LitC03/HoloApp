%% K-space_example
clear
close all
%% Homogeneous propagation medium 
% % create the computational grid
Nx = 250;           % number of grid points in the x (row) direction
Ny = 250;           % number of grid points in the y (column) direction
dx = 0.5e-4;        % grid point spacing in the x direction [m]
dy = 0.5e-4;        % grid point spacing in the y direction [m]
kgrid = kWaveGrid(Nx, dx, Ny, dy);

% define the properties of the propagation medium
medium.sound_speed = 1500;  % [m/s]
medium.alpha_coeff = 0.75;  % [dB/(MHz^y cm)]
medium.alpha_power = 1.5;
medium.density = 1;

%% Determine length of simulation (create time array)
% t_end = 2e-6;       % [s]
% kgrid.makeTime(medium.sound_speed, [], t_end);

% Or you can use this method:
Nt = 1000;          % num of steps
dt = 10e-9;          % [s] delay between simulation steps

kgrid.setTime(Nt, dt);


%% create initial pressure distribution (using makeDisc)
% disc_magnitude = 5; % [Pa]
% disc_x_pos = 50;    % [grid points]
% disc_y_pos = 50;    % [grid points]
% disc_radius = 8;    % [grid points]
% disc_1 = disc_magnitude * makeDisc(Nx, Ny, disc_x_pos, disc_y_pos, disc_radius);
% 
% disc_magnitude = 3; % [Pa]
% disc_x_pos = 80;    % [grid points]
% disc_y_pos = 60;    % [grid points]
% disc_radius = 5;    % [grid points]
% disc_2 = disc_magnitude * makeDisc(Nx, Ny, disc_x_pos, disc_y_pos, disc_radius);
% 
% source.p0 = disc_1 + disc_2;

%% Create initial pressure distribution with image

% img=imread('SLMtarget_gauss.png');
img=imread('SLMtarget_circ_parts12.png');
canvas = zeros(Nx,Ny);
offset=25;

% Need to normalise image from 0 to 1 for the simulation
canvas(offset:size(img,1)+offset-1,offset:size(img,2)+offset-1) = normalize(img,"range");

p0_magnitude = 2; % Once normalised, the magnitude can be changed here
p0 = p0_magnitude * canvas;

source.p0 = resize(p0, [Nx, Ny]); % Resize to the dimensions of the 2D simulation

figure(5)
imagesc(source.p0)
colorbar
%% Defining the sensor

% define a centered circular sensor
sensor_radius = 4e-3;   % [m]
num_sensor_points = 100;
sensor.mask = makeCartCircle(sensor_radius, num_sensor_points);

% % define the first rectangular sensor region by specifying the location of
% % opposing corners
% rect1_x_start = 25;
% rect1_y_start = 31;
% rect1_x_end = 30;
% rect1_y_end = 50;
% 
% % define the second rectangular sensor region by specifying the location of
% % opposing corners
% rect2_x_start = 71;
% rect2_y_start = 81;
% rect2_x_end = 80;
% rect2_y_end = 90;
% 
% % assign the list of opposing corners to the sensor mask
% sensor.mask = [rect1_x_start, rect1_y_start, rect1_x_end, rect1_y_end;...
%                rect2_x_start, rect2_y_start, rect2_x_end, rect2_y_end].';



%% Run the simulation
% figure;
% sensor_data = kspaceFirstOrder2D(kgrid, medium, source, sensor);
sensor_data = kspaceFirstOrder2D(kgrid, medium, source, sensor, ...
    'PlotLayout', true, 'PlotPML', false);

%% Display pressure field across time

figure;
% imagesc(squeeze(sensor_data(1).p(5,:,:)),[-1 1]); % For rectangular sensor.
imagesc(sensor_data,[-1 1]);
colormap(getColorMap);
ylabel('Sensor Position');
xlabel('Time Step');
colorbar;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3D
clear
close all

% create the computational grid
Nx = 64;            % number of grid points in the x direction
Ny = 64;            % number of grid points in the y direction
Nz = 64;            % number of grid points in the z direction
dx = 0.1e-3;        % grid point spacing in the x direction [m]
dy = 0.1e-3;        % grid point spacing in the y direction [m]
dz = 0.1e-3;        % grid point spacing in the z direction [m]
kgrid = kWaveGrid(Nx, dx, Ny, dy, Nz, dz);

% define the properties of the propagation medium
medium.sound_speed = 1500 * ones(Nx, Ny, Nz);	% [m/s]
medium.sound_speed(1:Nx/2, :, :) = 1800;        % [m/s]
medium.density = 1000 * ones(Nx, Ny, Nz);       % [kg/m^3]
medium.density(:, Ny/4:end, :) = 1200;          % [kg/m^3]

% create initial pressure distribution using makeBall
ball_magnitude = 10;    % [Pa]
ball_x_pos = 38;        % [grid points]
ball_y_pos = 32;        % [grid points]
ball_z_pos = 32;        % [grid points]
ball_radius = 5;        % [grid points]
ball_1 = ball_magnitude * makeBall(Nx, Ny, Nz, ball_x_pos, ball_y_pos, ball_z_pos, ball_radius);

ball_magnitude = 10;    % [Pa]
ball_x_pos = 20;        % [grid points]
ball_y_pos = 20;        % [grid points]
ball_z_pos = 20;        % [grid points]
ball_radius = 3;        % [grid points]
ball_2 = ball_magnitude * makeBall(Nx, Ny, Nz, ball_x_pos, ball_y_pos, ball_z_pos, ball_radius);

source.p0 = ball_1 + ball_2;

% define a series of Cartesian points to collect the data
x = (-22:2:22) * dx;          % [m]
y = 22 * dy * ones(size(x));    % [m]
z = (-22:2:22) * dz;          % [m]
sensor.mask = [x; y; z];

% input arguments
input_args = {'PlotLayout', true, 'PlotPML', false, ...
    'DataCast', 'single', 'CartInterp', 'nearest'};

% run the simulation
sensor_data = kspaceFirstOrder3D(kgrid, medium, source, sensor, input_args{:});

% Display pressure field across time

figure;
% imagesc(squeeze(sensor_data(1).p(5,:,:)),[-1 1]); % For rectangular sensor.
imagesc(sensor_data,[-1 1]);
colormap(getColorMap);
ylabel('Sensor Position');
xlabel('Time Step');
colorbar;

%% Time varying sources (2D)
clear source
% define a single source point
source.p_mask = zeros(Nx, Ny);
source.p_mask(end - round(Nx/4), Ny/2) = 1;
source.p_mask(end - round(Nx/4), Ny/2-1) = 1;

figure;
imagesc(source.p_mask)
colorbar

% define a time varying sinusoidal source
source_freq = 0.25e6;   % [Hz]
source_mag = 6;         % [Pa]
source.p(1,:) = source_mag * sin(2 * pi * source_freq * kgrid.t_array);
source.p(2,:) = -source_mag * sin(2 * pi * source_freq * kgrid.t_array+pi/2);

% filter the source to remove high frequencies not supported by the grid
source.p(1,:) = filterTimeSeries(kgrid, medium, source.p(1,:));
source.p(2,:) = filterTimeSeries(kgrid, medium, source.p(2,:));

%% define a single source point
source.u_mask = zeros(Nx, Ny);
source.u_mask(end - round(Nx/4), Ny/2) = 1;

figure;
imagesc(source.u_mask)
colorbar

% define a time varying sinusoidal velocity source in the x-direction
source_freq = 0.25e6;       % [Hz]
source_mag = 2 / (medium.sound_speed * medium.density);
source.ux = -source_mag * sin(2 * pi * source_freq * kgrid.t_array);

% filter the source to remove high frequencies not supported by the grid
source.ux = filterTimeSeries(kgrid, medium, source.ux);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Steering array
clear source
% define source mask for a linear transducer with an odd number of elements   
num_elements = 50;      % [grid points]
x_offset = 25;          % [grid points]
source.p_mask = zeros(Nx, Ny);
start_index = Ny/2 - round(num_elements/2) + 1;
source.p_mask(x_offset, start_index:start_index + num_elements - 1) = 1;

figure;
imagesc(source.p_mask)

% define the properties of the tone burst used to drive the transducer
sampling_freq = 1/kgrid.dt;     % [Hz]
steering_angle = 30;            % [deg]
element_spacing = dx;           % [m]
tone_burst_freq = 1e6;          % [Hz]
tone_burst_cycles = 8;

% create an element index relative to the centre element of the transducer
element_index = -(num_elements - 1)/2:(num_elements - 1)/2;

% use geometric beam forming to calculate the tone burst offsets for each
% transducer element based on the element index
tone_burst_offset = 50 + element_spacing * element_index * ...
    sin(steering_angle * pi/180) / (medium.sound_speed * kgrid.dt);

% create the tone burst signals
source.p = toneBurst(sampling_freq, tone_burst_freq, tone_burst_cycles, ...
    'SignalOffset', tone_burst_offset);


%% Photoacuoustics

% % size of the computational grid
% Nx = 64;    % number of grid points in the x (row) direction
% x = 1e-3;   % size of the domain in the x direction [m]
% dx = x/Nx;  % grid point spacing in the x direction [m]
% 
% % define the properties of the propagation medium
% medium.sound_speed = 1500;      % [m/s]
% 
% % size of the initial pressure distribution
% source_radius = 2;              % [grid points]
% 
% % distance between the centre of the source and the sensor
% source_sensor_distance = 10;    % [grid points]
% 
% % time array
% dt = 2e-9;                      % [s]
% t_end = 300e-9;                 % [s]
% 
% % computation settings
% input_args = {'DataCast', 'single'};
% 
% 
% % create the computational grid
% kgrid = kWaveGrid(Nx, dx);
% 
% % create the time array
% kgrid.setTime(round(t_end / dt) + 1, dt);
% 
% % create initial pressure distribution
% source.p0 = zeros(Nx, 1);
% source.p0(Nx/2 - source_radius:Nx/2 + source_radius) = 1;
% 
% % run the simulation
% % sensor_data_1D = kspaceFirstOrder1D(kgrid, medium, source, sensor, input_args{:});
% 
% % define a single sensor point
% sensor.mask = zeros(Nx, 1);
% sensor.mask(Nx/2 + source_sensor_distance) = 1;	
% 
% 
% % create the computational grid
% kgrid = kWaveGrid(Nx, dx, Nx, dx);
% 
% % create initial pressure distribution
% source.p0 = makeDisc(Nx, Nx, Nx/2, Nx/2, source_radius);
% 
% % define a single sensor point
% sensor.mask = zeros(Nx, Nx);
% sensor.mask(Nx/2 - source_sensor_distance, Nx/2) = 1;
% 
% % run the simulation
% sensor_data_2D = kspaceFirstOrder2D(kgrid, medium, source, sensor, input_args{:});

% Nx=30;
% Ny=Nx;
% define source mask for a linear transducer with an odd number of elements   
% num_elements = 21;      % [grid points]
% x_offset = 25;          % [grid points]
% source.p_mask = zeros(Nx, Ny);
% start_index = Ny/2 - round(num_elements/2) + 1;
% source.p_mask(x_offset, start_index:start_index + num_elements - 1) = 1;
% 
% % define the properties of the tone burst used to drive the transducer
% sampling_freq = 1/kgrid.dt;     % [Hz]
% steering_angle = 30;            % [deg]
% element_spacing = dx;           % [m]
% tone_burst_freq = 1e6;          % [Hz]
% tone_burst_cycles = 8;
% 
% % create an element index relative to the centre element of the transducer
% element_index = -(num_elements - 1)/2:(num_elements - 1)/2;
% 
% % use geometric beam forming to calculate the tone burst offsets for each
% % transducer element based on the element index
% tone_burst_offset = 40 + element_spacing * element_index * ...
%     sin(steering_angle * pi/180) / (medium.sound_speed * kgrid.dt);
% 
% % create the tone burst signals
% source.p = toneBurst(sampling_freq, tone_burst_freq, tone_burst_cycles, ...
%     'SignalOffset', tone_burst_offset);
