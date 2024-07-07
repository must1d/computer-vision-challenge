function cameraPositions = loadCameraPositionsFromImagesTxt(pathToImagesTxt)
% cameraPositions = loadCameraPositionsFromImagesTxt(pathToImagesTxt)
% - This function loads camera positions from an images.txt file.

    % Read the data from the images.txt file
    fileID = fopen(pathToImagesTxt, 'r');
    formatSpec = '%f %f %f %f %f %[^\n]';
    data = textscan(fileID, formatSpec, 'Delimiter', ' ', 'MultipleDelimsAsOne', true);
    fclose(fileID);

    % The data in the file is expected to have the following format:
    % #   IMAGE_ID, TX, TY, TZ, CAMERA_ID, NAME
    % #   POINTS2D[] as (X, Y, POINT3D_ID)
    
    % Sort the data based on the first column
    [~, idx] = sort(data{1});
    sortedData = cellfun(@(x) x(idx), data, 'UniformOutput', false);
    
    % Extract the X,Y,Z values from the sorted data
    cameraPositions = [sortedData{2}, sortedData{3}, sortedData{4}]';
end
