clear
clc
close all

%% User defined parameters initialization
data_path = './Data/House/';

%% Matching process
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
indices = find(sum(pointviewMatrix1(:,:)~=0) == 96);
denseBlock = pointviewMatrix1(:, indices);
denseBlock = denseBlock(1:96, :);

denseBlock = load('pointviewmatrix.txt');
%% Structure from motion
sfm(denseBlock)

