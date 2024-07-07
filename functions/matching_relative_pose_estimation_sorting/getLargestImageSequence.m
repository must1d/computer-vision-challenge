function [largestSequence, index] = getLargestImageSequence(imageSequences)
% [largestSequence, index] = getLargestImageSequence(imageSequences)
% - This function finds the largest image sequence within a cell array of 
%   image sequences.
% - It iterates over the cell array and compares the lengths of the image 
%   sequences to identify the largest one.

    % Initialize the index, largestSequence and maxLength variables
    index = 0;
    largestSequence = [];
    maxLength = 0;
    
    % Iterate over the cell array of image sequences
    for i = 1:numel(imageSequences)
        % Get the length of the current image sequence
        currentLength = length(imageSequences{i}.indices);
        
        % Check if the current length is greater than the maximum length
        if currentLength > maxLength
            % Update the maximum length and store the largest image sequence
            maxLength = currentLength;
            largestSequence = imageSequences{i};
            index = i;
        end
    end
end

