function mergedSequence = mergeSequenceOfImages(imageSequences, imagesWithFeatures, cameraParams)
% mergedSequence = mergeSequenceOfImages(imageSequences, imagesWithFeatures, cameraParams)
% - This function merges multiple image sequences into a single sequence.
% - It iterates over the sequences, attempting to merge them with the 
%   sequence having the largest image count.
% - The merging is performed by calling the 'mergeWith' method of the 
%   'ImageSequence' class.
% - The merging continues until no more successful merges can be performed.

    % Extract the image sequence with the longest sequence
    [curImageSequence, maxIndex] = getLargestImageSequence(imageSequences);
    imageSequences(maxIndex) = [];

     % Initialize the matrix to keep track of already failed pairs
    alreadyFailedPairs = zeros(numel(imagesWithFeatures), numel(imagesWithFeatures));
    
    % Count the number of sequences and calculate the maximum number of comparisons
    numSequences = numel(imageSequences);
    maxNumComparisons = numSequences * (numSequences - 1) / 2;
    curComparisons = 1;

    % Create progress bar
    progress = waitbar(0, sprintf("Trying to resort images (Step 3/5)"));

    % Iterate over all sequences and attempt to merge them with the largest sequence
    successful = 1;
    while successful && numel(imageSequences) >= 1
        fprintf("Starting\n")
        for i = 1:numel(imageSequences)
            % Merge the current image sequence with the i-th sequence
            [mergedImageSequence, successful, alreadyFailedPairs] = ... 
                curImageSequence.mergeWith(imageSequences{i}, imagesWithFeatures, ...
                cameraParams, alreadyFailedPairs);
            if successful
                % Merge was successful, update variables and progress
                fprintf("Successfully merged\n");
                imageSequences(i) = [];
                curImageSequence = mergedImageSequence;
                waitbar(curComparisons/(maxNumComparisons), progress);
                curComparisons = curComparisons + 1;
                fprintf("Start again!\n")
                break;
            end
            waitbar(curComparisons/(maxNumComparisons), progress);
            curComparisons = curComparisons + 1;
        end
    end

    % Update the progress bar
    waitbar(1, progress);

    % Store the merged image sequence as the result
    mergedSequence = curImageSequence;
    
    fprintf('\nResulting sequence of images from merging:\n');
    disp(curImageSequence.indices);

    % Close the progress bar
    close(progress);
end

