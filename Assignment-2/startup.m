%% SIFT setup
% Specify the path for vlfeat
VLFEAT_ROOT = 'C:\Users\user\Downloads\MathWorks\vlfeat-0.9.21-bin\vlfeat-0.9.21\';
% VLFEAT_ROOT = 'vlfeat-0.9.21\';
VLFEAT_ROOT = sprintf('%s%s', VLFEAT_ROOT, 'toolbox\vl_setup.m');
run(VLFEAT_ROOT);