@echo off
setlocal enabledelayedexpansion

REM ����������
if "%~4"=="" (
    echo �÷�: %~nx0 [x86^|x64] [release|debug] [vs�汾] [qt·��]
    echo ʾ��: %~nx0 x64 release vs2019 C:\Qt\5.15.2\msvc2019_64
    exit /b 1
)

REM ���ò���
set "arch=%~1"
set "mode=%~2"
set "vs=%~3"
set "qt_path=%~4"

REM ��֤�ܹ�����
if /i not "%arch%"=="x86" if /i not "%arch%"=="x64" (
    echo ����: �ܹ������� x86 �� x64
    exit /b 1
)

REM ��֤ģʽ����
if /i not "%mode%"=="release" if /i not "%mode%"=="debug" (
    echo ����: ģʽ������ release �� debug
    exit /b 1
)

REM ִ�� xmake ����
call xmake.bat clean -a
call xmake.bat f -cv -a %arch% -m %mode% --qt="%qt_path%" --vs="%vs%"
call xmake.bat -rv

echo �������
endlocal