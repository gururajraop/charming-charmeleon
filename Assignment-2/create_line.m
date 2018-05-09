function line = create_line(l, windowSize)
    % l is the line coeffificients 
    % the line is of the form ax+by+c=0
    % then l=[a,b,c]
    
    % Create x as image width
    x = 1:windowSize(2);
    % Find the y coordinate of y based on epipolar line
    y = - (l(1) * x + l(3)) / l(2);
    
    % Clip the indices outside image window
    index = y<windowSize(1) & y>0;
    x = x(index);
    y = y(index);
    
    % Create the line with line coordinates
    line = [x; y];
end