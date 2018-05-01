function [A] = build_point_matrix(f1, f2, matches)
    F = zeros(9,1);
    A = zeros(size(matches,2), 9);
    
    % Initialize A using the matching point coordinates
    A(:, 1) = f1(1,matches(1,:)) .* f2(1,matches(2,:));
    A(:, 2) = f1(1,matches(1,:)) .* f2(2,matches(2,:));
    A(:, 3) = f1(1,matches(1,:));
    A(:, 4) = f1(2,matches(1,:)) .* f2(1,matches(2,:));
    A(:, 5) = f1(2,matches(1,:)) .* f2(2,matches(2,:));
    A(:, 6) = f1(2,matches(1,:));
    A(:, 7) = f2(1,matches(2,:));
    A(:, 8) = f2(2,matches(2,:));
    A(:, 9) = ones(size(matches,2),1);
    
end