function [R, T] = run_icp(A1, A2, threshold)
    if nargin == 2
        threshold = 0.001;
    end
    R = eye(3);
    T = [0; 0; 0];
    
    done = true;
    iteration = 1;
    prev_rms = Inf('double');
    while (done && iteration < 10)
%         disp('Getting the matching points');
        [M, N] = get_matching_points(A1, A2);
        
        % Compute the centroids and centr the vectors
%         disp('Getting the centroids');
        p_prime = (sum(M, 2) / size(M, 2));
        q_prime = (sum(N, 2) / size(N, 2));
        P = M - p_prime;
        Q = N - q_prime;
        
        % Get the covariance matrix
        S = P * Q';
        
        % Perform the SVD operation
%         disp('SVD operation');
        [U, ~, V] = svd(S);
        
        % Find the new R and T values
%         disp('Updating rotation and transformation matrix');
        R = V*diag([1, 1, det(V*U')])*(U');
        T = R * p_prime - q_prime;
        
%         disp('Getting the new RMS value');
        rms_value = find_RMS(M, N, R, T);
        disp(sprintf('Iteration %d: rms value %f', iteration, rms_value));
        if abs(rms_value - prev_rms) < threshold
            done = false;
        end
        prev_rms = rms_value;
        iteration = iteration + 1;
%         disp('Tranforming the source points');
        A1 = R * A1 - T;
    end  
end