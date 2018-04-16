function [M, N] = get_matching_points(A, B, R, T)
    M = [];
    N = [];
    disp('Getting matching points');
    for i=1:size(A, 1)
        min_dist = Inf('double');
        M = [M; A(i, :)];
        index = 1;
        t = (R * A(i, :)')' - T;
        for j=1:size(B, 1)
            dist = sum(t - B(j, :));
            if dist < min_dist
                index = j;
            end
        end
        N = [N; B(index, :)];
    end
end