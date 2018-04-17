clear
clc
close all


% A = readPcd ("Data/data/0000000000.pcd");
% A(A(:,3)>2, :) = [];
% fscatter3(A(:,1), A(:, 2), A(:, 3), A(:, 4));

icp_iterative();

%% Run the ICP test for given sample source and destination
% load('Data\source.mat', 'source');
% load('Data\target.mat', 'target');
% run_icp(source, target);