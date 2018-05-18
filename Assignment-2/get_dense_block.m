function [denseBlock] = get_dense_block(pointviewMatrix)
    num_images = size(pointviewMatrix, 1);
    indices = sum(pointviewMatrix ~= 0) == num_images;
    denseBlock = pointviewMatrix(:, indices);
end