% Merging Scenes - 3.1
%
% Estimate camera poses and merge point clouds in a pairwise manner, with
% pairs being selected consecutively or with a larger step size.

function [merged_pc, color] = icp_3_1(step, sample_type, sample_size, threshold, n_iterations, matching_type)
    if nargin == 0
        step = 1
        sample_type = 'random'
    elseif nargin == 1
        sample_type = 'random'
    end
    
    % Retrieve all pcd files and separate point clouds and normals
    directory = 'Data\data\';
    
    point_clouds = dir(strcat(directory, '\', '\*.pcd'));
    normals_indices = contains({point_clouds.name}, 'normal.pcd');
    normals = point_clouds(normals_indices);
    point_clouds(normals_indices) = [];
    
    % Initialize a merged cloud outside of loop using the first .pcd
    merged_pc = readPcd ("Data/data/0000000000.pcd ")';
    merged_pc(:, merged_pc(3, :)>1.8) = [];
    merged_pc = merged_pc(1:3, :);
    
    % Append the first cloud to the end of the list of point clouds
    point_clouds = [point_clouds; dir(strcat(directory, '\', '\0000000000.pcd'))];
    
    % Initialize color column for fscatter
    color = [ones(1, size(merged_pc, 2))];
    color(1, 1) = 10;
    
    % Final improvement (select the transformed last frame)
    last_frame = merged_pc;
    last_frame_size = size(merged_pc, 2);
    
    for i = 1:step:length(point_clouds) - step
%     for i = 1:step:30 * step - step
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
        
        % Find camera movement from A1 to A2
        tic
%         [R, T, ~, ~, ~] = run_icp(A1, A2, threshold, ...
%         sample_type, sample_size, n_iterations, matching_type);
    
        % Final improvement (select the transformed last frame)
        [R, T, ~, ~, ~] = run_icp(last_frame, A2, threshold, ...
        sample_type, sample_size, n_iterations, matching_type);
        toc
        
        % Transform merged cloud using camera movement and merge with
        % target
        merged_pc = R * merged_pc - T;
        
        % Final improvement (select the transformed last frame)
        last_frame = merged_pc(:, end-last_frame_size+1:end);
        last_frame_size = size(A2, 2);
        
        merged_pc = [merged_pc, A2];
        color = [color ones(1, size(A2, 2)) * i + step];
    end
    
    % Visualize results
    figure();
    index = randsample(1:size(merged_pc,2), 200000);
    F = merged_pc(:, index);
    Fcolor = color(index);
    fscatter3(F(1,:), F(2,:), F(3,:), Fcolor');
    
    % Calculate the standard deviation in Euclidean distance from the
    % centroid
    centroid = mean(merged_pc, 2)
    total = 0;
    for i = 1:length(merged_pc)
        point = merged_pc(:, i);
        total = total + norm(centroid - point);
    end
    euclidean_std = total / length(merged_pc)
end