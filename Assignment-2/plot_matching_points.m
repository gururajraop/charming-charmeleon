function [] = plot_matching_points(image1, image2, matches, F1, F2) 
    [~, w, ~] = size(image1);
    
    figure();
    imshowpair(image1, image2, 'montage');
    hold on;
    
    perm = randperm(size(matches,2)) ;
    sel = perm(1:10);
    
    for s = sel
        F1_index = matches(1, s);
        F2_index = matches(2, s);
        
        data1 = F1(:, F1_index);
        h1 = vl_plotframe(data1);
        set(h1,'color','r','linewidth',2);
        
        data2 = F2(:, F2_index);
        data2(1) = data2(1) + w;        
        
        h2 = vl_plotframe(data2);        
        set(h2,'color','r','linewidth',2);
        
        plot([data1(1) data2(1)], [data1(2) data2(2)], 'b-', 'LineWidth', 2);
    end
    
    hold off;
    title('Matching points in 2 images');
end