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
REM set "MAX_JOBS=1"
REM set "TORCH_CUDA_ARCH_LIST=8.0;8.6;8.9"

REM ----------------------------------------------------------------------
REM 2.  Patch missing cooperative_groups::labeled_partition
REM ----------------------------------------------------------------------
REM set "CG_PATCH=%SRC_DIR%\cg_fix.h"
REM echo "CG_PATCH=%CG_PATCH%"

REM if exist "%RECIPE_DIR%\cg_fix.h" (
REM     echo "Found cg_fix.h in RECIPE_DIR"
REM ) else (
REM     echo "ERROR: cg_fix.h not found in RECIPE_DIR"
REM     exit /b 1
REM )

REM copy "%RECIPE_DIR%\cg_fix.h" "%CG_PATCH%"
REM if errorlevel 1 (
REM     echo "ERROR: Failed to copy cg_fix.h"
REM     exit /b 1
REM )

REM  Make the compilers force-include it
REM set "CXXFLAGS=%CXXFLAGS% /FI"%CG_PATCH%""
REM set "NVCC_FLAGS=%NVCC_FLAGS% -include "%CG_PATCH%""

REM echo "CXXFLAGS=%CXXFLAGS%"
REM echo "NVCC_FLAGS=%NVCC_FLAGS%"

REM ----------------------------------------------------------------------
REM 3.  Build + install
REM ----------------------------------------------------------------------
REM "%PYTHON%" -m pip install . -vv --no-build-isolation
REM if errorlevel 1 (
REM     echo "ERROR: pip install failed"
REM     exit /b 1
REM )

endlocal
