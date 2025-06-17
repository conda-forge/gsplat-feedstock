@echo off
:: ------------------------------------------------------------
::  gsplat – Windows build script used by conda-build
:: ------------------------------------------------------------
::  Fail on first error and allow !var! expansion
setlocal EnableExtensions EnableDelayedExpansion

:: ------------------------------------------------------------
:: 1. Build parameters
:: ------------------------------------------------------------
set "MAX_JOBS=1"
set "TORCH_CUDA_ARCH_LIST=5.0;6.0;6.1;7.0;7.5;8.0;8.6;8.9;9.0+PTX"

:: ------------------------------------------------------------
:: 2. Shim for cooperative_groups::labeled_partition
:: ------------------------------------------------------------
set "CG_PATCH=%SRC_DIR%\cg_fix.h"
echo [bld.bat] Writing shim header: %CG_PATCH%

(
  echo #pragma once
  echo #include ^<cooperative_groups.h^>
  echo namespace cooperative_groups {
  echo     template ^<class Group^>
  echo     __device__ __forceinline__
  echo     auto labeled_partition(const Group^& g,unsigned int id) {
  echo         return experimental::labeled_partition(g,id);
  echo     }
  echo }
) > "%CG_PATCH%"

:: Tell MSVC and NVCC to include the shim
if not defined CXXFLAGS set "CXXFLAGS="
set "CXXFLAGS=!CXXFLAGS! /FI\"%CG_PATCH%\""

if not defined NVCC_FLAGS set "NVCC_FLAGS="
set "NVCC_FLAGS=!NVCC_FLAGS! -include \"%CG_PATCH%\""

:: ------------------------------------------------------------
:: 3. Build the wheel
:: ------------------------------------------------------------
echo [bld.bat] Invoking pip install…
"%PYTHON%" -m pip install . -vv
if errorlevel 1 (
    echo [bld.bat] pip install failed – aborting.
    exit /b 1
)

echo [bld.bat] Build finished successfully.
endlocal
