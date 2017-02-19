% misc.f

function [x] = fun_smooth2(x,n,n1,n2)
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
        if ii<n1 | ii>n2, x(ii) = 0.54*xx + 0.23*(xl+xr); end
    end % 10
    if n1>1, x(1) = a; end
    if n2<n, x(n) = b; end
end