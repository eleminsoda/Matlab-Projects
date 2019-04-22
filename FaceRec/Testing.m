
testImage = double(imread('t5.bmp'));
trainingResult = load('trainingResult.mat');
trainingResult = trainingResult.trainingResult;
DimReductWithWhiteningMatrix = trainingResult{1};
meanFace = trainingResult{2};
projectionOfTrainingData = trainingResult{3};
classNamesForEachTrainingImage = trainingResult{4};

testVector = testImage(:);
testVector = (testVector - mean(testVector)) / std(testVector);
% testVector = testVector - mean(testVector);
testVectorCentralized = testVector - meanFace;
testProjection = DimReductWithWhiteningMatrix * testVectorCentralized;

imNosOfTrainingFace = size(projectionOfTrainingData, 2);

maxIndex = 1;
error = Inf;
for templateIndex = 1:imNosOfTrainingFace
    currentError = norm(testProjection - projectionOfTrainingData(:,templateIndex));
    if currentError < error
        error = currentError;
        maxIndex = templateIndex;
    end
end
threshold = 2.12;
if error > threshold
    disp(['this person does not exist in the dataset']);
else
    Identity = classNamesForEachTrainingImage{maxIndex};
    disp(['this person is ' Identity]);
end

% maxIndex = 1;
% sim = 0;
% for templateIndex = 1:imNosOfTrainingFace
%     currentSim = abs(sum(testProjection.* projectionOfTrainingData(:,templateIndex)) / (norm(testProjection) * norm(projectionOfTrainingData(:,templateIndex))));
%     if currentSim > sim
%         sim = currentSim;
%         maxIndex = templateIndex;
%     end
% end
% threshold = 0.10;
% if sim < threshold
%     disp(['this person does not exist in the dataset']);
% else
%     Identity = classNamesForEachTrainingImage{maxIndex};
%     disp(['this person is ' Identity]);
% end
