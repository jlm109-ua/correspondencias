images = imageDatastore('./mano_UA/');

% Compute features for the first image.

I = im2gray(readimage(images,1));
pointsPrev = detectSURFFeatures(I);
[featuresPrev,pointsPrev] = extractFeatures(I,pointsPrev);

% Create an image view set and add one view to the set.

vSet = imageviewset;
vSet = addView(vSet,1,'Features',featuresPrev,'Points',pointsPrev);

% Compute features and matches for the rest of the images.

for i = 2:numel(images.Files)
  I = im2gray(readimage(images, i));
  points = detectSURFFeatures(I);
  [features, points] = extractFeatures(I,points);
  vSet = addView(vSet,i,'Features',features,'Points',points);
  pairsIdx = matchFeatures(featuresPrev,features);
  vSet = addConnection(vSet,i-1,i,'Matches',pairsIdx);
  featuresPrev = features;
end

% Find point tracks across viewwplos in the image view set.

tracks = findTracks(vSet);
G = createPoseGraph(vSet);