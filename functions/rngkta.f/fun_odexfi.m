% rngkta.f
% old: [~,~,f] + fun_odexfi(x,y,f)
% [f]
% called by: fun_trace -> fun_rkdump;
% call: none.

function [f] = fun_odexfi(x,y, bcotan,c,factan,iblk,layer,mcotan)
% pair of first order o.d.e.'s solved by runge kutta method
% with x as independent variable

	% global bcotan c factan iblk layer mcotan;

	sa = 1.0 .* sign(y(2));
	n1 = fix(sa.*y(2).*factan) + 1;
	f(1) = mcotan(n1).*y(2) + sa.*bcotan(n1);
	term1 = c(layer,iblk,3) + c(layer,iblk,4) .* x;
	term2 = x.*(c(layer,iblk,1)+c(layer,iblk,2).*x) + term1.*y(1) + c(layer,iblk,5);
	vxv = (x.*(c(layer,iblk,8)+c(layer,iblk,9).*x)+c(layer,iblk,10).*y(1)+c(layer,iblk,11)) ./ (term2.*(c(layer,iblk,6).*x+c(layer,iblk,7)));
	vzv = term1 ./ term2;
	f(2) = vzv - vxv .* f(1);

end
