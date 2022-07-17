function y = movingInt(x, win_width)
    scale = (1 / win_width);
    y = 0;
    for i = 1:win_width
        y = y + (scale * x(i));
end
