%% fun_load_fin: read in floating reflectors
%% f.in文件结构与v.in类似，只不过每个小节前面增加了一个描述本层节点数目的整数
function [nfrefl,xfrefl,zfrefl,ivarf,npfref,fmodel]=fun_load_fin(file_fin)
    % read in floating reflectors

    global ppfref;

    fid = fopen(file_fin,'r');
    count=0;
    imdata={};
    line = fgetl(fid);
    while ischar(line)
        count=count+1;
        imdata{count,1}=line;
        line = fgetl(fid);
    end
    fclose(fid);

    line=imdata{2};
    value=sscanf(line,'%i');
    startnum=value(1);  %the start number of floating reflector
    line=imdata{length(imdata)-2};
    value=sscanf(line,'%i');
    endnum=value(1);  %the end number of floating reflector

    fmodel={};
    pp=1;  % first line of the v.in
    error={};
    errorcount=0;
    for i=startnum:endnum
        line=imdata{(i-1)*4+1};
        value=sscanf(line,'%i');
        nn=value;   %the number of nodes
        if nn<2 || nn>ppfref
            error('e:error','\n***  error in f.in file  ***\n');
        end
        over10=1; % assume nodes number larger than 10
        final=[];
        while over10
            vv=cell(3,1);
            vl=zeros(3,1); %length
            for j=1:3; % x, z, partial derivative
                pp=pp+1;
                value=sscanf(imdata{pp},'%f'); % read values
                vv{j}=value'; % transverse to line vector
                vl(j)=length(value);
            end
            if vl(2)-vl(1)>2 || vl(3)~=vl(1)-1;
                errorcount=errorcount+1;
                error{errorcount}=['Number ',num2str(i),', parameter ',num2str(j),': Node numbers do not equal!'];
            elseif vl(2)==vl(1)-1;
                over10=0;
            elseif vl(2)==vl(1);
                if vv{2}(1)==0,
                    over10=0;
                end
            end
            [ll,cc]=size(final);
            final(:,cc+1:cc+vl(3))=[vv{1}(2:end); vv{2}(end-vl(3)+1:end); vv{3}];
        end
        [ll,cc]=size(final);
        temp(1,1:cc)=[nn, zeros(1,cc-1)];
        final=[temp; final];
        fmodel{i}=final;
        pp=pp+1;
        xfrefl(i,1:nn)=final(2,:);
        zfrefl(i,1:nn)=final(3,:);
        ivarf(i,1:nn)=final(4,:);
        npfref(i,1)=nn;
    end
    nfrefl=endnum;  %total number of nodes
end