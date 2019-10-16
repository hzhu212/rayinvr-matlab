% This function is written by Tao HE to calculate the azimuth of target relative to home
% The north is 0 degree.
% Note that azimuth is different from (ship) heading. However, just keep the target ahead of home, you 
% still can use this function to calculate heading.

function azi=fun_azimuth(home,target) % start/target: east and north coordinate pair; if both are *-by-2 matrix, must be in same dimension

a=target(:,1)-home(:,1); % east difference
b=target(:,2)-home(:,2); % north difference
azi=atand(b./a);
index=(a>=0)&(b>0);
azi(index)=90-azi(index);
index=(a>0)&(b<=0);
azi(index)=90+abs(azi(index));
index=(a<0)&(b>=0);
azi(index)=270+abs(azi(index));
index=(a<=0)&(b<0);
azi(index)=270-azi(index);



