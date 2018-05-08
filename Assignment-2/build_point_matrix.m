function [A] = build_point_matrix(f1, f2)
    A = zeros(size(f1,2), 9);
    
    % Initialize A using the matching point coordinates
    A(:, 1) = f1(1,:) .* f2(1,:);
    A(:, 2) = f1(1,:) .* f2(2,:);
    A(:, 3) = f1(1,:);
    A(:, 4) = f1(2,:) .* f2(1,:);
    A(:, 5) = f1(2,:) .* f2(2,:);
    A(:, 6) = f1(2,:);
    A(:, 7) = f2(1,:);
    A(:, 8) = f2(2,:);
    A(:, 9) = ones(size(f1,2),1);
end