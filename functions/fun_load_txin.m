% [xpf,tpf,upf,ipf]
% called by: main

function [xpf,tpf,upf,ipf] = fun_load_txin(file_txin)
% load the tx.in file into main process

    global ilshot vred

    txData = load(file_txin,'-ascii');
    [xpf,tpf,upf,ipf] = deal(txData(:,1),txData(:,2),txData(:,3),txData(:,4));
    isf = 1; nsf = 0; xshotc = 0.0;

    while ipf(isf) ~= -1
        if ipf(isf) <= 0
            nsf = nsf + 1;
            ilshot(nsf) = isf;
            xshotc = xpf(isf);
        else
            if vred ~= 0
                tpf(isf) = tpf(isf) - abs(xshotc-xpf(isf)) ./ vred;
            end
        end
        isf = isf + 1;
    end

    nsf = nsf + 1;
    ilshot(nsf) = isf;

end % fun_load_txin end
