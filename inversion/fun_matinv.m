function [a,y,n]=fun_matinv(a,y,n)
%invert the n*n matrix a

global pnvar;
indx=zeros(pnvar,1);

for i=1:n
    y(i,i)=1;
end

d=1.0;
[a,n,indx,d]=fun_ludcmp(a,n,indx,d);
%fun_ludcmp(a,n,indx,d);

for j=1:n
    [a,n,indx,y]=fun_lubksb(a,n,indx,y,j);
    %fun_lubksb(a,n,indx,y(1,j));
end

end