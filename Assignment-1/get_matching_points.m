function [M, N] = get_matching_points(A, B, sample_type, sample_size, match_type)
    if nargin == 2
        sample_type = 'random';
        sample_size = 1000;
        match_type = 'brute_force';
    elseif nargin == 3
        sample_size = 1000;
        match_type = 'brute_force';
    elseif nargin == 4
        match_type = 'brute_force';
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
    
    switch match_type
        case 'brute_force'
            N = match_brute_force(M, B);
        case 'kdTree'
            N = match_kdTree(M, B);
        case 'delaunay'
            N = match_delaunay(M, B);
        otherwise
            error('Unknown matching technique. Please use brute_force or kdTree option');
    end
end

function [N] = match_brute_force(M, B)
    N = zeros(size(M));
    for i=1:size(M, 2)
        current_point = M(:, i);
        dist = current_point - B;
        dist = sqrt(sum(dist .* dist));
        [~, index] = min(dist);
        N(:, i) = B(:, index);
    end
end

function [N] = match_kdTree(M, B)
    idx = knnsearch(B', M');
    N = B(:, idx);
end

function [N] = match_delaunay(M, B)
    DT = delaunayTriangulation(B');
    idx = nearestNeighbor(DT, M');
    N = B(:, idx);
end