function [] = icp()
    data = readPcd ("Data/data/0000000000.pcd ");
    data(data(:,3)>2, :) = [];
    A1 = data(:, 1:3);
    data = readPcd ("Data/data/0000000001.pcd ");
    data(data(:,3)>2, :) = [];
    A2 = data(:, 1:3);
    
    run_icp(A1, A2);
end