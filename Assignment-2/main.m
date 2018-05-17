clear
clc
close all

%% User defined parameters initialization
data_path = './Data/House/';

%% matching process
% image_matching(data_path);

%% Chaining
% Set threshold for vl_ubcmatch
threshold = 5;

% Baseline method
pointviewMatrix1 = chaining(data_path, threshold);

% save('./Results/point_view_matrix1.mat', 'point_view_matrix1');
%% 
% Alternative method matching SIFT descriptors across views
threshold = 5;
pointviewMatrix2 = chaining2(data_path, threshold);

%%
% Improved baseline, region-based matching and recovering double matches
threshold = 8;
distance_threshold = 30;
pointviewMatrix3 = chaining3(data_path, threshold, distance_threshold);

save('./Results/point_view_matrix2.mat', 'point_view_matrix2');
%%
point_view_matrix = load('pointviewmatrix.txt');

%% Structure from motion
sfm(point_view_matrix, true)

%% Build 3D structure from point view matrix
sample_size = 200;
step_size = 4;
% load('./Results/point_view_matrix1.mat');
% plot_3D_structure(point_view_matrix, step_size, sample_size);

