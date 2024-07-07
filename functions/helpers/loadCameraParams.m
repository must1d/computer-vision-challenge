function cameraParams = loadCameraParams(pathToParameterFile)
% cameraParams = loadCameraParams(pathToParameterFile)
% - This function loads camera parameters from a parameter file.
    
    % Read the data from the file 
    fileID = fopen(pathToParameterFile, 'r');
    data = fscanf(fileID, '%c');
    fclose(fileID);

    % Data is structered as follows
    % data = ['# Camera list with one line of data per camera:'
    %         '#   CAMERA_ID, MODEL, WIDTH, HEIGHT, PARAMS[]'
    %         '# Number of cameras: 1'
    %         '0 PINHOLE 6211 4137 3410.34 3409.98 3121.33 2067.07'];
    
    % Split the data into lines
    lines = strsplit(data, '\n');
    
    % Get the last line with the parameters
    line = strtrim(lines{4});

    % Split the line by whitespace
    cameraData = strsplit(line, ' ');

    % Extract the camera parameters
    cameraId = str2double(cameraData{1});
    model = cameraData{2};
    width = str2double(cameraData{3});
    height = str2double(cameraData{4});
    params = str2double(cameraData(5:end));
    
    % Create the camera parameters object with the given info
    cameraParams = cameraParameters('K', [params(1) 0 params(3); 0 params(2) params(4); 0 0 1], ...
    'ImageSize', [height, width]);

end