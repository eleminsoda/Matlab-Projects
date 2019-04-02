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
distance = [];
for i=1:N1
    for j=1:N2
        subtract = d1(:,i)-d2(:,j);
        distance(i,j) = norm(subtract);
    end
end 

matchArr=[]
for i=1:N1
    subDist = distance(i,:);
    sortDistance = sort(subDist);
    if(sortDistance(1) < 0.7*sortDistance(2))
        j=find(distance==sortDistance(1));
        matchArr(1,i) = j;
    end
end

for j=1:N2
    subDist = distance(:,j);
    sortDistance = sort(subDist);
    if(sortDistance(1) < 0.7*sortDistance(2))
        i=find(distance==sortDistance(1));
        matchArr(2,j) = i;
    end
end



   

