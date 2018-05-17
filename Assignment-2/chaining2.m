function pointviewMatrix = chaining2(path, threshold)    
    path = './Data/House/';
    images = dir(strcat(path, '\', '\*.png'));
    images = [images; dir(strcat(path, '\', '\frame00000001.png'))];

    pointviewMatrix = [];
    % Store points added on the previous image pair
%     points_added = [];
%     counter = 0
    
    keypoints_added = [];

    for i = 1:length(images) - 1
%     for i = 1:6
        fprintf("Progress: %d/%d image pairs\n", i, length(images) - 1);
        image1 = im2single(imread(strcat(path, images(i).name)));
        image2 = im2single(imread(strcat(path, images(i + 1).name)));
        [matches, f1, f2, D1, D2] = keypoint_matching(image1, image2, threshold);

        f1 = f1(:, matches(1, :));
        f2 = f2(:, matches(2, :));
        D1 = D1(:, matches(1, :));
        D2 = D2(:, matches(2, :));
        
        % Store points added during the iteration
%         new_points = [];
%         index = [];
        
        if i ~= 1
            [matching_descriptors, scores] = vl_ubcmatch(keypoints_added, D1, threshold);
            index_in_pvm = matching_descriptors(1, :);
            index_point = matching_descriptors(2, :);
            pointviewMatrix(i * 2 - 1, index_in_pvm) = f1(1, index_point);
            pointviewMatrix(i * 2, index_in_pvm) = f1(2, index_point);
            f1(:,index_point) = [];
            D1(:,index_point) = [];
        end
        
        added_matrix = zeros(size(images,1) * 2 - 2 , size(f1, 2));
        added_matrix(i * 2 - 1, :) = f1(1, :);
        added_matrix(i * 2, :) = f1(2, :);
        pointviewMatrix = [pointviewMatrix added_matrix];
        keypoints_added = [keypoints_added, D1];
    end
    
%     fprintf("Two points matched to a single point: %d times\n", counter);
    

    %%
    density = nnz(pointviewMatrix)/prod(size(pointviewMatrix));
    figure()
    pointviewMatrix_inverted = double(~pointviewMatrix);
    imagesc(pointviewMatrix_inverted)
    colormap(gray)
%     axis off
end
