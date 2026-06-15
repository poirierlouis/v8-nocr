@echo off
setlocal EnableExtensions DisableDelayedExpansion

:: ============================================================
::  patch.cmd
::  Autodiscovers and applies .patch files while preserving
::  the folder hierarchy relative to a configurable root.
::
::  Usage (run from your repo subdirectory, e.g. v8\):
::    patch.cmd <PATCH_ROOT> <REPO_ROOT>
::
::  Folder mapping convention:
::    A patch at  <PATCH_ROOT>\foo\bar\my.patch
::    is applied inside <REPO_ROOT>\foo\bar\
::
::  Example:
::    cd v8\
::    ..\win\patch.cmd "..\win\x64\patches\14.6.202.34" "."
:: ============================================================

set "PATCH_ROOT=%~f1"
set "REPO_ROOT=%~f2"

if "%PATCH_ROOT%"=="" set "PATCH_ROOT=%CD%\patches"
if "%REPO_ROOT%"=="" set "REPO_ROOT=%CD%"

if not exist "%PATCH_ROOT%" (
    echo [ERROR] Patch root not found: %PATCH_ROOT%
    exit /b 1
)
if not exist "%REPO_ROOT%" (
    echo [ERROR] Repo root not found: %REPO_ROOT%
    exit /b 1
)

echo.
echo ============================================================
echo  patch.cmd
echo ------------------------------------------------------------
echo  Patch root : %PATCH_ROOT%
echo  Repo root  : %REPO_ROOT%
echo ============================================================
echo.

set /a TOTAL=0
set /a PASSED=0
set /a FAILED=0

for /r "%PATCH_ROOT%" %%F in (*.patch) do (
    call :apply_patch "%%~fF" "%%~dpF"
)

echo ============================================================
echo  Summary
echo ------------------------------------------------------------
echo  Total patches found : %TOTAL%
echo  Applied OK          : %PASSED%
echo  Failed              : %FAILED%
echo ============================================================

if %FAILED% GTR 0 (
    echo.
    echo [ERROR] One or more patches failed. See output above.
    exit /b 1
)
if %TOTAL% EQU 0 (
    echo.
    echo [WARN] No .patch files found under: %PATCH_ROOT%
    exit /b 0
)
echo.
echo [OK] All patches applied successfully.
exit /b 0


:: ============================================================
:apply_patch
::   %1 = full path to .patch file
::   %2 = directory containing the .patch file (with trailing \)
:: ============================================================
set /a TOTAL+=1

set "THIS_PATCH=%~f1"
set "THIS_PATCH_DIR=%~2"

:: Strip trailing backslash
if "%THIS_PATCH_DIR:~-1%"=="\" set "THIS_PATCH_DIR=%THIS_PATCH_DIR:~0,-1%"

:: Remove the PATCH_ROOT prefix to get the relative subdirectory.
:: We use a call trick to do string substitution without delayed expansion.
call set "REL_SUBDIR=%%THIS_PATCH_DIR:%PATCH_ROOT%=%%"

:: Strip leading backslash if present
if "%REL_SUBDIR:~0,1%"=="\" set "REL_SUBDIR=%REL_SUBDIR:~1%"

:: Build target directory
if "%REL_SUBDIR%"=="" (
    set "TARGET_DIR=%REPO_ROOT%"
) else (
    set "TARGET_DIR=%REPO_ROOT%\%REL_SUBDIR%"
)

echo [INFO] Applying : %~nx1
echo        Patch    : %THIS_PATCH%
echo        Target   : %TARGET_DIR%

if not exist "%TARGET_DIR%" (
    echo [ERROR] Target directory does not exist: %TARGET_DIR%
    set /a FAILED+=1
    echo.
    goto :eof
)

pushd "%TARGET_DIR%"
git apply --3way --ignore-whitespace "%THIS_PATCH%"
set "GIT_EXIT=%ERRORLEVEL%"
popd

if %GIT_EXIT% EQU 0 (
    echo [OK]    Patch applied successfully.
    set /a PASSED+=1
) else (
    echo [ERROR] git apply failed ^(exit code %GIT_EXIT%^) for: %~nx1
    set /a FAILED+=1
)
echo.
goto :eof