function plotClusters(points, idx, graph)
% plotClusters(points, idx, graph) 
% - Plots a box around the clusters defined by the indices and the corresponding points.

    % Determine the number of clusters
    numClusters = max(idx);

    % Iterate over each cluster
    for i = 1:numClusters
        % Extract the points belonging to the current cluster
        cluster_points = double(points(idx==i, :));

        % Check if the cluster has sufficient points to form a box
        if size(cluster_points, 1) > 3
            % Find the minimum and maximum points in the cluster
            min_point = min(cluster_points);
            max_point = max(cluster_points);

            % Define the vertices of the box
            vertices = [min_point(1), min_point(2), min_point(3);
                        max_point(1), min_point(2), min_point(3);
                        max_point(1), max_point(2), min_point(3);
                        min_point(1), max_point(2), min_point(3);
                        min_point(1), min_point(2), max_point(3);
                        max_point(1), min_point(2), max_point(3);
                        max_point(1), max_point(2), max_point(3);
                        min_point(1), max_point(2), max_point(3)];

            % Define the faces of the box
            faces = [1 2 3 4; % bottom face
                     5 6 7 8; % top face
                     1 2 6 5; % front face
                     4 3 7 8; % back face
                     1 4 8 5; % left face
                     2 3 7 6]; % right face

            % Plot the box with transparent faces
            patch(graph, 'Vertices',vertices,'Faces',faces,'FaceAlpha',1, 'FaceColor', 'w','EdgeColor','k')

            % Alternatively, you can use alphaShape to plot a shape enclosing the points
            % aShape = alphaShape(cluster_points, 5);
            % h = plot(aShape);
            % h.FaceColor = 'w';
        end
    end
end

