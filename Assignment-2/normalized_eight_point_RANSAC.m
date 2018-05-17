function [F] = normalized_eight_point_RANSAC(f1, f2, threshold, iterations)
    if nargin == 2
        threshold = 3;
        iterations = 100;
    elseif nargin == 3
        iterations = 100;
    end
    
    % Get the normalized coordinates
    [f1_new, T1] = normalization(f1);
    [f2_new, T2] = normalization(f2);
    
    
    % Find optimal F using RANSAC
    best_inliers = 0;
    best_inliers_index = [];
    
    for i = 1:iterations
        % Randomly sample eight point correspondences
        index = randsample(1:size(f1_new,2), 8);
        f1_sampled_points = f1_new(:, index);
        f2_sampled_points = f2_new(:, index);
        
        F = normalized_eight_point(f1_sampled_points, f2_sampled_points, false, T1, T2);
        
        % Apply Sampson distance threshold
        sampson = zeros(1, size(f1_new, 2));
        
        for j = 1:size(f1, 2)
            p1 = f1_new(1:3, j);
            p2 = f2_new(1:3, j);
            
            Fp1 = F * p1;
            FTp2 = F' * p2;
            
            numerator = (p2' * F * p1)^2;
            
            denominator = (Fp1(1)^2 + Fp1(2)^2 ... 
                + FTp2(1)^2 + FTp2(2)^2);
            
            sampson(j) = numerator / denominator;
        end
        inliers_index = find(sampson < threshold);
        inliers = length(inliers_index);
%         fprintf("\n\nIteration %d\n", i);
        
        if inliers > best_inliers
            best_inliers_index = inliers_index;
            best_inliers = inliers;
        end
    end
    
    % Recompute F using best inliers
    f1_best = f1(:, best_inliers_index);
    f2_best = f2(:, best_inliers_index);
    F = normalized_eight_point(f1_best, f2_best);
end