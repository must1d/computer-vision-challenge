function [imagePair, successful] = relativePoseEstimation(imagesWithFeatures, index1, index2, cameraParams)
% [imagePair, successful] = relativePoseEstimation(imagesWithFeatures, index1, index2, cameraParams)
% - This function performs relative pose estimation between two images.
% - It matches features between the images, estimates the essential matrix,
% and computes the relative pose.

% Set the max. number of trials and the max. distance for RANSAC
maxNumTrialsForRansac = 10000;
maxDistanceForRansac = 0.1;

% Extract images together with features from cell array
imageWithFeature1 = imagesWithFeatures{index1};
imageWithFeature2 = imagesWithFeatures{index2};

% Perform feature matching
indexPairs = matchFeatures(imageWithFeature1.featureDescriptors, imageWithFeature2.featureDescriptors, MaxRatio=0.7, Unique=true);
numMatches = length(indexPairs(:,1));
fprintf('\t%d matched features found for image %d and %d. Computing essential matrix...\n', numMatches, index1, index2);

matchedPoints1 = imageWithFeature1.featurePoints(indexPairs(:, 1));
matchedPoints2 = imageWithFeature2.featurePoints(indexPairs(:, 2));

% Estimate the essential matrix
[E, inliers, status] = estimateEssentialMatrix(matchedPoints1, matchedPoints2, ...
    cameraParams, ...
    'MaxNumTrials', maxNumTrialsForRansac, ...
    'MaxDistance', maxDistanceForRansac ...
    );

% Estimate relative pose
% inlierPercentage = sum(inliers) / length(inliers);
if sum(inliers) < 20
    status = 2;
else 
    [relativePose, validPointsFraction]  = estrelpose(E, cameraParams.Intrinsics, matchedPoints1(inliers), matchedPoints2(inliers));
end

imagePair = ImagePair();

% Check result based on the status code of essential matrix estimation and
% relative pose estimation
if status == 0 && validPointsFraction >= 0.9
    fprintf('\t\tEssential matrix computation was successfull with %d inlier points.\n', sum(inliers));
    imagePair.imageIndex1 = index1;
    imagePair.imageIndex2 = index2;
    imagePair.matchedPoints1 = matchedPoints1;
    imagePair.matchedPoints2 = matchedPoints2;
    imagePair.indexPairs = indexPairs;
    imagePair.essentialMatrix = E;
    imagePair.relativePose = relativePose;
    imagePair.inlierIndices = inliers;
    successful = 1;
elseif status == 1
    fprintf('\t\tStaus Code 1: not enough matched points\n');
    successful = 0;
elseif status == 2
    fprintf('\t\tStaus Code 2: not enough inliers; num inliers = %d\n', sum(inliers));
    successful = 0;
else
    fprintf('\t\tEstimation of (R, T) failed; fraction of valid points = %.2f%%\n', validPointsFraction);
    successful = 0;
end

end

