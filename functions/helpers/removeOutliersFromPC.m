function pc = removeOutliersFromPC(pc, distance, pointCount)
% pc = removeOutliersFromPC(pc, distance, pointCount)
% - This function removes outliers from a point cloud based on distance and
%   point count thresholds.

    % Check the number of input arguments and assign default values if 
    % necessary
    if nargin < 3
        pointCount = 30;
    end

    if nargin < 2
       distance = 4; 
    end

    % Segment the point cloud based on distance
    [labels, numClusters] = pcsegdist(pc, distance);

    % Initialize an empty array to store the indices of inlier points
    inlier_idx = [];

    % Count the number of points in each cluster
    for k = 1:numClusters
        count(k) = sum(labels==k);
    end

    % Find the labels of clusters with more points than the point count
    % threshold
    inlier_labels = find(count>pointCount);

     % Iterate over the labels and check if they are included in the
     % inlier_labels
    for l = 1:length(labels)
        if ismember(l, inlier_labels)
            inlier_idx = [inlier_idx; find(labels==l)];
        end
    end

    % Select the inlier points from the original point cloud using the 
    % inlier indices
    pc = select(pc, inlier_idx);

end