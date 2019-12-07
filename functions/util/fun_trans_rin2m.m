function fileOut = fun_trans_rin2rm(file_rin)
    % fileOut = <strong>fun_trans_rin2rm</strong>(file_rin)
    %
    % 读取r.in文件并将其稍作修改转换为.m文件，此后只需执行.m脚本便可导入r.in中的所有变量
    %
    % file_rin: full file path;

    [filePath,fileName,fileExt] = fileparts(file_rin);
    fileOut = fullfile(filePath,[fileName,'_in.m']);
    [fin,errmsg1] = fopen(file_rin, 'rt'); % 文本形式打开，只读
    [fout,errmsg2] = fopen(fileOut, 'wt'); % 文本形式打开，只写
    error(errmsg1);
    error(errmsg2);

    while ~feof(fin)
        currentLine = strtrim(fgetl(fin));
        inSection = false;
        [tokens,split] = regexp(currentLine, '(&\w+)\s*', 'tokens', 'split');
        if ~isempty(tokens)
            % detect section beginning
            inSection = true;
            currentLine = strtrim(strjoin(split));
            sectionName = tokens{1}{1};
            fprintf(fout, ['%% ',sectionName,'\n']);
        else
            % if contents are out of section marks, just print them as comment
            if ~isempty(strtrim(currentLine))
                fprintf(fout, ['%% ',currentLine,'\n']);
            end
            continue;
        end

        % join all lines of the same section into one string, separating by '\n'
        while(inSection)
            tempLine = strtrim(fgetl(fin));

            % if the line is empty or comment, just skip
            if isempty(tempLine), continue; end
            if startsWith(tempLine, '!'), continue; end
            [tokens] = regexp(tempLine, '(&\w+)\s*', 'tokens');

            % detect section ending
            if ~isempty(tokens)
                sectionEnd = tokens{1}{1};
                if ~strcmp(sectionEnd, '&end')
                    error('e:input_error',sprintf('Section should be closed up by ''&end''!\nin file [%s] line: %d\n',fileIn,tempLine));
                end
                inSection = false;
            else
                currentLine = [currentLine,'\n',tempLine];
            end
        end

        % 处理逗号，将每个完整的赋值语句后面的逗号替换成分号
        currentLine = sprintf(currentLine); % 将字符串转化为格式化字符串（这样\n之类的特殊字符才能被识别，否则\n将被看作2个普通字符）
        currentLine = strrep(strtrim(currentLine), ' ', ''); % 去掉首尾空白以及所有空格
        currentLine = regexprep(currentLine, ',(\s*\w+=)', ']; $1'); % 将每个完整的赋值语句后面的逗号替换成分号
        currentLine = regexprep(currentLine, ',$', ']; '); % 上一步不能识别最末尾的逗号，此处作为上一步的补充
        currentLine = strrep(currentLine, '=', '(1)=['); % 为赋值的开头添加方括号，对所有的数组默认加上下标1(后面再根据赋值的长度作调整)
        currentLine = regexprep(currentLine, ',\n', ',...\n'); % 将数组折行处加上matlab折行语法
        % 处理*号
        [tokens,split] = regexp(currentLine,'([\d\.]+)\*([\d\.]+)','tokens','split');
        replaced = {};
        for h = 1:length(tokens)
            num = str2num(tokens{h}{1});
            val = str2num(tokens{h}{2});
            strMat = sprintf('%.4f,',ones(1,num).*val); strMat = strMat(1:end-1);
            replaced = [replaced, strMat];
        end
        currentLine = strjoin(split,replaced);

        % 对于数组形式的赋值，修正变量的下标，如 a(1)=[1,2,3]，变为 a(1:3)=[1,2,3]
        [tokens,split] = regexp(currentLine,'\(1\)=\[(([\d\n\.-]+,)+)','tokens','split');
        replaced = {};
        for t = tokens
            arrayLength = sum(t{1}{1}==',') + 1; % 数组长度即数组中逗号的个数加1
            replaced = [replaced, sprintf('(1:%d)=[%s',arrayLength,t{1}{1})];
        end
        currentLine = strjoin(split,replaced);

        % 一些 Fortran 中的变量名与 MATLAB 的关键字有冲突，于是在 MATLAB 代码中进行了重命名。
        % 但 r.in 需要保持对 Fortran 原版的兼容性，因此不能在 r.in 中直接改变量名，而是在此处做替换。
        currentLine = strrep(currentLine, 'step', 'step_');

        fprintf(fout, [currentLine,'\n']);
        fprintf(fout, '%% &end\n\n');
    end
    fclose(fin);
    fclose(fout);
end
