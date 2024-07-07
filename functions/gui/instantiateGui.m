% The 'instantiateGui.m' file includes the main function "instantiateGui", 
% which instatiates the GUI, and its helpers "plotModel",
% "distSliderChanged", "PtCntSliderChanged" and "shrinkFacSliderChanged".


% Function to unstantiate the GUI
function fig = instantiateGui()
    % Clear the command window and close all existing figures
    clc;
    close all;

    % Create the main figure window and store a handle to the figure in "fig"
    fig = uifigure('Name', '3D - Room Scanner', 'WindowState', 'maximize');

    % Initialize various fields in the UserData.
    % These fields will be used to store data shared across multiple UI 
    % components and functions.

    fig.UserData.Images = {}; % Placeholder for storing images
    fig.UserData.CameraParams = []; % Placeholder for storing camera parameters
    fig.UserData.CameraPositions = []; % Placeholder for storing camera positions
    fig.UserData.CameraPositionsFromSFM = [];  % Placeholder for storing camera positions from Structure From Motion
    fig.UserData.ogPtCloud = {}; % Placeholder for storing original point cloud
    fig.UserData.curPtCloud = {}; % Placeholder for storing current point cloud
    fig.UserData.plotPoints = false; % Variable to check whether points are being plotted
    fig.UserData.distanceModeOn = false; % Variable to check whether distance measurment mode is on
    fig.UserData.pointsForDistances = ...
        struct('point1', [], 'point2', [], ...
        'linePlot', [], 'textPlot', []); % data for distance measurement

    fig.UserData.model = struct('floorShape', {}, 'yFloor', 0, 'yCeiling', 0, ...
        'points', [], 'idx', []); % Structure for storing model details
    fig.UserData.optimizableParams = struct('distance', 2, 'PointCount', 5, ...
        'ShrinkFactor', 0.1, 'SIFT', false, 'K', 30); % Structure for storing optimizable parameters

    % Create a grid layout inside the main figure window
    grid = uigridlayout(fig);
    grid.RowHeight = {'.3x', '.7x', '1x', '5x', '.5x', '1x'};
    grid.ColumnWidth = {'.5x', '.5x', '1x', '1x', '1x', '1x','1x'};
    
    % Create a listbox for displaying images, and position it at
    % bottom-left
    imList = uilistbox(grid);
    imList.Items = {};
    imList.Layout.Row = 4;
    imList.Layout.Column = [1 2];
    
    % Create a button for loading parameters, and position it at top-left
    paramsButton = uibutton(grid, 'Text', 'Load Parameters');
    paramsButton.Layout.Row = [1 2];
    paramsButton.Layout.Column = [1 2];
    paramsButton.ButtonPushedFcn = @(src, event) addParamsPushed(src, paramsButton); % Call "addParamsPushed" function if the button is pressed
    
    % Create a button for loading images, and position it under  "Load
    % Parameters" buton.
    addImages = uibutton(grid, 'Text', 'Load Images');
    addImages.ButtonPushedFcn = @(src, event) loadImagesGui(src, imList); % Call "loadImagesGui" function if the button is pressed
    addImages.Layout.Row = 3;
    addImages.Layout.Column = [1 2];

    % Create a uiaxes for the plot, and position it in the center-right
    graph = uiaxes(grid);
    graph.Layout.Row = [3 5];
    graph.Layout.Column = [3 7];
    graph.Visible = 'off'; % Initially set the axes to be invisible
    axis(graph, 'equal'); % Set the aspect ratio of the axes to be 1:1

    % Create a button for generating the point cloud, and position it at
    % bottom-left
    generateButton = uibutton(grid, 'Text', 'Generate Point Cloud');
    generateButton.Layout.Row = 6;
    generateButton.Layout.Column = [1 2];
    generateButton.ButtonPushedFcn = @(src, event) generatePointCloud(src, graph, generateButton); % Call "generatePointCloud" function if the button is pressed
    
    % Button to change turn distance measuring on or off
    distbutton = uibutton(grid, 'Text', 'Turn Distance Measurement Mode On');
    distbutton.Layout.Row = 6;
    distbutton.Layout.Column = 7;
    distbutton.ButtonPushedFcn = @(src, event)  measureDistance(src, graph, distbutton);

    % Create a button for plotting the visualization, and position it at
    % top-right.
    plotButton = uibutton(grid, 'Text', 'Plot Visualization');
    plotButton.Layout.Row = [1 2]; 
    plotButton.Layout.Column = 7; 
    plotButton.ButtonPushedFcn = @(src, event) plotModel(src, plotButton, distbutton,  graph); % Call "plotModel" function if the button is pressed

    % Create dropdown for selecting a feature matching algorithm and place 
    % it at the top.
    siftLabel = uilabel(grid, 'WordWrap', 'on', ...
        'Text', 'Algorithm used for feature extraction');
    siftLabel.Layout.Row = 5;
    siftLabel.Layout.Column = 1;
    siftDD = uidropdown(grid, 'Items', ["SURF", "SIFT"]);
    siftDD.Layout.Row = 5;
    siftDD.Layout.Column = 2;
    siftDD.ValueChangedFcn = @(src, event)siftChanged(src, event);

    % Create slider for adjusting the 'Distance for Denoising' and place it
    % at the top.
    distLabel = uilabel(grid, 'Text', 'Distance for Denoising');
    distLabel.Layout.Row = 1;
    distLabel.Layout.Column = 3;
    distSlider = uislider(grid, 'Value', fig.UserData.optimizableParams.distance, ...
        'Limits', [0.01 5]);
    distSlider.Layout.Row = 2;
    distSlider.Layout.Column = 3;
    distSlider.ValueChangedFcn = @(src, event) distSliderChanged(src, event, graph, distbutton);
    
    % Create slider for adjusting the 'Point Count for Denoising' and place
    % it at the top.
    PtCntLabel = uilabel(grid, 'Text', 'Point Count for Denoising');
    PtCntLabel.Layout.Row = 1;
    PtCntLabel.Layout.Column = 4;
    PtCntSlider = uislider(grid, 'Value', fig.UserData.optimizableParams.PointCount, ...
        'Limits', [2 10]);
    PtCntSlider.Layout.Row = 2;
    PtCntSlider.Layout.Column = 4;
    PtCntSlider.ValueChangedFcn = @(src, event) PtCntSliderChanged(src, event, graph, distbutton);
    
    % Create slider for adjusting the 'Shrink Factor for Room Shape' and
    % place it at the top.
    shrinkFacLabel = uilabel(grid, 'Text', 'Shrink Factor for Room Shape');
    shrinkFacLabel.Layout.Row = 1;
    shrinkFacLabel.Layout.Column = 5;
    shrinkFacSlider = uislider(grid, 'Value', fig.UserData.optimizableParams.ShrinkFactor, ...
        'Limits', [0.01 1]);
    shrinkFacSlider.Layout.Row = 2;
    shrinkFacSlider.Layout.Column = 5;
    shrinkFacSlider.ValueChangedFcn = @(src, event) shrinkFacSliderChanged(src, event, graph, distbutton);

    % Create Slider for adjusting the K of the k means.
    kLabel = uilabel(grid, 'Text', 'Number of Boxes in Visualization');
    kLabel.Layout.Row = 1;
    kLabel.Layout.Column = 6;
    kSlider = uislider(grid, 'Value', fig.UserData.optimizableParams.K, ...
        'Limits', [10 100]);
    kSlider.Layout.Row = 2;
    kSlider.Layout.Column = 6;
    kSlider.ValueChangedFcn = @(src, event) kSliderChanged(src, event, graph, distbutton);
end

% The "plotModel" function visualizes either the point cloud or the model 
% depending on the current state.
% The state is tracked using UserData.plotPoints variable in 'fig'
% structure.
% If the point cloud has not been created yet, it alerts the user to create
% the point cloud.
function plotModel(src, button, distButton, graph)
    fig = ancestor(src,"figure","toplevel");
    if (isempty(fig.UserData.curPtCloud))
        uialert(fig, 'Please first create a point cloud!', 'No Point Cloud', ...
            'Icon', 'warning');
    % if plotPoints flag is true, plot the point cloud
    elseif (fig.UserData.plotPoints == true)
        fig.UserData.plotPoints = false;
        button.Text = 'Plot Visualization';
        visualize(fig.UserData, graph);
        
        fig.UserData.distanceModeOn = false;
        distButton.Text = 'Turn Distance Measurement Mode On';
    % if plotPoints flag is false, plot the model
    else
        fig.UserData.plotPoints = true;
        button.Text = 'Plot Point Cloud';
        visualize(fig.UserData, graph);
    end
end

% The "distSliderChanged" function is triggered when the 'Distance for 
% Denoising' slider value is changed.
% It updates the distance value in fig.UserData and also updates the model.
function distSliderChanged(src, event, graph, distButton)
    fig = ancestor(src, "figure", "toplevel");
    fig.UserData.optimizableParams.distance = event.Value;
    % update model if point cloud is already loaded
    if (~isempty(fig.UserData.ogPtCloud))
        fig.UserData = updateModel(fig.UserData, true);
        visualize(fig.UserData, graph);

        fig.UserData.distanceModeOn = false;
        distButton.Text = 'Turn Distance Measurement Mode On';
    end
end

% The "PtCntSliderChanged" function is triggered when the 'Point Count for 
% Denoising' slider value is changed.
% It updates the point count value in fig.UserData and also updates the 
% model and visualization.
function PtCntSliderChanged(src, event, graph, distButton)
    fig = ancestor(src, "figure", "toplevel");
    fig.UserData.optimizableParams.PointCount = event.Value;
    % update model if point cloud is already loaded
    if (~isempty(fig.UserData.ogPtCloud))
        fig.UserData = updateModel(fig.UserData, true);
        visualize(fig.UserData, graph);

        fig.UserData.distanceModeOn = false;
        distButton.Text = 'Turn Distance Measurement Mode On';
    end
end

% The "shrinkFacSliderChanged" function is triggered when the 'Shrink Factor
% for Room Shape' slider value is changed.
% It updates the shrink factor value in fig.UserData and also updates the 
% model and visualization.
function shrinkFacSliderChanged(src, event, graph, distButton)
    fig = ancestor(src, "figure", "toplevel");
    fig.UserData.optimizableParams.ShrinkFactor = event.Value;
    % update model if point cloud is already loaded
    if (~isempty(fig.UserData.ogPtCloud))
        fig.UserData = updateModel(fig.UserData, false);
        visualize(fig.UserData, graph);

        fig.UserData.distanceModeOn = false;
        distButton.Text = 'Turn Distance Measurement Mode On';
    end
end


% The "shrinkFacSliderChanged" function is triggered when the 'Shrink Factor
% for Room Shape' slider value is changed.
% It updates the shrink factor value in fig.UserData and also updates the 
% model and visualization.
function kSliderChanged(src, event, graph, distButton)
    fig = ancestor(src, "figure", "toplevel");
    fig.UserData.optimizableParams.K = event.Value;
    % update model if point cloud is already loaded
    if (~isempty(fig.UserData.ogPtCloud))
        fig.UserData = updateModel(fig.UserData, false);
        visualize(fig.UserData, graph);

        fig.UserData.distanceModeOn = false;
        distButton.Text = 'Turn Distance Measurement Mode On';
    end
end



% The "measureDistance" function is triggered when summon presses the
% distance measurement button
% It swaps turns the distance measuring on or off
function measureDistance(src, graph, distbutton)
    fig = ancestor(src,"figure","toplevel");
    % if plot button is set to points, change to visualization mode before
    %plotting
    if (isempty(fig.UserData.curPtCloud))
        uialert(fig, 'Please first create a room visualization!', 'No room visualization', ...
            'Icon', 'warning');
    elseif (~fig.UserData.plotPoints)
        uialert(fig, 'Please switch back to visualization mode before!', 'Visualization mode needed', ...
            'Icon', 'warning');
    
    elseif (fig.UserData.distanceModeOn)
        fig.UserData.distanceModeOn = false;
        distbutton.Text = 'Turn Distance Measurement Mode On';
        
        % Reset everything by plotting again
        visualize(fig.UserData, graph);
    else % if plot button is on visualization, plot the model
        fig.UserData.distanceModeOn = true;
        distbutton.Text = 'Turn Distance Measurement Mode Off';

        dcm = datacursormode(fig);
        dcm.Enable = 'on'; 
        
        disp("Turn callback on")

        dcm.UpdateFcn = @(~, event) pointSelectedCallback(event, graph);
    end
end

% The "siftChanged" function is triggered when the SIFT or SURF dropdown
% value is changed.
% It updates the corresponding flag in fig.UserData but requires a
% manual regeneration of the point cloud to create changes
function siftChanged(src, event)
    fig = ancestor(src,"figure","toplevel");
    if event.Value == "SURF"
        fig.UserData.optimizableParams.SIFT = false;
    else
        fig.UserData.optimizableParams.SIFT = true;
    end
end
