; RUN: llc -mtriple=aarch64-linux-gnu                                                  -verify-machineinstrs < %s | FileCheck %s
; RUN: llc -mtriple=aarch64-apple-darwin -code-model=large                             -verify-machineinstrs < %s | FileCheck %s --check-prefix=LARGE
; RUN: llc -mtriple=aarch64-apple-darwin -code-model=large -fast-isel -fast-isel-abort=1 -verify-machineinstrs < %s | FileCheck %s --check-prefix=LARGE
; RUN: llc -mtriple=aarch64-none-eabi    -code-model=tiny                              -verify-machineinstrs < %s | FileCheck %s --check-prefix=TINY

@varf32 = global float 0.0
@varf64 = global double 0.0

define void @check_float() {
; CHECK-LABEL: check_float:
; TINY-LABEL: check_float:

  %val = load float, float* @varf32
  %newval1 = fadd float %val, 8.5
  store volatile float %newval1, float* @varf32
; CHECK-DAG: fmov {{s[0-9]+}}, #8.5
; TINY-DAG: fmov {{s[0-9]+}}, #8.5

  %newval2 = fadd float %val, 128.0
  store volatile float %newval2, float* @varf32
; CHECK-DAG: mov [[W128:w[0-9]+]], #1124073472
; CHECK-DAG: fmov {{s[0-9]+}}, [[W128]]
; TINY-DAG: mov [[W128:w[0-9]+]], #1124073472
; TINY-DAG: fmov {{s[0-9]+}}, [[W128]]

; CHECK: ret
; TINY: ret
  ret void
}

define void @check_double() {
; CHECK-LABEL: check_double:
; TINY-LABEL: check_double:

  %val = load double, double* @varf64
  %newval1 = fadd double %val, 8.5
  store volatile double %newval1, double* @varf64
; CHECK-DAG: fmov {{d[0-9]+}}, #8.5
; TINY-DAG: fmov {{d[0-9]+}}, #8.5

  %newval2 = fadd double %val, 128.0
  store volatile double %newval2, double* @varf64
; CHECK-DAG: mov [[X128:x[0-9]+]], #4638707616191610880
; CHECK-DAG: fmov {{d[0-9]+}}, [[X128]]
; TINY-DAG: mov [[X128:x[0-9]+]], #4638707616191610880
; TINY-DAG: fmov {{d[0-9]+}}, [[X128]]

; 64-bit ORR followed by MOVK.
; CHECK-DAG: mov  [[XFP0:x[0-9]+]], #1082331758844
; CHECK-DAG: movk [[XFP0]], #64764, lsl #16
; CHECk-DAG: fmov {{d[0-9]+}}, [[XFP0]]
  %newval3 = fadd double %val, 0xFCFCFC00FC
  store volatile double %newval3, double* @varf64

; CHECK: ret
; TINY: ret
  ret void
}

; LARGE-LABEL: check_float2
; LARGE:       mov [[REG:w[0-9]+]], #4059
; LARGE-NEXT:  movk [[REG]], #16457, lsl #16
; LARGE-NEXT:  fmov s0, [[REG]]
; TINY-LABEL:  check_float2
; TINY:        mov [[REG:w[0-9]+]], #4059
; TINY-NEXT:   movk [[REG]], #16457, lsl #16
define float @check_float2() {
  ret float 3.14159274101257324218750
}

; LARGE-LABEL: check_double2
; LARGE:       mov [[REG:x[0-9]+]], #11544
; LARGE-NEXT:  movk [[REG]], #21572, lsl #16
; LARGE-NEXT:  movk [[REG]], #8699, lsl #32
; LARGE-NEXT:  movk [[REG]], #16393, lsl #48
; LARGE-NEXT:  fmov d0, [[REG]]
; TINY-LABEL: check_double2
; TINY:  ldr     d0, .LCPI3_0
define double @check_double2() {
  ret double 3.1415926535897931159979634685441851615905761718750
}
