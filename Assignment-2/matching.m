function [] = matching(image1, image2)
    
    % Get the matching points
    [matches, f1, f2, ~, ~] = keypoint_matching(image1, image2);
    
    % Apply RANSAC on the matches to get the transformation
    [f1_new, t_new, ~] = RANSAC(matches, f1, f2);
    
    % Extract the feature points only from foreground
    f1_foreground = f1(:, matches(1, :));
    f1_foreground_new = f1_new(:, matches(1, :));
    
%     % Plot the matching points
    plot_matching_points(image1, image2, t_new, f1, f1_new);
    
    % Apply eight point algorithm
    disp('Basic eight point algorithm');
    F1 = eight_point(f1_foreground, f1_foreground_new);
    check_correctness(F1, f1_foreground, f1_foreground_new);
    plot_epipolar_lines(image2, f1_foreground, F1);
    
    disp('Normalized eight point algorithm');
    F2 = normalized_eight_point(f1_foreground, f1_foreground_new);
    check_correctness(F2, f1_foreground, f1_foreground_new);
    plot_epipolar_lines(image2, f1_foreground, F2);

    disp('Normalized eight point algorithm using RANSAC');
    F3 = normalized_eight_point_RANSAC(f1_foreground, f1_foreground_new, 0.01, 1000);
    check_correctness(F3, f1_foreground, f1_foreground_new);
    plot_epipolar_lines(image2, f1_foreground, F3);
end

function [] = check_correctness(F, f1, f2)
    p1 = ones(3, size(f1, 2));
    p2 = ones(3, size(f2, 2));
    p1(1:2, :) = f1(1:2, :);
    p2(1:2, :) = f2(1:2, :);
    
    out = zeros(1,size(f1,2));
    for i=1:size(out,2)
        out(1,i) = p1(:,i)' * F * p2(:,i);
    end
    
    if any(out > 1)
        disp('Error! Fundamental matrix does not satisfy the correspondence condition');
    else
        disp('Calculated fundamental matrix passes the correspondence test');
    end
    
    if det(F) > 0.000001
        disp('Error! Fundamental matrix does not satisfy the determinant condition');
    else
        disp('Calculated fundamental matrix passes the determinant test');
    end
end