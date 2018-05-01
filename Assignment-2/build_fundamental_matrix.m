function [A, F] = build_fundamental_matrix(image, transformation)
    F = zeros(9,1);
    A = zeros(size(image,1)*size(image,2), 9);
end