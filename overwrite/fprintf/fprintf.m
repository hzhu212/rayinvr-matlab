function fprintf(varargin)
%% Custom `fprintf` function: skip writing to file.

    % Ignore writing to file
    if isa(varargin{1}, 'double')
        return;
    end

    % But still allow printing to console
    str = sprintf(varargin{:});
    if endsWith(str, sprintf('\n'))
        str = str(1:end-1);
    end
    disp(str);
end
