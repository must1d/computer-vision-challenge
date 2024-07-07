function loadImagesGui(src, imList)
% loadImagesGui(src, imList)
% - This function is called when the "Load Images" button is clicked in a GUI.
% - It prompts the user to select multiple image files and loads them.
% - The loaded images are stored in a cell array and assigned to the user data 
% of the figure.

    % Get the figure that contains the button
    fig = ancestor(src,"figure","toplevel");

     % Prompt the user to select image files
    [selectedFiles, path] = uigetfile({'*.png;*.jpg;*.img', 'Image Files'}, ...
        'Please Select Some Image Files', '..', 'MultiSelect', 'on');
    
    % Check if the user selected any files
    if isequal(selectedFiles, 0)
        disp('No files selected.');
        return;
    end

    % Initialize an empty cell array to store the images
    images = cell(1, numel(selectedFiles));

    % Create a progress bar
    progress = waitbar(0, 'Loading Images...');

    % Load images
    for i = 1:numel(selectedFiles)
        % Construct the image file path, read and store the images
        imagePath = fullfile(path, selectedFiles{i});
        image = imread(imagePath);
        images{i} = image;

    % Update the progress bar with the current loading status
        waitbar(i/numel(selectedFiles), progress, sprintf("Loading Image %d of %d", i, numel(selectedFiles)));
    end

    % Store the loaded images in the user data.
    fig.UserData.Images = images;

    % Assign the filenames of the loaded images to the items of imList.
    imList.Items = selectedFiles;

    % Close the progress bar
    close(progress);
end
