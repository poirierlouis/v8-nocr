@echo off
setlocal EnableExtensions DisableDelayedExpansion

:: ============================================================
::  patch.cmd
::  Auto-discovers and applies .patch files while preserving
::  the folder hierarchy relative to a configurable root.
:: ============================================================

set "PATCH_ROOT=%~f1"
set "REPO_ROOT=%~f2"

if "%PATCH_ROOT%"=="" set "PATCH_ROOT=%CD%\patches"
if "%REPO_ROOT%"=="" set "REPO_ROOT=%CD%"

:: Strip trailing slashes from roots to ensure predictable string manipulation
if "%PATCH_ROOT:~-1%"=="\" set "PATCH_ROOT=%PATCH_ROOT:~0,-1%"
if "%REPO_ROOT:~-1%"=="\" set "REPO_ROOT=%REPO_ROOT:~0,-1%"

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

:: Run the loop and call the patch function
for /r "%PATCH_ROOT%" %%F in (*.patch) do (
    call :apply_patch "%%~fF"
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
::  SUBROUTINES
:: ============================================================

:apply_patch
set "THIS_PATCH=%~1"

:: Get the directory containing the patch file
for %%A in ("%THIS_PATCH%") do set "THIS_PATCH_DIR=%%~dpA"
if "%THIS_PATCH_DIR:~-1%"=="\" set "THIS_PATCH_DIR=%THIS_PATCH_DIR:~0,-1%"

:: Safely calculate REL_SUBDIR without using internal setlocal
:: We leverage the 'call' trick to substitute the patch root out of the path safely
call set "SUBDIR=%%THIS_PATCH_DIR:%PATCH_ROOT%=%%"

:: Strip leading backslash if it exists
if "%SUBDIR:~0,1%"=="\" set "SUBDIR=%SUBDIR:~1%"

if "%SUBDIR%"=="" (
    set "FINAL_TARGET=%REPO_ROOT%"
) else (
    set "FINAL_TARGET=%REPO_ROOT%\%SUBDIR%"
)

echo [INFO] Applying : %~nx1
echo        Patch    : %THIS_PATCH%
echo        Target   : %FINAL_TARGET%
set /a TOTAL+=1

if not exist "%FINAL_TARGET%" (
    echo [ERROR] Target directory does not exist: %FINAL_TARGET%
    set /a FAILED+=1
    echo.
    goto :eof
)

pushd "%FINAL_TARGET%"
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