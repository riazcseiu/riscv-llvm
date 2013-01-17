// RUN: rm -rf %t
// RUN: %clang -fsyntax-only -fmodules -fmodule-cache-path %t -D__need_wint_t %s -Xclang -verify
// RUN: %clang -fsyntax-only -std=c99 -fmodules -fmodule-cache-path %t -D__need_wint_t %s -Xclang -verify
// expected-no-diagnostics
// XFAIL: win32

#ifdef __SSE__
@import _Builtin_intrinsics.intel.sse;
#endif

#ifdef __AVX2__
@import _Builtin_intrinsics.intel.avx2;
#endif
