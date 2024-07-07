function userData = updateModel(userData, updatePtCloud)
% userData = updateModel(userData, updatePtCloud)
% - This function updates all stored parameters in the userData structure 
% after something has been changed.

    % Check updatePtCloud flag
    if updatePtCloud
        % Remove outliers from the original point cloud based on the 
        % specified distance and point count thresholds with the
        % "removeOutliersFromPC" function
        sparsePtCloud = removeOutliersFromPC(userData.ogPtCloud, ...
            userData.optimizableParams.distance, userData.optimizableParams.PointCount);

        % Rotate the sparse point cloud based on the camera positions from 
        % structure-from-motion with the "rotatePointCloud" function. 
        sparsePtCloud = rotatePointCloud(sparsePtCloud, userData.CameraPositionsFromSFM);

        % Update the current point cloud
        userData.curPtCloud = sparsePtCloud;
    else
        % If updatePtCloud is false, use the current point cloud stored in 
        % the user data
        sparsePtCloud = userData.curPtCloud;
    end

    % Get the floor and wall projections
    [floor, wall1, wall2] = getProjectionsOfRoom(sparsePtCloud);

    % Extract the floor shape from the floor projection, based on the specified shrink factor
    floorShape = extractFloorShape(floor, userData.optimizableParams.ShrinkFactor);

    % Extract the y-coordinates of wall projections
    [yFloor1, yCeiling1] = extractYCoordinatesOfWall(wall1);
    [yFloor2, yCeiling2] = extractYCoordinatesOfWall(wall2);

    % Calculate the average Y-coordinates of the walls
    yFloor = (yFloor1 + yFloor2) / 2;
    yCeiling = (yCeiling1 + yCeiling2) / 2;
    
    % Remove points close to the wall
    filteredSparsePtCloud = filterPointsCloseToWall(floorShape, sparsePtCloud);

    % Apply clustering to the filtered point cloud
    showProgressBar = 1;
    [points, idx, ~] = applyClustering(filterPointsCloseToWall(0.8 * floorShape, filteredSparsePtCloud),userData.optimizableParams.K, showProgressBar);

    % Update the model structure
    userData.model = struct('floorShape', floorShape, 'yFloor', yFloor, ...
        'yCeiling', yCeiling, 'points', points, 'idx', idx);
end

