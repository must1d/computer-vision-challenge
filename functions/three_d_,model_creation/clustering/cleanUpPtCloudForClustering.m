function newPoints = cleanUpPtCloudForClustering(Mdl, points, threshold)
% newPoints = cleanUpPtCloudForClustering(Mdl, points, threshold)
% - Removes points from a point cloud that do not have nearby points.

    % Initialize variables
    count = 1;
    newPoints = zeros(size(points));

    % Iterate over each point in the input point cloud
    for i = 1:length(points)
        % Calculate the point closest to points(i,:) and calculate the 
        % difference
        p1 = points(i,:);
        closest_points_idx = knnsearch(Mdl, p1, "K", 5);
        closest_points = points(closest_points_idx, :);
        max_diff = 0.0;

        % Find the maximum difference between the closest points and p1
        for i = 1:length(closest_points)
            diff = norm(closest_points(i,:) - p1);
            if diff > max_diff
                max_diff = diff;
            end
        end

        % If the maximum difference is below the threshold, add the point 
        % to newPoints
        if (max_diff < threshold)
            newPoints(count, :) = p1;
            count = count + 1;
        end

    end
    
    % Remove excess rows and return the cleaned up points
    newPoints = newPoints(1:count-1, :);
end

