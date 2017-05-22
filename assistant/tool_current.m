function tool_current
disp ('4: run current model');
end

%{

% function tool_current
% 
% 
% cd ('current');
% [s,r]=system('xrayinvr','-echo');  % use rayinvr to get the output without plotting and avoid interactive requirement
% assignin('base','rr2',r);
% % ['q',char(13)]
% cd ..
% 
% end

screen_dump=rrr;
% translate rayinvr screen output information to read-easy mode
location=1;  % the head character of each line

% 1. ray traced number for each shot
% 47 characters + 1 terminator character (LF) = 48 totoal characters for each line
LL=47;
index=strfind(screen_dump,'rays traced');
screen_1_rays_number=repmat(' ',length(index),LL); % construct a char (space) matrix
for i=1:length(index);
    screen_1_rays_number(i,:)=screen_dump(location:location+LL-1);
    location=location+LL+1;
end

% 2. ray tracing result summary
% 66 characters + 1 terminator character = 67 totoal characters for each line
% fix 7 lines
LL=66;
LN=7;
rest=screen_dump(location:end);  % rest part of screen_dump
index=strfind(rest,char(10)); % use LF (line feed) as count
location=index(1)+1; % skip a blank line
screen_2_ray_tracing_summary=repmat(' ',LN,LL);
for i=1:LN;
    screen_2_ray_tracing_summary(i,:)=rest(location:location+LL-1);
    location=location+LL+1;
end

% 3. chi-squared summary
% 36 characters + 1 terminator character = 37 totoal characters for each line
% fix 3 lines
LL=36;
LN=3;
rest=rest(location:end);  % rest part of screen_dump
index=strfind(rest,char(10)); % use LF (line feed) as count
location=index(2)+1; % skip a blank line
screen_3_chi_squared_summary=repmat(' ',LN,LL);
for i=1:LN;
    screen_3_chi_squared_summary(i,:)=rest(location:location+LL-1);
    location=location+LL+1;
end

% 4. phase chi-squared table head
% 35 characters + 1 terminator character = 36 totoal characters for each line
% fix 2 lines
LL=35;
LN=2;
rest=rest(location:end);  % rest part of screen_dump
index=strfind(rest,char(10)); % use LF (line feed) as count
location=index(1)+1; % skip a blank line
screen_4_phase_chi_squared_table_head=repmat(' ',LN,LL);
for i=1:LN;
    screen_4_phase_chi_squared_table_head(i,:)=rest(location:location+LL-1);
    location=location+LL+1;
end

% 5. phase chi-squared
% 32 characters + 1 terminator character = 33 totoal characters for each line
% flexiable lines
LL=32;
rest=rest(location:end);  % rest part of screen_dump
index=strfind(rest,char(10)); % use LF (line feed) as count
LN=sum(index<strfind(rest,'shot  dir   npts   Trms   chi-squared'))-1;
location=index(1)-LL; % skip a blank line
screen_5_phase_chi_squared=repmat(' ',LN,LL);
for i=1:LN;
    screen_5_phase_chi_squared(i,:)=rest(location:location+LL-1);
    location=location+LL+1;
end

% 6. shot chi-squared table head
% 42 characters + 1 terminator character = 43 totoal characters for each line
% fix 2 lines
LL=42;
LN=2;
rest=rest(location:end);  % rest part of screen_dump
index=strfind(rest,char(10)); % use LF (line feed) as count
location=index(1)+1; % skip a blank line
screen_6_shot_chi_squared_table_head=repmat(' ',LN,LL);
for i=1:LN;
    screen_6_shot_chi_squared_table_head(i,:)=rest(location:location+LL-1);
    location=location+LL+1;
end

% last part: 7. shot chi-squared
% 39 characters + 1 terminator character = 40 totoal characters for each line
% flexiable lines
LL=39;
rest=rest(location:end);  % rest part of screen_dump
index=strfind(rest,char(10)); % use LF (line feed) as count
LN=length(index)-1;
location=index(1)-LL; % skip a blank line
screen_7_shot_chi_squared=repmat(' ',LN,LL);
for i=1:LN;
    screen_7_shot_chi_squared(i,:)=rest(location:location+LL-1);
    location=location+LL+1;
end

%}