function [] = compare_sampling_methods()

    load('Data\source.mat', 'source');
    load('Data\target.mat', 'target');
    
    sample_size = 1000;
    threshold = 0.00001;
    n_iterations = 25;
    sample_types = ["all", "uniform", "random", "regions"];
    rms = {};
    mse = {};
    source_transformed = {};
    
    tic
    i = 1;
    for sample_type = sample_types
        disp(sprintf('Running ICP test for sample type: %s', sample_type));
        [~, ~, source_transformed{i}, rms{i}, mse{i}] = run_icp(source, target, threshold, ...
            sample_type, sample_size, n_iterations);
        i = i + 1;
    end
    toc

    % Plot the results from various sampling methods
    i = 1;
    figure()
    for sample_type = sample_types
        subplot(2,2,i)
        hold on;
        new = source_transformed{i};
        scatter3(source(1,:), source(2, :), source(3, :), 'b');
        scatter3(target(1,:), target(2, :), target(3, :), 'r');
        scatter3(new(1,:), new(2, :), new(3, :), 'g');
        legend('source', 'target', 'transformed source');
        title(sample_type);
        hold off
        i = i + 1;
    end
    
    % Plot the RMS value propagation for various sampling methods
    color = ["-r.", "-b^", "-g*", "-mo"];
    figure()
    hold on
    i = 1;
    for sample_type = sample_types
        iterations = 1:n_iterations;
        rms_values = zeros(1, n_iterations);
        rms_values(:, 1:size(rms{i}, 2)) = rms{i};
        rms_values(:, size(rms{i}, 2):end) = rms{i}(:, end);
        plot(iterations, rms_values, color(:,i), 'LineWidth', 2.0);
        i = i + 1;
    end
    legend(sample_types);
    title('RMS value propagation');
    hold off
        
    % Plot the MSE error propagation for various sampling methods
    figure()
    hold on
    i = 1;
    for sample_type = sample_types
        iterations = 1:n_iterations;
        mse_values = zeros(1, n_iterations);
        mse_values(:, 1:size(mse{i}, 2)) = mse{i};
        mse_values(:, size(mse{i}, 2):end) = mse{i}(:, end);
        plot(iterations, mse_values, color(:,i), 'LineWidth', 2.0);
        i = i + 1;
    end
    legend(sample_types);
    title('MSE error propagation');
    hold off
end