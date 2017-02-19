# 编译项目powershell脚本，请将此脚本放在项目根目录，并保持文件名为：BuildProject.ps1
# 有关powershell的详细信息见：http://www.pstips.net/powershell-online-tutorials

# 1 设定输出文件
$outputFile = "main.exe"

# 2.1 根据后缀名找到所有要编译的文件（以C++为例）
$fFiles = ls *.f | foreach-object {$_.name}
$includeFiles = [array]$fFiles

# 2.2 也可以手动设定要编译的文件，将覆盖上一步的结果
# $includeFiles = "hello.h", "hello.cpp", "main.cpp"

# 3 编译
"compiling ...`ncommand: [ gfortran $includeFiles -o $outputFile ]"
"--------------------------------------------------------------------------------"
gfortran $includeFiles -o $outputFile

# 4 运行
"running ...`ncommand: [ ./$outputFile ]"
"--------------------------------------------------------------------------------"
& "./$outputFile"
