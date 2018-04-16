function [R, T] = run_icp(A1, A2)
    R = eye(3);
    T = [0, 0, 0];
    
    done = true;
    iteration = 1;
    prev_rms = Inf('double');
    while (done && iteration < 100)
        tic
        [M, N] = get_matching_points(A1, A2, R, T);
        toc
        
        % Compute the centroids and center the vectors
        p_prime = (sum(M) / size(M, 1));
        q_prime = (sum(N) / size(N, 1));
        P = M - p_prime;
        Q = N - q_prime;
        
        % Get the covariance matrix
        S = P' * Q;
        
        % Perform the SVD operation
        [U, ~, V] = svd(S);
        
        % Find the new R and T values
        R = V*diag([1, 1, det(V*U')])*(U');
        T = q_prime - p_prime * R;
        
        rms_value = find_RMS(M, N);
        disp(sprintf('Iteration %d: rms value %f', iteration, rms_value));
        if abs(rms_value - prev_rms) < 0.001
            done = false;
        end
        prev_rms = rms_value;
        iteration = iteration + 1;
    end  
end