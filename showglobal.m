% 将所有global变量载入工作区，以方便查看

varNamesCell = who('global');
joinedString = strjoin(varNamesCell',' ');
eval(['global ',joinedString]);
clear varNamesCell joinedString;