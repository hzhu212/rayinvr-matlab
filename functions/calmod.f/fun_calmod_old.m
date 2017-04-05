% calmod.f
% [~,~,poisb,poisl,~,invr,iflagm,~,xmin1d,xmax1d,~,~,~]
% called by: main;
% call: fun_cvcalc; fun_smooth; fun_smooth2; fun_vel; done.

function [ncont,pois,poisb,poisl,poisbl,invr,iflagm,ifrbnd,xmin1d,xmax1d,insmth,xminns,xmaxns] = fun_calmod(ncont,pois,poisb,poisl,poisbl,invr,iflagm,ifrbnd,xmin1d,xmax1d,insmth,xminns,xmaxns);
% calculate model parameters now for use later in program
% ncont: 模型总层数（包括最后一层）
% pois: Poisson's ratio，数组，保存模型中每一层的泊松比
% poisl: Poisson layer, 数组，泊松比的层索引
% poisb: Poisson block, 数组，泊松比的块索引（模型中每层包含许多小块）
% poisbl: 数组，按照poisl和poisb两个索引来存储的泊松比，将会覆盖pois数组的内容
% iflagm: i-flag-model,代表模型是否有误，0-正常，1-模型错误
% invr: 计算所选定模型参数的偏微分，并把结果写入到i.out文件
% ifrbnd: 为1说明读取了f.in文件
% insmth: 非-smooth，数组，列出未使用光滑边界模拟的层面
% xminns,xmaxns: 限定最小模型距离和最大模型距离，当ibsmth=1或2时，insmth
%   中所列出的层一旦超出该范围将不做光滑处理
% pncntr: player+1，player为模型分层数，pncntr则为模型层界面数

    % global file_rayinvr_par file_rayinvr_com;
    % global fID_12;
    % run(file_rayinvr_par);
    % run(file_rayinvr_com);

    global fID_12;
    global b cosmth c cz dvmax dsmax idvmax idsmax ivarz ivarv ivv ivg izv ...
        ivarf iblk idump ibsmth layer ldvmax ldsmax nzed nvel nlayer ...
        nvar nblk npbnd nfrefl npfref nbsmth papois pnsmth ppcntr ppvel ...
        player pncntr partyp parorg ptrap pnvar pi18 s vsvp vm vf xm xvel ...
        xmax xbnd xmin xsinc zm zfrefl;

    % xa = zeros(1,2*(ppcntr+ppvel));

    xa = [];
    zsmth = zeros(1,pnsmth);
    % zsmth = [];
    iflagm = 0;
    idvmax = 0;
    idsmax = 0;

    % 1. 检查形状模型是否有误
    for ii = 1:ncont % 10
        for jj = 1:ppcntr % 20
            if abs(xm(ii,jj)-xmax) < 0.0001, break; end % go to 30
            nzed(ii) = nzed(ii) + 1;
        end % 20
        % 30
        if nzed(ii) > 1
            for jj = 1: nzed(ii)-1 % 40
                if xm(ii,jj) >= xm(ii,jj+1)
                    fprintf('%12d%12d%12d\n',1,ii,jj);
                    iflagm=1; fun_goto999();
                end
            end % 40
            if abs(xm(ii,1)-xmin) > 0.001 | abs(xm(ii,nzed(ii))-xmax) > 0.001
                fprintf('%11d %11d\n',2,ii);
                iflagm=1; fun_goto999();
            end
        else
            xm(ii,1) = xmax;
        end
    end % 10

    % 2. 检查速度模型（顶界面）是否有误
    for ii = 1:nlayer % 11
        for jj = 1:ppvel % 21
            if abs(xvel(ii,jj,1)-xmax) < 0.0001, break; end % go to 31
            nvel(ii,1) = nvel(ii,1) + 1;
        end % 21
        % 31
        if nvel(ii,1) > 1
            for jj = 1:nvel(ii,1)-1 % 41
                if xvel(ii,jj,1) >= xvel(ii,jj+1,1)
                    fprintf('%11d %11d %11d\n',3,ii,jj);
                    iflagm = 1; fun_goto999();
                end
            end % 41
            % isError3 = xvel(ii,1:nvel(ii,1)-1,1) >= xvel(ii,2:nvel(ii,1),1);
            % if any(isError3)
            %     fprintf('%11d %11d %11d\n',3,ii,find(isError3,1));
            %     iflagm=1; fun_goto999();
            % end
            if abs(xvel(ii,1,1)-xmin) > 0.001 | abs(xvel(ii,nvel(ii,1),1)-xmax) > 0.001
                fprintf('%11d %11d\n',4,ii);
                iflagm=1; fun_goto999();
            end
        else
            if vf(ii,1,1) > 0
                xvel(ii,1,1) = xmax;
            else
                if ii == 1
                    fprintf('%11d\n',5);
                    iflagm=1; fun_goto999();
                else
                    nvel(ii,1) = 0;
                end
            end
        end
    end % 11

    % 3. 检查速度模型（底界面）是否有误
    for ii = 1:nlayer % 12
        for jj = 1:ppvel % 22
            if abs(xvel(ii,jj,2)-xmax) < 0.0001, break; end % go to 32
            nvel(ii,2) = nvel(ii,2) + 1;
        end % 22
        % 32
        if nvel(ii,2) > 1
            for jj = 1:nvel(ii,2)-1 % 42
                if xvel(ii,jj,2) >= xvel(ii,jj+1,2)
                    fprintf('%11d %11d %11d\n',6,ii,jj);
                    iflagm=1; fun_goto999();
                end
            end % 42
            % isError6 = xvel(ii,1:nvel(ii,2)-1,2) >= xvel(ii,2:nvel(ii,2),2);
            % if any(isError6)
            %     fprintf('%11d %11d %11d\n',6,ii,find(isError6,1));
            %     iflagm=1; fun_goto999();
            % end
            if abs(xvel(ii,1,2)-xmin) > 0.001 | abs(xvel(ii,nvel(ii,2),2)-xmax) > 0.001
                fprintf('%11d %11d\n',7,ii);
                iflagm=1; fun_goto999();
            end
        else
            if vf(ii,1,2) > 0
                xvel(ii,1,2) = xmax;
            else
                nvel(ii,2) = 0;
            end
        end
    end % 12

    % 4. 将模型的每一层都切分成小梯形
    for ii = 1:nlayer % 50
        % xa = [];
        xa(1) = xmin;
        xa(2) = xmax;
        ib = 2;
        ih = ib;

        for jj = 1:nzed(ii) % 60
            if any(abs(xm(ii,jj)-xa(1:ih))<0.005), continue; end % go to 60
            ib = ib + 1;
            xa(ib) = xm(ii,jj);
        end % 60
        ih = ib;

        for jj = 1:nzed(ii+1) % 70
            if any(abs(xm(ii+1,jj)-xa(1:ih))<0.005), continue; end % go to 70
            ib = ib + 1;
            xa(ib) = xm(ii+1,jj);
        end % 70
        ih = ib;

        if nvel(ii,1) > 0, il = ii; is = 1;
        else
            if nvel(ii-1,2) > 0, il = ii-1; is = 2;
            else il = ii-1; is = 1; end
        end

        for jj = 1:nvel(il,is) % 71
            if any(abs(xvel(il,jj,is)-xa(1:ih))<0.005), continue; end % go to 71
            ib = ib + 1;
            xa(ib) = xvel(il,jj,is);
        end % 71

        if nvel(ii,2) > 0
            ih = ib;
            for jj = 1:nvel(ii,2) % 72
                if any(abs(xvel(ii,jj,2)-xa(1:ih))<0.005), continue; end % go to 72
                ib = ib + 1;
                xa(ib) = xvel(ii,jj,2);
            end % 72
        end

        if ib > (ptrap+1)
            fprintf('\n***  maximum number of blocks in layer %2d exceeded  ***\n\n',ii);
            iflagm = 1; return;
        end

        xa = sort(xa(1:ib));

        nblk(ii) = ib - 1;
        % 90
        xbnd(ii,1:nblk(ii),1) = xa(1:nblk(ii));
        xbnd(ii,1:nblk(ii),2) = xa(2:nblk(ii)+1);
    end % 50

    % disp(xbnd(1,1:15,1));
    % disp(xbnd(1,1:15,2));

    if invr == 1
        for ii = 1:nlayer % 310
            ivlyr = 0;
            for jj = 1:nzed(ii) % 320
                if ivarz(ii,jj) ~= 1 & ivarz(ii,jj) ~= -1
                    ivarz(ii,jj) = 0;
                end
                if ivarz(ii,jj) == -1, ivlyr = 1; end
            end % 320
            if ivlyr == 1
                if ii == 1
                    fprintf('%12d\n',8);
                    iflagm=1; fun_goto999();
                end
                if nzed(ii) ~= nzed(ii-1)
                    fprintf('%12d%12d\n',9,ii);
                    iflagm=1; fun_goto999();
                end
                for jj = 1:nzed(ii) % 327
                    if xm(ii,jj) ~= xm(ii-1,jj)
                        fprintf('%12d%12d%12d\n',10,ii,jj);
                        iflagm=1; fun_goto999();
                    end
                    if zm(ii,jj) < zm(ii-1,jj)
                        fprintf('%12d%12d%12d\n',11,ii,jj);
                        iflagm=1; fun_goto999();
                    end
                    if ivarz(ii-1,jj) == 0 & ivarz(ii,jj) == -1
                        ivarz(ii,jj) = 0;
                    end
                end % 327
            end
            for jj = 1:nvel(ii,1) % 321
                if ivarv(ii,jj,1) ~= 1, ivarv(ii,jj,1) = 0; end
            end % 321
            ivgrad = 0;
            if nvel(ii,2) > 0
                for jj = 1:nvel(ii,2) % 322
                    if ivarv(ii,jj,2)~=1 & ivarv(ii,jj,2)~=-1
                        ivarv(ii,jj,2) = 0;
                    end
                    if ivarv(ii,jj,2)==-1, ivgrad=1; end
                end % 322
                if ivgrad == 1
                    iflag = 0;
                    isGoto326 = false;
                    if nvel(ii,1) > 0
                        iflag = 1; ig = ii; jg = 1;
                        isGoto326 = true;
                    end
                    if ~isGoto326 && ii > 1 && nvel(ii,1) == 0
                        for jj = ii-1 : -1 : 1 % 324
                            if nvel(jj,2) > 0
                                iflag = 1; ig = jj; jg = 2;
                                break; % go to 326
                            end
                            if nvel(jj,1) > 0
                                iflag = 1; ig = jj; jg = 1;
                                break; % go to 326
                            end
                        end % 324
                    end
                    % 326
                    if iflag==1 && nvel(ig,jg)==nvel(ii,2)
                        for jj = 1:nvel(ig,jg) % 323
                            if xvel(ig,jj,jg) ~= xvel(ii,jj,2)
                                fprintf('%12d',12,ii,jj,ig,jg); fprintf('\n');
                                iflagm=1; fun_goto999();
                            end
                            if ivarv(ig,jj,jg)==0 && ivarv(ii,jj,2)==-1
                                ivarv(ii,jj,2) = 0;
                            end
                        end % 323
                    else
                        fprintf('%12d',13,ii,ig,jg); fprintf('\n');
                        iflagm=1; fun_goto999();
                    end
                end
            end
        end % 310

        nvar = 0;
        for ii = 1:nlayer % 410
            for jj = 1:nzed(ii) % 420

                % check for layer pinchouts

                iflag = 0;
                if ii > 1
                    for k = 1:ii-1 % 427
                        isGoto429 = false;
                        for l = 1:nzed(k) % 428
                            if abs(xm(ii,jj)-xm(k,l)) < 0.005 && abs(zm(ii,jj)-zm(k,l)) < 0.005
                                iflag = 1;
                                iv = ivarz(k,l);
                                isGoto429 = true; break; % go to 429 step1
                            end
                        end % 428
                        if isGoto429, break; end % go to 429 step2
                    end % 427
                end
                % 429
                if ivarz(ii,jj) == 1 && iflag == 0
                    nvar = nvar + 1;
                    ivarz(ii,jj) = nvar;
                    partyp(nvar) = 1;
                    parorg(nvar) = zm(ii,jj);
                else
                    if iflag==1, ivarz(ii,jj)=iv;
                    else
                        if ivarz(ii,jj)~=-1, ivarz(ii,jj)=0; end
                    end
                end
            end % 420

            for jj = 1:nvel(ii,1) % 421
                if ivarv(ii,jj,1) == 1
                    nvar = nvar + 1;
                    ivarv(ii,jj,1) = nvar;
                    partyp(nvar) = 2;
                    parorg(nvar) = vf(ii,jj,1);
                else
                    ivarv(ii,jj,1) = 0;
                end
            end % 421
            if nvel(ii,2) > 0
                for jj = 1:nvel(ii,2) % 422
                    if ivarv(ii,jj,2) == 1
                        nvar = nvar + 1;
                        ivarv(ii,jj,2) = nvar;
                        partyp(nvar) = 2;
                        parorg(nvar) = vf(ii,jj,2);
                    end
                end % 422
            end
        end % 410

        % check for inverting floating reflectors

        for ii = 1:nfrefl % 426
            for jj = 1:npfref(ii) % 431
                if ivarf(ii,jj) == 1
                    nvar = nvar + 1;
                    ivarf(ii,jj) = nvar;
                    partyp(nvar) = 3;
                    parorg(nvar) = zfrefl(ii,jj);
                end
            end % 431
        end % 426

        if nvar == 0
            fprintf('\n***  no parameters varied for inversion  ***\n\n');
            invr = 0;
        end

        if nvar > pnvar
            fprintf('\n***  too many parameters varied for inversion  ***\n\n');
            iflagm = 1; return;
        end
    end

    % calculate slopes and intercepts of each block boundary

    for ii = 1:nlayer % 100
        for jj = 1:nblk(ii) % 110
            xbndc = xbnd(ii,jj,1) + 0.001;
            if nzed(ii) > 1
                for k = 1 : nzed(ii)-1 % 120
                    if xbndc >= xm(ii,k) && xbndc <= xm(ii,k+1)
                        dx = xm(ii,k+1) - xm(ii,k);
                        c1 = (xm(ii,k+1)-xbnd(ii,jj,1)) ./ dx;
                        c2 = (xbnd(ii,jj,1)-xm(ii,k)) ./ dx;
                        z1 = c1 .* zm(ii,k) + c2 .* zm(ii,k+1);
                        if ivarz(ii,k) >= 0
                            iv = ivarz(ii,k);
                        else
                            iv = ivarz(ii-1,k);
                        end
                        izv(ii,jj,1) = iv;
                        if iv > 0
                            cz(ii,jj,1,1) = xm(ii,k+1);
                            cz(ii,jj,1,2) = xm(ii,k+1) - xm(ii,k);
                        end

                        c1 = (xm(ii,k+1)-xbnd(ii,jj,2)) ./ dx;
                        c2 = (xbnd(ii,jj,2)-xm(ii,k)) ./ dx;
                        z2 = c1 .* zm(ii,k) + c2 .* zm(ii,k+1);
                        if ivarz(ii,k+1) >= 0
                            iv = ivarz(ii,k+1);
                        else
                            iv = ivarz(ii-1,k+1);
                        end
                        izv(ii,jj,2) = iv;
                        if iv > 0
                            cz(ii,jj,2,1) = xm(ii,k);
                            cz(ii,jj,2,2) = xm(ii,k+1) - xm(ii,k);
                        end
                        break; % go to 130
                    end
                end % 120
            else
                z1 = zm(ii,1);
                if ivarz(ii,1) >= 0
                    iv = ivarz(ii,1);
                else
                    iv = ivarz(ii-1,1);
                end
                izv(ii,jj,1) = iv;
                if iv > 0
                    cz(ii,jj,1,1) = 0.0;
                    cz(ii,jj,1,2) = 0.0;
                end
                z2 = zm(ii,1);
                izv(ii,jj,2) = 0;
            end
            % 130
            s(ii,jj,1) = (z2-z1) ./ (xbnd(ii,jj,2)-xbnd(ii,jj,1));
            b(ii,jj,1) = z1 - s(ii,jj,1) .* xbnd(ii,jj,1);
            if nzed(ii+1) > 1
                for k = 1: nzed(ii+1)-1 % 140
                    if xbndc >= xm(ii+1,k) && xbndc <= xm(ii+1,k+1)
                        dx = xm(ii+1,k+1) - xm(ii+1,k);
                        c1 = (xm(ii+1,k+1)-xbnd(ii,jj,1)) ./ dx;
                        c2 = (xbnd(ii,jj,1)-xm(ii+1,k)) ./ dx;
                        z3 = c1 .* zm(ii+1,k) + c2 .* zm(ii+1,k+1);
                        if ii == nlayer
                            izv(ii,jj,3) = 0;
                        else
                            if ivarz(ii+1,k) >= 0
                                iv = ivarz(ii+1,k);
                            else
                                iv = ivarz(ii,k);
                            end
                            izv(ii,jj,3) = iv;
                            if iv > 0
                                cz(ii,jj,3,1) = xm(ii+1,k+1);
                                cz(ii,jj,3,2) = xm(ii+1,k+1) - xm(ii+1,k);
                            end
                        end

                        c1 = (xm(ii+1,k+1)-xbnd(ii,jj,2)) ./ dx;
                        c2 = (xbnd(ii,jj,2)-xm(ii+1,k)) ./ dx;
                        z4 = c1 .* zm(ii+1,k) + c2 .* zm(ii+1,k+1);
                        if ii == nlayer
                            izv(ii,jj,4) = 0;
                        else
                            if ivarz(ii+1,k+1) >= 0
                                iv = ivarz(ii+1,k+1);
                            else
                                iv = ivarz(ii,k+1);
                            end
                            izv(ii,jj,4) = iv;
                            if iv > 0
                                cz(ii,jj,4,1) = xm(ii+1,k);
                                cz(ii,jj,4,2) = xm(ii+1,k+1) - xm(ii+1,k);
                            end
                        end
                        break; % go to 150
                    end
                end % 140
            else
                z3 = zm(ii+1,1);
                if ii == nlayer
                    izv(ii,jj,3) = 0;
                else
                    if ivarz(ii+1,1) >= 0
                        iv = ivarz(ii+1,1);
                    else
                        iv = ivarz(ii,1);
                    end
                    izv(ii,jj,3) = iv;
                    if iv > 0
                        cz(ii,jj,3,1) = 0.0;
                        cz(ii,jj,3,2) = 0.0;
                    end
                end
                z4 = zm(ii+1,1);
                izv(ii,jj,4) = 0;
            end
            % 150
            s(ii,jj,2) = (z4-z3) ./ (xbnd(ii,jj,2)-xbnd(ii,jj,1));
            b(ii,jj,2) = z3 - s(ii,jj,2) .* xbnd(ii,jj,1);

            % check for layer pinchouts

            ivg(ii,jj) = 1;
            if abs(z3-z1) < 0.0005, ivg(ii,jj) = 2; end
            if abs(z4-z2) < 0.0005, ivg(ii,jj) = 3; end
            if abs(z3-z1) < 0.0005 && abs(z4-z2) < 0.0005, ivg(ii,jj) = -1; end
        end % 110
    end % 100


    % assign velocities to each model block

    for ii = 1:nlayer % 160
        if nvel(ii,1) == 0
            for jj = ii-1 : -1 : 1 % 161
                if nvel(jj,2) > 0
                    ig = jj; jg = 2; n1g = nvel(jj,2);
                    break; % go to 162
                end
                if nvel(jj,1) > 0
                    ig = jj; jg = 1; n1g = nvel(jj,1);
                    break; % go to 162
                end
            end % 161
        else
            ig = ii; jg = 1; n1g = nvel(ii,1);
        end

        % 162
        if n1g> 1 && nvel(ii,2)> 1, ivcase = 1; end
        if n1g> 1 && nvel(ii,2)==1, ivcase = 2; end
        if n1g==1 && nvel(ii,2)> 1, ivcase = 3; end
        if n1g==1 && nvel(ii,2)==1, ivcase = 4; end
        if n1g> 1 && nvel(ii,2)==0, ivcase = 5; end
        if n1g==1 && nvel(ii,2)==0, ivcase = 6; end

        for jj = 1:nblk(ii) % 170
            if ivg(ii,jj)==-1, continue; end % go to 170

            isGoto171 = false;

            xbndcl = xbnd(ii,jj,1) + 0.001;
            xbndcr = xbnd(ii,jj,2) - 0.001;

            % go to (1001,1002,1003,1004,1005,1006), ivcase

            % 1001
            if ivcase == 1
                for k = 1: n1g-1 % 180
                    if xbndcl>=xvel(ig,k,jg) & xbndcl<=xvel(ig,k+1,jg)
                        dxx = xvel(ig,k+1,jg) - xvel(ig,k,jg);
                        c1 = xvel(ig,k+1,jg) - xbnd(ii,jj,1);
                        c2 = xbnd(ii,jj,1) - xvel(ig,k,jg);
                        vm(ii,jj,1) = (c1*vf(ig,k,jg)+c2*vf(ig,k+1,jg)) / dxx;
                        if ig~=ii, vm(ii,jj,1)=vm(ii,jj,1)+0.001; end
                        if invr == 1
                            iv = ivarv(ig,k,jg);
                            ivv(ii,jj,1) = iv;
                            if iv > 0
                                cf = c1 / dxx;
                                fun_cvcalc(ii,jj,1,1,cf);
                                if ivg(ii,jj) == 2
                                    fun_cvcalc(ii,jj,1,3,cf);
                                end
                            end
                            if c2 > 0.001
                                iv = ivarv(ig,k+1,jg);
                                ivv(ii,jj,2) = iv;
                                if iv > 0
                                    cf = c2 / dxx;
                                    fun_cvcalc(ii,jj,2,1,cf);
                                    if ivg(ii,jj) == 2
                                        fun_cvcalc(ii,jj,2,3,cf);
                                    end
                                end
                            end
                        end
                        break; % go to 1811
                    end
                end % 180

                % 1811
                for k = 1: n1g-1 % 1812
                    if xbndcr>=xvel(ig,k,jg) & xbndcr<=xvel(ig,k+1,jg)
                        dxx = xvel(ig,k+1,jg) - xvel(ig,k,jg);
                        c1 = xvel(ig,k+1,jg) - xbnd(ii,jj,2);
                        c2 = xbnd(ii,jj,2) - xvel(ig,k,jg);
                        vm(ii,jj,2) = (c1*vf(ig,k,jg)+c2*vf(ig,k+1,jg)) / dxx;
                        if ig~=ii, vm(ii,jj,2)=vm(ii,jj,2)+0.001; end
                        if invr == 1
                            iv = ivarv(ig,k+1,jg);
                            ivv(ii,jj,2) = iv;
                            if iv > 0
                                cf = c2 / dxx;
                                fun_cvcalc(ii,jj,2,2,cf);
                                if ivg(ii,jj)==3, fun_cvcalc(ii,jj,2,4,cf); end
                            end
                            if c1 > 0.001
                                iv = ivarv(ig,k,jg);
                                ivv(ii,jj,1) = iv;
                                if iv > 0
                                    cf = c1 / dxx;
                                    fun_cvcalc(ii,jj,1,2,cf);
                                    if ivg(ii,jj)==3, fun_cvcalc(ii,jj,1,4,cf); end
                                end
                            end
                        end
                        break; % go to 181
                    end
                end % 1812

                % 181
                for k = 1: nvel(ii,2)-1 % 182
                    if xbndcl>=xvel(ii,k,2) & xbndcl<=xvel(ii,k+1,2)
                        dxx = xvel(ii,k+1,2) - xvel(ii,k,2);
                        c1 = xvel(ii,k+1,2) - xbnd(ii,jj,1);
                        c2 = xbnd(ii,jj,1) - xvel(ii,k,2);
                        if ivg(ii,jj) ~= 2
                            vm(ii,jj,3) = (c1*vf(ii,k,2)+c2*vf(ii,k+1,2)) / dxx;
                        else
                            vm(ii,jj,3) = vm(ii,jj,1);
                        end
                        if invr == 1
                            if ivg(ii,jj) == 2
                                ivv(ii,jj,3) = 0;
                                icorn = 0;
                            else
                                iv = ivarv(ii,k,2);
                                if iv > 0
                                    ivv(ii,jj,3) = iv;
                                    icorn = 3;
                                else
                                    ivv(ii,jj,3) = 0;
                                    if iv<0, icorn=1;
                                    else icorn=0; end
                                end
                            end
                            if icorn > 0
                                cf = c1 / dxx;
                                fun_cvcalc(ii,jj,icorn,3,cf);
                            end

                            if c2 > 0.001
                                if ivg(ii,jj) == 2
                                    ivv(ii,jj,4) = 0;
                                    icorn = 0;
                                else
                                    iv = ivarv(ii,k+1,2);
                                    if iv > 0
                                        ivv(ii,jj,4) = iv;
                                        icorn = 4;
                                    else
                                        ivv(ii,jj,4) = 0;
                                        if iv<0, icorn=2;
                                        else icorn=0; end
                                    end
                                end
                                if icorn > 0
                                    cf = c2 / dxx;
                                    fun_cvcalc(ii,jj,icorn,3,cf);
                                end
                            end
                        end
                        break; % go to 187
                    end
                end % 182

                % 187
                for k = 1: nvel(ii,2)-1 % 1822
                    if xbndcr>=xvel(ii,k,2) & xbndcr<=xvel(ii,k+1,2)
                        dxx = xvel(ii,k+1,2) - xvel(ii,k,2);
                        c1 = xvel(ii,k+1,2) - xbnd(ii,jj,2);
                        c2 = xbnd(ii,jj,2) - xvel(ii,k,2);
                        if ivg(ii,jj) ~= 3
                            vm(ii,jj,4) = (c1*vf(ii,k,2)+c2*vf(ii,k+1,2)) / dxx;
                        else
                            vm(ii,jj,4) = vm(ii,jj,2);
                        end
                        if invr == 1
                            if ivg(ii,jj) == 3
                                ivv(ii,jj,4) = 0;
                                icorn = 0;
                            else
                                iv = ivarv(ii,k+1,2);
                                if iv > 0
                                    ivv(ii,jj,4) = iv;
                                    icorn = 4;
                                else
                                    ivv(ii,jj,4) = 0;
                                    if iv<0, icorn=2;
                                    else icorn=0; end
                                end
                            end
                            if icorn > 0
                                cf = c2 / dxx;
                                fun_cvcalc(ii,jj,icorn,4,cf);
                            end

                            if c1 > 0.001
                                if ivg(ii,jj) == 3
                                    ivv(ii,jj,3) = 0;
                                    icorn = 0;
                                else
                                    iv = ivarv(ii,k,2);
                                    if iv > 0
                                        ivv(ii,jj,3) = iv;
                                        icorn = 3;
                                    else
                                        ivv(ii,jj,3) = 0;
                                        if iv<0, icorn=1;
                                        else icorn=0; end
                                    end
                                end
                                if icorn > 0
                                    cf = c1 / dxx;
                                    fun_cvcalc(ii,jj,icorn,4,cf);
                                end
                            end
                        end
                        isGoto171 = true; break; % go to 171
                    end
                end % 1822
            end

            % 1002
            if ~isGoto171 && ivcase <= 2
                for k = 1: n1g-1 % 183
                    if xbndcl>=xvel(ig,k,jg) & xbndcl<=xvel(ig,k+1,jg)
                        dxx = xvel(ig,k+1,jg) - xvel(ig,k,jg);
                        c1 = xvel(ig,k+1,jg) - xbnd(ii,jj,1);
                        c2 = xbnd(ii,jj,1) - xvel(ig,k,jg);
                        vm(ii,jj,1) = (c1*vf(ig,k,jg)+c2*vf(ig,k+1,jg)) / dxx;
                        if ig~=ii, vm(ii,jj,1)=vm(ii,jj,1)+0.001; end
                        if invr == 1
                            iv = ivarv(ig,k,jg);
                            ivv(ii,jj,1) = iv;
                            if iv > 0
                                cf = c1 / dxx;
                                fun_cvcalc(ii,jj,1,1,cf);
                            end
                            if c2 > 0.001
                                iv = ivarv(ig,k+1,jg);
                                ivv(ii,jj,2) = iv;
                                if iv > 0
                                    cf = c2 / dxx;
                                    fun_cvcalc(ii,jj,2,1,cf);
                                end
                            end
                        end
                        break; % go to 1833
                    end
                end % 183

                % 1833
                for k = 1: n1g-1 % 1832
                    if xbndcr>=xvel(ig,k,jg) & xbndcr<=xvel(ig,k+1,jg)
                        dxx = xvel(ig,k+1,jg) - xvel(ig,k,jg);
                        c1 = xvel(ig,k+1,jg) - xbnd(ii,jj,2);
                        c2 = xbnd(ii,jj,2) - xvel(ig,k,jg);
                        vm(ii,jj,2) = (c1*vf(ig,k,jg)+c2*vf(ig,k+1,jg)) / dxx;
                        if ig~=ii, vm(ii,jj,2)=vm(ii,jj,2)+0.001; end
                        if invr == 1
                            iv = ivarv(ig,k+1,jg);
                            ivv(ii,jj,2) = iv;
                            if iv > 0
                                cf = c2 / dxx;
                                fun_cvcalc(ii,jj,2,2,cf);
                            end
                            if c1 > 0.001
                                iv = ivarv(ig,k,jg);
                                ivv(ii,jj,1) = iv;
                                if iv > 0
                                    cf = c1 / dxx;
                                    fun_cvcalc(ii,jj,1,2,cf);
                                end
                            end
                        end
                        break; % go to 184
                    end
                end % 1832

                % 184
                vm(ii,jj,3) = vf(ii,1,2);
                if ivg(ii,jj)==2, vm(ii,jj,3)=vm(ii,jj,1); end
                vm(ii,jj,4) = vf(ii,1,2);
                if ivg(ii,jj)==3, vm(ii,jj,4)=vm(ii,jj,2); end
                if invr == 1
                    iv = ivarv(ii,1,2);
                    ivv(ii,jj,3) = iv;
                    ivv(ii,jj,4) = 0;
                    if iv > 0
                        if ivg(ii,jj)~=2, fun_cvcalc(ii,jj,3,3,1.0); end
                        if ivg(ii,jj)~=3, fun_cvcalc(ii,jj,3,4,1.0); end
                    end
                end
                isGoto171 = true; % go to 171
            end

            % 1003
            if ~isGoto171 && ivcase <= 3
                vm(ii,jj,1) = vf(ig,1,jg);
                vm(ii,jj,2) = vf(ig,1,jg);
                if ig ~= ii
                    vm(ii,jj,1) = vm(ii,jj,1) + 0.001;
                    vm(ii,jj,2) = vm(ii,jj,2) + 0.001;
                end
                if invr == 1
                    iv = ivarv(ig,1,jg);
                    ivv(ii,jj,1) = iv;
                    ivv(ii,jj,2) = 0;
                    if iv > 0
                        fun_cvcalc(ii,jj,1,1,1.0);
                        fun_cvcalc(ii,jj,1,2,1.0);
                    end
                end

                for k = 1: nvel(ii,2)-1 % 185
                    if xbndcl>=xvel(ii,k,2) & xbndcl<=xvel(ii,k+1,2)
                        dxx = xvel(ii,k+1,2) - xvel(ii,k,2);
                        c1 = xvel(ii,k+1,2) - xbnd(ii,jj,1);
                        c2 = xbnd(ii,jj,1) - xvel(ii,k,2);
                        if ivg(ii,jj) ~= 2
                            vm(ii,jj,3) = (c1*vf(ii,k,2)+c2*vf(ii,k+1,2)) / dxx;
                        else
                            vm(ii,jj,3) = vm(ii,jj,1);
                        end
                        if invr == 1
                            if ivg(ii,jj) == 2
                                ivv(ii,jj,3) = 0;
                                icorn = 1;
                            else
                                iv = ivarv(ii,k,2);
                                if iv > 0
                                    ivv(ii,jj,3) = iv;
                                    icorn = 3;
                                else
                                    ivv(ii,jj,3) = 0;
                                    icorn = 0;
                                end
                            end
                            if icorn > 0
                                cf = c1 / dxx;
                                fun_cvcalc(ii,jj,icorn,3,cf);
                            end

                            if c2 > 0.001
                                if ivg(ii,jj) == 2
                                    ivv(ii,jj,3) = 0;
                                    icorn = 2;
                                else
                                    iv = ivarv(ii,k+1,2);
                                    if iv > 0
                                        ivv(ii,jj,4) = iv;
                                        icorn = 4;
                                    else
                                        ivv(ii,jj,4) = 0;
                                        icorn = 0;
                                    end
                                end
                                if icorn > 0
                                    cf = c2 / dxx;
                                    fun_cvcalc(ii,jj,icorn,3,cf);
                                end
                            end
                        end
                        break; % go to 188
                    end
                end % 185

                % 188
                for k = 1: nvel(ii,2)-1 % 1851
                    if xbndcr>=xvel(ii,k,2) & xbndcr<=xvel(ii,k+1,2)
                        dxx = xvel(ii,k+1,2) - xvel(ii,k,2);
                        c1 = xvel(ii,k+1,2) - xbnd(ii,jj,2);
                        c2 = xbnd(ii,jj,2) - xvel(ii,k,2);
                        if ivg(ii,jj) ~= 3
                            vm(ii,jj,4) = (c1*vf(ii,k,2)+c2*vf(ii,k+1,2)) / dxx;
                        else
                            vm(ii,jj,4) = vm(ii,jj,2);
                        end
                        if invr == 1
                            if ivg(ii,jj) == 3
                                ivv(ii,jj,4) = 0;
                                icorn = 2;
                            else
                                iv = ivarv(ii,k+1,2);
                                if iv > 0
                                    ivv(ii,jj,4) = iv;
                                    icorn = 4;
                                else
                                    ivv(ii,jj,4) = 0;
                                    icorn = 0;
                                end
                            end
                            if icorn > 0
                                cf = c2 / dxx;
                                fun_cvcalc(ii,jj,icorn,4,cf);
                            end

                            if c1 > 0.001
                                if ivg(ii,jj) == 3
                                    ivv(ii,jj,4) = 0;
                                    icorn = 1;
                                else
                                    iv = ivarv(ii,k,2);
                                    if iv > 0
                                        ivv(ii,jj,3) = iv;
                                        icorn = 3;
                                    else
                                        ivv(ii,jj,3) = 0;
                                        icorn = 0;
                                    end
                                end
                                if icorn > 0
                                    cf = c1 / dxx;
                                    fun_cvcalc(ii,jj,icorn,4,cf);
                                end
                            end
                        end
                        isGoto171 = true; break; % go to 171
                    end
                end % 1851
            end

            % 1004
            if ~isGoto171 && ivcase <= 4
                vm(ii,jj,1) = vf(ig,1,jg);
                vm(ii,jj,2) = vf(ig,1,jg);
                if ig ~= ii
                    vm(ii,jj,1) = vm(ii,jj,1) + 0.001;
                    vm(ii,jj,2) = vm(ii,jj,2) + 0.001;
                end
                if invr == 1
                    iv = ivarv(ig,1,jg);
                    ivv(ii,jj,1) = iv;
                    ivv(ii,jj,2) = 0;
                    if iv > 0
                        fun_cvcalc(ii,jj,1,1,1.0);
                        fun_cvcalc(ii,jj,1,2,1.0);
                    end
                end

                vm(ii,jj,3) = vf(ii,1,2);
                if ivg(ii,jj)==2, vm(ii,jj,3)=vm(ii,jj,1); end
                vm(ii,jj,4) = vf(ii,1,2);
                if ivg(ii,jj)==3, vm(ii,jj,4)=vm(ii,jj,2); end
                if invr == 1
                    iv = ivarv(ii,1,2);
                    if iv > 0
                        ivv(ii,jj,3) = iv;
                        icorn = 3;
                    else
                        ivv(ii,jj,3) = 0;
                        if iv<0, icorn=1;
                        else icorn=0; end
                    end
                    ivv(ii,jj,4) = 0;
                    if icorn > 0
                        if ivg(ii,jj)~=2, fun_cvcalc(ii,jj,icorn,3,1.0); end
                        if ivg(ii,jj)~=3, fun_cvcalc(ii,jj,icorn,4,1.0); end
                    end
                end
                isGoto171 = true; % go to 171
            end

            % 1005
            if ~isGoto171 && ivcase <= 5
                for k = 1: n1g-1 % 186
                    if xbndcl>=xvel(ig,k,jg) & xbndcl<=xvel(ig,k+1,jg)
                        dxx = xvel(ig,k+1,jg) - xvel(ig,k,jg);
                        c1 = xvel(ig,k+1,jg) - xbnd(ii,jj,1);
                        c2 = xbnd(ii,jj,1) - xvel(ig,k,jg);
                        vm(ii,jj,1) = (c1*vf(ig,k,jg)+c2*vf(ig,k+1,jg)) / dxx;
                        if ig~=ii, vm(ii,jj,1)=vm(ii,jj,1)+0.001; end
                        vm(ii,jj,3) = vm(ii,jj,1);
                        if invr == 1
                            iv = ivarv(ig,k,jg);
                            ivv(ii,jj,1) = iv;
                            if iv > 0
                                cf = c1 / dxx;
                                fun_cvcalc(ii,jj,1,1,cf);
                                if ivg(ii,jj) ~= 2
                                    fun_cvcalc(ii,jj,1,3,cf);
                                end
                            end
                            if c2 > 0.001
                                iv = ivarv(ig,k+1,jg);
                                ivv(ii,jj,2) = iv;
                                if iv > 0
                                    cf = c2 / dxx;
                                    fun_cvcalc(ii,jj,2,1,cf);
                                    if ivg(ii,jj) ~= 2
                                        fun_cvcalc(ii,jj,2,3,cf);
                                    end
                                end
                            end
                        end
                        break; % go to 1861
                    end
                end % 186

                % 1861
                for k = 1: n1g-1 % 1862
                    if xbndcr>=xvel(ig,k,jg) & xbndcr<=xvel(ig,k+1,jg)
                        dxx = xvel(ig,k+1,jg) - xvel(ig,k,jg);
                        c1 = xvel(ig,k+1,jg) - xbnd(ii,jj,2);
                        c2 = xbnd(ii,jj,2) - xvel(ig,k,jg);
                        vm(ii,jj,2) = (c1*vf(ig,k,jg)+c2*vf(ig,k+1,jg)) / dxx;
                        if ig~=ii, vm(ii,jj,2)=vm(ii,jj,2)+0.001; end
                        vm(ii,jj,4) = vm(ii,jj,2);
                        if invr == 1
                            iv = ivarv(ig,k+1,jg);
                            ivv(ii,jj,2) = iv;
                            if iv > 0
                                cf = c2 / dxx;
                                fun_cvcalc(ii,jj,2,2,cf);
                                if ivg(ii,jj)~=3, fun_cvcalc(ii,jj,2,4,cf); end
                            end
                            if c1 > 0.001
                                iv = ivarv(ig,k,jg);
                                ivv(ii,jj,1) = iv;
                                if iv > 0
                                    cf = c1 / dxx;
                                    fun_cvcalc(ii,jj,1,2,cf);
                                    if ivg(ii,jj)~=3, fun_cvcalc(ii,jj,1,4,cf); end
                                end
                            end
                            ivv(ii,jj,3) = 0;
                            ivv(ii,jj,4) = 0;
                        end
                        isGoto171 = true; break; % go to 171
                    end
                end % 1862
            end

            % 1006
            if ~isGoto171 && ivcase <= 6
                vm(ii,jj,1) = vf(ig,1,jg);
                if ig ~= ii, vm(ii,jj,1) = vm(ii,jj,1) + 0.001; end
                vm(ii,jj,2:4) = vm(ii,jj,1); % ?...
                if invr == 1
                    iv = ivarv(ig,1,jg);
                    ivv(ii,jj,1) = iv;
                    ivv(ii,jj,2:4) = 0; % ?...
                    if iv > 0
                        fun_cvcalc(ii,jj,1,1,1.0);
                        fun_cvcalc(ii,jj,1,2,1.0);
                        fun_cvcalc(ii,jj,1,3,1.0);
                        fun_cvcalc(ii,jj,1,4,1.0);
                    end
                end
            end


            % calculate velocity coefficients
            % 171
            s1 = s(ii,jj,1);
            s2 = s(ii,jj,2);
            b1 = b(ii,jj,1);
            b2 = b(ii,jj,2);
            xb1 = xbnd(ii,jj,1);
            xb2 = xbnd(ii,jj,2);
            if ivg(ii,jj) == 2
                z3 = s(ii,jj,2)*xb1 + b(ii,jj,2) + 0.001;
                z4 = s(ii,jj,2)*xb2 + b(ii,jj,2);
                s2 = (z4-z3) / (xb2-xb1);
                b2 = z3 - s2*xb1;
            end
            if ivg(ii,jj) == 3
                z3 = s(ii,jj,2)*xb1 + b(ii,jj,2);
                z4 = s(ii,jj,2)*xb2 + b(ii,jj,2) + 0.001;
                s2 = (z4-z3) / (xb2-xb1);
                b2 = z3 - s2*xb1;
            end
            v1 = vm(ii,jj,1);
            v2 = vm(ii,jj,2);
            v3 = vm(ii,jj,3);
            v4 = vm(ii,jj,4);

            c(ii,jj, 1) = s2*(xb2*v1-xb1*v2) + b2*(v2-v1) - s1*(xb2*v3-xb1*v4) - b1*(v4-v3);
            c(ii,jj, 2) = s2*(v2-v1) - s1*(v4-v3);
            c(ii,jj, 3) = - xb2*v1 + xb1*v2 + xb2*v3 - xb1*v4;
            c(ii,jj, 4) = - v2 + v1 + v4 - v3;
            c(ii,jj, 5) = b2*(xb2*v1-xb1*v2) - b1*(xb2*v3-xb1*v4);
            c(ii,jj, 6) = (s2-s1) * (xb2-xb1);
            c(ii,jj, 7) = (b2-b1) * (xb2-xb1);
            c(ii,jj, 8) = 2.0 * c(ii,jj,2) * c(ii,jj,7);
            c(ii,jj, 9) = c(ii,jj,2) * c(ii,jj,6);
            c(ii,jj,10) = c(ii,jj,4)*c(ii,jj,7) - c(ii,jj,3)*c(ii,jj,6);
            c(ii,jj,11) = c(ii,jj,1)*c(ii,jj,7) - c(ii,jj,5)*c(ii,jj,6);

            if ivg(ii,jj) == -1
                vm(ii,jj,1:4) = 0.0; % ?...
                for k = 1:11
                    c(ii,jj,1) = 0.0; % ?...
                end % 172
            end
            if abs(vm(ii,jj,1)-vm(ii,jj,2))<0.001 & abs(vm(ii,jj,2)-vm(ii,jj,3))<0.001 ...
                & abs(vm(ii,jj,3)-vm(ii,jj,4))<0.001 & ivg(ii,jj)~=-1
                ivg(ii,jj) = 0;
            end
        end % 170
    end % 160

    % assign values to array vsvp
    if pois(1) < -10.0
        for ii = 1:nlayer
            vsvp(ii,1:nblk(ii)) = 0.57735;
        end % 190
    else
        if nlayer > 1
            if pois(2) < -10.0
                % 210
                vsvp(1,1:nblk(1)) = sqrt( (1.0-2.0*pois(1))/(2.0*(1.0-pois(1))) );
                for ii = 2:nlayer
                    vsvp(ii,1:nblk(ii)) = vsvp(1,1);
                end % 220
            else
                for ii = 1:nlayer
                    if pois(ii) < -10.0
                        vsvp(ii,1:nblk(ii)) = 0.57735; % 250
                    else
                        vsvp(ii,1:nblk(ii)) = sqrt( (1.0-2.0*pois(ii))/(2.0*(1.0-pois(ii))) );
                    end
                end % 240
            end
        end
    end

    % calculate velocity ratios for specific model blocks specified
    % through the arrays poisbl, poisl and poisb

    % 270
    for ii = 1:papois
        if poisbl(ii)<-10.0, break; end % go to 400
        vsvp(poisl(ii),poisb(ii)) = sqrt((1.0-2.0*poisbl(ii))/(2.0*(1.0-poisbl(ii))));
    end

    % calculation of smooth layer boundaries

    % 400
    if ibsmth > 0
        xsinc = (xmax-xmin) ./ (npbnd-1);
        for ii = 1: nlayer+1 % 600
            if ii < nlayer+1
                il = ii; ib = 1;
            else
                il = ii-1; ib = 2;
            end
            iblk = 1;
            for jj = 1:npbnd % 610
                x = xmin + (jj-1).*xsinc;
                if x < xmin, x = xmin + 0.001; end
                if x > xmax, x = xmax - 0.001; end

                % 620 % -------------------- cycle620 begin
                cycle620 = true;
                while cycle620
                    if x >= xbnd(il,iblk,1) && x <= xbnd(il,iblk,2)
                        cosmth(ii,jj) = s(il,iblk,ib).*x + b(il,iblk,ib);
                        break; % go to 610
                    else
                        iblk = iblk + 1;
                        continue; % go to 620
                    end
                    break; % go to nothing
                end % -------------------- cycle620 begin
            end % 610
        end % 600
        n1ns = round(xminns./xsinc) + 1;
        n2ns = round(xmaxns./xsinc) + 1;
        iflag12 = 0;
        if n1ns >= 1 && n1ns <= npbnd && n2ns >= 1 && n2ns <= npbnd && n1ns < n2ns
            iflag12 = 1;
        end
        if nbsmth > 0
            for ii = 1: nlayer+1 % 630
                if xminns<xmin & xmaxns<xmin
                    % 6630
                    if any(insmth(1:pncntr)==ii), continue; end % go to 630
                end
                iflagns = 0;
                % 6640
                if any(insmth(1:pncntr)==ii), iflagns=1; end
                % 640
                zsmth(1:npbnd) = cosmth(ii,1:npbnd);
                for jj = 1:nbsmth
                    if iflag12==1 & iflagns==1
                        [zsmth,~,~,~] = fun_smooth2(zsmth,npbnd,n1ns,n2ns);
                    else
                        [zsmth,~] = fun_smooth(zsmth,npbnd);
                    end
                end % 650
                % 660
                cosmth(ii,1:npbnd) = zsmth(1:npbnd);
                if idump == 2
                    for jj = 1:npbnd
                        x = xmin + (jj-1)*xsinc;
                        fprintf(fID_12,'%7.2f%7.2f\n',x,zsmth(jj));
                    end % 670
                end
            end % 630
        end
    end

    if idump == 1
        fprintf(fID_12,'***  velocity model:  ***\n\nnumber of layers=%2d\n',nlayer);
        for ii = 1:nlayer
            fprintf(fID_12,'\nlayer#%2d  nblk=%4d (ivg,x1,x2,z11,z12,z21,z22,s1,b1,s2,b2,vp1,vs1,vp2,vs2,vp3,vs3,vp4,vs4,c1,c2,...,c11)\n',ii,nblk(ii));
            tempj = 1:nblk(ii);
            fprintf(fID_12,'%10d',ivg(ii,tempj)); fprintf(fID_12,'\n');
            fprintf(fID_12,'%10.4f',xbnd(ii,tempj,1)); fprintf(fID_12,'\n');
            fprintf(fID_12,'%10.4f',xbnd(ii,tempj,2)); fprintf(fID_12,'\n');
            temp1 = s(ii,tempj,1) .* xbnd(ii,tempj,1) + b(ii,tempj,1);
            temp2 = s(ii,tempj,1) .* xbnd(ii,tempj,2) + b(ii,tempj,1);
            temp3 = s(ii,tempj,2) .* xbnd(ii,tempj,1) + b(ii,tempj,2);
            temp4 = s(ii,tempj,2) .* xbnd(ii,tempj,2) + b(ii,tempj,2);
            fprintf(fID_12,'%10.4f',temp1); fprintf(fID_12,'\n');
            fprintf(fID_12,'%10.4f',temp2); fprintf(fID_12,'\n');
            fprintf(fID_12,'%10.4f',temp3); fprintf(fID_12,'\n');
            fprintf(fID_12,'%10.4f',temp4); fprintf(fID_12,'\n');
            fprintf(fID_12,'%10.4f',s(ii,tempj,1)); fprintf(fID_12,'\n');
            fprintf(fID_12,'%10.4f',b(ii,tempj,1)); fprintf(fID_12,'\n');
            fprintf(fID_12,'%10.4f',s(ii,tempj,2)); fprintf(fID_12,'\n');
            fprintf(fID_12,'%10.4f',b(ii,tempj,2)); fprintf(fID_12,'\n');
            fprintf(fID_12,'%10.4f',vm(ii,tempj,1)); fprintf(fID_12,'\n');
            fprintf(fID_12,'%10.4f',vm(ii,tempj,1).*vsvp(ii,tempj)); fprintf(fID_12,'\n');
            fprintf(fID_12,'%10.4f',vm(ii,tempj,2)); fprintf(fID_12,'\n');
            fprintf(fID_12,'%10.4f',vm(ii,tempj,2).*vsvp(ii,tempj)); fprintf(fID_12,'\n');
            fprintf(fID_12,'%10.4f',vm(ii,tempj,3)); fprintf(fID_12,'\n');
            fprintf(fID_12,'%10.4f',vm(ii,tempj,3).*vsvp(ii,tempj)); fprintf(fID_12,'\n');
            fprintf(fID_12,'%10.4f',vm(ii,tempj,4)); fprintf(fID_12,'\n');
            fprintf(fID_12,'%10.4f',vm(ii,tempj,4).*vsvp(ii,tempj)); fprintf(fID_12,'\n');
            fprintf(fID_12,'%10.3e',c(ii,tempj, 1)); fprintf(fID_12,'\n');
            fprintf(fID_12,'%10.3e',c(ii,tempj, 2)); fprintf(fID_12,'\n');
            fprintf(fID_12,'%10.3e',c(ii,tempj, 3)); fprintf(fID_12,'\n');
            fprintf(fID_12,'%10.3e',c(ii,tempj, 4)); fprintf(fID_12,'\n');
            fprintf(fID_12,'%10.3e',c(ii,tempj, 5)); fprintf(fID_12,'\n');
            fprintf(fID_12,'%10.3e',c(ii,tempj, 6)); fprintf(fID_12,'\n');
            fprintf(fID_12,'%10.3e',c(ii,tempj, 7)); fprintf(fID_12,'\n');
            fprintf(fID_12,'%10.3e',c(ii,tempj, 8)); fprintf(fID_12,'\n');
            fprintf(fID_12,'%10.3e',c(ii,tempj, 9)); fprintf(fID_12,'\n');
            fprintf(fID_12,'%10.3e',c(ii,tempj,10)); fprintf(fID_12,'\n');
            fprintf(fID_12,'%10.3e',c(ii,tempj,11)); fprintf(fID_12,'\n');
        end % 510

        xmod = xmax - xmin;
        fprintf(fID_12,'\nequivalent 1-dimensional velocity model:\n');
        for ii = 1:nlayer
            [z1sum,z2sum,vp1,vp2,vs1,vs2,vp1sum,vp2sum,vs1sum,vs2sum,xvmod] = deal(0);
            for jj = 1:nblk(ii)
                xblk = xbnd(ii,jj,2) - xbnd(ii,jj,1);
                z11 = s(ii,jj,1) * xbnd(ii,jj,1) + b(ii,jj,1);
                z12 = s(ii,jj,1) * xbnd(ii,jj,2) + b(ii,jj,1);
                z21 = s(ii,jj,2) * xbnd(ii,jj,1) + b(ii,jj,2);
                z22 = s(ii,jj,2) * xbnd(ii,jj,2) + b(ii,jj,2);
                z1sum = z1sum + xblk*(z11+z12)/2.0;
                z2sum = z2sum + xblk*(z21+z22)/2.0;
                if vm(ii,jj,1) > 0.001
                    vp1sum = vp1sum + xblk*(vm(ii,jj,1)+vm(ii,jj,2))/2.0;
                    vs1sum = vs1sum + xblk*(vm(ii,jj,1)+vm(ii,jj,2))*vsvp(ii,jj)/2.0;
                    vp2sum = vp2sum + xblk*(vm(ii,jj,3)+vm(ii,jj,4))/2.0;
                    vs2sum = vs2sum + xblk*(vm(ii,jj,3)+vm(ii,jj,4))*vsvp(ii,jj)/2.0;
                    xvmod = xvmod + xblk;
                end
            end % 530
            z1 = z1sum / xmod;
            z2 = z2sum / xmod;
            if xvmod > 0.000001
                vp1 = vp1sum / xvmod;
                vp2 = vp2sum / xvmod;
                vs1 = vs1sum / xvmod;
                vs2 = vs2sum / xvmod;
            end
            fprintf(fID_12,'layer# %2d   z1=%7.2f   z2=%7.2f km\n',ii,z1,z2);
            fprintf(fID_12,'%9s  vp1=%7.2f  vp2=%7.2f km/s\n','',vp1,vp2);
            fprintf(fID_12,'%9s  vs1=%7.2f  vs2=%7.2f km/s\n','',vs1,vs2);
        end % 520

        if xmin1d<-999998.0, xmin1d=xmin; end
        if xmax1d<-999998.0, xmax1d=xmax; end
        fprintf(fID_12,'\n1-dimensional P-wave velocity model between %7.2f and %7.2f km:\n',xmin1d,xmax1d);
        xmod = xmax1d - xmin1d;
        for ii = 1:nlayer
            [z1sum,z2sum,vp1,vp2,vs1,vs2,vp1sum,vp2sum,vs1sum,vs2sum,xvmod] = deal(0);
            for jj = 1:nblk(ii)
                if xbnd(ii,jj,1)>=xmax1d, continue; end
                if xbnd(ii,jj,2)<=xmin1d, continue; end
                if xbnd(ii,jj,1)<xmin1d, xb1=xmin1d;
                else xb1=xbnd(ii,jj,1); end
                if xbnd(ii,jj,2)>xmax1d, xb2=xmax1d;
                else xb2=xbnd(ii,jj,2); end
                xblk = xb2 - xb1;
                z11 = s(ii,jj,1) * xb1 + b(ii,jj,1);
                z12 = s(ii,jj,1) * xb2 + b(ii,jj,1);
                z21 = s(ii,jj,2) * xb1 + b(ii,jj,2);
                z22 = s(ii,jj,2) * xb2 + b(ii,jj,2);
                z1sum = z1sum + xblk*(z11+z12)/2.0;
                z2sum = z2sum + xblk*(z21+z22)/2.0;
                if vm(ii,jj,1) > 0.001
                    layer = ii; iblk = jj;
                    v11 = fun_vel(xb1,z11);
                    v12 = fun_vel(xb2,z12);
                    v21 = fun_vel(xb1,z21);
                    v22 = fun_vel(xb2,z22);
                    vp1sum = vp1sum + xblk*(v11+v12)/2.0;
                    vs1sum = vs1sum + xblk*(v11+v12)*vsvp(ii,jj)/2.0;
                    vp2sum = vp2sum + xblk*(v21+v22)/2.0;
                    vs2sum = vs2sum + xblk*(v21+v22)*vsvp(ii,jj)/2.0;
                    xvmod = xvmod + xblk;
                end
            end % 730
            z1 = z1sum / xmod;
            z2 = z2sum / xmod;
            if xvmod > 0.000001
                vp1 = vp1sum / xvmod;
                vp2 = vp2sum / xvmod;
                vs1 = vs1sum / xvmod;
                vs2 = vs2sum / xvmod;
            end
            fprintf(fID_12,'%2d %7.2f\n%2d %7.2f\n   %7d\n',ii,xmax,0,z1,0);
            fprintf(fID_12,'%2d %7.2f\n%2d %7.2f\n   %7d\n',ii,xmax,0,vp1,0);
            fprintf(fID_12,'%2d %7.2f\n%2d %7.2f\n   %7d\n',ii,xmax,0,vp2,0);
            if ii == nlayer
                fprintf(fID_12,'%2d %7.2f\n%2d %7.2f\n',ii+1,xmax,0,z2);
            end
        end % 720
    end

    if idump == 1
        fprintf(fID_12,'\nlayer   max. gradient (km/s/km)   block\n');
    end

    for ii = 1:nlayer
        delv = 0.0; ibd = 0;
        for jj = 1:nblk(ii)
            if ivg(ii,jj)<1, continue; end
            if ivg(ii,jj) == 2
                delv1 = 0.0; delv3 = 0.0;
            else
                x1 = xbnd(ii,jj,1);
                z1 = s(ii,jj,1) * x1 + b(ii,jj,1);
                denom = c(ii,jj,6) * x1 + c(ii,jj,7);
                vx = (c(ii,jj,8)*x1+c(ii,jj,9)*x1.^2+c(ii,jj,10)*z1+c(ii,jj,11)) / denom.^2;
                vz = (c(ii,jj,3)+c(ii,jj,4)*x1) / denom;
                delv1 = (vx.^2+vz.^2) .^ 0.5;
                z3 = s(ii,jj,2) * x1 + b(ii,jj,2);
                vx = (c(ii,jj,8)*x1+c(ii,jj,9)*x1.^2+c(ii,jj,10)*z3+c(ii,jj,11)) / denom.^2;
                vz = (c(ii,jj,3)+c(ii,jj,4)*x1) / denom;
                delv3 = (vx.^2+vz.^2) .^ 0.5;
            end
            if ivg(ii,jj) == 3
                delv2 = 0.0; delv4 = 0.0;
            else
                x2 = xbnd(ii,jj,2);
                z2 = s(ii,jj,1) * x2 + b(ii,jj,1);
                denom = c(ii,jj,6) * x2 + c(ii,jj,7);
                vx = (c(ii,jj,8)*x2+c(ii,jj,9)*x2.^2+c(ii,jj,10)*z2+c(ii,jj,11)) / denom.^2;
                vz = (c(ii,jj,3)+c(ii,jj,4)*x2) / denom;
                delv2 = (vx.^2+vz.^2) .^ 0.5;
                z4 = s(ii,jj,2) * x2 + b(ii,jj,2);
                vx = (c(ii,jj,8)*x2+c(ii,jj,9)*x2.^2+c(ii,jj,10)*z4+c(ii,jj,11)) / denom.^2;
                vz = (c(ii,jj,3)+c(ii,jj,4)*x2) / denom;
                delv4 = (vx.^2+vz.^2) .^ 0.5;
            end
            delm = max([delv1,delv2,delv3,delv4]);
            if delm > delv
                delv = delm;
                ibd = jj;
            end
        end % 920
        if idump == 1
            fprintf(fID_12,'%4d%17.4f%17d\n',ii,delv,ibd);
        end
        if delv > dvmax
            idvmax = idvmax + 1;
            ldvmax(idvmax) = ii;
        end
    end % 910

    if idump == 1
        fprintf(fID_12, '\nboundary   slope change (degrees)   between points\n');
    end

    for ii = 1:ncont
        dslope = 0.0;
        [ips1,ips2] = deal(0);
        if nzed(ii) > 2
            for jj = 1: nzed(ii)-2
                slope1 = (zm(ii,jj+1)-zm(ii,jj)) / (xm(ii,jj+1)-xm(ii,jj));
                slope2 = (zm(ii,jj+2)-zm(ii,jj+1)) / (xm(ii,jj+2)-xm(ii,jj+1));
                ds1 = atan(slope1) * pi18;
                ds2 = atan(slope2) * pi18;
                if abs(ds2-ds1) > dslope
                    dslope = abs(ds2-ds1);
                    ips1 = jj;
                    ips2 = jj + 2;
                end
            end % 940
        end
        if idump == 1
            fprintf(fID_12,'%4d%19.4f%12s%7d%7d\n',ii,dslope,'',ips1,ips2);
        end
        if dslope > dsmax
            idsmax = idsmax + 1;
            ldsmax(idsmax) = ii;
        end
    end % 930

    return;

end % fun_calmod end

% --------------------------------------------------
function fun_goto999()
% calculate end for model error

    error('e:stop','\n***  error in velocity model 2 ***\n\n');
end % fun_goto999 end
