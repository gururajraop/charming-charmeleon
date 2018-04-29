% Merging Scenes - 3.2
%
% Estimate camera poses from each consecutive frame to the merged point
% cloud of preceding frames, and merge with that cloud.

function [merged_pc, color] = icp_3_2(step, sample_type, sample_size, threshold, n_iterations, matching_type)
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
    
    % Append the first cloud to the end of the list of point clouds
    point_clouds = [point_clouds; dir(strcat(directory, '\', '\0000000000.pcd'))];
    
    % Initialize a merged cloud outside of loop using the first .pcd
    merged_pc = readPcd ("Data/data/0000000000.pcd ")';
    merged_pc(:, merged_pc(3, :)>1.8) = [];
    merged_pc = merged_pc(1:3, :);
    
    R_accumulative = eye(3);
    T_accumulative = [0; 0; 0];
    
    % Initialize color column for fscatter
    color = [ones(1, size(merged_pc, 2))];
    color(1, 1) = 10;
    
    for i = 1:step:length(point_clouds) - step
%     for i = 1:step:27 * step - step
        fprintf('Current frame: %d/%d\n', i, length(point_clouds));
        target = strcat(directory, point_clouds(i + 1).name);
        A2 = readPcd(target)';
        
        % Remove background points with distance > 2 to the camera
        A2(:, A2(3,:)>2) = [];
        
        % Remove 'rgb' entry from point clouds
        A2 = A2(1:3, :);
        
        % Find camera movement from A2 to A1
        tic
        [R, T, ~, ~, ~] = run_icp(merged_pc, A2, threshold, ...
        sample_type, sample_size, n_iterations, matching_type);
        
        % Transform merged cloud using camera movement and merge with
        % target
        merged_pc = R * merged_pc - T;
            
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