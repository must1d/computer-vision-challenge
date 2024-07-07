function output_txt = pointSelectedCallback(event, graph)
    fig = ancestor(graph, 'figure');

    output_txt = "";

    pos = event.Position;

    fig.UserData.pointsForDistances

    if isempty(fig.UserData.pointsForDistances.point1)
        disp("Point 1")
        if ~isempty(fig.UserData.pointsForDistances.linePlot)
            % delete(fig.UserData.pointsForDistances.linePlot);
            % delete(fig.UserData.pointsForDistances.textPlot);
        end
        fig.UserData.pointsForDistances.point1 = pos;
    elseif isempty(fig.UserData.pointsForDistances.point2)
        disp("Point 2")
        % Second point selected
        fig.UserData.pointsForDistances.point2 = pos;

        % Compute the distance between the two points
        distance = norm(fig.UserData.pointsForDistances.point2 - fig.UserData.pointsForDistances.point1);

        x1 = fig.UserData.pointsForDistances.point1(1);
        y1 = fig.UserData.pointsForDistances.point1(2);
        z1 = fig.UserData.pointsForDistances.point1(3);

        x2 = fig.UserData.pointsForDistances.point2(1);
        y2 = fig.UserData.pointsForDistances.point2(2);
        z2 = fig.UserData.pointsForDistances.point2(3);
        
        midpoint_x = (x1 + x2) / 2;
        midpoint_y = (y1 + y2) / 2;
        midpoint_z = (z1 + z2) / 2 + 1;

        distanceText = sprintf('%.2f m', distance);
        
        fig.UserData.pointsForDistances.linePlot = plot3(graph, [x1, x2], [y1, y2], [z1, z2], 'b--', 'LineWidth',3);
        fig.UserData.pointsForDistances.textPlot = text(graph, midpoint_x, midpoint_y, midpoint_z, distanceText);
        fig.UserData.pointsForDistances.textPlot.FontSize = 20;
        fig.UserData.pointsForDistances.textPlot.FontWeight = 'bold';
        
        fig.UserData.pointsForDistances.point1 = [];
        fig.UserData.pointsForDistances.point2 = [];
    end
end
