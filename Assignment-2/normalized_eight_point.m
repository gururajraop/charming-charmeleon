function [F] = normalized_eight_point(f1, f2, normalize, T1, T2)
    if nargin == 2
        normalize = true;
    end
    
    % Get normalized coordinates if not normalized already
    if normalize
        [f1, T1] = normalization(f1);
        [f2, T2]= normalization(f2);
    end

    % Obtain the A matrix
    A = build_point_matrix(f1, f2);
    
    % Find SVD components of point matrix A
    [~, D, V] = svd(A);
    
    % Initialize F with column of V corresponding to min singular value
    [~,i] = min(diag(D));
    F = reshape(V(:,i), 3, 3)';
    
    % Correct the entries of F for singularity
    [Uf, Df, Vf] = svd(F);
    [~,i] = min(diag(Df));
    Df(i,i) = 0;
    
    % Update F with corrected values
    F = Uf * Df * Vf';
    F = reshape(F, 3,3);
    
    % Denormalize the fundamental matrix
    if normalize
        F = T2' * F' * T1;
    end
end