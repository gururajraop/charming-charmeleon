function pointviewMatrix = chaining(path, threshold)
    images = dir(strcat(path, '\', '\*.png'));
    images = [images; dir(strcat(path, '\', '\frame00000001.png'))];

    pointviewMatrix = [];
    % Store points added on the previous image pair
    points_added = [];
    counter = 0;

    for i = 1:length(images) - 1
        fprintf("Progress: %d/%d image pairs\n", i, length(images) - 1);
        image1 = im2single(imread(strcat(path, images(i).name)));
        image2 = im2single(imread(strcat(path, images(i + 1).name)));
        [matches, f1, f2, ~, ~] = keypoint_matching(image1, image2, threshold);

        % Store points added during the iteration
        new_points = [];
        index = [];

        for j = 1:size(matches, 2)
            matches_index = matches(1:2, j);
            point1 = f1(1:2, matches_index(1));
            point2 = f2(1:2, matches_index(2));

%             if j ~= 1 && isempty(find(new_points(1, :) == matches_index(2))) == 0
%                 counter = counter + 1;
%                 continue
%             end

            if i ~= 1
                index = find(points_added(1, :) == matches_index(1));
                if length(index) > 1
                    counter = counter + 1;
                    index = [];
                end
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
    end
    
    fprintf("Two points matched to a single point: %d times\n", counter);
    

    %% 
    
    density = nnz(pointviewMatrix)/prod(size(pointviewMatrix));
    figure()
    pointviewMatrix_inverted = double(~pointviewMatrix);
    imagesc(pointviewMatrix_inverted)
    colormap(gray)
    axis off
end
