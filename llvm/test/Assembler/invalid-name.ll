; RUN: not llvm-as < %s 2>&1 | FileCheck %s

define void @f () {
  %" " = sext i16 0 to i32
; CHECK: expected instruction opcode
  ret void
}
