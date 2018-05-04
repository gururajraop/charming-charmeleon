function [] = image_matching(path)
    path1 = sprintf('%sframe00000001.png', path);
    path2 = sprintf('%sframe00000002.png', path);
    image1 = im2single(imread(path1));
    image2 = im2single(imread(path2));
    
    matching(image1, image2);  
end