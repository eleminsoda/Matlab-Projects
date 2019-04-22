%this is my implementation of principle component analysis 
%sampleData contains the sample data in each column
function [DimReductWithWhiteningMatrix, meanOfSampleData, projectionOfTrainingData] = MyPCA(sampleData, reservedRatio)

    PCVectors = []; %each column will contain a principal component
    meanOfSampleData = mean(sampleData,2); %the mean of all the data samples
    centerlizedData = bsxfun(@minus,sampleData,meanOfSampleData); %centerlize all the training samples
    
    %since the real cov matrix XX' is high dimension, we will at first
    %perform the eigvalue decomposition on X'X, and then multiply X to the
    %obtained eigen-vectors to get the real eigen-vector of XX'. Of course,
    %a normalization procedure is required at last to make the vector has a
    %unit length.
    tmpMatrix = (centerlizedData' * centerlizedData) / (size(sampleData,2)-1); 
    
    subSpaceDim = min(size(sampleData));
    reservedPCs = floor(subSpaceDim * reservedRatio);
    [tmpEigVectors, d] = eig(tmpMatrix);
    
    d = diag(d);
    [d_sort, d_index]= sort(d,'descend');     
    sortedTmpVectors = tmpEigVectors(:, d_index);  
    
    eigVectors = centerlizedData * sortedTmpVectors(:,1:reservedPCs);
    
    for pcIndex = 1:reservedPCs
        tmpVector = eigVectors(:, pcIndex);
        tmpVector = tmpVector / norm(tmpVector);
        PCVectors = [PCVectors tmpVector];
    end
    
    DimReductWithWhiteningMatrix =  diag(1./sqrt(d_sort(1:reservedPCs))) * PCVectors';
    projectionOfTrainingData = DimReductWithWhiteningMatrix * centerlizedData;

