@echo off
setlocal
cd /d %~dp0

call "%VS120COMNTOOLS%\vsvars32.bat"

rem if "%1"=="" (set CONFIGURATION=Release) else (set CONFIGURATION=%1)
rem if "%2"=="" (set TARGET=Build) else (set TARGET=%2)
rem if "%3"=="" (set VERBOSITY=normal) else (set VERBOSITY=%3)

echo Build xyzzy...
cd src
nmake %1 %2 %3 %4 %5 %6 %7 %8 %9
