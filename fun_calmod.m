
function     [ncont,pois,poisb,poisl,poisbl,invr,iflagm,ifrbnd,xmin1d,xmax1d,insmth,xminns,xmaxns] ...
 = fun_calmod(ncont,pois,poisb,poisl,poisbl,invr,iflagm,ifrbnd,xmin1d,xmax1d,insmth,xminns,xmaxns);
 % calculate model

    temp = num2cell(zeros(1,13));
    [ncont,pois,poisb,poisl,poisbl,invr,iflagm,ifrbnd,...
        xmin1d,xmax1d,insmth,xminns,xmaxns] = deal(temp{:});
    % global pois poisbl poisb poisl insmth

    % xa = zeros(1,2*(ppcntr+ppvel));
    % zsmth = zeros(1,pnsmth);
    % pois = zeros(1,player);
    % poisbl = zeros(1,papois);
    % zsmth = zeros(pnsmth);

end
