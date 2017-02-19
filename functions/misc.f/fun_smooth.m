% misc.f

function [x] = fun_smooth(x,n)
% three point triangular smoothing filter

    m = n-1;
    a = 0.77*x(1) + 0.23*x(2);
    b = 0.77*x(n) + 0.23*x(m);
    xx = x(1);
    xr = x(2);
    for ii = 2:m
        xl = xx;
        xx = xr;
        xr = x(ii+1);
        x(ii) = 0.54*xx + 0.23*(xl+xr);
    end % 10
    x(1) = a;
    x(n) = b;
end