function [model,LN,xmin,xmax,zmin,zmax,precision,xx,ZZ,error]=fun_load_vin(filein)
% <strong>fun_load_vin</strong> - load input file "v.in".
% 
%   [model,LN,xmin,xmax,zmin,zmax,precision,xx,ZZ,error] = <strong>fun_load_vin</strong>(filein)
%   
%   <strong>model</strong>: a structure with 3 fields: model.bd(layer top boundary), model.tv(top velocity) and model.bv(bottom velocity). each field is designed as a cell, which stores a 3-by-Nodes matrix for row(1): x, row(2): z or v, and row(3): partial derivative for each node
%   <strong>LN</strong>: layer number of the model

fid = fopen(filein,'r');
count=0;
imdata={};
line = fgetl(fid);
value=sscanf(line,'%f'); % read values of first boundary
xmin=value(2); % model left boundary
index=strfind(line,'.'); % get the position of '.'
value=index(2:end)-index(1:end-1);
switch mean(value)
    case 7
        precision='low';
    case 8
        precision='high';
    otherwise
        precision=['unknown, the 1st line is: "',line,'"']; % cannot determine the format, something wrong
end
while ischar(line)
    count=count+1;
    imdata{count,1}=line;
    line = fgetl(fid);
end
fclose(fid);
% imdata=importdata(filein,'D');  % use an INVALID delimiter to force the data is imported in as a string cell; each line is a cell element

% get layer number and value precision
line=imdata{length(imdata)-1}; % string of last boundary line
value=sscanf(line,'%f'); % read values of last boundary
LN=value(1); % layer number of the model
xmax=value(end); % model right boundary

% use structure to store model, bd=layer top boundary, tv=top velocity, bv=bottom velocity
% each cell is a 3xNodes matrix for (1) x, (2) z or v, and (3) partial derivative for each node
fieldname={'bd','tv','bv'};
fullfn={'top boundary depth','top velocity','bottom velocity'};
model=struct(fieldname{1},{},fieldname{2},{},fieldname{3},{}); 
pp=1;  % first line of the v.in
xx=xmin:(xmax-xmin)/100:xmax;
ZZ=zeros(LN,length(xx));
error={};
errorcount=0;
for i=1:LN-1;
    for j=1:3; % bd=layer top boundary, tv=top velocity, bv=bottom velocity
        over10=1; % assume nodes number larger than 10
        final=[];
        while over10
            vv=cell(3,1);
            vl=zeros(3,1);
            for k=1:3; % x, z(v), partial derivative
                value=sscanf(imdata{pp},'%f'); % read values
                vl(k)=length(value);
                vv{k}=value'; % transverse to line vector
                pp=pp+1;
            end
            if vl(2)-vl(1)>2 || vl(3)~=vl(1)-1;
                errorcount=errorcount+1;
                error{errorcount}=['Layer ',num2str(i),', parameter ',num2str(j),': Node numbers do not equal!'];
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
        if length(final(1,:))==1; % extend one node format to standard 2 or more nodes format
            final(:,2)=final;
            final(1,1)=xmin;
        end
        if final(1,1)~=xmin || final(1,end)~=xmax;
            errorcount=errorcount+1;
            error{errorcount}=['Layer ',num2str(i),', ',fullfn{j},': Node x coordinate is over model boundary! This problem has been fixed by reset first and last x coordinates.'];
            final(1,1)=xmin; final(1,end)=xmax;
        end
        duplicate=find((final(1,2:end)-final(1,1:end-1))==0);
        if ~isempty(duplicate);
            errorcount=errorcount+1;
            error{errorcount}=['Layer ',num2str(i),', ',fullfn{j},': Node x has same coordinate! This problem has been fixed by delete duplicated x coordinates.'];
            final(:,duplicate)=[];
        end
        if ~isempty(find((final(1,2:end)-final(1,1:end-1))<0));
            errorcount=errorcount+1;
            error{errorcount}=['Layer ',num2str(i),', ',fullfn{j},': Node x coordinate is not monotonic increasing! This problem has been fixed by resort.'];
            final=sortrows(final',1)';
        end
        if sum(final(3,:)==0)+sum(final(3,:)==1)+sum(final(3,:)==-1)~=length(final(3,:));
            errorcount=errorcount+1;
            error{errorcount}=['Layer ',num2str(i),', ',fullfn{j},': Node partial derivative has abnormal value! This problem has to be fixed MANULLY.'];
        end
        if j==1;
            ZZ(i,:)=interp1(final(1,:),final(2,:),xx,'linear');  % for later depth check
        end
        eval(['model(',num2str(i),').',fieldname{j},'=final;']);
    end
end
% model bottom 
value=sscanf(imdata{pp},'%f')';
pp=pp+1;
final=sscanf(imdata{pp},'%f')';
if length(value)>length(final);
    model(LN).bd=[value(2:end); final];
else
    model(LN).bd=[value(2:end); final(2:end)];
end
final=model(LN).bd;
if length(final(1,:))==1; % extend one node format to standard 2 or more nodes format
            final(:,2)=final;
            final(1,1)=xmin;
end
model(LN).bd=final;
ZZ(LN,:)=interp1(model(LN).bd(1,:),model(LN).bd(2,:),xx,'linear');
zmin=min(min(ZZ));
zmax=max(max(ZZ));

% depth check
for i=2:LN;
    if ~isempty(find((ZZ(i,:)-ZZ(i-1,:))<0))
        errorcount=errorcount+1;
        error{errorcount}=['Layer ',num2str(i),': Top boundary depth less than above layer after linear interpolation! This problem has to be fixed MANULLY.'];
    end
end

end % fun_load_vin