; ModuleID = 'ch_test_8_1.bc'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.8.0"

%struct.date = type { i8, i8, i8 }

define i32 @main() nounwind uwtable ssp {
  %1 = alloca i32, align 4
  %d = alloca %struct.date, align 1
  %month = alloca i8, align 1
  store i32 0, i32* %1
  %2 = getelementptr inbounds %struct.date* %d, i32 0, i32 0
  store i8 12, i8* %2, align 1
  %3 = getelementptr inbounds %struct.date* %d, i32 0, i32 1
  store i8 12, i8* %3, align 1
  %4 = getelementptr inbounds %struct.date* %d, i32 0, i32 2
  store i8 2, i8* %4, align 1
  %5 = getelementptr inbounds %struct.date* %d, i32 0, i32 1
  %6 = load i8* %5, align 1
  store i8 %6, i8* %month, align 1
  ret i32 0
}
