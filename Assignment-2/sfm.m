function [M, S] = sfm(block, visualize, affine)
    if nargin == 2
        affine = false;
    end
    % Center each view in the dense block
    block = block - mean(block, 2);

    % Apply SVD to the dense block
    [U,W,V] = svd(block);

    % Use first three singular values
    U = U(:, 1:3);
    W = W(1:3, 1:3);
    V = V(:, 1:3);

    % Factorize into M and S
    M = U * sqrtm(W);
    S = sqrtm(W) * V';
    
    % Affine ambiguity removal
    if affine
        MInverse = pinv(M);
        L = mldivide(M, transpose(MInverse));
        C = chol(L, 'lower');
        M = M * C;
        S = mldivide(C, S);
    end

    % Visualize
    if visualize
        figure()
        fscatter3(S(1,:), S(2,:), S(3,:), S(1,:));
    end
end

