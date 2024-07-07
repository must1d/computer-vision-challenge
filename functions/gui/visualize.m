function visualize(userData, graph)
% visualize(userData, graph)
% - This function plots the model according to the user data into a 
% specified graph.
% If the userData.plotPoints flag is false, the graph is cleared and the 
% current point cloud is plotted.
% If the userData.plotPoints flag is true, the graph is reset and the floor,
% walls, and clusters are plotted.
    
    % Check the plotPoints flag
    if (userData.plotPoints == false) 
        % Clear the graph
        cla(graph);
        % Plot the current point cloud
        pcshow(userData.curPtCloud, 'Parent', graph, 'MarkerSize', 50);
    else
        % Reset the graph and clear its content
        cla(graph);
        pcshow(userData.curPtCloud, 'Parent', graph, 'MarkerSize', 50);
        cla(graph, 'reset');
        reset(graph);
        delete(graph.Children);

        % Plot the floor and walls with the "plotFloorAndWalls" function
        [xLim, yLim, zLim] = plotFloorAndWalls(userData.model.floorShape, userData.model.yFloor, ...
            userData.model.yCeiling, graph);
        
        % Plot the clusters using the plotClusters function
        plotClusters(userData.model.points, userData.model.idx, graph);

        % Set the graph parameters
        graph.Visible = 'off';
        rotate3d(graph);
        xlim(graph, xLim);
        ylim(graph, yLim);
        zlim(graph, zLim);
        graph.DataAspectRatio = [1 1 1];

        hold(graph, 'on');
    end
end
