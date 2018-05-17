function [F] = eight_point(f1, f2)

    % Obtain the fundamental matrix
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
    F = reshape(F, 3, 3);
end