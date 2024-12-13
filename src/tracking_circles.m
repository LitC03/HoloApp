clear
close all

% Horizontal distance
pos1=[855,765,635,505,444,324,262,136];
idx1=[304,371,668,926,1183,1457,1721,2029];
pos2=[1752,1695,1565,1491,1361,1232,1102,996,874];
idx2=[930,1188,1472,1723,2030,2281,2488,2759,2916];

total_travelled_px1 = pos1(1)-pos1(end);
total_travelled_px2 = pos2(1)-pos2(end);

total_travelled_real1 = total_travelled_px1*2e-3;
total_travelled_real2 = total_travelled_px2*2e-3;

travel_max_pxs = (idx1(4)-idx1(1))+(total_travelled_px2);
travel_max_real_hor = travel_max_pxs*2e-3 %in mm

% Vertical distance
pos=[1713,1809,1864,1946,2024,2083,2192,2298,2336];
idx=[6,578,785,1069,1220,1434,1671,1929,2283];

total_travelled_px = pos(end)-pos(1);
total_max_real_ver = total_travelled_px*2e-3 % in mm
