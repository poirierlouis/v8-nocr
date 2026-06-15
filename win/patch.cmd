@echo off
setlocal EnableDelayedExpansion

:: ============================================================
::  patch.cmd
::  Autodiscovers and applies .patch files while preserving
::  the folder hierarchy relative to a configurable root.
::
::  Usage:
::    patch.cmd [PATCH_ROOT] [REPO_ROOT]
::
::  Arguments (both optional, positional):
::    PATCH_ROOT   Directory that contains the .patch files.
::                 Defaults to: .\patches  (relative to CWD)
::    REPO_ROOT    Root of the repository tree to patch into.
::                 Defaults to: .  (CWD)
::
::  Folder mapping convention:
::    A patch file at  <PATCH_ROOT>\foo\bar\my.patch
::    is applied inside <REPO_ROOT>\foo\bar\
::
::  git apply flags used:
::    --3way             falls back to 3-way merge on conflict
::    --ignore-whitespace  ignores whitespace differences
:: ============================================================

:: ---- Resolve arguments ----------------------------------------
set "PATCH_ROOT=%~1"
if "%PATCH_ROOT%"=="" set "PATCH_ROOT=.\patches"

set "REPO_ROOT=%~2"
if "%REPO_ROOT%"=="" set "REPO_ROOT=."

:: Strip any trailing backslash for consistency
if "%PATCH_ROOT:~-1%"=="\" set "PATCH_ROOT=%PATCH_ROOT:~0,-1%"
if "%REPO_ROOT:~-1%"=="\" set "REPO_ROOT=%REPO_ROOT:~0,-1%"

:: ---- Validate inputs ------------------------------------------
if not exist "%PATCH_ROOT%" (
    echo [ERROR] Patch root not found: %PATCH_ROOT%
    exit /b 1
)

if not exist "%REPO_ROOT%" (
    echo [ERROR] Repo root not found: %REPO_ROOT%
    exit /b 1
)

:: Convert to absolute paths so cd never gets confused
pushd "%PATCH_ROOT%" || (echo [ERROR] Cannot enter patch root & exit /b 1)
set "PATCH_ROOT_ABS=%CD%"
popd

pushd "%REPO_ROOT%" || (echo [ERROR] Cannot enter repo root & exit /b 1)
set "REPO_ROOT_ABS=%CD%"
popd

echo.
echo ============================================================
echo  patch.cmd
echo ------------------------------------------------------------
echo  Patch root : %PATCH_ROOT_ABS%
echo  Repo root  : %REPO_ROOT_ABS%
echo ============================================================
echo.

:: ---- Counters ------------------------------------------------
set /a TOTAL=0
set /a PASSED=0
set /a FAILED=0

:: ---- Autodiscover and apply patches --------------------------
::  /r   - recurse into subdirectories
::  /b   - bare filename (%%~nxF)
::  %%F  - full path to the .patch file
for /r "%PATCH_ROOT_ABS%" %%F in (*.patch) do (
    set /a TOTAL+=1

    :: Relative path of the patch file's *directory* under PATCH_ROOT_ABS
    ::   e.g. if patch = C:\patches\v8\build\fix.patch
    ::   and PATCH_ROOT_ABS = C:\patches
    ::   then REL_DIR = v8\build
    set "PATCH_FILE=%%~fF"
    set "PATCH_DIR=%%~dpF"

    :: Strip trailing backslash from PATCH_DIR
    set "PATCH_DIR=!PATCH_DIR:~0,-1!"

    :: Compute relative subdirectory by removing the absolute patch root prefix
    set "REL_SUBDIR=!PATCH_DIR:%PATCH_ROOT_ABS%=!"

    :: REL_SUBDIR now starts with \ (or is empty for patches in root)
    :: Strip the leading backslash when non-empty
    if "!REL_SUBDIR:~0,1!"=="\" set "REL_SUBDIR=!REL_SUBDIR:~1!"

    :: Build the target directory inside the repo
    if "!REL_SUBDIR!"=="" (
        set "TARGET_DIR=%REPO_ROOT_ABS%"
    ) else (
        set "TARGET_DIR=%REPO_ROOT_ABS%\!REL_SUBDIR!"
    )

    echo [INFO] Applying: %%~nxF
    echo        Patch : !PATCH_FILE!
    echo        Target: !TARGET_DIR!

    :: Validate that the target directory exists
    if not exist "!TARGET_DIR!" (
        echo [ERROR] Target directory does not exist: !TARGET_DIR!
        set /a FAILED+=1
        echo.
        goto :continue
    )

    :: Enter target directory and apply the patch
    pushd "!TARGET_DIR!"
    git apply --3way --ignore-whitespace "!PATCH_FILE!"
    set "GIT_EXIT=!ERRORLEVEL!"
    popd

    if !GIT_EXIT! EQU 0 (
        echo [OK]    Patch applied successfully.
        set /a PASSED+=1
    ) else (
        echo [ERROR] git apply failed ^(exit code !GIT_EXIT!^) for: %%~nxF
        set /a FAILED+=1
    )

    echo.
    :continue
)

:: ---- Summary -------------------------------------------------
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
    echo [WARN] No .patch files found under: %PATCH_ROOT_ABS%
    exit /b 0
)

echo.
echo [OK] All patches applied successfully.
exit /b 0