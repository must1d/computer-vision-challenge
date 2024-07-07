function [ptCloud] = loadTestPointCloud(path)

    data = removeColumnsFromPoints3DTestData(path);
    
    % Extract the x, y, and z values into a matrix
    x = data(:, 1);
    y = data(:, 2);
    z = data(:, 3);
    r = data(:, 4) / 255;  % Scale RGB values to [0, 1]
    g = data(:, 5) / 255;
    b = data(:, 6) / 255;
    
    % Create a color point cloud object
    ptCloud = pointCloud([x, y, z], 'Color', [r, g, b]);
    
    % Set the threshold distance for outlier removal
    thresholdDistance = 0.1;  % Adjust this value as per your requirements
    
    % Remove outliers from the point cloud
    ptCloud = pcdenoise(ptCloud, 'Threshold', thresholdDistance);
end

