; RUN: opt %loadPolly -polly-scops \
; RUN: -analyze < %s | FileCheck %s --check-prefix=SCOP

; RUN: opt %loadPolly -polly-codegen-ppcg \
; RUN: -S -polly-acc-codegen-managed-memory \
; RUN: -polly-acc-rewrite-managed-memory < %s | FileCheck %s --check-prefix=HOST-IR
;
; Check that we can correctly rewrite `malloc` to `polly_mallocManaged`
;
; #include <memory.h>
;
; static const int N = 100;
; int* f() {
;     int *A = (int *)malloc(sizeof(int) * N);
;     for(int i = 0; i < N; i++) {
;         A[i] = 42;
;     }
;     return A;
;
; }

; SCOP:      Function: f
; SCOP-NEXT: Region: %for.body---%for.end
; SCOP-NEXT: Max Loop Depth:  1

; SCOP:      Arrays {
; SCOP-NEXT:     i32 MemRef_call[*]; // Element size 4
; SCOP-NEXT: }

; // Check that polly_mallocManaged is declared and used correctly.
; HOST-IR: %call = tail call i8* @polly_mallocManaged(i64 400)
; HOST-IR: declare i8* @polly_mallocManaged(i64)

target datalayout = "e-m:o-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.12.0"

define i32* @f() {
entry:
  br label %entry.split

entry.split:                                      ; preds = %entry
  %call = tail call i8* @malloc(i64 400)
  %tmp = bitcast i8* %call to i32*
  br label %for.body

for.body:                                         ; preds = %entry.split, %for.body
  %indvars.iv1 = phi i64 [ 0, %entry.split ], [ %indvars.iv.next, %for.body ]
  %arrayidx = getelementptr inbounds i32, i32* %tmp, i64 %indvars.iv1
  store i32 42, i32* %arrayidx, align 4, !tbaa !3
  %indvars.iv.next = add nuw nsw i64 %indvars.iv1, 1
  %exitcond = icmp eq i64 %indvars.iv.next, 100
  br i1 %exitcond, label %for.end, label %for.body

for.end:                                          ; preds = %for.body
  ret i32* %tmp
}

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64, i8* nocapture) #0

declare i8* @malloc(i64)

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64, i8* nocapture) #0

attributes #0 = { argmemonly nounwind }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 6.0.0 (http://llvm.org/git/clang.git 6660f0d30ef23b3142a6b08f9f41aad3d47c084f) (http://llvm.org/git/llvm.git 052dd78cb30f77a05dc8bb06b851402c4b6c6587)"}
!3 = !{!4, !4, i64 0}
!4 = !{!"int", !5, i64 0}
!5 = !{!"omnipotent char", !6, i64 0}
!6 = !{!"Simple C/C++ TBAA"}
