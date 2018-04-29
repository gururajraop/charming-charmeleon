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
            maxB = max(B, [], 2);
            minB = min(B, [], 2);
                       
            A(:, A(1,:) > maxB(1)) = [];
            A(:, A(2,:) > maxB(2)) = [];
            A(:, A(3,:) > maxB(3)) = [];
          
            A(:, A(1,:) < minB(1)) = [];
            A(:, A(2,:) < minB(2)) = [];
            A(:, A(3,:) < minB(3)) = [];
            
            index = randsample(1:size(A,2), sample_size);
            M = A(:, index);
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