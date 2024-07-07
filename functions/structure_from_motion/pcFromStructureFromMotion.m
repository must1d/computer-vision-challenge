function [sparsePtCloud, viewSet] = pcFromStructureFromMotion(images, cameraParams, cameraPositions, fig)
% [sparsePtCloud, viewSet] = pcFromStructureFromMotion(images, cameraParams, cameraPositions, fig)
% - This function performs structure-from-motion (SFM) algorithm to generate a
% point cloud from a sequence of images. It includes feature extraction,
% image sorting, SFM, and additional processing steps.

    doPlot = 0; % Flag to control plotting of intermediate results
    
    % Load images and extract features of images
    fprintf('\nExtract features of images...\n');
    tic
    sift = fig.UserData.optimizableParams.SIFT;
    imagesWithFeatures = extractFeaturesOfImages(images, sift);
    toc
    
    % Sort images into a sequence based on matching features and inlier points
    fprintf('\nSorting images based on matching features and inlier points for essential matrix...\n');
    tic
    imageSequence = matchSequenceOfImagesAndComputeEssentialMatrices(imagesWithFeatures, cameraParams);
    toc
    
    % Perform structure-from-motion (SFM) algorithm
    fprintf("\nStructure from motion algorithm...\n");
    tic
    [sparsePtCloud, viewSet] = sfm(imagesWithFeatures, imageSequence.imagePairs, cameraParams);
    toc

    % Plot the point cloud if specified
    if doPlot
        figure;
        pcshow(sparsePtCloud);
    end

    % Extract camera positions from the SFM viewSet
    fprintf("\nExtracting camera positions...\n");
    tic
    cameraPositionsFromSFM = extractCameraPositionsFromViewSet(viewSet);
    toc

    % Store the corrected camera positions in the figure UserData
    fig.UserData.CameraPositionsFromSFM = cameraPositionsFromSFM;

    % Scale the point cloud to the correct size
    fprintf("\nScaling point cloud to correct size...\n");
    tic
    relevantCameraPositions = cameraPositions(:, imageSequence.indices);
    sparsePtCloud = scalePointCloudToCorrectSize(sparsePtCloud, cameraPositionsFromSFM, relevantCameraPositions);
    toc

    % Plot the scaled point cloud if specifie
    if doPlot
        figure;
        pcshow(sparsePtCloud);
    end

    % Assign the intermediate result (original denoised point cloud) to the
    % figure UserData
    fig.UserData.ogPtCloud = sparsePtCloud;

    % Denoise the point cloud
    fprintf("\nDenoise point cloud...\n");
    tic 
    sparsePtCloud = removeOutliersFromPC(sparsePtCloud, ...
        fig.UserData.optimizableParams.distance, fig.UserData.optimizableParams.PointCount);
    toc

    % Plot the denoised point cloud if specified
    if doPlot
        figure;
        pcshow(sparsePtCloud);
    end

    % Rotate the point cloud such that the cameras are parallel to the xy plane
    fprintf("\nRotating point cloud, such that cameras are parallel to xy plane...\n");
    tic
    sparsePtCloud = rotatePointCloud(sparsePtCloud, cameraPositionsFromSFM);
    toc

    % Plot the rotated point cloud if specified
    if doPlot
        figure;
        pcshow(sparsePtCloud);
    end

    % Assign the denoised result as the current point cloud to the figure UserData
    fig.UserData.curPtCloud = sparsePtCloud;
end