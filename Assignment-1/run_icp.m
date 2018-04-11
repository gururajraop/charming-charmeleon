function [R, T] = run_icp(A1, A2)
    R = eye(3);
    T = [0, 0, 0];
    
    done = true;
    while done
        [M, N] = get_matching_points(A1, A2, R, T);
        rms_value = find_RMS(M, N, R, T);
        S = M' * N;
        [U, ~, V] = svd(S);
        R = V*diag([1, 1, det(U*V')])*(U');
        T = N - M*R;
        
        if rms_value < 0.001
            done = false;
        end
    end  
end