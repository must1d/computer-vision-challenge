function camPositions = extractCameraPositionsFromViewSet(viewSet)
% camPositions = extractCameraPositionsFromViewSet(viewSet)
% - This function extracts camera positions from a viewSet object.
% - It retrieves the absolute poses and the translation vectors from the 
%   viewSet.

    % Retrieve the camera poses from the viewSet
    camPoses = poses(viewSet);

    % Extract the absolute poses from the camera poses
    absolutePoses = camPoses.AbsolutePose;

    % Initialize a matrix to store the camera positions
    camPositions = zeros(3, numel(absolutePoses));

    % Loop over each pose
    for i = 1:numel(absolutePoses)
        % Extract the translation vector from the absolute pose
        camPositions(:,i) = absolutePoses(i).Translation;
    end
    % Store the camera positions
    camPositions = [camPositions(1,:); camPositions(3,:); -camPositions(2,:)];
end
