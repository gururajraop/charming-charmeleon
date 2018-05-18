% Baseline method using chaining to previously added matches
function pointviewMatrix = chaining(path, threshold)
    images = dir(strcat(path, '\', '\*.png'));
    images = [images; dir(strcat(path, '\', '\frame00000001.png'))];

    pointviewMatrix = [];
    points_added = [];
    counter = 0;

    for i = 1:length(images) - 1
        fprintf("Progress: %d/%d image pairs\n", i, length(images) - 1);
        image1 = im2single(imread(strcat(path, images(i).name)));
        image2 = im2single(imread(strcat(path, images(i + 1).name)));
        [matches, f1, f2, ~, ~] = keypoint_matching(image1, image2, threshold);

        new_points = [];
        index = [];
        
        % Remove double (or more) matchings to a single im2 keypoint
        matches_im2 = matches(2, :);
        unique_matches = unique(matches_im2);
        double_matches = unique_matches(1<histc(matches_im2,unique(matches_im2)));
        matches(:, find(ismember(matches_im2 , double_matches))) = [];
        
        for j = 1:size(matches, 2)
            matches_index = matches(1:2, j);
            point1 = f1(1:2, matches_index(1));
            point2 = f2(1:2, matches_index(2));
            
            % Find index if the point was matched on the previous iteration
            if i ~= 1
                index = find(points_added(1, :) == matches_index(1));
            end
            
            if isempty(index) == 0 % Add coordinates at index
                index_in_pvm = points_added(2, index);
                pointviewMatrix(i * 2 - 1, index_in_pvm) = point1(1);
                pointviewMatrix(i * 2, index_in_pvm) = point1(2);
                indices = [matches_index(2); index_in_pvm];
                new_points = [new_points indices]; 
            else % Add new column if index is empty
                pointviewMatrix = [pointviewMatrix zeros(size(images,1) * 2 - 2 ,1)];
                pointviewMatrix(i * 2 - 1, end) = point1(1);
                pointviewMatrix(i * 2, end) = point1(2);
                indices = [matches_index(2); size(pointviewMatrix, 2)];
                new_points = [new_points indices];
            end         
        end
        % Store points added for the next iteration
        points_added = new_points;
        counter = counter + size(double_matches, 2);
    end
    
    fprintf("Two points matched to a single point: %d times\n", counter);
    
    %% Visualize results and calculate density
    density = nnz(pointviewMatrix)/prod(size(pointviewMatrix))
    figure()
    pointviewMatrix_inverted = double(~pointviewMatrix);
    imagesc(pointviewMatrix_inverted)
    colormap(gray)
    axis off
end
