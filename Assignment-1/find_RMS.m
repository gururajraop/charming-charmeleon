function [rms_value] = find_RMS(M, N)
    n = size(M, 1);
    diff = sum(sum((M-N) .* (M-N)));
    rms_value = sqrt(diff/n);
end