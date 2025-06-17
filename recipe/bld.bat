@echo off

::---------------------------------------------------------------
:: Builds against CUDA ≥ 12.6 where cg::labeled_partition()       │
:: vanished from the public header. We shim it back in and pass   │
:: the header to both MSVC and NVCC.                              │
::---------------------------------------------------------------

::--- General build switches ------------------------------------
set MAX_JOBS=1
set "TORCH_CUDA_ARCH_LIST=5.0;6.0;6.1;7.0;7.5;8.0;8.6;8.9;9.0+PTX"

::--- Create a one-line header that forwards to the experimental impl.
set "CG_PATCH=%SRC_DIR%\cg_fix.h"

(
  echo #pragma once
  echo #include ^<cooperative_groups.h^>
  echo namespace cooperative_groups {
  echo   template ^<class Group^> __device__ __forceinline__
  echo   auto labeled_partition(const Group& g, unsigned int id) {
  echo     return experimental::labeled_partition(g, id);
  echo   }
  echo }
) > "%CG_PATCH%"

::--- Inject the header for both host (MSVC) and device (NVCC) passes
set "CXXFLAGS=%CXXFLAGS% /FI\"%CG_PATCH%\" /wd9002"
set "TORCH_NVCC_FLAGS=%TORCH_NVCC_FLAGS% -include \"%CG_PATCH%\""

::---------------------------------------------------------------
:: Kick off the build
::---------------------------------------------------------------
"%PYTHON%" -m pip install . -vv
