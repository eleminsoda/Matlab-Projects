% this demo program was composed by Dr. Lin Zhang, SSE, Tongji University,
% China for the course computer vision.
% It demonstrates how to make use of the classical PCA technique for face
% recognition

classDirs = dir('normalizedDB');
data = [];

classNames = {};
imageCount = 1;
for i=1:length(classDirs)
    if strcmp(classDirs(i,1).name,'.') || strcmp(classDirs(i,1).name,'..')
        continue;
    end
    currentClassDirName = ['normalizedDB\' classDirs(i,1).name];
    files = dir([currentClassDirName, '\*.bmp']);
   
    for j=1:length(files)
        classNames{imageCount} = classDirs(i,1).name;
        imageCount = imageCount + 1;
        roiFileName = [currentClassDirName '\' files(j,1).name];
        ROIimage = double(imread(roiFileName));
        imageVec = ROIimage(:);
        imageVec = (imageVec - mean(imageVec)) / std(imageVec);
%         imageVec = imageVec - mean(imageVec);
        data = [data imageVec];
    end
end

reservedRatio = 0.9;
[DimReductWithWhiteningMatrix, meanOfSampleData, projectionOfTrainingData] = MyPCA(data,reservedRatio);

trainingResult = {};
trainingResult{1} = DimReductWithWhiteningMatrix;
trainingResult{2} = meanOfSampleData;
trainingResult{3} = projectionOfTrainingData;
trainingResult{4} = classNames;

save('trainingResult.mat','trainingResult');

