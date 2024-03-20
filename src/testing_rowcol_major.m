% testing what happens when software is column/row major
clear
close all

% image = imread("C:\Users\lito\OneDrive - Imperial College London\Documents " + ...
    % "1\Yo\Education\PhD\HoloApp\img\tgt\SLMtarget_num4.png");
image = imread("C:\Users\lito\OneDrive - Imperial College London\Documents 1\Yo\Education\PhD\HoloApp\img\tgt\SLMtarget_circ_parts1.png");
dims = size(image);
one_way=image(:); %column major
or_another=reshape(image.',[],1); %row major

one_way = reshape(one_way,dims);
or_another = reshape(or_another,dims);
or_another = transpose(or_another);

figure
subplot(1,2,1)
imagesc(one_way)
subplot(1,2,2)
imagesc(or_another)