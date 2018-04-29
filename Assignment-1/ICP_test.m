function [] = ICP_test(test_scene, sample_type, sample_size, threshold, n_iterations, matching_type)
    switch test_scene
        case 'wave'
            load('Data\source.mat', 'source');
            load('Data\target.mat', 'target');
        case 'human_head'
            A1 = readPcd ("Data/data/0000000000.pcd")';
            A2 = readPcd ("Data/data/0000000005.pcd")';
            A1(:, A1(3,:)>2) = [];
            A2(:, A2(3,:)>2) = [];
            source = A1(1:3, :);
            target = A2(1:3, :);
        otherwise
            error('Wrong test scene type');
    end
    
    tic
    [~, ~, source_transformed, rms, mse] = run_icp(source, target, threshold, ...
        sample_type, sample_size, n_iterations, matching_type);
    toc
    
    if strcmp(test_scene, 'human_head')
        index = randsample(1:60000, 10000);
        source = source(:, index);
        target = target(:, index);
        source_transformed = source_transformed(:, index);
    end
    figure()
    subplot(2,2,1)
    scatter3(source(1,:), source(2, :), source(3, :), 'b'); title('source');
    subplot(2,2,2)
    scatter3(target(1,:), target(2, :), target(3, :), 'r'); title('target');
    subplot(2,2,3)
    hold on;
    scatter3(source(1,:), source(2, :), source(3, :), 'b');
    scatter3(target(1,:), target(2, :), target(3, :), 'r');
    scatter3(source_transformed(1,:), source_transformed(2, :), source_transformed(3, :), 'g');
    legend('source', 'target', 'transformed source');
    title('Merged scene');
    hold off
    subplot(2,2,4)
    iterations = 1:size(rms, 2);
    plot(iterations, rms, '-r.', iterations, mse, '-b*');
    legend('RMS values', 'MSE error');
    title('RMS and MSE error propagation');
end