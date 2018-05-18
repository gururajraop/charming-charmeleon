function [] = plot_iterative(point_view_matrix, step_size, sample_size)
    num_frames = size(point_view_matrix, 1) / 2;
    
    % Perform the initial sfm
    dense_block = get_dense_block(point_view_matrix(1:2*step_size, :));
    [~, S_prev] = sfm(dense_block, false);
%     S_prev(3, :) = S_prev(3, :) * 10;
    
    final_points = S_prev;
    T = {};
    
    % Perform sfm iteratively from second frame onwards
    for frame = 2:num_frames-step_size+1
        start = 2*frame-1;
        stop = start + 2*step_size - 1;
        dense_block = get_dense_block(point_view_matrix(start:stop, :));
        
        [~, S_current] = sfm(dense_block, false);

        limit = min(size(S_prev, 2), size(S_current, 2));
%         S_current(3, :) = S_current(3, :) * 10;
        
        % TO DO: Fix this using correct matching points
        [~, ~, Tr] = procrustes(S_prev(:, 1:limit), S_current(:, 1:limit));
        T{frame-1} = Tr;
        T{frame-1}.size = limit;
        
        current = S_current;
        for i=frame-1:-1:1
            current = T{i}.b * current(:,1:T{i}.size) * T{i}.T + T{i}.c;
        end
        
        final_points = [final_points, current];
        S_prev = S_current;
    end

    final_points(:, abs(final_points(3, :))>1) = [];
    figure()
    scatter3(final_points(1,:), final_points(2,:), final_points(3,:), 'b.');
end