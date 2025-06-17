@echo off
rem -------------------------------------------------------------------
rem Build script for gsplat (Windows)
rem -------------------------------------------------------------------
rem stop on first error
setlocal EnableDelayedExpansion
echo [bld.bat] starting…

rem -------------------------------------------------------------------
rem 1) Build parameters
rem -------------------------------------------------------------------
set "MAX_JOBS=1"
set "TORCH_CUDA_ARCH_LIST=5.0;6.0;6.1;7.0;7.5;8.0;8.6;8.9;9.0+PTX"

rem -------------------------------------------------------------------
rem 2) Header shim for missing cg::labeled_partition (CUDA < 12.6)
rem -------------------------------------------------------------------
set "CG_PATCH=%SRC_DIR%\cg_fix.h"
echo [bld.bat] writing shim header to %CG_PATCH%

> "%CG_PATCH%" (
  echo #pragma once
  echo #include ^<cooperative_groups.h^>
  echo namespace cooperative_groups {
  echo     template ^<class Group^>
  echo     __device__ __forceinline__
  echo     auto labeled_partition(const Group^& g,unsigned int id) {
  echo         return experimental::labeled_partition(g,id);
  echo     }
  echo }
)

rem make MSVC see it
if not defined CXXFLAGS set "CXXFLAGS="
set "CXXFLAGS=!CXXFLAGS! /FI\"%CG_PATCH%\""

rem make NVCC see it (host & device passes)
if not defined NVCC_FLAGS set "NVCC_FLAGS="
set "NVCC_FLAGS=!NVCC_FLAGS! -include \"%CG_PATCH%\""

rem -------------------------------------------------------------------
rem 3) Build
rem -------------------------------------------------------------------
echo [bld.bat] invoking pip build…
"%PYTHON%" -m pip install . -vv
if errorlevel 1 (
  echo [bld.bat] pip install failed, exiting.
  exit /b 1
)

echo [bld.bat] build finished OK.
endlocal
