% Merging Scenes - 3.2
%
% Estimate camera poses from each consecutive frame to the merged point
% cloud of preceding frames, and merge with that cloud.
function [] = icp_3_2
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
    
%     for i = 1:length(point_clouds)
    for i = 1:1
         = strcat(directory, point_clouds(i + 1).name);
        A2 = readPcd(target)';
        
        % Remove background points with distance > 2 to the camera.
        A2(:, A2(3,:)>2) = [];
        
        % Remove 'rgb' entry from point clouds.
        A2 = A2(1:3, :);
        
        % Find camera movement of A2 relative to the merged point cloud.
        tic
        [R, T] = run_icp(A2, merged_pc, 0.0001);
        toc
        
        % Transform A2 using camera movement and merge.
        transformed_A2 = R * A2 + T;
        merged_pc = [merged_pc, transformed_A2];
    end
    merged_pc = [merged_pc, A1];
    
    %%
    % Visualize results.
    figure(1)
    fscatter3(A2(1,:), A2(2, :), A2(3, :), A2(1, :));
    figure(2)
    fscatter3(transformed_A2(1,:), transformed_A2(2, :), transformed_A2(3, :), transformed_A2(1, :));
    figure(3)
    fscatter3(merged_pc(1,:), merged_pc(2,:), merged_pc(3,:), merged_pc(1,:));
end