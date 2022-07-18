%(1/8)[-z^2 - 2z^-1 - 2z^1 + z^2]
function y = ecgderive(x)
    n = length(x);
    y(1) = 0;
    y(2) = 0;
    for i = 3:(n-5)
        y(i) = (1/8) * (-x(i-2) - (2*x(i-1)) + (2*x(i+1)) + x(i+2) );
    end
end