clear
clc
close all

%% User defined parameters initialization
data_path = './Data/House/';        % Path to the dataset

threshold = 5;                      % Threshold for vl_ubcmatch

sample_size = 1000;                 % Sample size of 3D points for plotting

step_size = 5;                      % Step size for iterative SFM process

Affine = false;                     % Use affine ambiguity removal

%% matching process
image_matching(data_path);

%% Chaining

% Baseline method
% pointviewMatrix1 = chaining(data_path, threshold);
% save('./Results/point_view_matrix1.mat', 'point_view_matrix1');

% Alternative method matching SIFT descriptors across views
% pointviewMatrix2 = chaining2(data_path, threshold);
% save('./Results/point_view_matrix2.mat', 'point_view_matrix2');

% Improved baseline, region-based matching and recovering double matches
threshold = 8;
distance_threshold = 30;
point_view_matrix3 = chaining3(data_path, threshold, distance_threshold);
save('./Results/point_view_matrix3.mat', 'point_view_matrix3');

%% Provided PVM
point_view_matrix = load('pointviewmatrix.txt');

%% Build 3D structure from point view matrix

% load('./Results/point_view_matrix3.mat');
plot_single_dense(point_view_matrix, Affine);
plot_iterative(point_view_matrix, step_size, sample_size, Affine);

