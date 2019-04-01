% This script is composed by Lin Zhang, SSE, Tongji to demonstrate the
% basic ideas of panorama stitching. This script is based on Peter Kovesi's
% work.
% Demonstration of feature matching via simple correlation, and then using
% RANSAC to estimate the homography between two images and at the same time
% identify (mostly) inlying matches. Then, the first image is transformed
% to the coordinate system of the second image and I use a bilinear
% interpolation method to generate the transformed image. In this example,
% simple technique is used to reduce the global tune difference of two
% images
%
	imgColor1 = imread('images\gate1.bmp');
	imgColor2 = imread('images\gate2.bmp');    
    
    imgColor1 = double(imgColor1);
    imgColor2 = double(imgColor2);
    
    %at first, i want to know the global intensity difference between the
    %two images
    diff = getGlobalIntensityDiff(imgColor1, imgColor2);
    imgColor2(:,:,1) = imgColor2(:,:,1) + diff(1);
    imgColor2(:,:,2) = imgColor2(:,:,2) + diff(2);
    imgColor2(:,:,3) = imgColor2(:,:,3) + diff(3);
    
    resultImage = mergeTwoImages(imgColor1, imgColor2);
    
    figure;
    imshow(resultImage,[]);
    