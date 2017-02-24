% rngkta.f
% [x,~,y,~,h,~,~,~,g,s,t]
% called by: fun_trace;
% call: none.

function [x,z,y,f,h,hmin,e,func,g,s,t] = fun_rngkta(x,z,y,f,h,hmin,e,func,g,s,t)
% routine to solve a 2x2 system of first order o.d.e.'s
% using the runge-kutta method with error control
% func 是一个函数参数

    % real y(2),f(2),t(2),s(2),g(2)
    % logical*1 be,bh,br,bx
    % logical bxx
    % common /rkcs/ bxx
    global ok;
    bxx = ok;

    bh = true;
    br = true;
    bx = true;
    bxx = true;
    if z > x & h < 0.0, h = -h; end
    if z < x & h > 0.0, h = -h; end

    % 10 % -------------------- circle 10 begin
    cycle10 = true;
    while cycle10
        xs = x;

        g(1) = y(1);
        g(2) = y(2);

        % 20 % -------------------- circle 20 begin
        cycle20 = true;
        while cycle20
            isGoto20 = false;

            hs = h;
            q = x + h - z;
            be = true;
            if (h>0.0 & q>=0.0) | (h<0.0 & q<=0.0)
                h = z - x;
                br = false;
            end
            h3 = h ./ 3;

            [x,y,f] = func(x,y,f);

            for ii = 1:2 % 210
                q = h3 .* f(ii);
                t(ii) = q;
                r = q;
                y(ii) = g(ii) + r;
            end % 210
            x = x + h3;

            [x,y,f] = func(x,y,f);

            for ii = 1:2 %220
                q = h3 .* f(ii);
                r = 0.5 .* (q+t(ii));
                y(ii) = g(ii) + r;
            end %220

            [x,y,f] = func(x,y,f);

            for ii = 1:2 %230
                q = h3 .* f(ii);
                r = 3.0 .* q;
                s(ii) = r;
                r = 0.375 .* (r+t(ii));
                y(ii) = g(ii) + r;
            end %230
            x = x + 0.5 .* h3;

            [x,y,f] = func(x,y,f);

            for ii = 1:2 % 240
                q = h3 .* f(ii);
                r = t(ii) + 4.0 .* q;
                t(ii) = r;
                r = 1.5 .* (r-s(ii));
                y(ii) = g(ii) + r;
            end % 240
            x = x + 0.5.*h;

            [x,y,f] = func(x,y,f);

            for ii = 1:2 % 250
                q = h3 .* f(ii);
                r = 0.5 .* (q+t(ii));
                q = abs(r+r-1.5.*(q+s(ii)));
                y(ii) = g(ii) + r;
                r = abs(y(ii));
                if r < 0.001
                    r = e;
                else
                    r = e .* r;
                end
                if q >= r & bx
                    br = true;
                    bh = false;
                    h = 0.5 .* h;
                    if abs(h) < hmin
                        sigh = 1.0;
                        if h < 0.0, sigh=-1.0; end
                        h = sigh .* hmin;
                        bx = false;
                        bxx = false;
                    end
                    y(1) = g(1);
                    y(2) = g(2);
                    x = xs;
                    isGoto20 = true; break; % go to 20 step1
                end
                if q>=0.03125.*r, be=false; end
            end % 250
            if isGoto20, continue; end % go to 20 step2
            break; % go to nothing
        end % -------------------- circle 20 end

        if be & bh & br
            h = h + h;
            bx = true;
        end
        bh = true;
        if br, continue; end % go to 10
        h = hs;
        break; % go to nothing
    end % -------------------- circle 10 end

    ok = bxx;
    return;

end % fun_rngkta end