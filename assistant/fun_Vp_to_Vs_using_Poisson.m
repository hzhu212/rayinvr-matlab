% convert P-wave velocity to S-wave velocity using Poisson's ratio

function vs=fun_Vp_to_Vs_using_Poisson(vp,pois)

c=2*(1-pois)./(1-2*pois);
c=sqrt(c);
vs=vp./c;

end
