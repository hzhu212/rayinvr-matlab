% rngkta.f
% old: [~,~,f] = fun_odezfi(x,y,f)
% [f]
% called by: fun_trace -> fun_rkdump;
% call: none.

function [f] = fun_odezfi(x,y, btan,c,factan,iblk,layer,mtan)
% pair of first order o.d.e.'s solved by runge kutta method
% with z as independent variable

	% global btan c factan iblk layer mtan;

	% real y(2),f(2)
	% f = zeros(1,2);

	sa = 1.0 .* sign(y(2));
	n1 = fix(sa.*y(2).*factan) + 1; % int -> fix
	f(1) = mtan(n1).*y(2) + sa.*btan(n1);
	term1 = c(layer,iblk,3) + c(layer,iblk,4) .* y(1);
	term2 = y(1).*(c(layer,iblk,1)+c(layer,iblk,2).*y(1)) + term1.*x + c(layer,iblk,5);
	vxv = (y(1).*(c(layer,iblk,8)+c(layer,iblk,9).*y(1))+c(layer,iblk,10).*x+c(layer,iblk,11)) ./ (term2.*(c(layer,iblk,6).*y(1)+c(layer,iblk,7)));
	vzv = term1 ./ term2;
	f(2) = vzv .* f(1) - vxv;

end
