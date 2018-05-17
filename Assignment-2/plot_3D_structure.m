function [] = plot_3D_structure(point_view_matrix, step_size, sample_size)
    num_frames = size(point_view_matrix, 1);
    
    % Perform the initial sfm
    dense_block = get_dense_block(point_view_matrix(1:step_size, :));
    [~, S_prev] = sfm(dense_block, false);
    index = randsample(1:size(S_prev, 2), sample_size);
    S_prev = S_prev(:, index);
    S_prev(3, :) = S_prev(3, :) * 10;
    
    final_points = S_prev;
    
    for frame = 2:num_frames-step_size
        dense_block = get_dense_block(point_view_matrix(frame:frame+step_size-1, :));
        [~, S_current] = sfm(dense_block, false);
        index = randsample(1:size(S_current, 2), sample_size);
        S_current = S_current(:, index);
        S_current(3, :) = S_current(3, :) * 10;
        [~, Z, ~] = procrustes(S_current, S_prev);
        final_points = [final_points, Z];
        S_prev = S_current;
    end

    final_points(:, abs(final_points(3, :))>3) = [];
    figure()
    fscatter3(final_points(1,:), final_points(2,:), final_points(3,:), final_points(1,:));
end