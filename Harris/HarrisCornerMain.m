
    im = imread('officegray.bmp');
    im = double(im);

    sigma = 2.5;
    thresh = 35;  
    nonmaxrad = 5;
    K=0.02;
    [cim, r3, c3] = harris(im, sigma,thresh, nonmaxrad);
    
    figure;
    imshow(im,[]), hold on, plot(c3,r3,'go');
    