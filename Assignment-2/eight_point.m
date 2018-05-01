function [F] = eight_point(A)
    F = zeros(9,1);
    
    % Find SVD components of point matrix A
    [~, D, V] = svd(A);
    
    % Initialize F with column of V corresponding to min sigular value
    [~,i] = min(diag(D));
    F = V(:,i);
    
    % Correct the entries of F for sigularity
    [Uf, Df, Vf] = svd(F);
    [~,i] = min(Df);
    Df(i) = 0;
    
    % Update F with corrected values
    F = Uf * Df * Vf;
end