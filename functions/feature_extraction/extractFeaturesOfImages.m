function imagesWithFeatures = extractFeaturesOfImages(images, sift)
% imagesWithFeatures = extractFeaturesOfImages(images)
% - This function extracts features from a set of input images using the 
%   SURF algorithm.
% - The resulting features are stored in a cell array of ImageWithFeatures 
%   objects.

    % Get the number of input images and initialize a cell array to store
    % the "ImageWithFeatures" objects
    numImages = numel(images);
    imagesWithFeatures = cell(numImages, 1);
    
    % Create a progress bar
    progress = waitbar(0, sprintf("Extracting Features Of %d Images (Step 1/5)", numImages));
    
    % Loop over each input image
    for i=1:numImages
        % Create a new ImageWithFeatures object
        imageWithFeatures = ImageWithFeatures();

        % Assign the images to the ImageWithFeatures object
        imageWithFeatures.image = images{i};

        % Store the imageWithFeatures object in the cell array
        imagesWithFeatures{i} = imageWithFeatures;
    end

    % Clear the input images from memory
    clear images;
    
    % Loop over each imageWithFeatures object
    for i=1:numImages
        % Convert images to gray scale
        imageWithFeatures = imagesWithFeatures{i};
        img = rgb2gray(imageWithFeatures.image);

        % Detect and extract features using SURF
        if (~sift)
            features = detectSURFFeatures(img, NumOctaves=8);
        else
            features = detectSIFTFeatures(img);
        end
        [descriptors, points] = extractFeatures(img, features, Upright=true);

        % Store the extracted feature points and descriptors
        imageWithFeatures.featurePoints = points;
        imageWithFeatures.featureDescriptors = descriptors;

        % Update the imageWithFeatures object in the cell array
        imagesWithFeatures{i} = imageWithFeatures;
        
        % Update the progress bar
        waitbar(i / numImages, progress);

        fprintf('\tFound %d features for image %d\n', points.Count, i);
    end
    % Close the progress bar
    close(progress);

end
