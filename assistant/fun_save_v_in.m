function fun_save_v_in(model,fileout,precision)

switch precision
    case 'high'
        format_f='%8.3f';
        format_d='%8i';
    case 'low'
        format_f='%7.2f';
        format_d='%7i';
end
fn=fieldnames(model);
LN=length(model);
fid=fopen(fileout,'w');
for i=1:LN;
    for j=1:length(fn);
        if (i==LN) && (j>1);
        else
            value=getfield(model,{i},fn{j});
            nodes=length(value(1,:));
            startnode=1:10:1000;
            startnode=startnode(find(startnode<=nodes));
            linecount=length(startnode);
            if linecount==1;
                endnode=nodes;
            else
                endnode=[startnode(2:end)-1 nodes];
            end
            flag=1;
            for k=1:linecount;
                if k==linecount;
                    flag=0;
                end
                fprintf(fid,'%2i ',i);
                fprintf(fid,format_f,value(1,startnode(k):endnode(k)));
                fprintf(fid,'\n');
                %                 if flag==0;
                %                     fprintf(fid,'%s',blanks(3));
                %                 else
                %                     fprintf(fid,'%2i ',flag);
                %                 end
                fprintf(fid,'%2i ',flag);  % use 0 instead of 3X
                fprintf(fid,format_f,value(2,startnode(k):endnode(k)));
                fprintf(fid,'\n');
                if i<LN;
                    fprintf(fid,'%s',blanks(3));
                    fprintf(fid,format_d,value(3,startnode(k):endnode(k)));
                    fprintf(fid,'\n');
                end
            end
        end
    end
end
fclose(fid);

end
