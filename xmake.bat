@echo off
REM 获取当前目录并设置 xmake 路径
set "cur_dir=%cd%"
set "xmake_bin=%cur_dir%\bin\xmake.exe"

REM 检查 xmake 是否存在
if not exist "%xmake_bin%" (
    echo 错误: 未找到 xmake.exe
    exit /b 1
)

%xmake_bin% %*