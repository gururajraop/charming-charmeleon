function [] = plot_iterative(point_view_matrix, step_size, sample_size)
    num_frames = size(point_view_matrix, 1) / 2;
    
    % Perform the initial sfm
    dense_block = get_dense_block(point_view_matrix(1:2*step_size, :));
    [~, S_prev] = sfm(dense_block, false);
    index = randsample(1:size(S_prev, 2), sample_size);
    S_prev = S_prev(:, index);
    S_prev(3, :) = S_prev(3, :) * 10;
    
    final_points = S_prev;
    
    % Perform sfm iteratively from second frame onwards
    for frame = 2:num_frames-step_size+1
        start = 2*frame-1;
        stop = start + 2*step_size - 1;
        dense_block = get_dense_block(point_view_matrix(start:stop, :));
        
        [~, S_current] = sfm(dense_block, false);
        
%         index = randsample(1:size(S_current, 2), sample_size);
        S_current = S_current(:, index);
        S_current(3, :) = S_current(3, :) * 10;
        
        % TO DO: Fix this using correct matching points
        [~, Z, ~] = procrustes(S_current, S_prev);
        
        final_points = [final_points, Z];
        S_prev = Z;
    end

    final_points(:, abs(final_points(3, :))>10) = [];
    figure()
    scatter3(final_points(1,:), final_points(2,:), final_points(3,:), 'm.');
end