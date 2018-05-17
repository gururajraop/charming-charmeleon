clear
clc
close all

%% User defined parameters initialization
data_path = './Data/House/';

%% matching process
% image_matching(data_path);

%% Chaining
% Set threshold for ubcmatch
% threshold = 50;
% pointviewMatrix1 = chaining(data_path, threshold);

% save('./Results/point_view_matrix1.mat', 'point_view_matrix1');
%%
<<<<<<< HEAD
% TODO: Get denseBlock from pointviewMatrix, until then use the loaded one
indices = find(sum(pointviewMatrix2(:,:)~=0) == 96);
denseBlock = pointviewMatrix2(:, indices);
denseBlock = denseBlock(1:96, :);

% denseBlock = load('pointviewmatrix.txt');
=======
% threshold = 50;
% pointviewMatrix2 = chaining2(data_path, threshold);
>>>>>>> a9f3c06d3878c80292690e82983da6f88afe46d8

% save('./Results/point_view_matrix2.mat', 'point_view_matrix2');

point_view_matrix = load('pointviewmatrix.txt');

%% Structure from motion
% sfm(denseBlock, true)

%% Build 3D structure from point view matrix
sample_size = 200;
step_size = 4;
% load('./Results/point_view_matrix1.mat');
% plot_3D_structure(point_view_matrix, step_size, sample_size);

