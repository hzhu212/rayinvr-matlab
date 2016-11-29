
function     [ncont,pois,poisb,poisl,poisbl,invr,iflagm,ifrbnd,xmin1d,xmax1d,insmth,xminns,xmaxns] ...
 = fun_calmod(ncont,pois,poisb,poisl,poisbl,invr,iflagm,ifrbnd,xmin1d,xmax1d,insmth,xminns,xmaxns);
 % calculate model
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

    global file_rayinvr_par file_rayinvr_com;
    run(file_rayinvr_par);
    xa = zeros(1,2*(ppcntr+ppvel));
    zsmth = zeros(1,pnsmth);
    run(file_rayinvr_com);
    iflagm = 0;
    idvmax = 0;
    idsmax = 0;

    % 1. 检查形状模型是否有误
    for ii = 1:ncont
        for jj = 1:ppcntr
            if abs(xm(ii,jj)-xmax) < 0.0001, break; end
            nzed(ii) = nzed(ii) + 1;
        end
        if nzed(ii) > 1
            isError1 = xm(ii,1:nzed(ii)-1) >= xm(ii,2:nzed(ii));
            if any(isError1)
                disp(sprintf('%11d %11d %11d',1,ii,find(isError1,1)));
                fun_goto999(); return;
            end
            if abs(xm(ii,1)-xmin)>0.001 | abs(xm(ii,nzed(ii))-xmax)>0.001
                disp(sprintf('%11d %11d',2,ii));
                fun_goto999(); return;
            end
        else
            xm(ii,1) = xmax;
        end
    end

    % 2. 检查速度模型（顶界面）是否有误
    for ii = 1:nlayer
        for jj = 1:ppvel
            if abs(xvel(ii,jj,1)-xmax) < 0.0001, break; end
            nvel(ii,1) = nvel(ii,1) + 1;
        end
        if nvel(ii,1) > 1
            isError3 = xvel(ii,1:nvel(ii,1)-1,1) >= xvel(ii,2:nvel(ii,1),1);
            if any(isError3)
                disp(sprintf('%11d %11d %11d',3,ii,find(isError3,1)));
                fun_goto999(); return;
            end
            if abs(xvel(ii,1,1)-xmin)>0.001 | abs(xvel(ii,nvel(ii,1),1)-xmax)>0.001
                disp(sprintf('%11d %11d',4,ii));
                fun_goto999(); return;
            end
        else
            if vf(ii,1,1)>0, xvel(ii,1,1)=xmax;
            else
                if ii == 1, disp('%11d',5); fun_goto999(); return;
                else nvel(ii,1) = 0; end
            end
        end
    end

    % 3. 检查速度模型（底界面）是否有误
    for ii = 1:nlayer
        for jj = 1:ppvel
            if abs(xvel(ii,jj,2)-xmax) < 0.0001, break; end
            nvel(ii,2) = nvel(ii,2) + 1;
        end
        if nvel(ii,2) > 1
            isError6 = xvel(ii,1:nvel(ii,2)-1,2) >= xvel(ii,2:nvel(ii,2),2);
            if any(isError6)
                disp(sprintf('%11d %11d %11d',6,ii,find(isError6,1)));
                fun_goto999(); return;
            end
            if abs(xvel(ii,1,2)-xmin)>0.001 | abs(xvel(ii,nvel(ii,2),2)-xmax)>0.001
                disp(sprintf('%11d %11d',7,ii));
                fun_goto999(); return;
            end
        else
            if vf(ii,1,2)>0, xvel(ii,1,2)=xmax;
            else nvel(ii,2) = 0; end
        end
    end

    % 4. 将模型的每一层都切分成小梯形
    for ii = 1:nlayer
        xa(1) = xmin;
        xa(2) = xmax;
        ib = 2;
        ih = ib;

        for jj = 1:nzed(ii)
            if any(abs(xm(ii,jj)-xa(1:ih))<0.005), continue; end
            ib = ib + 1;
            xa(ib) = xm(ii,jj);
        end % 60
        ih = ib;

        for jj = 1:nzed(ii+1)
            if any(abs(xm(ii+1,jj)-xa(1:ih))<0.005), continue; end
            ib = ib + 1;
            xa(ib) = xm(ii+1,jj);
        end % 70
        ih = ib;

        if nvel(ii,1)>0, il = ii; is = 1;
        else
            if nvel(ii-1,2)>0, il = ii-1; is = 2;
            else il = ii-1; is = 1; end
        end

        for jj = 1:nvel(il,is)
            if any(abs(xvel(il,jj,is)-xa(1:ih))<0.005), continue; end % 81
            ib = ib + 1;
            xa(ib) = xvel(il,jj,is);
        end % 71

        if nvel(ii,2) > 0
            ih = ib;
            for jj = 1:nvel(ii,2)
                if any(abs(xvel(ii,jj,2)-xa(1:ih))<0.005), continue; end % 82
                ib = ib + 1;
                xa(ib) = xvel(ii,jj,2);
            end % 72
        end

        if ib > (ptrap+1)
            disp(sprintf('\n***  maximum number of blocks in layer %d exceeded  ***\n',ii));
            iflagm = 1;
            return;
        end

        xa = sort(xa);

        nblk(ii) = ib - 1;
        xbnd(ii,1:nblk(ii),1) = xa(1:nblk(ii))
        xbnd(ii,1:nblk(ii),2) = xa(2:nblk(ii)+1) % 90
    end % 50


    if invr == 1
        for ii = 1:nlayer
            ivlyr = 0;
            for jj = 1:nzed(ii)
                if ivarz(ii,jj)~=1 & ivarz(ii,jj)~=-1, ivarz(ii,jj) = 0; end
                if ivarz(ii,jj)==-1, ivlyr=1; end
            end % 320
            if ivlyr == 1
                if ii==1
                    disp(sprintf('%12d',8)); fun_goto999(); return;
                end
                if nzed(ii) ~= nzed(ii-1)
                    disp(sprintf('%12d%12d',9,ii)); fun_goto999(); return;
                end
                for jj = 1:nzed(ii)
                    if xm(ii,jj) ~= xm(ii-1,jj)
                        disp(sprintf('%12d%12d%12d',10,ii,jj));
                        fun_goto999(); return;
                    end
                    if zm(ii,jj) ~= zm(ii-1,jj)
                        disp(sprintf('%12d%12d%12d',11,ii,jj));
                        fun_goto999(); return;
                    end
                    if ivarz(ii-1,jj)==0 & ivarz(ii,jj)==-1
                        ivarz(ii,jj) = 0;
                    end
                end % 327
            end
            for jj = 1:nvel(ii,1)
                if ivarv(ii,jj,1)~=1, ivarv(ii,jj,1)=0; end
            end % 321
            ivgrad = 0;
            if nvel(ii,2) > 0
                for jj = 1:nvel(ii,2)
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
                    if ~isGoto326 & i>1 & nvel(ii,1)==0
                        for jj = ii-1 : -1 : 1
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
                    if iflag==1 & nvel(ig,jg)==nvel(ii,2)
                        for jj = 1:nvel(ig,jg)
                            if xvel(ig,jj,jg) ~= xvel(ii,jj,2)
                                disp(sprintf('%12d',12,ii,jj,ig,jg));
                                fun_goto999(); return;
                            end
                            if ivarv(ig,jj,jg)==0 & ivarv(ii,jj,2)==-1
                                ivarv(ii,jj,2) = 0;
                            end
                        end % 323
                    else
                        disp(sprintf('%12d',13,ii,ig,jg));
                        fun_goto999(); return;
                    end
                end
            end
        end % 310

        nvar = 0;
        for ii = 1:nlayer
            for jj = 1:nzed(ii)
                % check for layer pinchouts
                iflag = 0;
                if ii > 1
                    for k = 1:ii-1
                        isGoto429 = false;
                        for l = 1:nzed(k)
                            if abs(xm(ii,jj)-xm(k,l))<0.005 & abs(zm(ii,jj)-zm(k,l))<0.005
                                iflag = 1;
                                iv = ivarz(k,l);
                                isGoto429 = true; break; % go to 429
                            end
                        end % 428
                        if isGoto429, break; end
                    end % 427
                end
                % 429
                if ivarz(ii,jj)==1 & iflag==0
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

            for jj = 1:nvel(ii,1)
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
                for jj = 1:nvel(ii,2)
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
        for ii = 1:nfrefl
            for jj = 1:npfref(ii)
                if ivarf(ii,jj) == 1
                    nvar = nvar + 1;
                    ivarf(ii,jj) = nvar;
                    partyp(nvar) = 3;
                    parorg(nvar) = zfrefl(ii,jj);
                end
            end % 431
        end % 426

        if nvar == 0
            disp(sprintf('\n***  no parameters varied for inversion  ***\n'));
            invr = 0;
        end

        if nvar > pnvar
            disp(sprintf('\n***  too many parameters varied for inversion  ***\n'));
            iflagm = 1; return;
        end
    end


    % calculate slopes and intercepts of each block boundary
    for ii = 1:nlayer
        for jj = 1:nblk(ii)
            xbndc = xbnd(ii,jj,1) + 0.001;
            if nzed(ii) > 1
                for k = 1 : nzed(ii)-1
                    if xbndc>=xm(ii,k) & xbndc<=xm(ii,k+1)
                        dx = xm(ii,k+1) - xm(ii,k);
                        c1 = (xm(ii,k+1)-xbnd(ii,jj,1)) / dx;
                        c2 = (xbnd(ii,jj,1)-xm(ii,k)) / dx;
                        z1 = c1 * zm(ii,k) + c2 * zm(ii,k+1);
                        if ivarz(ii,k) > 0
                            iv = ivarz(ii,k);
                        else
                            iv = ivarz(ii-1,k);
                        end
                        izv(ii,jj,1) = iv;
                        if iv > 0
                            cz(ii,jj,1,1) = xm(ii,k+1);
                            cz(ii,jj,1,2) = xm(ii,k+1) - xm(ii,k);
                        end

                        c1 = (xm(ii,k+1)-xbnd(ii,jj,2)) / dx;
                        c2 = (xbnd(ii,jj,2)-xm(ii,k)) / dx;
                        z2 = c1 * zm(ii,k) + c2 * zm(ii,k+1);
                        if ivarz(ii,k+1) > 0
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
                if ivarz(ii,1) > 0
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
            s(ii,jj,1) = (z2-z1) / (xbnd(ii,jj,2)-xbnd(ii,jj,1));
            b(ii,jj,1) = z1 - s(ii,jj,1) * xbnd(ii,jj,1);
            if nzed(ii+1) > 1
                for k = 1: nzed(ii+1)-1
                    if xbndc>=xm(ii+1,k) & xbndc<=xm(ii+1,k+1)
                        dx = xm(ii+1,k+1) - xm(ii+1,k);
                        c1 = (xm(ii+1,k+1)-xbnd(ii,jj,1)) / dx;
                        c2 = (xbnd(ii,jj,1)-xm(ii+1,k)) / dx;
                        z3 = c1 * zm(ii+1,k) + c2 * zm(ii+1,k+1);
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

                        c1 = (xm(ii+1,k+1)-xbnd(ii,jj,2)) / dx;
                        c2 = (xbnd(ii,jj,2)-xm(ii+1,k)) / dx;
                        z4 = c1 * zm(ii+1,k) + c2 * zm(ii+1,k+1);
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
            s(ii,jj,2) = (z4-z3) / (xbnd(ii,jj,2)-xbnd(ii,jj,1));
            b(ii,jj,2) = z3 - s(ii,jj,2) * xbnd(ii,jj,1);

            % check for layer pinchouts
            ivg(ii,jj) = 1;
            if abs(z3-z1)<0.0005, ivg(ii,jj)=2; end
            if abs(z4-z2)<0.0005, ivg(ii,jj)=3; end
            if abs(z3-z1)<0.0005 & abs(z4-z2)<0.0005, ivg(ii,jj)=-1; end
        end % 110
    end % 100


    % assign velocities to each model block
    for ii = 1:nlayer
        if nvel(ii,1) == 0
            for jj = ii-1 : -1 : 1
                if nvel(jj,2) > 0
                    ig = j; jg = 2; n1g = nvel(jj,2);
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
        if n1g> 1 & nvel(ii,2)> 1, ivcase=1; end
        if n1g> 1 & nvel(ii,2)==1, ivcase=2; end
        if n1g==1 & nvel(ii,2)> 1, ivcase=3; end
        if n1g==1 & nvel(ii,2)==1, ivcase=4; end
        if n1g> 1 & nvel(ii,2)==0, ivcase=5; end
        if n1g==1 & nvel(ii,2)==0, ivcase=6; end

        for jj = 1:nblk(ii)
            if ivg(ii,jj)==-1, continue; end % go to 170
            
            isGoto171 = false;

            xbndcl = xbnd(ii,jj,1) + 0.001;
            xbndcr = xbnd(ii,jj,2) - 0.001;

            % go to (1001,1002,1003,1004,1005,1006), ivcase
            
            % 1001
            if ivcase == 1
                for k = 1: n1g-1
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
                                fun_cvcalc(ii,jj,1,1,cf); % call cvcalc(i,j,1,1,cf)
                                if ivg(ii,jj) == 2
                                    fun_cvcalc(ii,jj,1,3,cf); % call cvcalc(i,j,1,3,cf)
                                end
                            end
                            if c2 > 0.001
                                iv = ivarv(ig,k+1,jg);
                                ivv(ii,jj,2) = iv;
                                if iv > 0
                                    cf = c2 / dxx;
                                    fun_cvcalc(ii,jj,2,1,cf); % call cvcalc(i,j,2,1,cf)
                                    if ivg(ii,jj) == 2
                                        fun_cvcalc(ii,jj,2,3,cf); % call cvcalc(i,j,2,3,cf)
                                    end
                                end
                            end
                        end
                        break; % go to 1811
                    end
                end % 180

                % 1811
                for k = 1: n1g-1
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
                                fun_cvcalc(ii,jj,2,2,cf); % call cvcalc(i,j,1,1,cf)
                                if ivg(ii,jj)==3, fun_cvcalc(ii,jj,2,4,cf); end
                            end
                            if c1 > 0.001
                                iv = ivarv(ig,k,jg);
                                ivv(ii,jj,1) = iv;
                                if iv > 0
                                    cf = c1 / dxx;
                                    fun_cvcalc(ii,jj,1,2,cf); % call cvcalc(i,j,2,1,cf)
                                    if ivg(ii,jj)==3, fun_cvcalc(ii,jj,1,4,cf); end
                                end
                            end
                        end
                        break; % go to 181
                    end
                end % 1812

                % 181
                for k = 1: nvel(ii,2)-1
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
                for k = 1: nvel(ii,2)-1
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
            if ~isGoto171 & ivcase<=2
                for k = 1: n1g-1
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
                                fun_cvcalc(ii,jj,1,1,cf); % call cvcalc(i,j,1,1,cf)
                            end
                            if c2 > 0.001
                                iv = ivarv(ig,k+1,jg);
                                ivv(ii,jj,2) = iv;
                                if iv > 0
                                    cf = c2 / dxx;
                                    fun_cvcalc(ii,jj,2,1,cf); % call cvcalc(i,j,2,1,cf)
                                end
                            end
                        end
                        break; % go to 1833
                    end
                end % 183

                % 1833
                for k = 1: n1g-1
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
                                fun_cvcalc(ii,jj,2,2,cf); % call cvcalc(i,j,1,1,cf)
                            end
                            if c1 > 0.001
                                iv = ivarv(ig,k,jg);
                                ivv(ii,jj,1) = iv;
                                if iv > 0
                                    cf = c1 / dxx;
                                    fun_cvcalc(ii,jj,1,2,cf); % call cvcalc(i,j,2,1,cf)
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
                        if ivg(ii,jj)~=2, fun_cvcalc(ii,jj,3,3,1.0);
                        if ivg(ii,jj)~=3, fun_cvcalc(ii,jj,3,4,1.0);
                    end
                end
                isGoto171 = true; % go to 171
            end
            
            % 1003
            if ~isGoto171 & ivcase<=3
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

                for k = 1: nvel(ii,2)-1
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
                for k = 1: nvel(ii,2)-1
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
            if ~isGoto171 & ivcase<=4
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
            if ~isGoto171 & ivcase<=5
                for k = 1: n1g-1
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
                                fun_cvcalc(ii,jj,1,1,cf); % call cvcalc(i,j,1,1,cf)
                                if ivg(ii,jj) ~= 2
                                    fun_cvcalc(ii,jj,1,3,cf); % call cvcalc(i,j,1,3,cf)
                                end
                            end
                            if c2 > 0.001
                                iv = ivarv(ig,k+1,jg);
                                ivv(ii,jj,2) = iv;
                                if iv > 0
                                    cf = c2 / dxx;
                                    fun_cvcalc(ii,jj,2,1,cf); % call cvcalc(i,j,2,1,cf)
                                    if ivg(ii,jj) ~= 2
                                        fun_cvcalc(ii,jj,2,3,cf); % call cvcalc(i,j,2,3,cf)
                                    end
                                end
                            end
                        end
                        break; % go to 1861
                    end
                end % 186

                % 1861
                for k = 1: n1g-1
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
                                fun_cvcalc(ii,jj,2,2,cf); % call cvcalc(i,j,1,1,cf)
                                if ivg(ii,jj)~=3, fun_cvcalc(ii,jj,2,4,cf); end
                            end
                            if c1 > 0.001
                                iv = ivarv(ig,k,jg);
                                ivv(ii,jj,1) = iv;
                                if iv > 0
                                    cf = c1 / dxx;
                                    fun_cvcalc(ii,jj,1,2,cf); % call cvcalc(i,j,2,1,cf)
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
            if ~isGoto171 & ivcase<=6
                vm(ii,jj,1) = vf(ig,1,jg);
                if ig~=ii, vm(ii,jj,1)=vm(ii,jj,1)+0.001; end
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
        xsinc = (xmax-xmin) / (npbnd-1);
        for ii = 1: nlayer+1
            if ii < nlayer+1
                il = ii; ib = 1;
            else
                il = ii-1; ib = 2;
            end
            iblk = 1;
            for jj = 1:npbnd
                x = xmin + (jj-1)*xsinc;
                if x<xmin, x=xmin+0.001; end
                if x>xmax, x=xmax-0.001; end
                while true
                    % 620
                    if x>=xbnd(il,iblk,1) & x<=xbnd(il,iblk,2)
                        cosmth(ii,jj) = s(il,iblk,ib)*x + b(il,iblk,ib);
                        break; % go to 610
                    else
                        iblk = iblk + 1;
                    end
                end
            end % 610
        end % 600

        
    end

    %% fun_goto999: calculate end for model error
    function fun_goto999()
        disp(sprintf('\n***  error in velocity model 2 ***\n'));
        iflagm = 1;
    end

    function fun_cvcalc(ii,jj,ipos,itype,cf)
    % calculate coefficients of velocity partial derivatives
        if itype == 1
            ssign = 1.0;
            sb = s(ii,jj,2);
            xb = xbnd(ii,jj,2);
            bb = b(ii,jj,2);
        elseif itype == 2
            ssign = -1.0;
            sb = s(ii,jj,2);
            xb = xbnd(ii,jj,1);
            bb = b(ii,jj,2);
        elseif itype == 3
            ssign = -1.0;
            sb = s(ii,jj,1);
            xb = xbnd(ii,jj,2);
            bb = b(ii,jj,1);
        elseif itype == 4
            ssign = 1.0;
            sb = s(ii,jj,1);
            xb = xbnd(ii,jj,1);
            bb = b(ii,jj,1);
        end

        cv(ii,jj,ipos,1) = cv(ii,jj,ipos,1) + cf * ssign * (sb*xb-bb);
        cv(ii,jj,ipos,2) = cv(ii,jj,ipos,2) - cf * ssign * sb;
        cv(ii,jj,ipos,3) = cv(ii,jj,ipos,3) - cf * ssign * xb;
        cv(ii,jj,ipos,4) = cv(ii,jj,ipos,4) + cf * ssign;
        cv(ii,jj,ipos,5) = cv(ii,jj,ipos,5) + cf * ssign * bb * xb;

        return;
    end
end


