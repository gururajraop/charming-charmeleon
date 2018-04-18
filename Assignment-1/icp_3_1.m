% Merging Scenes - 3.1
%
% Estimate camera poses and merge point clouds in a pairwise manner, with
% pairs being selected consecutively or with a larger step size.
function [] = icp_3_1(step)
    if nargin == 0
        step = 1;
    end
    
    % Retrieve all pcd files and separate point clouds and normals.
    directory = 'Data\data\';
    
    point_clouds = dir(strcat(directory, '\', '\*.pcd'));
    normals_indices = contains({point_clouds.name}, 'normal.pcd');
    normals = point_clouds(normals_indices);
    point_clouds(normals_indices) = [];
    
    % Initialize a merged cloud outside of loop using the first .pcd.
    merged_pc = readPcd ("Data/data/0000000000.pcd ")';
    merged_pc(:, merged_pc(3, :)>2) = [];
    merged_pc = merged_pc(1:3, :);
    
%     for i = 1:step:length(point_clouds) - step  
    for i = 1:1
        first = strcat(directory, point_clouds(i).name);
        second = strcat(directory, point_clouds(i + step).name);
        A1 = readPcd(first)';
        A2 = readPcd(second)';
        
        % Remove background points with distance > 2 to the camera.
        A1(:, A1(3,:)>2) = [];
        A2(:, A2(3,:)>2) = [];
        
        % Remove 'rgb' entry from point clouds.
        A1 = A1(1:3, :);
        A2 = A2(1:3, :);
        
        % Find camera movement from A2 to A1
        tic
        [R, T] = run_icp(A2, A1, 0.0001);
        toc
        
        % Transform A2 using camera movement and merge.
        transformed_A2 = R * A2 + T;
        merged_pc = [merged_pc, transformed_A2];
    end
    
    %%
    % Visualize results.
    figure(1)
    fscatter3(A1(1,:), A1(2, :), A1(3, :), A1(1, :));
    figure(2)
    fscatter3(A2(1,:), A2(2, :), A2(3, :), A2(1, :));
    figure(3)
    fscatter3(transformed_A2(1,:), transformed_A2(2, :), transformed_A2(3, :), transformed_A2(1, :));
    figure(4)
    fscatter3(merged_pc(1,:), merged_pc(2,:), merged_pc(3,:), merged_pc(1,:));
end