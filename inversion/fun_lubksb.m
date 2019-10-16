function [a,n,indx,b]=fun_lubksb(a,n,indx,b,t)
%solve the system of n linear equations ax=b


ii=0;
for i=1:n
    ll=indx(i);
    sum=b(ll,t);
    b(ll,t)=b(i,t);
    if ii~=0
        for j=ii:i-1
            sum=sum-a(i,j)*b(j,t);
        end
    else if sum~=0.0
            ii=i;
        end
    end
    b(i,t)=sum;
end
for i=n:-1:1
    sum=b(i,t);
    if i<n
        for j=i+1:n
            sum=sum-a(i,j)*b(j,t);
        end
    end
    b(i,t)=sum/a(i,i);
end

end
