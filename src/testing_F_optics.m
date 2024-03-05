clear 
close all

m=imread('peppers.png');
imshow(m)
dims = size(m);
[x_grid,y_grid] = meshgrid(1:100,1:100);
l=1064e-9;
A=1;
d=20e-3;
f=40e-3;

D = A*exp(pi*1i/(l*f)*(1-d/f)*(x_grid.^2+y_grid.^2));
% F1 = D * fft();
F1 = zeros(dims(1:2));

% for a=1:dims(1)
%     F1(a,:) = m(a,:)*exp()-i=1i*2*pi/(l*f)();
% end
