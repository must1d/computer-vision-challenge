function [points, idx, C] = applyClustering(ptCloud, K, showProgressBar)
% [points, idx, C] = applyClustering(ptCloud, showProgressBar) 
% Performs clustering on a point cloud.
    
    "Clustering received:"
    K = int32(round(K))

    % Extract the points from the point cloud
    points = ptCloud.Location;

    % Create a KDTreeSearcher object for efficient nearest neighbor search
    Mdl = KDTreeSearcher(points);

    % Clean up the point cloud by removing outliers
    points = cleanUpPtCloudForClustering(Mdl, points, 0.5);

    % Get the number of points
    N = length(points);

    % Define the range of possible values for the number of clusters (k)
    N_K = 10;
    possible_k = int32(linspace(round(N / 100), round(N/10), N_K));
    fprintf("%d number of possible k for clustering.\n", length(possible_k))

    % Find the optimal number of clusters using the "extractBestK" function
    %optimalK = extractBestK(points, possible_k, showProgressBar);

    % Perform k-means clustering
    [idx, C] = kmeans(points, K);%kmeans(points,optimalK);
end

