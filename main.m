% This main function starts the program and the GUI.


% Clear all variables, open windows and the command window.
clear all;
close all;
clc;

% Add the directory 'functions' and its subdirectories to the path.
addpath(genpath('functions'));

% Instantiate the GUI
instantiateGui()

