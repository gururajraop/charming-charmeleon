function [] = plot_epipolar_lines(image, f, F, Title)
    figure()
    imshow(image);
    
    hold on;
    
    p = ones(3, size(f,2));
    p(1:2, :) = f(1:2,:);
    perm = randperm(size(p,2)) ;
    sel = perm(1:8);
    
    for s = sel
        l = F * p(:,s);
        line = create_line( l, size(image));
        
        plot(line(1,:), line(2,:), 'g-', 'LineWidth', 1.2);
        plot(p(1,s), p(2,s), 'o', 'MarkerSize', 5,...
            'MarkerEdgeColor','w','MarkerFaceColor','r');
    end
    
    hold off;
    title(Title);
end