@echo off
REM ======================================================================
REM  bld.bat – conda-build entry point for gsplat (Windows)
REM ======================================================================

REM ── Build parallelism ────────────────────────────────────────────────
set "MAX_JOBS=1"

REM ── Tell PyTorch which GPU architectures to compile for ──────────────
set "TORCH_CUDA_ARCH_LIST=5.0;6.0;6.1;7.0;7.5;8.0;8.6;8.9;9.0+PTX"

REM ── Work-around for missing cooperative_groups::labeled_partition ────
set "CG_PATCH=%SRC_DIR%\cg_fix.h"

REM  Create the header (escape < and > so batch doesn’t treat them
REM  as redirections). The first line truncates/creates the file (>)
REM  and subsequent lines append (>>).
>  "%CG_PATCH%" echo #pragma once
>> "%CG_PATCH%" echo #include ^<cooperative_groups.h^>
>> "%CG_PATCH%" echo namespace cooperative_groups ^{
>> "%CG_PATCH%" echo     template ^<class Group^>
>> "%CG_PATCH%" echo     __device__ __forceinline__
>> "%CG_PATCH%" echo     auto labeled_partition(const Group^& g, unsigned int id) ^{
>> "%CG_PATCH%" echo         return experimental::labeled_partition(g, id);
>> "%CG_PATCH%" echo     ^}
>> "%CG_PATCH%" echo ^}

REM ── Inject the header for all host-side compilations (MSVC) ───────────
set "CXXFLAGS=%CXXFLAGS% /FI\"%CG_PATCH%\""

REM ── …and for device-side passes (NVCC) ───────────────────────────────
set "NVCC_FLAGS=%NVCC_FLAGS% -include \"%CG_PATCH%\""

REM ── Build & install the wheel inside the conda environment ───────────
"%PYTHON%" -m pip install . -vv
