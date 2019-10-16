function fun_plot_model(fh,model,xmin,xmax,zmin,zmax,xx,ZZ,selectL,dx,dy,blocks,bselect,X1D,plot1D,output1D,savepath,varargin)
% varargin(1): symbol and label switches, slswitch={'y','y''y''y''y'}
% varargin(2): symbol color scolor={'b','k','r'}

% zmin=2; zmax=5.5;
% selectL=[1:1:10]; % which layer to draw symbol and label value

% define symbol and color
% depth node use empty square, velocity node use solid dot
% depth node on the line, velocity node slightly above/below line
% partial derivative: -1 is blue, 0 is black, 1 is red
% default:
labelL=true; % 'y' for yes to label the layer boundary number; 'n' for no
symbolZ=false; %
labelZ=false; % 'y' for yes to label depth value; 'n' for no: only valid if the symbol is drawn
symbolV=true; %
labelV=true; %
colorplot=false;
scolor={'m','k','r'};  % for node variable or not: m for -1 of gradient, k for 0 of fixed, r for 1 of derivative
symb={'s','.','.'}; % s for depth node, . for top and bottom velocity node
V1D=cell(1,length(X1D)); % 用于存放插值出来的1D速度模型

if dx==0 || dy==0;
    dx=0.01; dy=0.01;
end
    
if length(varargin)>=1;
    if ~isempty(varargin{1});
        slswitch=varargin{1};
        [labelL,symbolZ,labelZ,symbolV,labelV,colorplot]=deal(slswitch{1:6});
    end
end
if length(varargin)==2 && ~isempty(varargin{2});
    scolor=varargin{2};
end

fn=fieldnames(model);
LN=length(model);

X=xmin:0.001:xmax;  % 横向采用1米的精度对深度和速度进行插值
[x,y,z]=deal([]);
for i=1:LN-1;
    % top V
    x=[x; X'];
    v1=getfield(model,{i},fn{1});
    v=interp1(v1(1,:),v1(2,:),X,'linear');
    y=[y; v'+0.00001];
    v1=getfield(model,{i},fn{2});
    v=interp1(v1(1,:),v1(2,:),X,'linear');
    z=[z; v'];
    % bottom V
    x=[x; X'];
    v1=getfield(model,{i+1},fn{1});
    v=interp1(v1(1,:),v1(2,:),X,'linear');
    y=[y; v'];
    v1=getfield(model,{i},fn{3});
    v=interp1(v1(1,:),v1(2,:),X,'linear');
    z=[z; v'];
end
F = TriScatteredInterp(x,y,z); % 三角形插值的类


% fh=figure(100);
figure(fh);
hold off;
if colorplot;  % 处理彩色图
    wh = waitbar(0/4,'Preparing the color plot, please wait...');
    XI=xmin:dx:xmax;
    YI=zmin:dy:zmax;
    [qx,qy] = meshgrid(XI,YI);
    LYI=length(YI);
    waitbar(1/4,wh);
    for i=1:LYI
        qz(i,:) = F(qx(i,:),qy(i,:));
        waitbar(1/4+i/LYI*0.75,wh);
    end
    delete(wh);
    load('mycolormap','pvelocity_color_map');
    pcolor(qx,qy,qz);%伪彩色图
    shading interp;
    caxis([1.48, 4.5]);
    colormap(pvelocity_color_map);
    colorbar('location','southoutside');
    hold on;
end
plot(xx,ZZ,'k--'); % 画层边界
hold on;

% plot block's vertical boundaries
if bselect{1}
    for i=1:length(blocks)
        nodes=blocks{i};
        for j=1:length(nodes(:,1))
            plot([nodes(j,1) nodes(j,1)],nodes(j,2:3),'k:');
            % label block's number
            if bselect{2} && j<length(nodes(:,1))
                text((nodes(j,1)+nodes(j+1,1))/2,(nodes(j,2)+nodes(j,3)+nodes(j+1,2)+nodes(j+1,3))/4,['\color{red}',num2str(i),'-',num2str(j)]);
            end
        end
    end;
end

% Top Z
if symbolZ;
    j=1;
    for i=selectL;
        value=getfield(model,{i},fn{j});
        vl=length(value(1,:));
        if i==LN;
            pd=ones(1,vl)*2;
        else
            pd=value(3,:)+2;
        end
        for k=1:vl;
            px=value(1,k);
            py=value(2,k);
            plot(px,py,[scolor{pd(k)},symb{j}]);
            if labelZ;
                text(px-(xmax-xmin)/100,py-(zmax-zmin)/50,sprintf('%5.3f',py));
            end
        end
    end
end
% Top V
if symbolV || labelV;
    j=2;
    for i=selectL;
        if i~=LN;
            value=getfield(model,{i},fn{j});
            px=value(1,:);
            vl=length(px);
            py=interp1(xx,ZZ(i,:),px,'linear');
            d=interp1(xx,ZZ(i+1,:),px,'linear')-py;
            pd=value(3,:)+2;
            for k=1:vl;
                dd=min([d(k)/4,(zmax-zmin)/100]);
                if symbolV;
                    plot(px(k),py(k)+dd,[scolor{pd(k)},symb{j}],'MarkerSize',15);
                end
                if labelV;
                    text(px(k)+(xmax-xmin)/80,py(k)+dd,['\color{blue}',sprintf('%5.3f',value(2,k))]);
                end
            end
        end
    end
end
% bottom V
if symbolV || labelV;
    j=3;
    for i=selectL;
        if i~=LN;
            value=getfield(model,{i},fn{j});
            px=value(1,:);
            vl=length(px);
            py=interp1(xx,ZZ(i+1,:),px,'linear');
            d=py-interp1(xx,ZZ(i,:),px,'linear');
            pd=value(3,:)+2;
            for k=1:vl;
                dd=min([d(k)/4,(zmax-zmin)/100]);
                if symbolV;
                    plot(px(k),py(k)-dd,[scolor{pd(k)},symb{j}],'MarkerSize',15);
                end
                if labelV;
                    text(px(k)+(xmax-xmin)/80,py(k)-dd,['\color{orange}',sprintf('%5.3f',value(2,k))]);
                end
            end
        end
    end
end
% Label Layer number
if labelL
    for i=1:LN;
        text(xmin-(xmax-xmin)/20,ZZ(i,1),['B',num2str(i)]);
        text(xmax+(xmax-xmin)/20,ZZ(i,end),['B',num2str(i)]);
    end
end


% axes et al
hold off;
set(gca,'YDir','reverse');
xlabel('Distance (km)');
ylabel ('Depth (km)');
ylim ([zmin zmax]);
xlim ([xmin-(xmax-xmin)/10,xmax+(xmax-xmin)/10]);
text(xmin,zmin-(zmax-zmin)/20,['Symbol: square for depth, dot for velocity ({\color{red}red color for change label 1, \color{magenta}magenta for -1, }black for 0)',char(13,10)',...
    'Value: black for depth, {\color{blue}blue for top velocity, \color{orange}orange for bottom velocity}'],...
     'BackgroundColor',[.7 .9 .7],'EdgeColor','c','Margin',8);
 
 if output1D || plot1D;
     TZ=interp1(xx,ZZ(1,:),X1D);
     seafloor=interp1(xx,ZZ(2,:),X1D);
     BZ=interp1(xx,ZZ(end,:),X1D);
     nX=length(X1D);
     for i=1:nX
         qy=[TZ(i):dy:BZ(i)]';
         qx=ones(length(qy),1)*X1D(i);
         qz = F(qx,qy);
         V1D{i}=[qx,qy,qz];
     end
     if plot1D
         figure (1221);
         linetype={'b-','r-','k-','c-','m-','b:','r:','k:','c:','m:'};
         for i=1:nX
             data=V1D{i};
             plot(data(:,3),data(:,2),linetype{i});
             hold on;
         end
         hold off;
         xlabel ('Velocity (km/s)');
         ylabel ('Depth below seafloor (km)');
         set(gca,'YDir','reverse');
         ylim ([zmin zmax]);
         grid on;
         legend (num2str(X1D'));
     end
     if output1D
         for i=1:nX
             data=V1D{i};
             fid=fopen(fullfile(savepath,['Vp_at_',num2str(X1D(i)),'.txt']),'w');
             fprintf(fid,'1D Vp at model distance of %-10.3f\n',X1D(i));
             fprintf(fid,'Seafloor depth is %-10.3f\n',seafloor(i));
             fprintf(fid,'Velocity profile:\n');
             fprintf(fid,'     Depth     Velocity \n');
             fprintf(fid,'%10.3f %10.3f\n',data(:,2:3)'); %因为输出的顺序是按矩阵单下标索引方式输出，所以需要转置一下
             fclose(fid);
         end
     end
 end


end  % end fun_plot_model