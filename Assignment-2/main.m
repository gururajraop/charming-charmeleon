clear
clc
close all

%% User defined parameters initialization
data_path = './Data/House/';

%% matching process
image_matching(data_path);

%% Chaining
% Set threshold for ubcmatch
threshold = 5
pointviewMatrix1 = chaining(data_path, threshold);
%%
threshold = 5
pointviewMatrix2 = chaining2(data_path, threshold);

%%
% TODO: Get denseBlock from pointviewMatrix, until then use the loaded one
% indices = find(sum(pointviewMatrix1(:,:)~=0) == 96);
% denseBlock = pointviewMatrix1(:, indices);
% denseBlock = denseBlock(1:96, :);
% 
% denseBlock = load('pointviewmatrix.txt');

% point_view_matrix = chaining(data_path);
% pointviewMatrix2 = chaining2(data_path);
% save('./Results/point_view_matrix.mat', 'point_view_matrix');

point_view_matrix = load('pointviewmatrix.txt');

%% Structure from motion
% sfm(denseBlock, true)

%% Build 3D structure from point view matrix
sample_size = 200;
step_size = 4;
% load('./Results/point_view_matrix.mat');
plot_3D_structure(point_view_matrix, step_size, sample_size);

