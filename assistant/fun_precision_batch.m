function fun_precision_batch(varargin)
% varargin

precision='';
options.Interpreter = 'tex';
options.Default = 'Cancel';
qstring= {'\bf\fontsize{12}\color{red}Choose the precision format you want to get'};
choice = questdlg(qstring,'Select conversion direction','Low to High','High to Low','Cancel',options);
switch choice,
    case 'Low to High';
        precision='high';
    case 'High to Low';
        precision='low';
    case 'Cancel'
end
if ~isempty(precision);
    if isempty(varargin)
        [FileName,PathName] = uigetfile('*.in','Select multiple files by holding down the Shift or Ctrl key and clicking on file names','MultiSelect','on');
    else
        [FileName,PathName] = uigetfile(fullfile(varargin{1},'*.in'),'Select multiple files by holding down the Shift or Ctrl key and clicking on file names','MultiSelect','on');
    end
    if ~isscalar(FileName);
        if ~iscell(FileName);
            FileName={FileName};
        end
        fn=length(FileName);
        allin=cell(fn,1);
        allprecision=cell(fn,1);
        for i=1:fn;
%             if fn==1;
%             fullname=fullfile(PathName,FileName)
%             else
                fullname=fullfile(PathName,FileName{i});
%             end
            [model,LN,xmin,xmax,zmin,zmax,oldprecision,xx,ZZ,error]=fun_load_vin(fullname);
            allin(i)={model};
            allprecision(i)={oldprecision};
        end
        index=find(strcmp(precision,allprecision));
        if isempty(index);
            convert='yes';
        else
            FileName(index)
            qstring(1) = {['\bf\fontsize{12}\color{red}',strrep(sprintf('%s\n',FileName{index}),'_','\_'),' have already in ',precision,' precision format!']};
            qstring(2) = {'If continue, you next will be asked to pick a folder to save the files.'};
            choice = questdlg(qstring,'Confirm','Convert All','Skip these files','Cancel',options);
            switch choice,
                case 'Convert All';
                    convert='yes';
                case 'Skip these files';
                    convert='yes';
                    FileName(index)=[];
                    allin(index)=[];
                    if isempty(FileName);
                        hh=warndlg('All files are skipped! 0 files are converted.');
                        uiwait(hh);
                        return
                    end
                case 'Cancel'
                    convert='no';
            end
        end
        switch convert
            case 'no'
                return
            case 'yes'
                choosefolder=1;
                while choosefolder;
                    pn=uigetdir(PathName);
                    if pn==0;
                        qstring = {'\bf\fontsize{12}\color{red}You didn''t pick a valid folder! Try again or cancel?'};
                        choice = questdlg(qstring,'','Try again','Cancel',options);
                        switch choice,
                            case 'Try again'
                            case 'Cancel'
                                return
                        end
                    elseif strcmp(pn,PathName(1:end-1));
                        qstring = {'\bf\fontsize{12}\color{red}You pick the same folder as source, the files will be overwritten!'};
                        choice = questdlg(qstring,'','Change folder','Continue and overwrite','Cancel',options);
                        switch choice,
                            case 'Continue and overwrite'
                                choosefolder=0;
                            case 'Cancel'
                                return
                        end
                    else
                        choosefolder=0;
                    end
                end
                for i=1:length(FileName);
                    fullname=fullfile(pn,FileName{i});
                    fun_save_v_in(allin{i},fullname,precision);
                end
        end
        msgbox(['Total ',num2str(length(FileName)),' v.in files are converted to ',precision,' precision version.']);
    end
end

end % end of fun_precision_batch