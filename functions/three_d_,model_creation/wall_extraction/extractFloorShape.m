function floorShape = extractFloorShape(floor, shrinkFactor)
% floorShape = extractFloorShape(floor, shrinkFactor) 
% - Extracts the shape of the floor from a point cloud of the floor.

    % k = convhull(floor);
    % floorShape = floor(k, :);

    % Shrink the floor shape using the specified shrink factor
    boundaryIndices = boundary(floor(:, 1), floor(:, 2), shrinkFactor);
    floorShape = floor(boundaryIndices, :);

    angleThreshold = 20;
    
    % Line Types:
    %   0: vertical
    %   1: horizontal
    %   2: / -> top left or bottom right corner
    %   3: \ -> top right or bottom left corner
    lineTypes = zeros(1,length(floorShape)-1);

    
    % Determine the line type for each line segment of the floor shape
    for i = 1:length(floorShape) - 1
        currentPoint = floorShape(i,:);
        nextPoint = floorShape(i+1,:);

        deltaY = nextPoint(2) - currentPoint(2);
        deltaX = nextPoint(1) - currentPoint(1);

        angle_rad = atan2(deltaY, deltaX);
        anglesDeg = rad2deg(angle_rad);
        if anglesDeg < 0
            anglesDeg = anglesDeg + 180;
        end

        if anglesDeg <= angleThreshold || anglesDeg >= 180-angleThreshold
            lineTypes(i) = 1;
        elseif anglesDeg <= 90+angleThreshold && anglesDeg >= 90-angleThreshold
            lineTypes(i) = 0;
        elseif anglesDeg > 90+angleThreshold
            lineTypes(i) = 3;
        elseif anglesDeg < 90-angleThreshold
            lineTypes(i) = 2;
        end
    end
    
    lineTypesCopy = lineTypes;

    numPointsDeleted = 0;

    pointIndex = 0;

    % Remove consecutive horizontal or vertical lines
    for i = 1:numel(lineTypesCopy)
        % Check if the current element is 1
        index = i + numPointsDeleted;
        pointIndex = pointIndex + 1;
        if index > numel(lineTypesCopy)
            break;
        end
        if lineTypesCopy(index) == 0
            % Check the next elements for consecutive 1s
            count = 1;
            j = index + 1;
            while j <= numel(lineTypesCopy) && lineTypesCopy(j) == 0
                count = count + 1;
                j = j + 1;
            end
            numPointsDeleted = numPointsDeleted + count - 1;

            verticalPoints = floorShape(pointIndex:pointIndex+count,:);
            newXCoordinate = mean(verticalPoints(:,1));
            if pointIndex > 1
                floorShape = [
                    floorShape(1:pointIndex-1,:);
                    newXCoordinate, floorShape(pointIndex,2);
                    newXCoordinate, floorShape(pointIndex+count,2);
                    floorShape(pointIndex+count+1:end,:)
                    ];
            else
                floorShape = [
                    newXCoordinate, floorShape(pointIndex,2);
                    newXCoordinate, floorShape(pointIndex+count,2);
                    floorShape(pointIndex+count+1:end,:)
                    ];
            end
        elseif lineTypesCopy(index) == 1
            % Check the next elements for consecutive 1s
            count = 1;
            j = index + 1;
            while j <= numel(lineTypesCopy) && lineTypesCopy(j) == 1
                count = count + 1;
                j = j + 1;
            end
            numPointsDeleted = numPointsDeleted + count - 1;
            
            horizontalPoints = floorShape(pointIndex:pointIndex+count,:);
            newYCoordinate = mean(horizontalPoints(:,2));
            if pointIndex > 1
                floorShape = [
                    floorShape(1:pointIndex-1,:);
                    floorShape(pointIndex,1), newYCoordinate;
                    floorShape(pointIndex+count,1), newYCoordinate;
                    floorShape(pointIndex+count+1:end,:)
                    ];
            else
                floorShape = [
                    floorShape(pointIndex,1), newYCoordinate;
                    floorShape(pointIndex+count,1), newYCoordinate;
                    floorShape(pointIndex+count+1:end,:)
                    ];
            end
        end
    end
    
    numAddedPoints = 0;

    % Add missing points to create a complete floor shape
    for i = 1:length(floorShape) - 1
        index = i + numAddedPoints;
        currentPoint = floorShape(index,:);
        nextPoint = floorShape(index+1,:);

        angle_rad = atan2(nextPoint(2) - currentPoint(2), nextPoint(1) - currentPoint(1));
        anglesDeg = rad2deg(angle_rad);
        if anglesDeg < 0
            anglesDeg = anglesDeg + 180;
        end

        if anglesDeg <= angleThreshold || anglesDeg >= 180-angleThreshold
            continue;
        elseif anglesDeg <= 90+angleThreshold && anglesDeg >= 90-angleThreshold
            continue;
        elseif anglesDeg > 90+angleThreshold
            newPoint = [nextPoint(1), currentPoint(2)];
            numAddedPoints = numAddedPoints + 1;
            floorShape = [floorShape(1:index,:); newPoint; floorShape(index+1:end,:)];
        elseif anglesDeg < 90-angleThreshold
            newPoint = [currentPoint(1), nextPoint(2)];
            numAddedPoints = numAddedPoints + 1;
            floorShape = [floorShape(1:index,:); newPoint; floorShape(index+1:end,:)];
        end
    end

    % Close the floor shape by connecting the first and last points
    if floorShape(1,1) ~= floorShape(end,1) || floorShape(1,2) ~= floorShape(end,2)
        floorShape = [floorShape; floorShape(1,:)];
    end
end

