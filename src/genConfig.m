% Generates a config structure for holoApp 

function config = genConfig()
config = struct;
config.nCol = 0;
config.nRow =0;
config.focal_mm = 0;
config.do_circParts = 0;
config.force_size = 1;
config.targetMult = 0;
config.save_phase = 0;
config.MPUS_PC = 0;
config.do_loop = 0;
config.targetResized = [0 0 0 0; 0 0 0 0];
config.beamDiam = 0.0;
config.slmPix = 0.0;
config.camPix = 0.0;
config.slmDim = 0.0;
config.mapDim = 0.0;
config.mapDiam = 0.0;
config.mapRad = 0.0;
config.camDim = 0.0;
config.dispDims = 0.0;
config.apRad = 0.0;
config.apPaddingX = 0.0;
config.apPaddingY = 0.0;
config.gaussSigma = 0.0;
config.targetRot = 0;
config.labelSize = 0;
config.titleSize = 0;
config.circTitles = "";
config.targetTitle = " ";
config.N_ITERS = 5; % Iterations for the routine
% config.targetArraySmallSize = 0.0;
config.targetArraySmallSize = 1000;
config.startingPosX = [0 0 0 0];
config.startingPosY = [0 0 0 0];
config.goalPosX = [0 0 0 0];
config.goalPosY = [0 0 0 0];
config.targShiftX = [0 0 0 0];
config.targShiftY = [0 0 0 0];
config.targRot = [0 0 0 0];
