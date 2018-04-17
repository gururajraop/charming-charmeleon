clear
clc
close all


% A = readPcd ("Data/data/0000000000.pcd")';
% A(:, A(3,:)>2) = [];
% fscatter3(A(1,:), A(2,:), A(3,:), A(4,:));

% icp_iterative();

%% Run the ICP test for given sample source and destination
load('Data\source.mat', 'source');
load('Data\target.mat', 'target');
[R, T] = run_icp(source, target);
t = R * source + T;
Full = [target, t];
figure(1)
fscatter3(source(1,:), source(2, :), source(3, :), source(1, :));
figure(2)
fscatter3(target(1,:), target(2, :), target(3, :), target(1, :));
figure(3)
fscatter3(Full(1,:), Full(2, :), Full(3, :), Full(1, :));

