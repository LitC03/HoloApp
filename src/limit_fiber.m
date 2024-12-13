%create images
close all
row=[1102];
col=[555];
pixels_with_ones=sub2ind([1920,1920],row,col);
% imagesent = zeros(1920);

imagesent(pixels_with_ones)=255;

figure
imagesc(imagesent)


% inverse image
% inverse = 255*ones(1920);
inverse(pixels_with_ones)=0;

imwrite(imagesent,'..\img\tgt\sent.bmp')
imwrite(inverse,'..\img\tgt\inverse.bmp')