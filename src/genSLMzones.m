% Assigns regions of a given SLM geometry

function SLM = genSLMzones(slmDim, nCol, nRow)

zones = zeros(2, 2, nCol, nRow);
maxX = slmDim(2);
maxY = slmDim(1);
xSpan = round(maxX / nCol);
ySpan = round(maxY / nRow);

% Set order of SLM zones
zoneArr = [];
rowIdx = [0 1]; 
colIdx = [1 0]; 
beamIdx = [[0,1]; [1,1]; [1,0]; [0,0]];% beam order on SLM: 4 1
                                       %                    3 2

% Loop through each zone and determine pixel assignments    
% (get the positions and centers of each zone of the SLM, measured in SLM pixels)
for b = 1:4
    zone = struct;
    idx = beamIdx(b,:);
    thisX = [1+idx(2)*xSpan xSpan+idx(2)*xSpan];
    thisY = [1+idx(1)*ySpan ySpan+idx(1)*ySpan];
    zones(:,:,idx(1)+1,idx(2)+1) = [thisX; thisY];
    zone.X = thisX;
    zone.Y = thisY;
    zone.centX = floor(squeeze(mean(thisX)));
    zone.centY = floor(squeeze(mean(thisY)));
    zoneArr = [zoneArr zone];
end

[X, Y] = meshgrid(-round(slmDim(2)/2):round(slmDim(2)/2)-1, ...
         -round(slmDim(1)/2):round(slmDim(1)/2)-1); 
R = sqrt(X.^2 + Y.^2);  

% make and populate SLM structure
SLM = struct;
SLM.dim = slmDim;
SLM.nCol = nCol;
SLM.nRow = nRow;
SLM.zones = zoneArr;
SLM.X = X;
SLM.Y = Y;
SLM.R = R;
SLM.ap = R.*0.0+1; % might be useful in the future


