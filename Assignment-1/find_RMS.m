function [rms_value] = find_RMS(M, N, R, T)
    n = size(M, 2);
    M_transformed = R * M - T;
    diff = sum(sum((M_transformed - N) .* (M_transformed - N)));
    rms_value = sqrt(diff/n);
end