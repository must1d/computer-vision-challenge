function [yFloor, yCeiling]  = extractYCoordinatesOfWall(wall)
% [yFloor, yCeiling]  = extractYCoordinatesOfWall(wall) 
% - Extracts the minimum and maximum y-coordinates of a wall.

    % Remove low density points
    epsilon = 0.1; % Distance threshold to define neighborhood
    minPts = 5;   % Minimum number of points to form a dense region

    % Apply DBSCAN clustering to identify dense regions
    [idx, ~] = dbscan(wall, epsilon, minPts);

    % Find noise points identified by DBSCAN
    noise_indices = find(idx == -1);
    
    % Remove noise points from the wall
    denoised_wall = wall;
    denoised_wall(noise_indices, :) = [];
    
    % Extract the minimum and maximum y-coordinates from the denoised wall
    yFloor = min(denoised_wall(:,2));
    yCeiling = max(denoised_wall(:,2));
end
