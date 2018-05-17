function [] = plot_single_dense(pvm)
    [~, S] = sfm(pvm, false);
    S(3, :) = S(3, :) * 10;
    
    figure()
    scatter3(S(1,:), S(2,:), S(3,:), 'b.');
    title('3D structure representation using single dense block');
end