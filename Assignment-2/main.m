clear
clc
close all

%% User defined parameters initialization
data_path = './Data/House/';

%% matching process
image_matching(data_path);

%% Chaining
pointviewMatrix = chaining(data_path);

%% Structure from motion
