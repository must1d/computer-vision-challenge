function ptCloud = filterPointsCloseToWall(floorShape, ptCloud)
% ptCloud = filterPointsCloseToWall(floorShape, ptCloud)
% - Filters points in a point cloud that are close to the walls of the floor
%   shape.

    % Extract point cloud data
    points = ptCloud.Location;
    color = ptCloud.Color;

    % Extract coordinates of floor shape polygon
    xPoints = points(:, 1);
    yPoints = points(:, 2);
    xPolygon = floorShape(:, 1);
    yPolygon = floorShape(:, 2);
    
    % Use inpolygon to determine if points are inside the floor shape polygon
    isInside = inpolygon(xPoints, yPoints, xPolygon, yPolygon);
    
    % Filter the points matrix based on the isInside logical array
    filteredPoints = points(isInside, :);
    filteredColor = color(isInside, :);

    % Create a new point cloud with the filtered points and color
    ptCloud = pointCloud(filteredPoints, 'Color', filteredColor);
end

