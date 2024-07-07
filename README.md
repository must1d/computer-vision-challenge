# Computer Vision Challenge
This project was created for a Computer Vision module (SS23 edition) at TUM.

## Table of Contents

- [Description](#description)
- [Usage](#usage)
- [Requirements](#requirements)

## Description

This software is designed to process a collection of input images of a room and generate a 3D model of the room. By analyzing the images, the software reconstructs the spatial structure and provides an abstract visual representation of the room in three dimensions.

![GUI](/visuals/3dmodel.png)

While the software can work with random images, it produces more accurate results when the input images are taken sequentially in an ordered manner.

## Requirements

This software has been developed and tested using the following software and libraries.

- MATLAB (version R2023a)
- [Computer Vision Toolbox](https://www.mathworks.com/products/computer-vision.html)
- [Image Processing Toolbox](https://www.mathworks.com/products/image.html)
- [Statistics and Machine Learning Toolbox](https://www.mathworks.com/products/statistics.html)

## Quick start

#### <b/>Step 1: Launch GUI</b>  
Make sure you have MATLAB R2023a installed and running. From the MATLAB console, execute the main.m script. This will open the GUI interface shown below:

![GUI](/visuals/gui.png)
 
#### <b/>Step 2: Load Camera Parameters</b> 
Click on the "Load Parameters" button and select the folder containing the "images.txt" and "cameras.txt" files. This will load the camera parameters from "cameras.txt" and the camera positions from "images.txt".

#### <b/>Step 3: Load Images</b>
Click on the "Load Images" button and select the images of the room that you want to process.

![GUI](/visuals/guiloaded.png)

#### <b/>Step 4: Select Feature Extraction Algorithm</b>
Choose the desired algorithm for feature extraction. There are two options available: "SIFT" and "SURF". The "SIFT" algorithm is more effective at identifying feature points, resulting in a higher quality 3D point cloud and model. However, please note that "SIFT" is slower compared to "SURF".

#### <b/>Step 5: Generate Point Cloud</b>
Click on the "Generate Point Cloud" button to initiate the main algorithm. This will create a 3D point cloud of the room, and the generated 3D point cloud will be displayed automatically in the GUI once the process is complete.

![GUI](/visuals/point_cloud.png)

#### <b/>Step 6: Optimize Parameters</b> 
To achieve the best quality point cloud and 3D model, you have the option to optimize the following parameters. Keep in mind that different images and rooms may require different parameter settings based on their unique structures and feature points.

- <u/>Distance for Denoising:</u> Adjust the distance threshold using the provided slider. This parameter determines the distance at which points are clustered together during the denoising process. Points that are farther apart than the specified distance will be assigned to separate clusters.
- <u/>Point Count for Denoising:</u> Modify the point count threshold for denoising the point cloud. Any cluster with a lower number of points than the specified count will be considered as noise and subsequently removed from the point cloud.
- <u/>Shrink Factor for Room Shape</u>: Adjust the shrink factor to shape the fitted concave polygon according to the wall structure. A higher shrink factor will result in a tighter fit of the wall shape.
- <u/>Number of Boxes in Visualization</u>: Modify the number of boxes (point clusters) that will be created during the k-means process.

#### <b/>Step 7: Visualize the 3D-Model</b>
To visualize the abstract 3D-Model of the room, simply click the "Plot Visualization" button. This action will transform the current 3D point cloud plot into an abstract representation of the room's 3D model. If you wish to switch back to the 3D point cloud plot, you can click the same button again, which is now marked with "Plot Point Cloud".

![GUI](/visuals/3dmodel.png)

#### <b/>Step 8: Measure Distance</b>
To measure distances within the 3D model, click the "Turn Distance Measurement Mode On" button. This will enable you to select two points on the 3D model. After selection, the software will calculate the distance between the chosen points and display a line connecting them with the distance value written on it.

![GUI](/visuals/distance.png)

