function [F] = eight_point(f1, f2)

    % Obtain the fundamental matrix
    A = build_point_matrix(f1, f2);
    
    % Find SVD components of point matrix A
    [~, D, V] = svd(A);
    
    % Initialize F with column of V corresponding to min sigular value
    [~,i] = min(diag(D));
    F = V(i,:)';
    
    % Correct the entries of F for sigularity
    [Uf, Df, Vf] = svd(F);
    [~,i] = min(Df);
    Df(i) = 0;
    
    % Update F with corrected values
    F = Uf * Df * Vf;
    F = reshape(F, 3, 3);
end