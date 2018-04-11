function [rms_value] = find_RMS(M, N, R, T)
    n = size(M, 1);
    diff = sum(M-N) .* (M-N);
    rms_value = sqrt((diff(1,1)+diff(1,2)+diff(1,3))/n);
end