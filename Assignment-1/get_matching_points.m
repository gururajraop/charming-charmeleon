function [M, N] = get_matching_points(A, B, sample_type, sample_size)
    if nargin == 2
        sample_type = 'random';
        sample_size = 1000;
    elseif nargin == 3
        sample_size = 1000;
    end
    
    switch sample_type
        case 'all'
            M = A;
        case 'random'
            index = randsample(1:size(A,2), sample_size);
            M = A(:, index);
        case 'uniform'
            index = randsample(1:size(A,2), sample_size);
            M = A(:, index);
        case 'regions'
            % TODO: Implement the region based sampling
            M = A;
    end
    N = zeros(size(M));
    for i=1:size(M, 2)
        current_point = M(:, i);
        dist = current_point - B;
        dist = sqrt(sum(dist .* dist));
        [~, index] = min(dist);
        N(:, i) = B(:, index);
    end
end