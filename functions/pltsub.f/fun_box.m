% pltsub.f
% []
% call: fun_plot;
% called by: fun_pltmod; fun_plttx;

function fun_box(x1,z1,x2,z2)
% plot a box whose opposite corners are (x1,z1) and (x2,z2)

	fun_plot(x1,z1,3);
	fun_plot(x2,z1,2);
	fun_plot(x2,z2,2);
	fun_plot(x1,z2,2);
	fun_plot(x1,z1,2);

	return;
end % fun_box end