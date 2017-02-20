% misc.f
% [x,~]
% called by:
% call: none.

function [x,npts] = fun_sort(x,npts)
% sort the elements of array x in order of increasing size using
% a bubble sort technique

	% real x(1)
	for ii = 1:npts-1 % 10
	    iflag = 0;
	    for jj = 1:npts-1 % 20
	        if x(jj) > x(jj+1)
	            iflag = 1;
				xh = x(jj);
				x(jj) = x(jj+1);
				x(jj+1) = xh;
	        end
	    end % 20
	    if iflag == 0, return; end
	end % 10
	return;
end % fun_sort end