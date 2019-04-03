imgColor1 = imread('images\sse1.bmp');
imgColor2 = imread('images\sse2.bmp');

img1 = single(rgb2gray(imgColor1));
img2 = single(rgb2gray(imgColor2));

% Compute the SIFT key points as well as the descriptors using vl_sift
[f1,d1] = vl_sift(img1); 
[f2,d2] = vl_sift(img2);

f1(1:2,:) = uint16(f1(1:2,:));
f2(1:2,:) = uint16(f2(1:2,:));

% Plot the key points in both pictures
figure(1);
image(imgColor1);
h1 = vl_plotframe(f1(1:3,:));
set(h1, 'color', 'r', 'linewidth', 1);

figure(2);
image(imgColor2);
h2 = vl_plotframe(f2(1:3,:));
set(h2, 'color', 'b', 'linewidth', 1);

% Match the descriptors in both images by computing the Euclidean distance.
% The match should be a two-way match, that is, the point in img1 matches
% the point most in img2, and THE point in img2 matches the point most in
% img1.
[~,N1] = size(d1);
[~,N2] = size(d2);
distance = zeros(N1,N2);

% Parameter for matching supression
sigma = 0.7;

for i=1:N1
    for j=1:N2
        subtract = d1(:,i)-d2(:,j);
        distance(i,j) = norm(double(subtract));
    end
end 

matchArr = zeros(2,max([N1,N2]));
for i=1:N1
    subDist = distance(i,:);
    sortDistance = sort(subDist);
    if(sortDistance(1) < sigma*sortDistance(2))
        j=find(subDist==sortDistance(1));
        matchArr(1,i) = j;
    end
end

for j=1:N2
    subDist = distance(:,j);
    sortDistance = sort(subDist);
    if(sortDistance(1) < sigma*sortDistance(2))
        i=find(subDist==sortDistance(1));
        matchArr(2,j) = i;
    end
end

finalMatchArr = [];
tempMatchArr = find(matchArr(1,:));
for i = tempMatchArr
    colIndex = matchArr(1,i);
    rowIndex = matchArr(2,colIndex);
    
    if rowIndex == i
        finalMatchArr = [finalMatchArr; [rowIndex, colIndex]];
    end
end

% Next we use RANSAC to filter the key points and compute the Affine Matrix
% between two images using ransanfithomography. Note that the rows and cols
% should be reversed.
point1 = [];
point2 = [];
for i = 1:size(finalMatchArr)
    pair = finalMatchArr(i,:);
    point1 = [point1; [f1(2,pair(1)),f1(1,pair(1))]];
    point2 = [point2; [f2(2,pair(2)),f2(1,pair(2))]];
end

N = size(point1,1);
P1 = [point1';ones(1,N)];
P2 = [point2';ones(1,N)];

t = 0.005;  % Distance threshold for deciding outliers
[H, inliers] = ransacfithomography(P1, P2, t);

% H = [];
% H_T = P1'\P2';
% H = H_T';
% H(3,:) = [0 0 1];

point1 = point1';
point2 = point2';
inliers1 = point1(:,inliers);
inliers2 = point2(:,inliers);
m1 = inliers1';
m2 = inliers2';
x = 1:length(m2);
corr = [x' x'];

DisplayPoreCorr(img1, img2, m1, m2, corr);

% Finally we stitch two images 
[rowsIm1, colsIm1] = size(img1); 
[rowsIm2, colsIm2] = size(img2);
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

