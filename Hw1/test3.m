img = imread('sample.png');
%img = imread('officegray.bmp');

imshow(img);
img = single(rgb2gray(img));

[f,d] = vl_sift(img);

h1 = vl_plotframe(f(1:3,(1000:size(f,2))));
set(h1, 'color', 'r', 'linewidth', 1);