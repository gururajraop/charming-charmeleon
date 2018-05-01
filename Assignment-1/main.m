clear
clc
close all

%% User defined parameters initialization
test_scene = 'wave';                % Type of test scene
                                    % wave, human_head
sample_type = 'random';             % Point selection method to be used
                                    % all, uniform, random, regions
sample_size = 1000;                 % Number of points to be sampled for ICP
threshold = 0.0001;                 % RMS change threshold
n_iterations = 30;                  % Max number of iterations of ICP
matching_type = 'kdTree';           % Matching type
                                    % brute_force, kdTree, delaunay
step_size = 1;                      % Step size in merging

%% Run the ICP test
ICP_test(test_scene, sample_type, sample_size, threshold, n_iterations, matching_type);

%% Compare the various sampling methods
compare_sampling_methods();

%% Run full ICP on point clouds
threshold = 0.00000001;

% icp_3_1(step_size, sample_type, sample_size, threshold, n_iterations, matching_type);
% icp_3_2(step_size ,sample_type, sample_size, threshold, n_iterations, matching_type);

% Best result
icp_3_1(1 ,'random', 2000, 0.000000000001, 30, 'kdTree');
