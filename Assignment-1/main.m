clear
clc
close all

%% Read the sample point cloud and check fscatter
% A = readPcd ("Data/data/0000000000.pcd")';
% A(:, A(3,:)>2) = [];
% fscatter3(A(1,:), A(2,:), A(3,:), A(4,:));

%% Run the ICP test for given sample source and destination
load('Data\source.mat', 'source');
load('Data\target.mat', 'target');

[R, T, source_transformed, rms, mse] = run_icp(source, target);
Full = [target, source_transformed];
figure()
subplot(2,2,1)
scatter3(source(1,:), source(2, :), source(3, :), 'b'); title('source');
subplot(2,2,2)
scatter3(target(1,:), target(2, :), target(3, :), 'r'); title('target');
subplot(2,2,3)
hold on;
scatter3(target(1,:), target(2, :), target(3, :), 'r.'); title('target');
scatter3(source_transformed(1,:), source_transformed(2, :), source_transformed(3, :), 'b.'); title('target');
hold off
subplot(2,2,4)
iterations = 1:size(rms,2);
plot(iterations, rms, '-r.', iterations, mse, '-b*');
legend('rms values', 'mse error');

%% Run full ICP on point clouds
% icp_iterative();

