% Generates an SLM hologram

% clear
function config = holoAppBackend

config = genConfig;

do_circParts = 0;
force_size = 1;
targetMult = 1;
targetRot = 0;
N_ITERS = 10;
do_scp = 0;
save_phase = 0;
do_loop = 0; 

circTitles = ["circ_parts1.png" "circ_parts2.png" "circ_parts3.png" "circ_parts4.png"];
targetTitle = 'ICLback10mm';
targetTitle = 'gauss';
% if do_circParts
%     targetTitle='Numbers';
% end
buildTargTitle = 'CUSTOM_2spot_150px_grad_-13';

targetResized = [50 50 50 50; 50 50 50 50];
targetArraySmallSize = 1000;

gradientExp = 0.13;
targExp = 0;
targRot = 0;
circPhaseMaskSize = 2000;

labelSize = 14;
titleSize = 16;

config.do_circParts = do_circParts;
config.force_size = force_size;
config.targetMult = targetMult;
config.save_phase = save_phase;
config.do_loop = do_loop;
config.targetResized = targetResized;
config.targetRot = targetRot;
config.labelSize = labelSize;
config.titleSize = titleSize;
config.circTitles = circTitles;
config.targetTitle = targetTitle;
config.N_ITERS = N_ITERS;
config.targetArraySmallSize = targetArraySmallSize;

targShiftX = 000;
targShiftY = 000;

startingPosX = [3021 3351 3710 3461]*-1; 
startingPosY = [-32 -33 -279 -117]*-1;

goalPosX = [0 0 0 0];
goalPosY = [0 0 0 0];

% Sort out display beam index vs generation beam index
targShiftX = [1 -1 1 -1].*targShiftX;
targShiftY = [1 1 -1 -1].*targShiftY;

config.targShiftX = targShiftX;
config.targShiftY = targShiftY;
config.startingPosX = startingPosX;
config.startingPosY = startingPosY;
config.goalPosX = goalPosX;
config.goalPosY = goalPosY;

% holoApp;
    


