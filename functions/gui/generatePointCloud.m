function generatePointCloud(src, graph, generateButton)
% generatePointCloud(src, graph, generateButton)
% - This function is called when the "Generate Point Cloud" button is 
% clicked in a GUI.
% - It generates a point cloud model from loaded images and camera parameters.
% - The resulting model is stored in the user data of the figure, and a 
% visualization of the model is displayed.

    % Get the figure that contains the button
    fig = ancestor(src,"figure","toplevel");

    % Check if camera parameters and camera positions are loaded in the 
    % figure user data
    if (isempty(fig.UserData.CameraParams) || isempty(fig.UserData.CameraPositions))
        % Display a warning alert if camera parameters or positions are missing
        uialert(fig, 'Please first load the camera parameters!', 'No Camera Parameters', ...
            'Icon', 'warning');
        return;
    elseif (isempty(fig.UserData.Images))
        % Display a warning alert if images are missing
        uialert(fig, 'Please first load Images!', 'No Images', ...
            'Icon', 'warning');
        return;
    end

    % Retrieve the loaded images, camera parameters, and camera positions 
    images = fig.UserData.Images;
    cameraParams = fig.UserData.CameraParams;
    cameraPositions = fig.UserData.CameraPositions;

    % Start creating the point cloud with the "pcFromStructureFromMotion" 
    % function
    fprintf('\nCreating pointcloud...\n');
    tic
    [sparsePtCloud, ~] = pcFromStructureFromMotion(images, cameraParams, cameraPositions, fig);
    toc
    
    % Create a progress bar for the postprocessing steps
    progress = waitbar(0, "Postprocessing (Step 5/5)");

    % Start extracting the walls
    fprintf('\nExtract walls...\n');
    tic
    % Extract floor and wall projections from the point cloud using the
    % "getProjectionsOfRoom" function.
    [floor, wall1, wall2] = getProjectionsOfRoom(sparsePtCloud);

    % Update the progress bar
    waitbar(.33, progress);
    
    % Extract the shape of the floor from the floor projection with the
    % "extractFloorShape" function
    floorShape = extractFloorShape(floor, fig.UserData.optimizableParams.ShrinkFactor);

    % Update the progress bar
    waitbar(.66, progress);

    % Extract the y-coordinates of the walls with
    % "extractYCoordinatesOfWall" function.
    [yFloor1, yCeiling1] = extractYCoordinatesOfWall(wall1);
    [yFloor2, yCeiling2] = extractYCoordinatesOfWall(wall2);
    
    % Calculate the average y-coordinates of the walls
    yFloor = (yFloor1 + yFloor2) / 2;
    yCeiling = (yCeiling1 + yCeiling2) / 2;
    toc
        
    % Start clustering
    fprintf('\nApply clustering...\n');

    tic
    % Filter points close to the wall in the point cloud with
    % "filterPointsCloseToWall" function
    sparsePtCloud = filterPointsCloseToWall(floorShape, sparsePtCloud);
    showProgressBar = 0;

    % Apply clustering to the filtered point cloud "applyClustering"
    % function.
    [points, idx, ~] = applyClustering(filterPointsCloseToWall(0.8 * floorShape, sparsePtCloud),fig.UserData.optimizableParams.K, showProgressBar);
    toc

    % Create a model structure to store the extracted model components and
    % store it in the user data
    fig.UserData.model = struct('floorShape', floorShape, 'yFloor', yFloor, ...
        'yCeiling', yCeiling, 'points', points, 'idx', idx);
    
    % Visualize the current state of the mode
    visualize(fig.UserData, graph);

    % Update the progress bar
    waitbar(1, progress);

    % Close the progress bar
    close(progress);

    % Modify the background color and text of the button to indicate that 
    % the point cloud is created
    generateButton.BackgroundColor = [0 1 0]; % Set background color to green
    generateButton.Text = 'Create Point Cloud Again';
end
 
