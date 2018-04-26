% Merging Scenes - 3.2
%
% Estimate camera poses from each consecutive frame to the merged point
% cloud of preceding frames, and merge with that cloud.
function merged_pc = icp_3_2(step, sampling)
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
    color = [ones(1, size(merged_pc, 2))];
    color(1, 1) = 10;
    
    for i = 1:step:length(point_clouds) - step
%     for i = 1:step:7 * step - step
        fprintf('Current frame: %d/%d\n', i, length(point_clouds));
        target = strcat(directory, point_clouds(i + 1).name);
        A2 = readPcd(target)';
        
        % Remove background points with distance > 2 to the camera
        A2(:, A2(3,:)>2) = [];
        
        % Remove 'rgb' entry from point clouds
        A2 = A2(1:3, :);
        
        % Find camera movement from A2 to A1
        tic
        [R, T, ~, ~, ~] = run_icp(merged_pc, A2, 0.0000001, sampling);
        toc
        
        % Transform merged cloud using camera movement and merge with
        % target
        merged_pc = R * merged_pc - T;
        merged_pc = [merged_pc, A2];
        color = [color ones(1, size(A2, 2)) * i + step];
    end
    
    %%
    % Visualize results
    figure()
    fscatter3(merged_pc(1,:), merged_pc(2,:), merged_pc(3,:), color');
end