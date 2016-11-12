
function     [ncont,pois,poisb,poisl,poisbl,invr,iflagm,ifrbnd,xmin1d,xmax1d,insmth,xminns,xmaxns] ...
 = fun_calmod(ncont,pois,poisb,poisl,poisbl,invr,iflagm,ifrbnd,xmin1d,xmax1d,insmth,xminns,xmaxns);
 % calculate model

    % temp = num2cell(zeros(1,13));
    % [ncont,pois,poisb,poisl,poisbl,invr,iflagm,ifrbnd,...
    %     xmin1d,xmax1d,insmth,xminns,xmaxns] = deal(temp{:});
    % global pois poisbl poisb poisl insmth

    global file_rayinvr_par file_rayinvr_com;
    run(file_rayinvr_par);
    xa = zeros(1,2*(ppcntr+ppvel));
    zsmth = zeros(1,pnsmth);
    run(file_rayinvr_com);
    iflagm = 0;
    idvmax = 0;
    idsmax = 0;

    % xm(1:3,1:10),ncont

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

        size(xa);

    end

end


%% fun_goto999: calculate end for model error
function fun_goto999()
    disp(sprintf('\n***  error in velocity model 2 ***\n'));
    iflagm = 1;
end
