% misc.f
% [ra,rb,~]
% called by: main;
% call: none.

function [ra,rb,n] = fun_sort3(ra,rb,n)
% sort the elements of array x in order of increasing size using
% a heapsort technique

	% real ra(n)
	% integer rb(n)

	for ii = 1:n % 30
		rb(ii) = ii;
	end % 30

	l = n ./ 2 + 1;
	ir = n;

	% 10 % -------------------- cycle10 begin
	cycle10 = true;
	while cycle10
		if l > 1
			l = l - 1;
			rra = ra(l);
			rrb = rb(l);
		else
			rra = ra(ir);
			rrb = rb(ir);
			ra(ir) = ra(1);
			rb(ir) = rb(1);
			ir = ir - 1;
			if ir == 1
				ra(1) = rra;
				rb(1) = rrb;
				return;
			end
		end
		ii = l;
		jj = l + l;
		% 20 % -------------------- cycle20 begin
		while jj <= ir
			if jj < ir
				if ra(jj)<ra(jj+1), jj=jj+1; end
			end
			if rra < ra(jj)
				ra(ii) = ra(jj);
				rb(ii) = rb(jj);
				ii = jj;
				jj = jj+jj;
			else
				jj = ir + 1;
			end
			% go to 20
		end % -------------------- cycle20 end
		ra(ii) = rra;
		rb(ii) = rrb;
		% go to 10
	end % -------------------- cycle10 end
end % fun_sort3 end