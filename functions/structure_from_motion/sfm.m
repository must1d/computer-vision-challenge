function [ptCloud, viewSet] = sfm(imagesWithFeatures, imagePairs, cameraParams)
% [ptCloud, viewSet] = sfm(imagesWithFeatures, imagePairs, cameraParams)
%
% SFM performs Structure from Motion (SfM) algorithm to reconstruct a 3D 
% point cloud from a sequence of images.

% Create an empty viewset
vSet = imageviewset;

% Get the first image pair and corresponding features
firstImagePair = imagePairs{1};
firstImage = imagesWithFeatures{firstImagePair.imageIndex1};

% Add the first view to the viewset with an identity pose and the feature points
vSet = addView(vSet, 1, rigidtform3d, Points=firstImage.featurePoints);

% Create progress bar
progress = waitbar(0, "Structure from Motion Algorithm (Step 4/5)");

% Iterate over all image pairs
for i = 1:numel(imagePairs)
    imagePair = imagePairs{i};
    currentImage = imagesWithFeatures{imagePair.imageIndex2};

    % Obtain the absolute pose of the camera in the previous image
    prevPose = poses(vSet, i).AbsolutePose;
    
    % Calculate absolute pose of camera in next image using relative
    % transformation
    relativePose = imagePair.relativePose;
    currPose = rigidtform3d(prevPose.A * relativePose.A);
    
    % Update viewset with features and camera pose
    vSet = addView(vSet, i+1, currPose, Points=currentImage.featurePoints);

    % Add a connection between the current view and the previous view with 
    % the relative pose and matches
    vSet = addConnection(vSet, i, i+1, relativePose, Matches=imagePair.indexPairs(imagePair.inlierIndices,:));
    
    % Find tracks in the viewset
    tracks = findTracks(vSet);

    % Get camera poses from the viewset
    camPoses = poses(vSet);

    % Triangulate the 3D world points from the tracks and camera poses
    xyzPoints = triangulateMultiview(tracks, camPoses, cameraParams.Intrinsics);
    
    % Refine the 3D world points and camera poses using bundle adjustment
    [xyzPoints, camPoses, reprojectionErrors] = bundleAdjustment(xyzPoints, ...
        tracks, camPoses, cameraParams.Intrinsics, FixedViewId=1, ...
        PointsUndistorted=true);

    % Update the viewset with the refined camera poses
    vSet = updateView(vSet, camPoses);

    waitbar(i/numel(imagePairs), progress);

    fprintf("\t%d done\n", i);
end

% Flip the xyz points to correct the coordinate frame
xyzPoints = [xyzPoints(:,1), xyzPoints(:,3), -xyzPoints(:,2)];

% Retrieve the tracks from the viewset and extract colors from the corresponding images
tracks = findTracks(vSet);
colors = [];
for i=1:length(tracks)
    currPoint = tracks(i);
    pointInImage = round(currPoint.Points(1,:));
    imageId = currPoint.ViewIds(1);
    image = imagesWithFeatures{imageId}.image;
    rgbValues = double(image(pointInImage(2), pointInImage(1), :)) / 255.0;
    rgbValues = reshape(rgbValues, 1, []);
    colors = [colors; rgbValues];
end

% Select points that have reprojection errors below a certain threshold
viewSet = vSet;

goodIdx = (reprojectionErrors < 5);
ptCloud = pointCloud(xyzPoints(goodIdx,:), "Color", colors(goodIdx,:));

% Perform point cloud denoising
thresholdDistance = 0.1;
ptCloud = pcdenoise(ptCloud, 'Threshold', thresholdDistance);

% Close progress bar
close(progress);

end

