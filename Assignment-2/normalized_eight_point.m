function [F] = normalized_eight_point(f1, f2)

    mx1 = sum(f1(1,:)) / size(f1, 2);
    my1 = sum(f1(2,:)) / size(f1, 2);
    d1 = sum(sqrt((f1(1,:)-mx1).^2 + (f1(2,:)-my1).^2)) / size(f1, 2);
    
    T1 = [sqrt(2)/d1, 0, -mx1*sqrt(2)/d1; 0, sqrt(2)/d1, -my1*sqrt(2)/d1; 0, 0, 1];
    
    f1_new = ones(3, size(f1,2));
    f1_new(1:2,:) = f1(1:2,:);
    f1_new = T1 * f1_new;

    mx2 = sum(f2(1,:)) / size(f2, 2);
    my2 = sum(f2(2,:)) / size(f2, 2);
    d2 = sum(sqrt((f2(1,:)-mx2).^2 + (f2(2,:)-my2).^2)) / size(f2, 2);
    
    T2 = [sqrt(2)/d2, 0, -mx2*sqrt(2)/d2; 0, sqrt(2)/d2, -my2*sqrt(2)/d2; 0, 0, 1];
    
    f2_new = ones(3, size(f2,2));
    f2_new(1:2,:) = f2(1:2,:);
    f2_new = T1 * f2_new;

    % Obtain the fundamental matrix
    A = build_point_matrix(f1_new, f2_new);
    
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
end