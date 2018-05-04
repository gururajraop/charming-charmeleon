function [] = matching(image1, image2)
    
    % Get the matching points
    [matches, f1, f2, ~, ~] = keypoint_matching(image1, image2);
    
    % Apply RANSAC on the matches to get the transformation
    [f1_new, ~, ~] = RANSAC(matches, f1, f2);
    
    % Plot the matching points
%     plot_matching_points(image1, image2, t_new, f1, f1_new);
    
    % Apply eight point algorithm
    F1 = eight_point(f1, f1_new);
    
    F2 = normalized_eight_point(f1, f1_new);
    
    F3 = normalized_eight_point_RANSAC(f1, f1_new)
end