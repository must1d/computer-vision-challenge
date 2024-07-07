function optimalK = extractBestK(points, possible_k, showProgressBar)
% optimalK = extractBestK(points, possible_k, showProgressBar) 
% - Finds the optimal number of clusters (k) using the silhouette method.

    % extract_best_k Method: This method measures how close each point in
    % one cluster is to the points in the neighboring clusters. The 
    % silhouette value is a measure of how similar an object is to its own
    % cluster compared to other clusters. The silhouette ranges from -1 to 1, 
    % where a high value indicates that the object is well matched to its own cluster 
    % and poorly matched to neighboring clusters. If most objects have a high value, then the
    % clustering configuration is appropriate. If many points have a low or negative value, 
    % then the clustering configuration may have too many or too few clusters en.wikipedia.org.

    % Initialize variables
    sil = []; % Silhouette values for each tested k
    numPossibleK = length(possible_k);
    testedK = 0;
    if showProgressBar
        progress = waitbar(0, "Placing Boxes...");
    end

    % Iterate over each possible k value
    for k = possible_k
        if k > 0
            % Perform k-means clustering with the current k value
            [idx, ~] = kmeans(points, k);
            % Calculate the average silhouette value for the clustering result
            sil(end+1) = mean(silhouette(points, idx));
            if showProgressBar
                testedK = testedK + 1;
                waitbar(testedK / numPossibleK, progress);
            end
        else
            fprintf("k not bigger than 0\n")
        end
    end
    % Find the optimal k value based on the maximum silhouette value
    figure;
    plot(possible_k, sil)
    if length(sil) > 1
        [~, optimalK] = max(sil);
        optimalK = possible_k(optimalK); % Adjusting for the fact that K starts from 2
    else
        optimalK = length(points(1,:))
    end

    if showProgressBar
        close(progress);
    end
end

