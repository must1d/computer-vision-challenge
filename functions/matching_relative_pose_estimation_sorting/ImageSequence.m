classdef ImageSequence
% ImageSequence
% - This class represents an image sequence with properties and methods to 
%   manage the sequence.
    properties
        indices;    % Indices of the images in the sequence
        imagePairs; % Pairs of images in the sequence
    end

    methods
        function obj = ImageSequence(initialImageIndex)
            % obj = ImageSequence(initialImageIndex)
            % - Constructs an ImageSequence object with an initial image 
            %   index.
            % - The indices property is initialized with the initial image 
            %   index.
            % - The imagePairs property is initialized as an empty cell 
            %   array.
            obj.indices = [initialImageIndex];
            obj.imagePairs = {};
        end

        function obj = add(obj, index, imagePair)
            % obj = add(obj, index, imagePair)
            % - Adds an image index and its corresponding image pair to the
            %   image sequence.
            % - The index is appended to the indices property.
            % - The imagePair is added to the imagePairs property.
            obj.indices = [obj.indices, index];
            obj.imagePairs{end + 1} = imagePair;
        end

        function [obj, successful, alreadyFailedPairs] = mergeWith(obj, imageSequence, imagesWithFeatures, cameraParams, alreadyFailedPairs)
            % [obj, successful, alreadyFailedPairs] = mergeWith(obj, imageSequence, imagesWithFeatures, cameraParams, alreadyFailedPairs)
            % - Merges the current image sequence with another image 
            %   sequence.
            % - It estimates the relative pose between the last image of the 
            %   current sequence and the first image of the other sequence 
            %   using feature-based relative pose estimation.

            % Get the indices of the first and last images in both sequences
            firstImageSequence2 = imageSequence.indices(1);
            lastImageSequence2 = imageSequence.indices(end);
            firstImageSequence1 = obj.indices(1);
            lastImageSequence1 = obj.indices(end);

            % Attempt relative pose estimation
            if alreadyFailedPairs(lastImageSequence1, firstImageSequence2)
                % The pair has already failed before
                successful = 0;
                fprintf('\tPair %d %d has already failed before!\n', lastImageSequence1, firstImageSequence2);
            else
                % Estimate the relative pose between the last image of the 
                % current sequence and the first image of the other sequence
                [imagePair, successful] = relativePoseEstimation(imagesWithFeatures, lastImageSequence1, firstImageSequence2, cameraParams);
            end
            if successful
                % Merge the sequences by appending the indices, imagePairs,
                % and imagePairs of the other sequence
                obj.indices = [obj.indices, imageSequence.indices];
                obj.imagePairs{end + 1} = imagePair;
                obj.imagePairs = [obj.imagePairs, imageSequence.imagePairs];
                fprintf('Successfully appended other sequence to end of this one!\n');
                disp(obj.indices);
            else
                % Mark the pair as failed and attempt relative pose estimation
                alreadyFailedPairs(lastImageSequence1, firstImageSequence2) = 1;
                if alreadyFailedPairs(lastImageSequence2, firstImageSequence1)
                    % The pair has already failed before
                    successful = 0;
                    fprintf('\tPair %d %d has already failed before!\n', lastImageSequence2, firstImageSequence1);
                else
                    % Estimate the relative pose between the last image of 
                    % the other sequence and the first image of the current sequence
                    [imagePair, successful] = relativePoseEstimation(imagesWithFeatures, lastImageSequence2, firstImageSequence1, cameraParams);
                end
                if successful
                    % Merge the sequences by prepending the indices, 
                    % imagePairs, and imagePairs of the current sequence
                    obj.indices = [imageSequence.indices, obj.indices];
                    imageSequence.imagePairs{end + 1} = imagePair;
                    obj.imagePairs = [imageSequence.imagePairs, obj.imagePairs];
                    fprintf('Successfully appended this sequence to end of other one!\n');
                    disp(obj.indices);
                else
                    % Mark the pair as failed
                    alreadyFailedPairs(lastImageSequence2, firstImageSequence1) = 1;
                end
            end
        end
    end
end

