clear
clc
close all

%% User defined parameters initialization
test_scene = 'wave';                % Type of the test scene
                                    % wave, human_head
sample_type = 'random';             % Point selection method to be used
                                    % all, uniform, random, regions
sample_size = 1000;                 % Number of points to be sampled for ICP
threshold = 0.0001;                 % RMS change threshold
n_iterations = 25;                  % Max number of iterations of ICP

%% Run the ICP test
ICP_test(test_scene, sample_type, sample_size, threshold, n_iterations);

%% Compare the various sampling methods
compare_sampling_methods();

%% Run full ICP on point clouds
% icp_iterative();

