@echo off
setlocal EnableDelayedExpansion

REM ──────────────────────────────────────────────────────────────────────
REM 1. Build-time options
REM ──────────────────────────────────────────────────────────────────────
set "MAX_JOBS=1"
set "TORCH_CUDA_ARCH_LIST=8.0;8.6;8.9"

REM ──────────────────────────────────────────────────────────────────────
REM 2.  Patch missing cooperative_groups::labeled_partition
REM     every ( ) in the text is escaped with **double** carets  ^^(
REM ──────────────────────────────────────────────────────────────────────
set "CG_PATCH=%SRC_DIR%\cg_fix.h"

> "%CG_PATCH%" (
    echo #pragma once
    echo #include ^<cooperative_groups.h^>
    echo namespace cooperative_groups {
    echo     template^<class Group^> __device__ __forceinline__
    echo     auto labeled_partition^^(const Group^^^& g, unsigned int id^^) ^{
    echo         return experimental::labeled_partition^^(g, id^^);
    echo     }
    echo }
)

REM  Make the compilers force-include it
set "CXXFLAGS=%CXXFLAGS% /FI\"%CG_PATCH%\""
set "NVCC_FLAGS=%NVCC_FLAGS% -include \"%CG_PATCH%\""

REM ──────────────────────────────────────────────────────────────────────
REM 3.  Build + install
REM ──────────────────────────────────────────────────────────────────────
"%PYTHON%" -m pip install . -vv --no-build-isolation
endlocal
