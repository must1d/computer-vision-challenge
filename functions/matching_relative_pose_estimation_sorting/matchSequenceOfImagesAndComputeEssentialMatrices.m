function imageSequence = matchSequenceOfImagesAndComputeEssentialMatrices(imagesWithFeatures, cameraParams)
% imageSequence = matchSequenceOfImagesAndComputeEssentialMatrices(imagesWithFeatures, cameraParams)
% - This function matches a sequence of images and computes essential matrices.
% - It iterates over the images and performs relative pose estimation to 
%   estimates the essential matrices.
% - It then creates image sequences based on the success of the relative 
%   pose estimation. Finally, it merges the image sequences into a single 
%   image sequence. 

    % Initialize the imageSequences cell array with the first image sequence
    imageSequences = {ImageSequence(1)};
    curSequenceIndex = 1;
    
    warning('off');
    
    fprintf('\tInitialized sequence 1 with image 1.\n');
    
    numImages = length(imagesWithFeatures);
    % Create progress bar
    progress = waitbar(0, sprintf("Matching %d Images (Step 2/5)", numImages));

    % Iterate over the images
    for i = 1:numImages-1
        % Perform relative pose estimation between current image and the next one
        [imagePair, successful] = relativePoseEstimation(imagesWithFeatures, i, i+1, cameraParams);
        if successful
            % If rel. pose est. was successful, add the image pair to the current sequence
            fprintf(['\t\tRelative pose estimation was successful for images %d and %d. ' ...
                'Adding image %d to current sequence %d.\n'], i, i+1, i+1, curSequenceIndex)
            imageSequences{curSequenceIndex} = imageSequences{curSequenceIndex}.add(i+1, imagePair);
        else
            % If not, create a new sequence with the current image
            curSequenceIndex = curSequenceIndex + 1;
            fprintf(['\t\tUnsuccessful relative pose estimation for images %d and %d. ' ...
                'Creating new sequence nr. %d with image %d.\n'], i, i+1, curSequenceIndex, i+1)
            imageSequences{curSequenceIndex} = ImageSequence(i+1);
        end
        waitbar(i/(numImages-1), progress);
    end

    % Finish progress bar
    waitbar(1, progress);
    fprintf("Resulting subsequences of images:\n")
    
    % Display the resulting subsequences of images
    for j = 1:numel(imageSequences)
        display(imageSequences{j}.indices)
    end

    % Close the progress bar
    close(progress);

    % Merge the image sequences into a single image sequence
    imageSequence = mergeSequenceOfImages(imageSequences, imagesWithFeatures, cameraParams);
    
    warning('on');
end

