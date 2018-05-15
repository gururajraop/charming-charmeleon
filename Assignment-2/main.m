clear
clc
close all

%% User defined parameters initialization
data_path = './Data/House/';

%% matching process
image_matching(data_path);

%% Chaining
pointviewMatrix = chaining(data_path);

%%

% TODO: Get denseBlock from pointviewMatrix, until then use the loaded one
indices = find(sum(pointviewMatrix(:,:)~=0) == 98)
denseBlock = pointviewMatrix(:, indices)

denseBlock = load('pointviewmatrix.txt')
%% Structure from motion
sfm(denseBlock)

