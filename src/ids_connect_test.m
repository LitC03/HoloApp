% Create a video input object
vid = videoinput('gige', 1);

% Configure the object (adjust parameters as needed)
set(vid, 'FramesPerTrigger', 1, 'TriggerSource', 'immediate');

% Start acquisition
start(vid);

% Read frames
while true
    image = step(vid);
    % Process the image as needed
end
