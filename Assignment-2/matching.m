function [] = matching(image1, image2)
    
    % Get the matching points
    [matches, f1, f2, ~, ~] = keypoint_matching(image1, image2);
    
    % Apply RANSAC on the matches to get the transformation
    [f1_new, t_new, transformation] = RANSAC(matches, f1, f2);
    
    % Plot the matching points
    plot_matching_points(image1, image2, t_new, f1, f1_new);

    % Obtain the fundamental matrix
    [A, F] = build_fundamental_matrix(image1, transformation);
    
    % Apply eight point algorithm
    eight_point(A, F);
end