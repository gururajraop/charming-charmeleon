function [matches, F1, F2, D1, D2] = keypoint_matching(image1, image2, threshold)
    if nargin == 2
        threshold = 10;
    end

    [F1, D1] = vl_sift(image1);
    [F2, D2] = vl_sift(image2);

    matches = vl_ubcmatch(D1, D2, threshold);
end