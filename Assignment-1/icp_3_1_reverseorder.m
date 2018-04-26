% Merging Scenes - 3.1
%
% Estimate camera poses and merge point clouds in a pairwise manner, with
% pairs being selected consecutively or with a larger step size.
% 
% Method can be (tbd):
% - 'a' if it follows the method described in 3.1.a
% - Anything else defaults to the method described in 3.1.b

function merged_pc = icp_3_1(step, sampling)
    if nargin == 0
        step = 1
        sampling = 'random'
    elseif nargin == 1
        sampling = 'random'
    end
    
    % Retrieve all pcd files and separate point clouds and normals
    directory = 'Data\data\';
    
    point_clouds = dir(strcat(directory, '\', '\*.pcd'));
    normals_indices = contains({point_clouds.name}, 'normal.pcd');
    normals = point_clouds(normals_indices);
    point_clouds(normals_indices) = [];
    
    % Initialize a merged cloud outside of loop using the first .pcd
    merged_pc = readPcd ("Data/data/0000000000.pcd ")';
    merged_pc(:, merged_pc(3, :)>2) = [];
    merged_pc = merged_pc(1:3, :);
    
    R_accumulative = eye(3);
    T_accumulative = [0; 0; 0];
    
    % Initialize color column for fscatter
    color = [ones(1, size(merged_pc, 2)) * 60];
    color(1, 1) = 10;

    for i = 1:step:length(point_clouds) - step
%     for i = 1:step:7 * step - step
        fprintf('Current frame: %d/%d\n', i, length(point_clouds));
        first = strcat(directory, point_clouds(i).name);
        second = strcat(directory, point_clouds(i + step).name);
        A1 = readPcd(first)';
        A2 = readPcd(second)';
        
        % Remove background points with distance > 2 to the camera
        A1(:, A1(3,:)>2) = [];
        A2(:, A2(3,:)>2) = [];

        % Remove 'rgb' entry from point clouds
        A1 = A1(1:3, :);
        A2 = A2(1:3, :);
        
        % Find camera movement from A2 to A1
        tic
        [R, T, ~, ~, ~] = run_icp(A2, A1, 0.0000001, sampling);
        toc
        
        % Define the total transformation by accumulating R and T
        R_accumulative = R_accumulative * R;
        T_accumulative = R * T_accumulative + T;
        
        % Transform merged cloud using camera movement and merge with
        % target
        transformed_A2 = R_accumulative * A2 - T_accumulative;
        merged_pc = [merged_pc, transformed_A2];
        color = [color ones(1, size(transformed_A2, 2)) * i + step];
    end
    % Visualize results
    figure();
%     index = randsample(1:size(merged_pc,2), 10000);
%     F = merged_pc(:, index);
    F = merged_pc;
%     color = color(index);
    fscatter3(F(1,:), F(2,:), F(3,:), color');
end