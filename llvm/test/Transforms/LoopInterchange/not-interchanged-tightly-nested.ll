; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 5
; RUN: opt < %s -passes=loop-interchange -verify-dom-info -verify-loop-info -S 2>&1 | FileCheck %s

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"

@A = common global [100 x [100 x i32]] zeroinitializer
@B = common global [100 x i32] zeroinitializer
@C = common global [100 x [100 x i32]] zeroinitializer
@D = common global [100 x [100 x [100 x i32]]] zeroinitializer

; Loops not tightly nested are not interchanged
;
;  for(int j=0;j<N;j++) {
;    B[j] = j+k;
;    for(int i=0;i<N;i++)
;      A[j][i] = A[j][i]+B[j];
;  }
;
define void @interchange_05(i32 %k, i32 %N){
; CHECK-LABEL: define void @interchange_05(
; CHECK-SAME: i32 [[K:%.*]], i32 [[N:%.*]]) {
; CHECK-NEXT:  [[ENTRY:.*:]]
; CHECK-NEXT:    [[CMP30:%.*]] = icmp sgt i32 [[N]], 0
; CHECK-NEXT:    br i1 [[CMP30]], label %[[FOR_BODY_LR_PH:.*]], label %[[FOR_END17:.*]]
; CHECK:       [[FOR_BODY_LR_PH]]:
; CHECK-NEXT:    [[TMP0:%.*]] = add i32 [[N]], -1
; CHECK-NEXT:    [[TMP1:%.*]] = zext i32 [[K]] to i64
; CHECK-NEXT:    br label %[[FOR_BODY:.*]]
; CHECK:       [[FOR_BODY]]:
; CHECK-NEXT:    [[INDVARS_IV32:%.*]] = phi i64 [ 0, %[[FOR_BODY_LR_PH]] ], [ [[INDVARS_IV_NEXT33:%.*]], %[[FOR_INC15:.*]] ]
; CHECK-NEXT:    [[TMP2:%.*]] = add nsw i64 [[INDVARS_IV32]], [[TMP1]]
; CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds [100 x i32], ptr @B, i64 0, i64 [[INDVARS_IV32]]
; CHECK-NEXT:    [[TMP3:%.*]] = trunc i64 [[TMP2]] to i32
; CHECK-NEXT:    store i32 [[TMP3]], ptr [[ARRAYIDX]], align 4
; CHECK-NEXT:    br label %[[FOR_BODY3:.*]]
; CHECK:       [[FOR_BODY3]]:
; CHECK-NEXT:    [[INDVARS_IV:%.*]] = phi i64 [ 0, %[[FOR_BODY]] ], [ [[INDVARS_IV_NEXT:%.*]], %[[FOR_BODY3]] ]
; CHECK-NEXT:    [[ARRAYIDX7:%.*]] = getelementptr inbounds [100 x [100 x i32]], ptr @A, i64 0, i64 [[INDVARS_IV32]], i64 [[INDVARS_IV]]
; CHECK-NEXT:    [[TMP4:%.*]] = load i32, ptr [[ARRAYIDX7]], align 4
; CHECK-NEXT:    [[ADD10:%.*]] = add nsw i32 [[TMP3]], [[TMP4]]
; CHECK-NEXT:    store i32 [[ADD10]], ptr [[ARRAYIDX7]], align 4
; CHECK-NEXT:    [[INDVARS_IV_NEXT]] = add nuw nsw i64 [[INDVARS_IV]], 1
; CHECK-NEXT:    [[LFTR_WIDEIV:%.*]] = trunc i64 [[INDVARS_IV]] to i32
; CHECK-NEXT:    [[EXITCOND:%.*]] = icmp eq i32 [[LFTR_WIDEIV]], [[TMP0]]
; CHECK-NEXT:    br i1 [[EXITCOND]], label %[[FOR_INC15]], label %[[FOR_BODY3]]
; CHECK:       [[FOR_INC15]]:
; CHECK-NEXT:    [[INDVARS_IV_NEXT33]] = add nuw nsw i64 [[INDVARS_IV32]], 1
; CHECK-NEXT:    [[LFTR_WIDEIV35:%.*]] = trunc i64 [[INDVARS_IV32]] to i32
; CHECK-NEXT:    [[EXITCOND36:%.*]] = icmp eq i32 [[LFTR_WIDEIV35]], [[TMP0]]
; CHECK-NEXT:    br i1 [[EXITCOND36]], label %[[FOR_END17_LOOPEXIT:.*]], label %[[FOR_BODY]]
; CHECK:       [[FOR_END17_LOOPEXIT]]:
; CHECK-NEXT:    br label %[[FOR_END17]]
; CHECK:       [[FOR_END17]]:
; CHECK-NEXT:    ret void
;
entry:
  %cmp30 = icmp sgt i32 %N, 0
  br i1 %cmp30, label %for.body.lr.ph, label %for.end17

for.body.lr.ph:
  %0 = add i32 %N, -1
  %1 = zext i32 %k to i64
  br label %for.body

for.body:
  %indvars.iv32 = phi i64 [ 0, %for.body.lr.ph ], [ %indvars.iv.next33, %for.inc15 ]
  %2 = add nsw i64 %indvars.iv32, %1
  %arrayidx = getelementptr inbounds [100 x i32], ptr @B, i64 0, i64 %indvars.iv32
  %3 = trunc i64 %2 to i32
  store i32 %3, ptr %arrayidx
  br label %for.body3

for.body3:
  %indvars.iv = phi i64 [ 0, %for.body ], [ %indvars.iv.next, %for.body3 ]
  %arrayidx7 = getelementptr inbounds [100 x [100 x i32]], ptr @A, i64 0, i64 %indvars.iv32, i64 %indvars.iv
  %4 = load i32, ptr %arrayidx7
  %add10 = add nsw i32 %3, %4
  store i32 %add10, ptr %arrayidx7
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %lftr.wideiv = trunc i64 %indvars.iv to i32
  %exitcond = icmp eq i32 %lftr.wideiv, %0
  br i1 %exitcond, label %for.inc15, label %for.body3

for.inc15:
  %indvars.iv.next33 = add nuw nsw i64 %indvars.iv32, 1
  %lftr.wideiv35 = trunc i64 %indvars.iv32 to i32
  %exitcond36 = icmp eq i32 %lftr.wideiv35, %0
  br i1 %exitcond36, label %for.end17, label %for.body

for.end17:
  ret void
}

declare void @foo(...) readnone

; Loops not tightly nested are not interchanged
;  for(int j=0;j<N;j++) {
;    foo();
;    for(int i=2;i<N;i++)
;      A[j][i] = A[j][i]+k;
;  }
;
define void @interchange_06(i32 %k, i32 %N) {
; CHECK-LABEL: define void @interchange_06(
; CHECK-SAME: i32 [[K:%.*]], i32 [[N:%.*]]) {
; CHECK-NEXT:  [[ENTRY:.*:]]
; CHECK-NEXT:    [[CMP22:%.*]] = icmp sgt i32 [[N]], 0
; CHECK-NEXT:    br i1 [[CMP22]], label %[[FOR_BODY_LR_PH:.*]], label %[[FOR_END12:.*]]
; CHECK:       [[FOR_BODY_LR_PH]]:
; CHECK-NEXT:    [[TMP0:%.*]] = add i32 [[N]], -1
; CHECK-NEXT:    br label %[[FOR_BODY:.*]]
; CHECK:       [[FOR_BODY]]:
; CHECK-NEXT:    [[INDVARS_IV24:%.*]] = phi i64 [ 0, %[[FOR_BODY_LR_PH]] ], [ [[INDVARS_IV_NEXT25:%.*]], %[[FOR_INC10:.*]] ]
; CHECK-NEXT:    tail call void (...) @foo()
; CHECK-NEXT:    br label %[[FOR_BODY3:.*]]
; CHECK:       [[FOR_BODY3]]:
; CHECK-NEXT:    [[INDVARS_IV:%.*]] = phi i64 [ [[INDVARS_IV_NEXT:%.*]], %[[FOR_BODY3]] ], [ 2, %[[FOR_BODY]] ]
; CHECK-NEXT:    [[ARRAYIDX5:%.*]] = getelementptr inbounds [100 x [100 x i32]], ptr @A, i64 0, i64 [[INDVARS_IV24]], i64 [[INDVARS_IV]]
; CHECK-NEXT:    [[TMP1:%.*]] = load i32, ptr [[ARRAYIDX5]], align 4
; CHECK-NEXT:    [[ADD:%.*]] = add nsw i32 [[TMP1]], [[K]]
; CHECK-NEXT:    store i32 [[ADD]], ptr [[ARRAYIDX5]], align 4
; CHECK-NEXT:    [[INDVARS_IV_NEXT]] = add nuw nsw i64 [[INDVARS_IV]], 1
; CHECK-NEXT:    [[LFTR_WIDEIV:%.*]] = trunc i64 [[INDVARS_IV]] to i32
; CHECK-NEXT:    [[EXITCOND:%.*]] = icmp eq i32 [[LFTR_WIDEIV]], [[TMP0]]
; CHECK-NEXT:    br i1 [[EXITCOND]], label %[[FOR_INC10]], label %[[FOR_BODY3]]
; CHECK:       [[FOR_INC10]]:
; CHECK-NEXT:    [[INDVARS_IV_NEXT25]] = add nuw nsw i64 [[INDVARS_IV24]], 1
; CHECK-NEXT:    [[LFTR_WIDEIV26:%.*]] = trunc i64 [[INDVARS_IV24]] to i32
; CHECK-NEXT:    [[EXITCOND27:%.*]] = icmp eq i32 [[LFTR_WIDEIV26]], [[TMP0]]
; CHECK-NEXT:    br i1 [[EXITCOND27]], label %[[FOR_END12_LOOPEXIT:.*]], label %[[FOR_BODY]]
; CHECK:       [[FOR_END12_LOOPEXIT]]:
; CHECK-NEXT:    br label %[[FOR_END12]]
; CHECK:       [[FOR_END12]]:
; CHECK-NEXT:    ret void
;
entry:
  %cmp22 = icmp sgt i32 %N, 0
  br i1 %cmp22, label %for.body.lr.ph, label %for.end12

for.body.lr.ph:
  %0 = add i32 %N, -1
  br label %for.body

for.body:
  %indvars.iv24 = phi i64 [ 0, %for.body.lr.ph ], [ %indvars.iv.next25, %for.inc10 ]
  tail call void (...) @foo()
  br label %for.body3

for.body3:
  %indvars.iv = phi i64 [ %indvars.iv.next, %for.body3 ], [ 2, %for.body ]
  %arrayidx5 = getelementptr inbounds [100 x [100 x i32]], ptr @A, i64 0, i64 %indvars.iv24, i64 %indvars.iv
  %1 = load i32, ptr %arrayidx5
  %add = add nsw i32 %1, %k
  store i32 %add, ptr %arrayidx5
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %lftr.wideiv = trunc i64 %indvars.iv to i32
  %exitcond = icmp eq i32 %lftr.wideiv, %0
  br i1 %exitcond, label %for.inc10, label %for.body3

for.inc10:
  %indvars.iv.next25 = add nuw nsw i64 %indvars.iv24, 1
  %lftr.wideiv26 = trunc i64 %indvars.iv24 to i32
  %exitcond27 = icmp eq i32 %lftr.wideiv26, %0
  br i1 %exitcond27, label %for.end12, label %for.body

for.end12:
  ret void
}

; The following Loop is not considered tightly nested and is not interchanged.
; The outer loop header does not branch to the inner loop preheader, or the
; inner loop header, or the outer loop latch.
;
define void @interchange_07(i32 %k, i32 %N, i64 %ny) {
; CHECK-LABEL: define void @interchange_07(
; CHECK-SAME: i32 [[K:%.*]], i32 [[N:%.*]], i64 [[NY:%.*]]) {
; CHECK-NEXT:  [[ENTRY:.*]]:
; CHECK-NEXT:    br label %[[FOR1_HEADER:.*]]
; CHECK:       [[FOR1_HEADER]]:
; CHECK-NEXT:    [[J23:%.*]] = phi i64 [ 0, %[[ENTRY]] ], [ [[J_NEXT24:%.*]], %[[FOR1_INC10:.*]] ]
; CHECK-NEXT:    [[CMP21:%.*]] = icmp slt i64 0, [[NY]]
; CHECK-NEXT:    br label %[[SINGLESUCC:.*]]
; CHECK:       [[SINGLESUCC]]:
; CHECK-NEXT:    br i1 [[CMP21]], label %[[PREHEADER_J:.*]], label %[[FOR1_INC10]]
; CHECK:       [[PREHEADER_J]]:
; CHECK-NEXT:    br label %[[FOR2:.*]]
; CHECK:       [[FOR2]]:
; CHECK-NEXT:    [[J:%.*]] = phi i64 [ [[J_NEXT:%.*]], %[[FOR2]] ], [ 0, %[[PREHEADER_J]] ]
; CHECK-NEXT:    [[ARRAYIDX5:%.*]] = getelementptr inbounds [100 x [100 x i32]], ptr @A, i64 0, i64 [[J]], i64 [[J23]]
; CHECK-NEXT:    [[LV:%.*]] = load i32, ptr [[ARRAYIDX5]], align 4
; CHECK-NEXT:    [[ADD:%.*]] = add nsw i32 [[LV]], [[K]]
; CHECK-NEXT:    store i32 [[ADD]], ptr [[ARRAYIDX5]], align 4
; CHECK-NEXT:    [[J_NEXT]] = add nuw nsw i64 [[J]], 1
; CHECK-NEXT:    [[EXITCOND:%.*]] = icmp eq i64 [[J]], 99
; CHECK-NEXT:    br i1 [[EXITCOND]], label %[[FOR1_INC10_LOOPEXIT:.*]], label %[[FOR2]]
; CHECK:       [[FOR1_INC10_LOOPEXIT]]:
; CHECK-NEXT:    br label %[[FOR1_INC10]]
; CHECK:       [[FOR1_INC10]]:
; CHECK-NEXT:    [[J_NEXT24]] = add nuw nsw i64 [[J23]], 1
; CHECK-NEXT:    [[EXITCOND26:%.*]] = icmp eq i64 [[J23]], 99
; CHECK-NEXT:    br i1 [[EXITCOND26]], label %[[FOR_END12:.*]], label %[[FOR1_HEADER]]
; CHECK:       [[FOR_END12]]:
; CHECK-NEXT:    ret void
;
entry:
  br label %for1.header

for1.header:
  %j23 = phi i64 [ 0, %entry ], [ %j.next24, %for1.inc10 ]
  %cmp21 = icmp slt i64 0, %ny
  br label %singleSucc

singleSucc:
  br i1 %cmp21, label %preheader.j, label %for1.inc10

preheader.j:
  br label %for2

for2:
  %j = phi i64 [ %j.next, %for2 ], [ 0, %preheader.j ]
  %arrayidx5 = getelementptr inbounds [100 x [100 x i32]], ptr @A, i64 0, i64 %j, i64 %j23
  %lv = load i32, ptr %arrayidx5
  %add = add nsw i32 %lv, %k
  store i32 %add, ptr %arrayidx5
  %j.next = add nuw nsw i64 %j, 1
  %exitcond = icmp eq i64 %j, 99
  br i1 %exitcond, label %for1.inc10, label %for2

for1.inc10:
  %j.next24 = add nuw nsw i64 %j23, 1
  %exitcond26 = icmp eq i64 %j23, 99
  br i1 %exitcond26, label %for.end12, label %for1.header

for.end12:
  ret void
}
