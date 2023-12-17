% Builds an array of padded targets for holoApp

function [targetPadArray, targetPadArraySmall] = buildTargetArray(target, targShiftX, targShiftY, config)

% Set up geometry and names
N_BEAM = config.nCol * config.nRow;
% circTitles = config.circTitles;
% circTitles = 
% targetTitle = config.targetTitle;
mapDim = config.mapDim;
camDim = config.camDim;
targRat = 1;

% Loop through beams and assign target images
for b = 1:N_BEAM

    dirName = '..\img\tgt\SLMtarget_';
    if config.do_circParts
        targetFile = [dirName,'circ_parts', num2str(b),'.png'];
    else
        targetFile = [dirName,'test.png'];
    end
    target = imread(targetFile);
    target = double(target);
 
    Xover = size(target,2) / camDim(2);
    Yover = size(target,1) / camDim(1);
    if config.force_size
        target = imresize(target, [config.targetResized(1,b) config.targetResized(2,b)]);

    elseif Xover > 1 || Yover > 1
        maxScale = max([Xover Yover]);
        target = imresize(abs(target.^targExp), [round(targSize(1)/maxScale) round(targSize(2)/maxScale)]); 
    else
        target = imresize(target, round([camDim(2)*targRat-camShrink(1) ...
            camDim(1)-camShrink(2)]));
    end
    
    target = target-min(target, [], 'all');
    target = target .* 255 / max(target(:));
    target = imrotate(target, config.targRot(b), "crop");

    % Pad the arrays to conform to correct PSF
    targetPad = padarray(target, [floor(mapDim(1)/2)-floor(size(target,1)/2) ...
        floor(mapDim(2)/2)-floor(size(target,2)/2)], 0, 'both');
    targetPad = imresize(targetPad, [mapDim(1) mapDim(2)]);
    targetPad = circshift(targetPad, targShiftX(b), 2);
    targetPad = circshift(targetPad, targShiftY(b), 1);
    targetPadSmall = imresize(targetPad, [config.targetArraySmallSize config.targetArraySmallSize]);
    targetPad = circshift(targetPad, -targShiftX(b), 2);
    targetPad = circshift(targetPad, -targShiftY(b), 1);
    if b == 1
        targetPadArraySmall = zeros(config.targetArraySmallSize, config.targetArraySmallSize); 
        targetPadArray = zeros(size(targetPad,1), size(targetPad,2), N_BEAM);
    end
    targetPadArray(:,:,b) = targetPad;
    targetPadArraySmall(:,:,b) = targetPadSmall;


end

% end

