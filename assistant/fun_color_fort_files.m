% use color fills to plot fort.35 or fort.36 files
% fort.35 is another representation of the discretised velocity model which can then be used in a GMT script to produce a colour contoured version of the velocity model. 
% It is a simple x,z,v file where the first column is the x position, the second column is the z position, and the third column is the velocity.
% fort.63 is a simple x,z,s file where the first column is the x position, the second column is the z position, and the third column is the number of rays 
% which pass through that cell. This can then be used for plotting ray density on the same plot as the velocity model.

function fun_color_fort_files(x,y,z,type,dx,dy,xx,ZZ,boundary,label)

% fort=importdata(file);
% x=fort(:,1); y=fort(:,2); z=fort(:,3);

load('mycolormap','pvelocity_color_map','ray_density_color_map');
wh = waitbar(1/4,'Preparing the color plot, please wait...');
switch type
    case '35'
        fnumber=123;
        ftitle='Color plot of fort.35 file';
        axistitle='P-wave velocity (km/s)';
%         cs='colormap(jet(256))';
        cs='colormap(pvelocity_color_map);';
    case '63'
        fnumber=124;
        ftitle='Color plot of fort.63 file';
        axistitle='Ray numbers passing trough the cell';
%         cs='caxis([0, 20]); colormap(prism(12));';
        cs='caxis([0, 10]); colormap(ray_density_color_map);';
end
F = TriScatteredInterp(x,y,z);
waitbar(2/4,wh);
XI=min(x):dx:max(x);
YI=min(y):dy:max(y);
[qx,qy] = meshgrid(XI,YI);
waitbar(3/4,wh);
qz = F(qx,qy);
waitbar(4/4,wh);
delete(wh);
figure (fnumber);
set(fnumber,'Name',ftitle,'NumberTitle','off'); 
pcolor(qx,qy,qz);%伪彩色图
shading interp;  
eval(cs);
colorbar('location','southoutside');
% colorbar('Ydir','reverse');
set(gca,'YDir','reverse');
xlabel('Distance (km)');
ylabel('Depth (km)');

if strcmp(boundary,'1');
    hold on;
    plot(xx,ZZ,'k--');    
end

if strcmp(label,'1');
    hold on;
    for i=1:length(ZZ(:,1));
        text(min(x)-(max(x)-min(x))/20,ZZ(i,1),['B',num2str(i)]);
        text(max(x)+(max(x)-min(x))/20,ZZ(i,end),['B',num2str(i)]);
    end
end

title (axistitle);
xlim ([min(x)-(max(x)-min(x))/10,max(x)+(max(x)-min(x))/10]);
hold off;

end