function [F] = normalized_eight_point(f1, f2, T1, T2) 
    % Get normalized coordinates if not normalized already
    if size(f1, 2) ~= 8
        [f1, T1] = normalization(f1);
        [f2, T2]= normalization(f2);
    end

    % Obtain the A matrix
    A = build_point_matrix(f1, f2);
    
    % Find SVD components of point matrix A
    [~, D, V] = svd(A);
    
    % Initialize F with column of V corresponding to min singular value
    [~,i] = min(diag(D));
    F = V(i,:)';
    
    % Correct the entries of F for singularity
    [Uf, Df, Vf] = svd(F);
    [~,i] = min(Df);
    Df(i) = 0;
    
    % Update F with corrected values
    F = Uf * Df * Vf;
    F = reshape(F, 3,3);
    
    % Denormalize the fundamental matrix
    F = T2' * F' * T1;
end