function [f_new, T] = normalization(f)
    % Get the normalization constants
    mx = sum(f(1,:)) / size(f, 2);
    my = sum(f(2,:)) / size(f, 2);
    d = sum(sqrt((f(1,:)-mx).^2 + (f(2,:)-my).^2)) / size(f, 2);
    
    % Construct the normalization matrix
    T = [sqrt(2)/d, 0, -mx*sqrt(2)/d; 0, sqrt(2)/d, -my*sqrt(2)/d; 0, 0, 1];
    
    % Get the normalized coordinates
    p = ones(3, size(f,2));
    p(1:2,:) = f(1:2,:);
    p = T * p;
    
    f_new = f;
    f_new(1:2, :) = p(1:2, :);
end

