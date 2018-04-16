function [] = icp_iterative()
   % Retrieve all pcd files and separate point clouds and normals.
    directory = 'Data\data\';
    
    point_clouds = dir(strcat(directory, '\', '\*.pcd'));
    normals_indices = contains({point_clouds.name}, 'normal.pcd');
    normals = point_clouds(normals_indices);
    point_clouds(normals_indices) = [];
    
    % Initialize a merged cloud outside of loop using the first .pcd.
    merged_pc = readPcd ("Data/data/0000000000.pcd ");
    merged_pc(merged_pc(:,3)>2, :) = [];
    merged_pc = merged_pc(:, 1:3);
    
    % Find camera poses for each pair and merge transformed clouds.
%     for i = 1:length(point_clouds)    
    for i = 1:1
        first = strcat(directory, point_clouds(i).name);
        second = strcat(directory, point_clouds(i + 1).name);
        A1 = readPcd(first);
        A2 = readPcd(second);
        
        % Remove background points with distance > 2 to the camera.
        A1(A1(:,3)>2, :) = [];
        A2(A2(:,3)>2, :) = [];
        
        % Remove 'rgb' entry from point clouds.
        A1 = A1(:, 1:3);
        A2 = A2(:, 1:3);
        
        % Find camera movement from A2 to A1
        [R, T] = run_icp(A2, A1);
        
        % Unsure of shape of R, so this probably does not work.
        transformed_A2 = A2 * R + T;
        
        % Would result in a 99 x 60k cloud, with many points close to or in
        % the same location?
        merged_pc = [merged_pc; transformed_A2];
    end
    
    % Visualize results.
    fscatter3(merged_pc(:,1), merged_pc(:, 2), merged_pc(:, 3), zeros(size(merged_pc(:, 1))));
end