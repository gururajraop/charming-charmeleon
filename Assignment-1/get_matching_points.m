function [A, N] = get_matching_points(A, B)
    N = zeros(size(A));
    for i=1:size(A, 1)
        current_point = A(i, :);
        dist = current_point - B;
        dist = sqrt(sum(dist .* dist, 2));
        [~, index] = min(dist);
        N(i, :) = B(index, :);
    end
end