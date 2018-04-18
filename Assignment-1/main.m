clear
clc
close all

%% Read the sample point cloud and check fscatter
% A = readPcd ("Data/data/0000000000.pcd")';
% A(:, A(3,:)>2) = [];
% fscatter3(A(1,:), A(2,:), A(3,:), A(4,:));

%% Run the ICP test for given sample source and destination
% load('Data\source.mat', 'source');
% load('Data\target.mat', 'target');
% 
% [R, T, source_transformed] = run_icp(source, target);
% Full = [target, source_transformed];
% figure()
% subplot(2,2,1)
% fscatter3(source(1,:), source(2, :), source(3, :), source(1, :)); title('source');
% subplot(2,2,2)
% fscatter3(target(1,:), target(2, :), target(3, :), target(1,:)); title('target');
% subplot(2,2,3)
% fscatter3(Full(1,:), Full(2, :), Full(3, :), Full(1, :)); title('combined');

%% Run full ICP on point clouds
icp_iterative();

