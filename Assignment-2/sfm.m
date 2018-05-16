function [M, S] = sfm(block, visualize)
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

    % Visualize
    if visualize
        figure()
        fscatter3(S(1,:), S(2,:), S(3,:), S(1,:));
    end
end

