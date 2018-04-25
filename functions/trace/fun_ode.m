function dy = fun_ode(x,y, c)

    v = (c(1)*x + c(2)*x^2 + c(3)*y(1) + c(4)*x*y(1) + c(5)) / (c(6)*x + c(7));
    vx = (c(8)*x + c(9)*x^2 + c(10)*y(1) + c(11)) / (c(6)*x + c(7)).^2;
    vz = (c(3) + c(4)*x) / (c(6)*x + c(7));

    dy = zeros(2,1);
    dy(1) = cot(y(2));
    dy(2) = (vz - vx*cot(y(2))) / v;
end
