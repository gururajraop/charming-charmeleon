clear
clc
close all

%% User defined parameters initialization
data_path = './Data/House/';

%% matching process
image_matching(data_path);

%% Chaining
% Set threshold for ubcmatch
% threshold = 5;
% pointviewMatrix1 = chaining(data_path, threshold);

% save('./Results/point_view_matrix1.mat', 'point_view_matrix1');

% threshold = 5;
% pointviewMatrix2 = chaining2(data_path, threshold);
% 
% save('./Results/point_view_matrix2.mat', 'point_view_matrix2');

point_view_matrix = load('pointviewmatrix.txt');

%% Structure from motion

%% Build 3D structure from point view matrix
sample_size = 200;
step_size = 2;
% load('./Results/point_view_matrix.mat');
% plot_single_dense(point_view_matrix);
% plot_iterative(point_view_matrix, step_size, sample_size);

