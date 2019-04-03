imgColor1 = imread('images\sse1.bmp');
imgColor2 = imread('images\sse2.bmp');

img1 = single(rgb2gray(imgColor1));
img2 = single(rgb2gray(imgColor2));

% Compute the SIFT key points as well as the descriptors using vl_sift
[f1,d1] = vl_sift(img1); 
[f2,d2] = vl_sift(img2);

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

% Next we compute the Affine Matrix between two images
point1 = [];
point2 = [];
for i = 1:size(finalMatchArr)
    pair = finalMatchArr(i,:);
    point1 = [point1; [f1(1,pair(1)),f1(2,pair(1))]];
    point2 = [point2; [f2(1,pair(2)),f2(2,pair(2))]];
end

N = size(point1,1);
P1 = [point1';ones(1,N)];
P2 = [point2';ones(1,N)];

H = [];
H_T = P1'\P2';
H = H_T';
H(3,:) = [0 0 1];


   

