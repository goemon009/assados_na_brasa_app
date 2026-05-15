@echo off
setlocal

cd /d "%~dp0"

set "APPDATA=%LOCALAPPDATA%\CodexFlutterWorkspace"
set "GRADLE_USER_HOME=%LOCALAPPDATA%\CodexGradleHome"
call flutter config --build-dir ..\..\..\..\..\AppData\Local\Temp\assados_na_brasa_flutter_build >nul

call flutter %*
