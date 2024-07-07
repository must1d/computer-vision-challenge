function ptCloud = rotatePointCloud(ptCloud, cameraPositions)
% ptCloud = rotatePointCloud(ptCloud, cameraPositions) 
% - Rotates the point cloud to align the floor with the xy plane and walls 
% with the axis using SVD.

    % Perform SVD to obtain the basis within the camera plane
    centerCamPositions = mean(cameraPositions, 2);
    [U, ~, ~] = svd(cameraPositions - centerCamPositions);
    
    % Check the determinant of U and flip the first column if necessary
    if det(U) < 0
        U(:,1) = -U(:,1);
    end
    
    % Ensure that the z-axis is not flipped upside down
    zAxis = U(:,3);
    if zAxis(3) < 0
        U(:,1) = -U(:,1);
        U(:,3) = -U(:,3);
    end
    
    % Extract data from the original point cloud
    points = ptCloud.Location;
    colors = ptCloud.Color;

    % Center the points around the origin
    origin = mean(points);
    points = points - origin;

    % Rotate the points using the obtained basis U
    points = (U' * points')';

    % now rotate point clound around z axis such that walls are axis
    % aligned
    % use floor and find many parallel and perpendicular lines

    % Perform RANSAC to fit lines in the floor points and extract the slopes
    floor = double(points(:,[1,2]));

    sampleSize = 2; % Number of points to sample per trial
    maxDistance = 0.5; % Max allowable distance for inliers

    fitLineFcn = @(points) polyfit(points(:,1),points(:,2),1); % fit function using polyfit
    evalLineFcn = @(model, points) sum((points(:, 2) - polyval(model, points(:,1))).^2,2);

    [modelRANSAC, inlierIdx] = ransac(floor,fitLineFcn,evalLineFcn, sampleSize,maxDistance);

    outlierPts = floor(~inlierIdx,:);
    slopes = [modelRANSAC(1)];

    % Fit lines using RANSAC multiple times and extract slopes
    for i = 1:7
        if length(outlierPts) <= 5
            break;
        end
        [modelRANSAC, inlierIdx] = ransac(outlierPts,fitLineFcn,evalLineFcn, sampleSize,maxDistance);
        slopes = [slopes, modelRANSAC(1)];
        outlierPts = outlierPts(~inlierIdx,:);
    end

    % Convert the slopes to angles
    angles = zeros(1, length(slopes));
    for i = 1:length(angles)
        angles(i) = atan2(slopes(i), 1) * 180 / pi;
        if angles(i) < 0
           angles(i) = angles(i) + 180;
        end
    end

    % Compare all lines with each other to identify parallel and perpendicular lines
    threshold = 7; % 10 degrees in either direction counts as (parallel | perpendicular)

    angleVsAngle = zeros(length(slopes), length(slopes));
    for i = 1:length(angles)
        angleVsAngle(i,:) = angles - angles(i);
    end
    parallels = (angleVsAngle <= (0 + threshold)) & (angleVsAngle >= (0 - threshold));
    perpendiculars = (angleVsAngle<= (90 + threshold)) & (angleVsAngle>= (90 - threshold));
    numParallelsOrPerpendiculars = sum((parallels | perpendiculars), 2);

    % Select the line with the most parallel and perpendicular lines
    [~, index] = max(numParallelsOrPerpendiculars);
    anglesOfParallelLines = angles(parallels(index,:));
    mean(anglesOfParallelLines)
    angle = pi - pi * angles(index) / 180;

    % Rotate all points in the opposite direction
    rotationMatrix = [  cos(angle)  -sin(angle) 0;
                        sin(angle)  cos(angle)  0;
                        0           0           1];

    points = (rotationMatrix * points')';
    ptCloud = pointCloud(points, 'Color', colors);
end

