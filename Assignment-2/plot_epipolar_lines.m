function [] = plot_epipolar_lines(image, f, F)
    figure()
    imshow(image);
    
    hold on;
    
    p = ones(3, size(f,2));
    p(1:2, :) = f(1:2,:);
    perm = randperm(size(p,2)) ;
    sel = perm(1:50);
    
    for s = sel
        l = F * p(:,s);
        l = l / norm(l);
        
        line = clipline( l, size(image)');
        plot(line(:,1), line(:,2), 'b-', 'LineWidth', 2);
    end
    
    hold off;
    title('Epipolar lines based on the fundamental matrix');
end