function [f1_new, t_new, best_x] = RANSAC(t, f1, f2)
    n = randi([15, 100]);
    
    best_inliers = 0;
    best_x = [1 1 0; 1 1 0];
    
    for i = 1:n
        
        perm = randperm(size(t, 2));
        perm_n = randi([1, round(size(t, 2) / 3)]);
        p = perm(1:perm_n);
     
        A = zeros(2*perm_n, 6);
        b = zeros(2*perm_n, 1);
        
        c = 1;
        for p_i = p
            f1_index = t(1, p_i);
            f2_index = t(2, p_i);
            r1 = [f1(1, f1_index) f1(2, f1_index) 0 0 1 0];
            r2 = [0 0 f1(1, f1_index) f1(2, f1_index) 0 1];
            A(2*c-1:2*c, :) = [r1; r2];
            b(2*c-1:2*c) = [f2(1, f2_index); f2(2, f2_index)];
            c = c + 1;
        end

        x = pinv(A)*b;
        
        inliers = 0;
        for j = 1:size(t, 2)
             f1_index = t(1, j);
             f2_index = t(2, j);
             f1_new = reshape(x(1:4), 2, 2)' * f1(1:2, f1_index) + reshape(x(5:6), 2, 1);
             diff = abs(f2(1:2, f2_index) - f1_new);
             if diff(1) < 10 && diff(2) < 10
                 inliers = inliers + 1;
             end
        end
        
        if inliers > best_inliers
            best_x = x;
            best_inliers = inliers;
        end
    end
    
    f1_new = zeros(size(f1));
    for j = 1:size(f1, 2)
        f1_index = j;
        f1_new(1:2, j) = reshape(best_x(1:4), 2, 2)' * f1(1:2, f1_index) + reshape(best_x(5:6), 2, 1); 
        f1_new(3:4, j) = f1(3:4, f1_index);
    end
    
    t_new = [t(1, :); t(1, :)];  
end