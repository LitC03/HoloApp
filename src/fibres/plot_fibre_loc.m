% plot_fibre location
close all
clear

f = figure;
f.Position = [1952.333333333333,-220.3333333333333,1828.666666666667,420];
subplot(1,2,1)
img = imread("SLM_map.tiff");
h = imagesc(img(:,:,1));
aH = ancestor(h,'axes');
axis equal;
set(aH,'PlotBoxAspectRatio',[1920 1152 1])
% set(gca,'visible','off')
set(gca,'xtick',[],'ytick',[])
title('Experimental data','FontSize',15)
subplot(1,2,2)
img2 = imread("..\..\img\tgt\theory_fibre.bmp");
h=imagesc(img2);
aH = ancestor(h,'axes');
axis equal;
set(aH,'PlotBoxAspectRatio',[1920 1152 1])
% set(gca,'visible','off')
set(gca,'xtick',[],'ytick',[])
title('Theory','FontSize',15)