%frontal face detection
  faceDetector = vision.CascadeObjectDetector;
  I = imread('sse-gather.jpg');
  bboxes = step(faceDetector, I);
  IFaces = insertObjectAnnotation(I, 'rectangle', bboxes, 'Face');
  figure, imshow(IFaces), title('Detected faces');
  
  
  bodyDetector = vision.CascadeObjectDetector('UpperBody');
  bodyDetector.MinSize = [60 60];
  bodyDetector.MergeThreshold = 10;
  I2 = imread('sse-gather.jpg');
  bboxBody = step(bodyDetector, I2);
  IBody = insertObjectAnnotation(I2, 'rectangle',bboxBody,'Upper Body');
  figure, imshow(IBody), title('Detected upper bodies');
  