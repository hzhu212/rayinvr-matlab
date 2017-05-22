function popstrings=fun_make_popup_strings(src,type)

total=size(src,2);
if total==0;
    popstrings=' ';
else
    popstrings=cell(1,total);
    switch type
        case 'SCS'
            for i=1:total;
                popstrings{i}=['SCS #',num2str(i),': ',src(i).name];
            end
        case 'OBS'
            for i=1:total;
                %              src(i).name
                %              src(i).moffset
                popstrings{i}=['OBS #',num2str(i),': ',src(i).name,' (',num2str(src(i).moffset),' km)'];
            end
        case 'Phase'
            for i=1:total;  % Note: here Time group is new defined one, not the same as the original tx.in 
                popstrings{i}=[num2str(i),': ','Phase #',num2str(i),': Time group ',num2str(src{i}(1,4)),', Layer ',...
                    num2str(src{i}(1,7)),', Ray ',num2str(src{i}(1,8)),', Wave ',num2str(src{i}(1,9))];
            end
    end
end
