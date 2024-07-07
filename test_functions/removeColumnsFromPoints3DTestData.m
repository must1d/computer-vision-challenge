function modifiedData = removeColumnsFromPoints3DTestData(inputFile)
    % Open the file
    fileID = fopen(inputFile, 'r');
    
    % Skip the first 3 lines
    for i = 1:3
        fgetl(fileID);
    end
    
    % Read the remaining data
    data = textscan(fileID, '%f %f %f %f %f %f %f %*f %*[^\n]', 'Delimiter', ' ');
    
    % Close the file
    fclose(fileID);
    
    % Convert the data to a matrix
    dataMatrix = cell2mat(data);
    
    % Extract columns 2 to 7
    modifiedData = dataMatrix(:, 2:7);
end

