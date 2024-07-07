function addParamsPushed(src, paramsButton)
% addParamsPushed(src, paramsButton)
% - This function is called when the "Add Parameters" button 
% is pushed.
% - It loads camera parameters and camera positions from a folder 
% selected by the user.
    
    % Get the figure that contains the button
    fig = ancestor(src,"figure","toplevel");    

    % Prompt the user to select a folder containing camera parameters
    folder = uigetdir("..", "Select Folder containing the Camera Parameters");

    % Construct the file path for the camera parameters
    cameraParamsPath = fullfile(folder, 'cameras.txt');

    % Load the camera parameters from the specified file with "loadCameraParams"
    % function
    cameraParams = loadCameraParams(cameraParamsPath);
    fprintf('Loaded camera parameters.\n')
    disp(cameraParams);

    % Construct the file path for the camera positions
    imagesTxtPath = fullfile(folder, 'images.txt');

    % Load the camera positions from the specified file with "loadCameraPositionsFromImagesTxt"
    % function
    cameraPositions = loadCameraPositionsFromImagesTxt(imagesTxtPath);
    fprintf('Loaded camera positions.\n')
    disp(cameraPositions);

    % Store the loaded camera parameters and positions inside the user data.
    fig.UserData.CameraParams = cameraParams;
    fig.UserData.CameraPositions = cameraPositions;

    % Change the background color and text of the button to indicate that
    % the parameters are loaded.
    paramsButton.BackgroundColor = [0 1 0];
    paramsButton.Text = 'Load Other Parameters';
end
