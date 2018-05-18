function [pointviewMatrix, density, counter, counter2] = chaining3(path, threshold, distance_threshold)
    images = dir(strcat(path, '\', '\*.png'));
    images = [images; dir(strcat(path, '\', '\frame00000001.png'))];

    pointviewMatrix = [];
    % Store points added on the previous image pair
    points_added = [];
    counter = 0;
    counter2 = 0;
    
    matches = [];
    
    for i = 1:length(images) - 1
%     for i = 1:3
        fprintf("Progress: %d/%d image pairs\n", i, length(images) - 1);
        image1 = im2single(imread(strcat(path, images(i).name)));
        image2 = im2single(imread(strcat(path, images(i + 1).name)));
        [~, f1, f2, D1, D2] = keypoint_matching(image1, image2, threshold);
        
        % Store points added during the iteration
        new_points = [];
        index = [];
        matches = [];
        
        distances = pdist2(f1', f2');
        closePoints = distances < distance_threshold;
        
        for j = 1:size(f1, 2)
            local_index = find(closePoints(j, :));
            descr_im1 = D1(:, j);
            descr_close = D2(:, local_index);
            [match, score] = vl_ubcmatch(descr_im1, descr_close, threshold);
            if isempty(match) == 0
                original_index = local_index(match(2));
                match = [j; original_index; score];
                matches = [matches match];
            end
        end
        j = 0;
        
        matches_im2 = matches(2, :);
        unique_matches = unique(matches_im2);
        double_matches = unique_matches(1<histc(matches_im2,unique(matches_im2)));
        
        for j = 1:size(double_matches, 2)
            keypoint = double_matches(j);
            scores = matches(:, find(matches(2, :) == keypoint));
            
            if sum(min(scores(3, :)) * threshold < scores(3, :)) == length(scores(3, :)) - 1
                [~, min_index] = min(scores(3, :));
                winning_point = scores(:, index);
                matches(:, find(ismember(matches(2, :) , keypoint))) = [];
                matches = [matches winning_point];
                counter2 = counter2 + 1;
            else
                matches(:, find(matches(2, :) == keypoint)) = [];
            end
        end
        j = 0;
 
        if size(matches(1, :), 2) ~= size(unique(matches(1, :)), 2) || size(matches(2, :), 2) ~= size(unique(matches(2, :)), 2)
            first = size(matches(1, :))
            f_unique = size(unique(matches(1, :)))
            second = size(matches(2, :))
            s_unique = size(unique(matches(2, :)))
            counter = counter + 1
        end
        
        for j = 1:size(matches, 2)
            matches_index = matches(1:3, j);
            point1 = f1(1:2, matches_index(1));
            point2 = f2(1:2, matches_index(2));
            
            if i ~= 1
                index = find(points_added(1, :) == matches_index(1));
            end

            if isempty(index) == 0
                index_in_pvm = points_added(2, index);
                pointviewMatrix(i * 2 - 1, index_in_pvm) = point1(1);
                pointviewMatrix(i * 2, index_in_pvm) = point1(2);
                indices = [matches_index(2); index_in_pvm];
                new_points = [new_points indices]; 
            else
                pointviewMatrix = [pointviewMatrix zeros(size(images,1) * 2 - 2 ,1)];
                pointviewMatrix(i * 2 - 1, end) = point1(1);
                pointviewMatrix(i * 2, end) = point1(2);
                indices = [matches_index(2); size(pointviewMatrix, 2)];
                new_points = [new_points indices];
            end         
        end
        points_added = new_points;
        counter = counter + length(double_matches);
    end
    
    fprintf("More than one point matched to a single point: %d times\n", counter);
    fprintf("Recovered matches: %d\n", counter2);

    %% 
    
    density = nnz(pointviewMatrix)/prod(size(pointviewMatrix))
    figure()
    pointviewMatrix_inverted = double(~pointviewMatrix);
    imagesc(pointviewMatrix_inverted)
    colormap(gray)
    axis off
end
