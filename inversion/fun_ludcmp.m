function [a,n,indx,d]=fun_ludcmp(a,n,indx,d)
%replace a by its LU decomposition

global pnvar;
vv=zeros(pnvar,1);
indx=zeros(n,1);

tiny=1.0/(10^20);

for i=1:n
    aamax=0;
    for j=1:n
        if(abs(a(i,j))>aamax)
            aamax=abs(a(i,j));  %该行最大绝对值
        end
    end
    if aamax==0     %若该行全为0
        error='***  singular matrix  ***';
        disp(error);
    end
    vv(i)=1.0/aamax;    %该行最大绝对值的倒数
end
for j=1:n
    if j>1
        for i=1:j-1     %不包括对角线的右上半矩阵
            sum=a(i,j); %第一行不替换
            if i>1
                for k=1:i-1
                    sum=sum-a(i,k)*a(k,j);
                end
                a(i,j)=sum;     %值替换
            end
        end
    end
    aamax=0;    
    for i=j:n   %左下半矩阵
        sum=a(i,j); %第一列不替换
        if j>1
            for k=1:j-1
                    sum=sum-a(i,k)*a(k,j);
            end
            a(i,j)=sum;     %值替换
        end
        dum=vv(i)*abs(sum);     %原矩阵每行最大绝对值的倒数*左下半矩阵新替换值的绝对值
        if dum>=aamax   
            imax=i;     %替换后左下半矩阵该列最大计算值所在行数（j<=i<=n）
            aamax=dum;  %aamax为替换后左下半矩阵该列最大计算值
        end
    end
    if j~=imax  
        for k=1:n
            dum=a(imax,k);
            a(imax,k)=a(j,k);
            a(j,k)=dum;     %第imax行与第j行值互换
        end
        d=-d;
        vv(imax)=vv(j);     %不互换？？
    end
    indx(j)=imax;   %替换后左下半矩阵该列最大计算值所在行数
    if j~=n
        if a(j,j)==0.0
            a(j,j)=tiny;    
        end
        dum=1.0/a(j,j);      %对角线倒数
        for i=(j+1):n       %不包括对角线的左下半矩阵值替换
            a(i,j)=a(i,j)*dum;  
        end
    end
end
if a(n,n)==0.0
    a(n,n)=tiny;    
end

end





