@echo off
setlocal EnableDelayedExpansion

echo "Starting bld.bat"
echo "RECIPE_DIR=%RECIPE_DIR%"
echo "SRC_DIR=%SRC_DIR%"

echo "Listing RECIPE_DIR:"
dir "%RECIPE_DIR%"

REM ----------------------------------------------------------------------
REM 1. Build-time options
REM ----------------------------------------------------------------------
set "MAX_JOBS=1"
set "TORCH_CUDA_ARCH_LIST=8.0;8.6;8.9"

REM ----------------------------------------------------------------------
REM 2.  Patch missing cooperative_groups::labeled_partition
REM ----------------------------------------------------------------------
set "CG_PATCH=%SRC_DIR%\cg_fix.h"
echo "CG_PATCH=%CG_PATCH%"

if exist "%RECIPE_DIR%\cg_fix.h" (
    echo "Found cg_fix.h in RECIPE_DIR"
) else (
    echo "ERROR: cg_fix.h not found in RECIPE_DIR"
    exit /b 1
)

copy "%RECIPE_DIR%\cg_fix.h" "%CG_PATCH%"
if errorlevel 1 (
    echo "ERROR: Failed to copy cg_fix.h"
    exit /b 1
)

REM  Make the compilers force-include it
set "CXXFLAGS=%CXXFLAGS% /FI"%CG_PATCH%""
set "NVCC_FLAGS=%NVCC_FLAGS% -include "%CG_PATCH%""

echo "CXXFLAGS=%CXXFLAGS%"
echo "NVCC_FLAGS=%NVCC_FLAGS%"

REM ----------------------------------------------------------------------
REM 3.  Build + install
REM ----------------------------------------------------------------------
"%PYTHON%" -m pip install . -vv --no-build-isolation
if errorlevel 1 (
    echo "ERROR: pip install failed"
    exit /b 1
)

endlocal
