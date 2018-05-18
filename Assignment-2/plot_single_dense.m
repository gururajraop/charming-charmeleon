function [] = plot_single_dense(pvm, affine)
    block = get_dense_block(pvm);

    [~, S] = sfm(block, false, affine);
    S(3, :) = S(3, :) * 10;
    
    figure()
    scatter3(S(1,:), S(2,:), S(3,:), 'b.');
    title('3D structure representation using single dense block');
    
%     plot_multiple_views(S);
end

function plot_multiple_views(S)
    figure()
    
    subplot(2,3,1);
    scatter3(S(1,:), S(2,:), S(3,:), 'b.');
    xlabel('x');
    ylabel('y');
    zlabel('z');
    view([ 30 40 ]);
    
    subplot(2,3,2);
    scatter3(S(1,:), S(2,:), S(3,:), 'b.');
    xlabel('x');
    ylabel('y');
    zlabel('z');
    view([ 0 0 ]);
    
    subplot(2,3,3);
    scatter3(S(1,:), S(2,:), S(3,:), 'b.');
    xlabel('x');
    ylabel('y');
    zlabel('z');
    view([ 180 0 ]);
    
    subplot(2,3,4);
    scatter3(S(1,:), S(2,:), S(3,:), 'b.');
    xlabel('x');
    ylabel('y');
    zlabel('z');
    view([ -90 0 ]);
    
    subplot(2,3,5);
    scatter3(S(1,:), S(2,:), S(3,:), 'b.');
    xlabel('x');
    ylabel('y');
    zlabel('z');
    view([ 0 90 ]);
    
    subplot(2,3,6);
    scatter3(S(1,:), S(2,:), S(3,:), 'b.');
    xlabel('x');
    ylabel('y');
    zlabel('z');
    view([ 0 -90 ]);
end