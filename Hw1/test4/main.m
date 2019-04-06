imgColor1 = imread('images\sse1.bmp');
imgColor2 = imread('images\sse2.bmp');    

im1 = double(rgb2gray(imgColor1));
im2 = double(rgb2gray(imgColor2));

imgColor1 = double(imgColor1);
imgColor2 = double(imgColor2);

% ====================================
% ---------------      Find Interest Point    ------------------
% ====================================
figure;imshow(im1, []);
hold on
sim1 = single(im1);
[f1,d1] = vl_sift(sim1);
f1(3, : ) = f1(3, :)*1.5;
h1 = vl_plotframe(f1(1:3, :));
set(h1,'color','r','linewidth',1) ;

figure;imshow(im2, []);
hold on
sim2 = single(im2);
[f2,d2] = vl_sift(sim2);
f2(3, : ) = f2(3, :)*1.5;
h2 = vl_plotframe(f2(1:3, :));
set(h2,'color','g','linewidth',1) ;

% ====================================
% ---------------      Match Discriptors     ------------------
% ====================================
[matches, scores] = vl_ubcmatch(d1, d2);
correspondRes = [matches; scores]';
correspondRes = sortrows(correspondRes, 3);
correspondRes = correspondRes';
matches = correspondRes(1:2, 1:100 );
m1 = zeros(2, size(matches, 2));
m2 = zeros(2, size(matches, 2));
for i = 1:size(matches, 2)
    m1(1:2,i) = int32(f1(1:2,matches(1, i)));
    m2(1:2,i) = int32(f2(1:2,matches(2, i)));
end

% ====================================
% ---------------      Rancac & Solve H     ------------------
% ====================================
x1 = [m1(2,:); m1(1,:); ones(1,length(m1))];
x2 = [m2(2,:); m2(1,:); ones(1,length(m1))];    
t = 0.005;  
[H, inliers] = ransacfithomography(x1, x2, t);

% ====================================
% -----------      Display Discriptors' Match    -------------
% ====================================
inliers1 = m1(:,inliers);
inliers2 = m2(:,inliers);
m1 = inliers1';
m2 = inliers2';
x = 1:length(m2);
corr = [x' x'];
DisplayPoreCorr(im1, im2, m1, m2, corr);

% ====================================
% -----------      Merge two Images with H    -------------
% ====================================
InverseOfH = inv(H); 

[rowsIm1, colsIm1] = size(im1); 
[rowsIm2, colsIm2] = size(im2);
finalLeft = 1;
finalRight = colsIm2;
finalTop = 1;
finalBot = rowsIm2;

leftTopCornerCoord = H * [1;1;1];
leftTopCornerCoord = leftTopCornerCoord / leftTopCornerCoord(3,1);
if leftTopCornerCoord(1) < finalLeft
    finalLeft = floor(leftTopCornerCoord(1));
end
if leftTopCornerCoord(2) < finalTop
    finalTop = floor(leftTopCornerCoord(2));
end

RightTopCornerCoord = H * [colsIm1;1;1];
RightTopCornerCoord = RightTopCornerCoord / RightTopCornerCoord(3,1);
if RightTopCornerCoord(1) > finalRight
    finalRight = floor(RightTopCornerCoord(1));
end
if RightTopCornerCoord(2) < finalTop
    finalTop = floor(RightTopCornerCoord(2));
end

leftBotCornerCoord = H * [1;rowsIm1;1];
leftBotCornerCoord = leftBotCornerCoord / leftBotCornerCoord(3,1);
if leftBotCornerCoord(1) < finalLeft
    finalLeft = floor(leftBotCornerCoord(1));
end
if leftBotCornerCoord(2) > finalBot
    finalBot = floor(leftBotCornerCoord(2));
end

RightBotCornerCoord = H * [colsIm1;rowsIm1;1];
RightBotCornerCoord = RightBotCornerCoord / RightBotCornerCoord(3,1);
if RightBotCornerCoord(1) > finalRight
    finalRight = floor(RightBotCornerCoord(1));
end
if RightBotCornerCoord(2) > finalBot
    finalBot = floor(RightBotCornerCoord(2));
end

mergeRows = finalBot - finalTop + 1;
mergeCols = finalRight - finalLeft + 1;
transformedImage = zeros(mergeRows, mergeCols,3);
for row = 1:mergeRows
    for col = 1: mergeCols
        currentCoord = [col+finalLeft-1;row+finalTop-1;1];
        CoordInOriImage = InverseOfH * currentCoord;
        CoordInOriImage = CoordInOriImage / CoordInOriImage(3,1);

        xInSrcImage = CoordInOriImage(1,1);
        yInSrcImage = CoordInOriImage(2,1);

        floorY = floor(yInSrcImage);
        floorX = floor(xInSrcImage);
        ceilY = ceil(yInSrcImage);
        ceilX = ceil(xInSrcImage);
        normalizedX = xInSrcImage - floorX;
        normalizedY = yInSrcImage - floorY;

        if (floorX >= 1 && floorY >=1 && ceilX <= colsIm1 && ceilY <= rowsIm1) 
            f00 = imgColor1(floorY,floorX,1);
            f01 = imgColor1(ceilY,floorX,1);
            f10 = imgColor1(floorY,ceilX,1);
            f11 = imgColor1(ceilY,ceilX,1);
            transformedImage(row,col,1) = f00 + normalizedX * (f10 - f00)+ ...
                                        normalizedY * (f01 - f00) + ...
                                        normalizedX*normalizedY*(f00-f10-f01+f11);

            f00 = imgColor1(floorY,floorX,2);
            f01 = imgColor1(ceilY,floorX,2);
            f10 = imgColor1(floorY,ceilX,2);
            f11 = imgColor1(ceilY,ceilX,2);
            transformedImage(row,col,2) = f00 + normalizedX * (f10 - f00)+ ...
                                        normalizedY * (f01 - f00) + ...
                                        normalizedX*normalizedY*(f00-f10-f01+f11);

            f00 = imgColor1(floorY,floorX,3);
            f01 = imgColor1(ceilY,floorX,3);
            f10 = imgColor1(floorY,ceilX,3);
            f11 = imgColor1(ceilY,ceilX,3);
            transformedImage(row,col,3) = f00 + normalizedX * (f10 - f00)+ ...
                                        normalizedY * (f01 - f00) + ...
                                        normalizedX*normalizedY*(f00-f10-f01+f11);
        end
    end
end

transformedImage(-finalTop + 2 : -finalTop + 1 + rowsIm2, -finalLeft + 2 : -finalLeft + 1 + colsIm2,:) = imgColor2;
figure;imshow(uint8(transformedImage),[]);



















