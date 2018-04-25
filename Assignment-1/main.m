clear
clc
close all

%% Read the sample point cloud and check fscatter
% A1 = readPcd ("Data/data/0000000000.pcd")';
% A2 = readPcd ("Data/data/0000000005.pcd")';
% A1(:, A1(3,:)>2) = [];
% A2(:, A2(3,:)>2) = [];
% source = A1(1:3, :);
% target = A2(1:3, :);

%% Run the ICP test for given sample source and destination
% load('Data\source.mat', 'source');
% load('Data\target.mat', 'target');

% tic
% [R, T, source_transformed, rms1, mse1] = run_icp(source, target, 0.001, 'all');
% toc
% tic
% [R, T, source_transformed, rms2, mse2] = run_icp(source, target, 0.001, 'uniform');
% toc
% tic
% [R, T, source_transformed, rms3, mse3] = run_icp(source, target, 0.001, 'random');
% toc
% index = randsample(1:60000, 10000);
% source = source(:, index);
% target = target(:, index);
% source_transformed = source_transformed(:, index);
% figure()
% subplot(2,2,1)
% scatter3(source(1,:), source(2, :), source(3, :), 'b'); title('source');
% subplot(2,2,2)
% scatter3(target(1,:), target(2, :), target(3, :), 'r'); title('target');
% subplot(2,2,3)
% hold on;
% scatter3(source(1,:), source(2, :), source(3, :), 'b');% title('source');
% scatter3(target(1,:), target(2, :), target(3, :), 'r');% title('target');
% scatter3(source_transformed(1,:), source_transformed(2, :), source_transformed(3, :), 'g');% title('target');
% legend('source', 'target', 'transformed source');
% hold off
% subplot(2,2,4)
% figure
% iterations = 1:25;
% plot(iterations, rms1, '-r.', iterations, rms2, '-b*', iterations, rms3, '-go');
% legend('all', 'uniform', 'random');
% 
% figure
% iterations = 1:25;
% plot(iterations, mse1, '-r.', iterations, mse2, '-b*', iterations, mse3, '-go');
% legend('all', 'uniform', 'random');

%% Run full ICP on point clouds
icp_iterative();

