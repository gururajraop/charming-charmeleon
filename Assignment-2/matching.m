function [] = matching(image1, image2)
    
    % Get the matching points
    [matches, F1, F2, D1, D2] = keypoint_matching(image1, image2);
    
    % Apply RANSAC on the matches to get the transformation
    [F1_new, t_new, transformation] = RANSAC(matches, F1, F2);
    size(t_new)
    size(transformation)
    size(matches)
    
    % Plot the matching points
%     plot_matching_points(image1, image2, t_new, F1, F1_new);

    % Obtain the fundamental matrix
    A = build_fundamental_matrix();
    
    % Apply eight point algorithm
    eight_point(A);
end