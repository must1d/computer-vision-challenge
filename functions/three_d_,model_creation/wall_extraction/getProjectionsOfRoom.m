function [floor, wall1, wall2] = getProjectionsOfRoom(roomPtCloud)
% [floor, wall1, wall2] = getProjectionsOfRoom(roomPtCloud)
% - Extracts the projections of a 3D room point cloud onto the floor, 
%   wall1, and wall2 planes, which are the XY, YZ and XZ planes.

    % Extract the x-y coordinates of the room points as the floor projection
    floor = double(roomPtCloud.Location(:,[1,2]));

    % Extract the y-z coordinates of the room points as wall1 projection
    wall1 = double(roomPtCloud.Location(:,[2,3]));

    % Extract the x-z coordinates of the room points as wall2 projection
    wall2 = double(roomPtCloud.Location(:,[1,3]));
end

