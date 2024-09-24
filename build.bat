@echo off
setlocal enabledelayedexpansion

REM 检查参数数量
if "%~4"=="" (
    echo 用法: %~nx0 [x86^|x64] [release|debug] [vs版本] [qt路径]
    echo 示例: %~nx0 x64 release vs2019 C:\Qt\5.15.2\msvc2019_64
    exit /b 1
)

REM 设置参数
set "arch=%~1"
set "mode=%~2"
set "vs=%~3"
set "qt_path=%~4"

REM 验证架构参数
if /i not "%arch%"=="x86" if /i not "%arch%"=="x64" (
    echo 错误: 架构必须是 x86 或 x64
    exit /b 1
)

REM 验证模式参数
if /i not "%mode%"=="release" if /i not "%mode%"=="debug" (
    echo 错误: 模式必须是 release 或 debug
    exit /b 1
)

REM 执行 xmake 命令
call xmake.bat clean -a
call xmake.bat f -cv -a %arch% -m %mode% --qt="%qt_path%" --vs="%vs%"
call xmake.bat -rv

echo 构建完成
endlocal