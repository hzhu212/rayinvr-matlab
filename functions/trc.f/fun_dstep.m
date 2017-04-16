% trc.f
% [dstep]
% called by: fun_trace;
% call: fun_vel; done.

function [dstep] = fun_dstep(x,z)
% calculate ray step length - step length is a function of the
% absolute value of the velocity divided by the sum of the
% absolute values of the velocity gradients in the x and z
% directions
% 计算射线步长。某点处的射线步长等于 该点速度除以 x 方向速度梯度绝对值与 z 方向速度梯度
% 绝度值之和，最后乘以某个固定系数 step_。即：【 dstep = A * v / (|vx| + |vz|) 】

	global c iblk layer smax smin step_;

	vx = (c(layer,iblk,8).*x + c(layer,iblk,9).*x.*x + c(layer,iblk,10).*z + ...
		c(layer,iblk,11)) ./ (c(layer,iblk,6).*x + c(layer,iblk,7)).^2;
	vz = (c(layer,iblk,3) + c(layer,iblk,4).*x) ./ (c(layer,iblk,6).*x + ...
		c(layer,iblk,7));
	dstep = step_ .* fun_vel(x,z) ./ (abs(vx)+abs(vz));

	if dstep < smin
	    dstep = smin;
	end
	if dstep > smax
	    dstep = smax;
	end
    return;
end % fun_dstep end
