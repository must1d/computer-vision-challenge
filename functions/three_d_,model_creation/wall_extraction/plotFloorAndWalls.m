function [xLim, yLim, zLim] = plotFloorAndWalls(floorShape, yFloor, yCeiling, graph)
% [xLim, yLim, zLim] = plotFloorAndWalls(floorShape, yFloor, yCeiling, graph)
% - Plots the floor and walls of a room in a 3D graph.    

    % Determine the number of points in the floor shape
    num_points = size(floorShape, 1);

    % Create 3D coordinates for the floor and ceiling
    floor_3D = [floorShape, yFloor * ones(num_points, 1)];
    ceiling_3D = [floorShape, yCeiling * ones(num_points, 1)];
    
    % Determine the x-axis limits
    xLim = [min(floorShape(:,1)), max(floorShape(:,1))];
    xDistance = xLim(2) - xLim(1);
    xLim = [xLim(1) - 0.5*xDistance, xLim(2) + 0.5*xDistance];

    % Determine the y-axis limits
    yLim = [min(floorShape(:,2)), max(floorShape(:,2))];
    yDistance = yLim(2) - yLim(1);
    yLim = [yLim(1) - 0.5*yDistance, yLim(2) + 0.5*yDistance];

    % Determine the z-axis limits
    zDistance = yCeiling - yFloor;
    zLim = [yFloor - 0.5*zDistance, yCeiling + 0.5*zDistance];
    
    % Plot the floor as a filled polygon
    fill3(graph ,floor_3D(:,1), floor_3D(:,2), floor_3D(:,3), 'w', 'FaceAlpha', 1);
    
    % Plot the walls as polygon patches
    for i = 1:num_points-1
        vertices = [floor_3D(i,:); ceiling_3D(i,:); ceiling_3D(i+1,:); floor_3D(i+1,:); floor_3D(i,:)];
        faces = [1 2 3 4];
        patch(graph, 'Vertices', vertices, 'Faces', faces, 'FaceColor', 'w', 'FaceAlpha', 0.5);
    end
end
