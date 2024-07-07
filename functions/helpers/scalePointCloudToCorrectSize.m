function ptCloud = scalePointCloudToCorrectSize(ptCloud, cameraPositionsFromSFM, relevantCameraPositions)
% ptCloud = scalePointCloudToCorrectSize(ptCloud, cameraPositionsFromSFM, relevantCameraPositions)
% - This function scales a point cloud to the correct size based on the mean
% distances between camera positions from structure-from-motion (SFM) and 
% the given camera positions.

    % Calculate the mean distance between camera positions from SFM
    meanDistanceFromSFM = mean(pdist(cameraPositionsFromSFM'));

    % Calculate the mean distance between given camera positions
    meanDistanceFromGiven = mean(pdist(relevantCameraPositions'));

    % Calculate the scaling factor
    scalingFactor = meanDistanceFromGiven / meanDistanceFromSFM;
    fprintf('Scaling point cloud with factor %d\n', scalingFactor);

    % Extract the points and colors from the point cloud
    points = ptCloud.Location;
    colors = ptCloud.Color;

    % Scale the points by the scaling factor
    points = scalingFactor * points;
    
    % Create a new point cloud with the scaled points and original colors
    ptCloud = pointCloud(points, 'Color', colors);
end

