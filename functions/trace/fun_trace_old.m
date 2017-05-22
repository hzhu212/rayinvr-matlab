% trc.f
% old: [npt,~,~,~,~,~,iflag,~,~,~,~,i1ray,~] = fun_trace(npt,ifam,ir,iturn,invr,xsmax,iflag,idl,idr,iray,ii2pt,i1ray,modout)
% [npt,iflag,i1ray]
% called by: main; fun_autotr;
% call: fun_strait; fun_check; fun_rngkta; fun_rkdumb; fun_odex; fun_odexfi;
% fun_velprt; fun_odez; fun_odezfi; fun_frefpt; fun_frefl; fun_adjpt; fun_hdwave;
% fun_dstep; fun_vel; done.

function [npt,iflag,i1ray] = fun_trace_old(npt,ifam,ir,iturn,invr,xsmax,idl,idr,iray,ii2pt,i1ray,modout)
% trace a single ray through the model
% npt: 当前射线的节点数
% ifam: 累计射线组编号
% ir: 当前射线在射线组内的编号
% xsmax: 当前射线可到达的最远距离
% idl: 射线组编号-层号
% idr: 射线组编号-射线类型编号
% iray: 1-绘制所有射线，2-只绘制到达边界的射线
% iflag: 0-函数正常完成，1-未正常完成

	global fID_11 fID_12;
	global ar_ b dstepf fid hdenom hmin iblk ivg ifcbnd idray iwave idump ...
		id ifast isrkc icasel ihdw layer ntray ntpts n2 n3 nptbnd pi2 pi4 pi18 ...
		ppray pi34 ray s smax tol vr vp vs vsvp xr xbnd zr;

	global bcotan c factan iblk layer mcotan; % for fun_rkdumb -> fun_odexfi
	global btan c factan iblk layer mtan; % for fun_rkdumb -> fun_odezfi
	global ar_ b c crit cosmth dstepf fid fid1 iblk id ivg iwave icasel ircbnd iccbnd ...
	  idray istop ibsmth icbnd iheadf idifff ihdw layer nbnd nptbnd npskp ...
	  n2 n3 nblk nstepr nccbnd nbnda nlayer piray pi2 pit2 ray refll s vm ...
	  vr vp vs vsvp xmin xr xsinc zr; % for fun_adjpt
	global c iblk layer smax smin step_; % for fun_dstep

	% layer: 当前节点所在的层号
	% iblk: 当前节点所在的 block 编号

	[xfr,zfr,ifrpt] = deal([]); % for fun_frefpt
	[lstart,istart] = deal([]); % for fun_adjpt

	ntray = ntray + 1;
	dstepf = 1.0;
	n2 = 0; n3 = 0;
	iflag = 0;
	if ivg(layer,iblk) > 0
		hn = fun_dstep(xr(npt),zr(npt), c,iblk,layer,smax,smin,step_) ./ hdenom;
	else
		hn = smax ./ hdenom;
	end
	hminn = hn .* hmin;

	% 1000 % -------------------- circle 1000 begin
	cycle1000 = true;
	while cycle1000
		% 输出到 r1.out
		if idump == 1
			fprintf(fID_12,'%2d%3d%4d%8.3f%8.3f%8.2f%8.2f%7.2f%7.2f%3d%3d%3d%3d\n',...
				ifam,ir,npt,xr(npt),zr(npt),ar_(npt,1).*pi18,ar_(npt,2).*pi18,...
				vr(npt,1),vr(npt,2),layer,iblk,id,iwave); % 5
		end
		% iwave=1: 当前射线为横波
		% 如果横波速度小到一定程度，为方便计算，认为其不能通过
		if iwave == -1 && vr(npt,2) <= 0.001
			vr(npt,2) = 0.0;
			iflag = 1;
			if ir ~= 0
				% 25
				fprintf(fID_11,'***  ray stopped - s-wave cannot propagate  ***\n');
			end
			[~,~,~,vr,~,iflag,ntpts] = fun_goto900(ifcbnd,idray,ii2pt,vr,npt,iflag,ntpts);
			return; % go to 900
		end
		% 如果该节点不是第一个节点
		if npt > 1
			% 如果在该节点处射线传播方向改变（例如由向下传播转为向上传播）
			if ((ar_(npt,2) - fid.*pi2) .* (ar_(npt-1,2) - fid.*pi2)) <= 0.0
				if iturn ~= 0
					[~,~,~,vr,~,iflag,ntpts] = fun_goto900(ifcbnd,idray,ii2pt,vr,npt,iflag,ntpts);
					return; % go to 900
				end
			end
		end

		isrkc = 1;
		% 如果该节点处出射角(射线方向与z轴正方向(朝下)之间的夹角，从z轴开始逆时针为正)
		% 在 pi/4 到 3/4*pi 之间，说明射线主要沿 x 方向传播
		if (fid .* ar_(npt,2)) >= pi4 && (fid .* ar_(npt,2)) <= pi34
			% solve o.d.e.'s w.r.t. x

			% 以 x 作为自变量，z 与 theta(出射角) 作为微分方程的待求量
			x = xr(npt);
			y(1) = zr(npt);
			y(2) = ar_(npt,2);

			% 如果当前 block 内没有速度梯度，射线沿直线行进一个 step
			if ivg(layer,iblk) == 0
				[x,y] = fun_strait(x,y,npt,0, ar_,dstepf,fid,pi2,smax,xr,zr);
			else
				% 射线行进一个步长，得到新的 x 坐标
				% 用变量 z 来代表新的 x 坐标？
				z = x + fid .* fun_dstep(xr(npt),zr(npt), c,iblk,layer,smax,smin,step_) ./ dstepf;
				% 检查点(new_x,z)是否在横向上超出了当前 block 的边界，如果出界则调节 new_x，使其刚好落在边界外 0.001km 处
				[z,zr(npt)] = fun_check(0,z,zr(npt), b,iblk,id,layer,s,xbnd);

				% 使用有错误控制的 Runge-kutta 方法，较慢
				if ifast == 0
					odex = @ fun_odex;
					[x,~,y,f,hn,~,~,~,w1,w2,w3] = fun_rngkta(x,z,y,f,hn,hminn,tol,odex,w1,w2,w3);
				% 使用不带错误控制的 Runge-kutta 方法，快 30%-40%，推荐使用！
				else
					% 求出下一个节点的 z 坐标和入射角(分别为 y(1),y(2))
					odexfi = @ fun_odexfi;
					[y] = fun_rkdumb(y,x,z,odexfi, bcotan,c,factan,iblk,layer,mcotan);
					x = z;
				end
			end

			% 如果节点数超过预设上限，退出
			if npt == ppray
				[vr,iflag,~,~,~,~,~,~,ntpts] = fun_goto999(vr,iflag,ir,fID_11,ifcbnd,idray,ii2pt,npt,ntpts);
				return; % go to 999
			end
			% 继续计算下一个节点
			npt = npt + 1;
			% 保存新节点的 x 和 z 坐标
			xr(npt) = x;
			zr(npt) = y(1);

		% 否则，说明射线主要沿 z 方向传播
		else
			% solve o.d.e.'s w.r.t. z

			% 以 z 坐标作为自变量 x，x 坐标与出射角作为微分方程待求量
			x = zr(npt);
			y(1) = xr(npt);
			y(2) = ar_(npt,2);

			if ivg(layer,iblk) == 0
				[x,y] = fun_strait(x,y,npt,1, ar_,dstepf,fid,pi2,smax,xr,zr);
			else
				% 射线行进一个步长，得到新的 z 坐标
				if (fid.*ar_(npt,2)) <= pi2
					z = x + fun_dstep(xr(npt),zr(npt), c,iblk,layer,smax,smin,step_) ./ dstepf;
				else
					z = x - fun_dstep(xr(npt),zr(npt), c,iblk,layer,smax,smin,step_) ./ dstepf;
				end

				% 检查点(x,new_z)是否在纵向上超出了当前 block 的边界，如果出界则调节 new_z，使其刚好落在边界外 0.001km 处
				[xr(npt),z] = fun_check(1,xr(npt),z, b,iblk,id,layer,s,xbnd);

				if ifast == 0
					odez = @ fun_odez;
					[x,~,y,f,hn,~,~,~,w1,w2,w3] = fun_rngkta(x,z,y,f,hn,hminn,tol,odez,w1,w2,w3);
				else
					odezfi = @ fun_odezfi;
					[y] = fun_rkdumb(y,x,z,odezfi, btan,c,factan,iblk,layer,mtan);
					x = z;
				end
			end
			if npt == ppray
				[vr,iflag,~,~,~,~,~,~,ntpts] = fun_goto999(vr,iflag,ir,fID_11,ifcbnd,idray,ii2pt,npt,ntpts);
				return; % go to 999
			end
			npt = npt + 1;
			xr(npt) = y(1);
			zr(npt) = x;
		end

		% 保存新节点的入射角
		ar_(npt,1) = y(2);
		% 新节点的出射角(即下一个节点的入射角)，暂时赋值为入射角，下一轮会计算
		ar_(npt,2) = y(2);
		% 计算新节点的入射速度值
		vp(npt,1) = fun_vel(xr(npt),zr(npt), c,iblk,layer);
		vs(npt,1) = vp(npt,1) .* vsvp(layer,iblk);
		if iwave == 1
			vr(npt,1) = vp(npt,1);
		else
			vr(npt,1) = vs(npt,1);
		end
		% 出射速度值(即下一个节点的入射速度值)，暂时赋值，下一轮会计算
		vr(npt,2) = vr(npt,1);
		vp(npt,2) = vp(npt,1);
		vs(npt,2) = vs(npt,1);

		iflagf = 0;
		% ifcbnd>0: 当前层内存在浮动界面
		if ifcbnd > 0
			if nptbnd == 0 || icasel ~= 5
				% 寻找与浮动界面的交点
				[xfr,zfr,ifrpt,iflagf] = fun_frefpt(npt);
			end
		end

		top = s(layer,iblk,1) .* xr(npt) + b(layer,iblk,1);
		bottom = s(layer,iblk,2) .* xr(npt) + b(layer,iblk,2);
		left = xbnd(layer,iblk,1);
		right = xbnd(layer,iblk,2);

		% 如果新节点仍在当前 block 内
		if zr(npt)>top && zr(npt)<=bottom && xr(npt)>left && xr(npt)<=right
			% 如果是横波且速度很低，计算浮动界面反射事件
			if iflag == 1
				fun_frefl(ir,npt,xfr,zfr,ifrpt,modout,invr);
			end
			% 如果需要反演，则计算速度偏微分
			if ir~=0 && invr==1
				fun_velprt(layer,iblk,npt);
			end
			dstepf = 1.0;
			continue; % go to 1000
		else
			nptin = npt;
			[ar_,b,c,crit,cosmth,dstepf,fid,fid1,iblk,id,ivg,iwave,icasel,ircbnd,iccbnd,...
				idray,istop,ibsmth,icbnd,iheadf,idifff,ihdw,layer,nbnd,nptbnd,npskp,...
				n2,n3,nblk,nstepr,nccbnd,nbnda,nlayer,piray,pi2,pit2,ray,refll,s,vm,...
				vr,vp,vs,vsvp,xmin,xr,xsinc,zr, ...
			npt,top,bottom,~,~,~,~,~,lstart,istart,~,iflag,~,~,~,~,~,~,~] ...
			= fun_adjpt(ar_,b,c,crit,cosmth,dstepf,fid,fid1,iblk,id,ivg,iwave,icasel,ircbnd,iccbnd,...
				idray,istop,ibsmth,icbnd,iheadf,idifff,ihdw,layer,nbnd,nptbnd,npskp,...
				n2,n3,nblk,nstepr,nccbnd,nbnda,nlayer,piray,pi2,pit2,ray,refll,s,vm,...
				vr,vp,vs,vsvp,xmin,xr,xsinc,zr, ...
				xbnd, ...
			npt,top,bottom,left,right,ifam,ir,iturn,lstart,istart,invr,iflag,idl,idr,xfr,zfr,ifrpt,iflagf,modout);
			% [npt,top,bottom,~,~,~,~,~,lstart,istart,~,iflag,~,~,~,~,~,~,~] ...
			% = fun_adjpt(npt,top,bottom,left,right,ifam,ir,iturn,lstart,istart,invr,iflag,idl,idr,xfr,zfr,ifrpt,iflagf,modout);

			if ir~=0 && invr==1 && nptin==npt
				fun_velprt(lstart,istart,npt);
			end

			if ihdw==1 && (ir~=0 || ii2pt>0)
				[npt,iflag,i1ray] = fun_hdwave(ifam,ir,npt,invr,xsmax,iflag,i1ray,modout);
			end

			if iflag==0, continue; end % go to 1000
		end

		break; % go to nothing
	end % -------------------- circle 1000 end

	[~,~,~,vr,~,iflag,ntpts] = fun_goto900(ifcbnd,idray,ii2pt,vr,npt,iflag,ntpts);
	return; % go to 900

end % function end


% 900
% [~,~,~,vr,~,iflag,ntpts]
function [ifcbnd,idray,ii2pt,vr,npt,iflag,ntpts] = fun_goto900(ifcbnd,idray,ii2pt,vr,npt,iflag,ntpts)

	if ifcbnd > 0 && idray(2) ~= 4 && ii2pt == 2
		vr(npt,2) = 0.0;
		iflag = 1;
	end
	ntpts = ntpts + npt;
	return;
end

% 999
% [vr,iflag,~,~,~,~,~,~,ntpts]
function [vr,iflag,ir,fID_11,ifcbnd,idray,ii2pt,npt,ntpts] = fun_goto999(vr,iflag,ir,fID_11,ifcbnd,idray,ii2pt,npt,ntpts)

	vr(500,2) = 0.0;
	iflag = 1;
	if ir ~= 0
		fprintf(fID_11,'***  ray stopped - consists of too many points  ***\n'); % 15
	end
	if ifcbnd > 0 && idray(2) ~= 4 && ii2pt == 2
		vr(npt,2) = 0.0;
		iflag = 1;
	end
	ntpts = ntpts + npt;
	return;
end
