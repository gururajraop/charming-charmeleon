function pointviewMatrix = chaining(path)
    path = './Data/House/';

    images = dir(strcat(path, '\', '\*.png'));
    images = [images; dir(strcat(path, '\', '\frame00000001.png'))];

    pointviewMatrix = [];
    % Store points added on the previous image pair
    points_added = [];
    counter = 0

    for i = 1:length(images) - 1
    % for i = 1:1
        fprintf("Progress: %d/%d image pairs\n", i, length(images) - 1);
        image1 = im2single(imread(strcat(path, images(i).name)));
        image2 = im2single(imread(strcat(path, images(i + 1).name)));
        [matches, f1, f2, ~, ~] = keypoint_matching(image1, image2);

        % Store points added during the iteration
        new_points = [];
        index = [];

        for j = 1:size(matches, 2)
            matches_index = matches(1:2, j);
            point1 = f1(1:2, matches_index(1));
            point2 = f2(1:2, matches_index(2));


            if j ~= 1 && isempty(find(new_points(1, :) == matches_index(2))) == 0
                counter = counter + 1;
                continue
            end

            if i ~= 1
                index = find(points_added(1, :) == matches_index(1));
            end

            if isempty(index) == 0
                index_in_pvm = points_added(2, index);
                pointviewMatrix(i, index_in_pvm) = 1;
                indices = [matches_index(2); index_in_pvm];
                new_points = [new_points indices]; 
            else
                pointviewMatrix = [pointviewMatrix zeros(size(images,1) ,1)];
                pointviewMatrix(i, end) = 1;
                indices = [matches_index(2); size(pointviewMatrix, 2)];
                new_points = [new_points indices];
            end         
        end
        points_added = new_points;
    end
    fprintf("Two points matched to a single point: %d times\n", counter);
    

    %%
    figure()
    spy(pointviewMatrix, 'sk');
    pbaspect([2 1 1])
    %%
    figure()
    pointviewMatrix_inverted = ~pointviewMatrix;
    imshow(pointviewMatrix_inverted);
    daspect([1 1 1])
    %%
    figure()
    [y,x] = find(pointviewMatrix);
    scatter(x,y,'s', 'MarkerEdgeColor', 'k',...
              'MarkerFaceColor','k', 'SizeData', 2);
    set ( gca, 'ydir', 'reverse' )
end
