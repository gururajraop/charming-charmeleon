function [] = plot_iterative(point_view_matrix, step_size, sample_size, affine)
    num_frames = size(point_view_matrix, 1) / 2;
    
    % Perform the initial sfm
    dense_block = get_dense_block(point_view_matrix(1:2*step_size, :));
    [~, S_prev] = sfm(dense_block, false);
    S_prev(3, :) = S_prev(3, :) * 10;
    
    final_points = S_prev;
    T = {};
    
    % Perform sfm iteratively from second frame onwards
    for frame = 2:num_frames-step_size+1
        % Get the dense block for the current frames
        start = 2*frame-1;
        stop = start + 2*step_size - 1;
        dense_block = get_dense_block(point_view_matrix(start:stop, :));
        
        % Perform the SFM
        [~, S_current] = sfm(dense_block, false);

        % Post processing for procrustes
        limit = min(size(S_prev, 2), size(S_current, 2));
        S_current(3, :) = S_current(3, :) * 10;
        
        % Get the transformation using procrustes
        [~, ~, Tr] = procrustes(S_prev(:, 1:limit), S_current(:, 1:limit));
        T{frame-1} = Tr;
        T{frame-1}.size = limit;
        
        % Transform the current frame usinf previous transformations
        current = S_current;
        for i=frame-1:-1:1
            l = min(size(current, 2), T{i}.size);
            current = T{i}.b * current(:,1:l) * T{i}.T(1:l, 1:l) + T{i}.c(:, 1:l);
        end
        
        % add it to the final points to be plotted
        final_points = [final_points, current];
        S_prev = S_current;
    end

    % Background removal and sampling
    final_points(:, abs(final_points(3, :))>10) = [];
    if sample_size < size(final_points, 2)
        index = randsample(1:size(final_points,2), sample_size);
    else
        index = randsample(1:size(final_points,2), size(final_points,2));
    end
    
    % Plotting
    figure()
    scatter3(final_points(1,:), final_points(2,:), final_points(3,:), 'b.');
    title('3D structure representation using iterative dense block');
    
%     plot_multiple_views(final_points(:, index));
end

function plot_multiple_views(S)
    figure()
    
    subplot(2,3,1);
    scatter3(S(1,:), S(2,:), S(3,:), 'b.');
    xlabel('x');
    ylabel('y');
    zlabel('z');
    view([ 30 40 ]);
    
    subplot(2,3,2);
    scatter3(S(1,:), S(2,:), S(3,:), 'b.');
    xlabel('x');
    ylabel('y');
    zlabel('z');
    view([ 0 0 ]);
    
    subplot(2,3,3);
    scatter3(S(1,:), S(2,:), S(3,:), 'b.');
    xlabel('x');
    ylabel('y');
    zlabel('z');
    view([ 180 0 ]);
    
    subplot(2,3,4);
    scatter3(S(1,:), S(2,:), S(3,:), 'b.');
    xlabel('x');
    ylabel('y');
    zlabel('z');
    view([ -90 0 ]);
    
    subplot(2,3,5);
    scatter3(S(1,:), S(2,:), S(3,:), 'b.');
    xlabel('x');
    ylabel('y');
    zlabel('z');
    view([ 0 90 ]);
    
    subplot(2,3,6);
    scatter3(S(1,:), S(2,:), S(3,:), 'b.');
    xlabel('x');
    ylabel('y');
    zlabel('z');
    view([ 0 -90 ]);
end