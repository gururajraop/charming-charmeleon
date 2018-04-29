function [R_accumulative, T_accumulative, A1, rms_values, mse_values] = run_icp(A1, A2, threshold, sample_type, sample_size, n)
    if nargin == 2
        threshold = 0.001;
        sample_type = 'random';
        sample_size = 1000;
        n = 25;
    elseif nargin == 3
        sample_type = 'random';
        sample_size = 1000;
        n = 25;
    elseif nargin == 4
        sample_size = 1000;
        n = 25;
    elseif nargin == 5
        n = 25;
    end
    R = eye(3);
    T = [0; 0; 0];
    
    R_accumulative = R;
    T_accumulative = T;
    
    done = true;
    iteration = 1;
    prev_rms = Inf('double');
    rms_values = [];
    mse_values = [];
    
    [M, ~] = get_matching_points(A1, A2, sample_type, sample_size);
    
    while (iteration < n+1 && done)
%         disp('Getting the matching points');
        if strcmp(sample_type, 'random') || strcmp(sample_type, 'regions')
            [M, N] = get_matching_points(A1, A2, sample_type, sample_size);
        else
            [~, N] = get_matching_points(M, A2, sample_type, sample_size);
        end
        
        % Compute the centroids and center the vectors
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
        
        % Define the total transformation by accumulating R and T
        R_accumulative = R_accumulative * R;
        T_accumulative = R * T_accumulative + T;
        
%         disp('Getting the new RMS value');
        rms_value = find_RMS(M, N, R, T);
        mse = immse(M,N);
        rms_values(end+1) = rms_value;
        mse_values(end+1) = mse;
        disp(sprintf('Iteration %d: rms value=%f, mse error=%f', iteration, rms_value, mse));
        if abs(rms_value - prev_rms) < threshold && iteration > 9
            done = false;
        end
        prev_rms = rms_value;
        iteration = iteration + 1;
%         disp('Tranforming the source points');
        A1 = R * A1 - T;
    end
end