function [] = icp_iterative()
   % Retrieve all pcd files and separate point clouds and normals.
    directory = 'Data\data\';
    
    point_clouds = dir(strcat(directory, '\', '\*.pcd'));
    normals_indices = contains({point_clouds.name}, 'normal.pcd');
%     normals = point_clouds(normals_indices);
    point_clouds(normals_indices) = [];
    
    % Initialize a merged cloud outside of loop using the first .pcd.
    merged_result = readPcd ("Data/data/0000000000.pcd ")';
    merged_result(:, merged_result(3, :)>2) = [];
    merged_result = merged_result(1:3, :);
    
    % Find camera poses for each pair and merge transformed clouds.
    for i = 1:(length(point_clouds)-1)
%     for i = 1:10
        disp(i);
        first = strcat(directory, point_clouds(i).name);
        second = strcat(directory, point_clouds(i + 1).name);
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
        [R, T, transformed_A1, ~, ~] = run_icp(A1, A2, 0.0001);
        toc
        
        merged_result = R * merged_result - T;
        
        % Would result in a 99 x 60k cloud, with many points close to or in
        % the same location?
        merged_result = [merged_result, transformed_A1];
    end
    
    % Visualize results.
    index = randsample(1:size(merged_result,2), 60000);
    F = merged_result(:, index);
%     F = merged_result;
    scatter3(F(1,:), F(2,:), F(3,:), 'r.');
end