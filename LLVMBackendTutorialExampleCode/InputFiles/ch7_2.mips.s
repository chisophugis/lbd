	.section .mdebug.abi32
	.previous
	.file	"ch7_2.bc"
	.text
	.globl	_Z5sum_iiiiiii
	.align	2
	.type	_Z5sum_iiiiiii,@function
	.ent	_Z5sum_iiiiiii          # @_Z5sum_iiiiiii
_Z5sum_iiiiiii:
	.cfi_startproc
	.frame	$sp,32,$ra
	.mask 	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -32
$tmp1:
	.cfi_def_cfa_offset 32
	sw	$4, 28($sp)
	sw	$5, 24($sp)
	sw	$6, 20($sp)
	sw	$7, 16($sp)
	lw	$2, 48($sp)
	sw	$2, 12($sp)
	lw	$2, 52($sp)
	sw	$2, 8($sp)
	lw	$3, %got(gI)($gp)
	lw	$3, 0($3)
	lw	$4, 28($sp)
	addu	$3, $3, $4
	lw	$4, 24($sp)
	addu	$3, $3, $4
	lw	$4, 20($sp)
	addu	$3, $3, $4
	lw	$4, 16($sp)
	addu	$3, $3, $4
	lw	$4, 12($sp)
	addu	$3, $3, $4
	addu	$2, $3, $2
	sw	$2, 4($sp)
	addiu	$sp, $sp, 32
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_Z5sum_iiiiiii
$tmp2:
	.size	_Z5sum_iiiiiii, ($tmp2)-_Z5sum_iiiiiii
	.cfi_endproc

	.globl	main
	.align	2
	.type	main,@function
	.ent	main                    # @main
main:
	.cfi_startproc
	.cfi_personality 0, __gxx_personality_v0
$eh_func_begin1:
	.cfi_lsda 0, $exception1
	.frame	$sp,88,$ra
	.mask 	0x80010000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -88
$tmp19:
	.cfi_def_cfa_offset 88
	sw	$ra, 84($sp)            # 4-byte Folded Spill
	sw	$16, 80($sp)            # 4-byte Folded Spill
$tmp20:
	.cfi_offset 31, -4
$tmp21:
	.cfi_offset 16, -8
	.cprestore	24
	sw	$zero, 76($sp)
	lw	$25, %call16(_ZNSaIiEC1Ev)($gp)
	addiu	$16, $sp, 56
	addu	$4, $zero, $16
	jalr	$25
	nop
	lw	$gp, 24($sp)
$tmp3:
	lw	$25, %call16(_ZNSt6vectorIiSaIiEEC1ERKS0_)($gp)
	addiu	$4, $sp, 64
	addu	$5, $zero, $16
	jalr	$25
	nop
	lw	$gp, 24($sp)
$tmp4:
# BB#1:
	lw	$25, %call16(_ZNSaIiED1Ev)($gp)
	addiu	$4, $sp, 56
	jalr	$25
	nop
	lw	$gp, 24($sp)
	addiu	$2, $zero, 2
	sw	$2, 44($sp)
$tmp6:
	lw	$25, %call16(_ZNSt6vectorIiSaIiEE9push_backERKi)($gp)
	addiu	$4, $sp, 64
	addiu	$5, $sp, 44
	jalr	$25
	nop
	lw	$gp, 24($sp)
$tmp7:
# BB#2:
$tmp11:
	addiu	$2, $zero, 6
	sw	$2, 20($sp)
	addiu	$2, $zero, 5
	sw	$2, 16($sp)
	lw	$25, %call16(_Z5sum_iiiiiii)($gp)
	addiu	$4, $zero, 1
	addiu	$5, $zero, 2
	addiu	$6, $zero, 3
	addiu	$7, $zero, 4
	jalr	$25
	nop
	lw	$gp, 24($sp)
$tmp12:
# BB#3:
	sw	$2, 36($sp)
	sw	$2, 76($sp)
	addiu	$2, $zero, 1
	sw	$2, 40($sp)
	b	$BB1_4
	nop
$BB1_5:
$tmp8:
	lw	$gp, 24($sp)
	sw	$4, 52($sp)
	sw	$5, 48($sp)
	lw	$4, 52($sp)
	lw	$25, %call16(__cxa_begin_catch)($gp)
	jalr	$25
	nop
	lw	$gp, 24($sp)
	addiu	$2, $zero, 1
	sw	$2, 76($sp)
	sw	$2, 40($sp)
$tmp9:
	lw	$25, %call16(__cxa_end_catch)($gp)
	jalr	$25
	nop
	lw	$gp, 24($sp)
$tmp10:
$BB1_4:
	lw	$25, %call16(_ZNSt6vectorIiSaIiEED1Ev)($gp)
	addiu	$4, $sp, 64
	jalr	$25
	nop
	lw	$gp, 24($sp)
	lw	$2, 76($sp)
	lw	$16, 80($sp)            # 4-byte Folded Reload
	lw	$ra, 84($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 88
	jr	$ra
	nop
$BB1_7:
$tmp5:
	lw	$gp, 24($sp)
	sw	$4, 52($sp)
	sw	$5, 48($sp)
	lw	$25, %call16(_ZNSaIiED1Ev)($gp)
	addiu	$4, $sp, 56
	jalr	$25
	nop
	lw	$gp, 24($sp)
	b	$BB1_8
	nop
$BB1_6:
$tmp13:
	lw	$gp, 24($sp)
	sw	$4, 52($sp)
	sw	$5, 48($sp)
$tmp14:
	lw	$25, %call16(_ZNSt6vectorIiSaIiEED1Ev)($gp)
	addiu	$4, $sp, 64
	jalr	$25
	nop
	lw	$gp, 24($sp)
$tmp15:
$BB1_8:
	lw	$4, 52($sp)
	lw	$25, %call16(_Unwind_Resume)($gp)
	jalr	$25
	nop
	lw	$gp, 24($sp)
$BB1_9:
$tmp16:
	lw	$gp, 24($sp)
	lw	$25, %call16(_ZSt9terminatev)($gp)
	jalr	$25
	nop
	lw	$gp, 24($sp)
	.set	macro
	.set	reorder
	.end	main
$tmp22:
	.size	main, ($tmp22)-main
	.cfi_endproc
$eh_func_end1:
	.section	.gcc_except_table,"a",@progbits
	.align	2
GCC_except_table1:
$exception1:
	.byte	255                     # @LPStart Encoding = omit
	.byte	0                       # @TType Encoding = absptr
	.asciz	 "\213\201"             # @TType base offset
	.byte	3                       # Call site Encoding = udata4
	.ascii	 "\202\001"             # Call site table length
$set0 = ($eh_func_begin1)-($eh_func_begin1) # >> Call Site 1 <<
	.4byte	($set0)
$set1 = ($tmp3)-($eh_func_begin1)       #   Call between $eh_func_begin1 and $tmp3
	.4byte	($set1)
	.4byte	0                       #     has no landing pad
	.byte	0                       #   On action: cleanup
$set2 = ($tmp3)-($eh_func_begin1)       # >> Call Site 2 <<
	.4byte	($set2)
$set3 = ($tmp4)-($tmp3)                 #   Call between $tmp3 and $tmp4
	.4byte	($set3)
$set4 = ($tmp5)-($eh_func_begin1)       #     jumps to $tmp5
	.4byte	($set4)
	.byte	0                       #   On action: cleanup
$set5 = ($tmp4)-($eh_func_begin1)       # >> Call Site 3 <<
	.4byte	($set5)
$set6 = ($tmp6)-($tmp4)                 #   Call between $tmp4 and $tmp6
	.4byte	($set6)
	.4byte	0                       #     has no landing pad
	.byte	0                       #   On action: cleanup
$set7 = ($tmp6)-($eh_func_begin1)       # >> Call Site 4 <<
	.4byte	($set7)
$set8 = ($tmp7)-($tmp6)                 #   Call between $tmp6 and $tmp7
	.4byte	($set8)
$set9 = ($tmp8)-($eh_func_begin1)       #     jumps to $tmp8
	.4byte	($set9)
	.byte	1                       #   On action: 1
$set10 = ($tmp11)-($eh_func_begin1)     # >> Call Site 5 <<
	.4byte	($set10)
$set11 = ($tmp12)-($tmp11)              #   Call between $tmp11 and $tmp12
	.4byte	($set11)
$set12 = ($tmp13)-($eh_func_begin1)     #     jumps to $tmp13
	.4byte	($set12)
	.byte	0                       #   On action: cleanup
$set13 = ($tmp12)-($eh_func_begin1)     # >> Call Site 6 <<
	.4byte	($set13)
$set14 = ($tmp9)-($tmp12)               #   Call between $tmp12 and $tmp9
	.4byte	($set14)
	.4byte	0                       #     has no landing pad
	.byte	0                       #   On action: cleanup
$set15 = ($tmp9)-($eh_func_begin1)      # >> Call Site 7 <<
	.4byte	($set15)
$set16 = ($tmp10)-($tmp9)               #   Call between $tmp9 and $tmp10
	.4byte	($set16)
$set17 = ($tmp13)-($eh_func_begin1)     #     jumps to $tmp13
	.4byte	($set17)
	.byte	0                       #   On action: cleanup
$set18 = ($tmp10)-($eh_func_begin1)     # >> Call Site 8 <<
	.4byte	($set18)
$set19 = ($tmp14)-($tmp10)              #   Call between $tmp10 and $tmp14
	.4byte	($set19)
	.4byte	0                       #     has no landing pad
	.byte	0                       #   On action: cleanup
$set20 = ($tmp14)-($eh_func_begin1)     # >> Call Site 9 <<
	.4byte	($set20)
$set21 = ($tmp15)-($tmp14)              #   Call between $tmp14 and $tmp15
	.4byte	($set21)
$set22 = ($tmp16)-($eh_func_begin1)     #     jumps to $tmp16
	.4byte	($set22)
	.byte	1                       #   On action: 1
$set23 = ($tmp15)-($eh_func_begin1)     # >> Call Site 10 <<
	.4byte	($set23)
$set24 = ($eh_func_end1)-($tmp15)       #   Call between $tmp15 and $eh_func_end1
	.4byte	($set24)
	.4byte	0                       #     has no landing pad
	.byte	0                       #   On action: cleanup
	.byte	1                       # >> Action Record 1 <<
                                        #   Catch TypeInfo 1
	.byte	0                       #   No further actions
                                        # >> Catch TypeInfos <<
	.4byte	0                       # TypeInfo 1
	.align	2

	.section	.text._ZNSt6vectorIiSaIiEEC1ERKS0_,"axG",@progbits,_ZNSt6vectorIiSaIiEEC1ERKS0_,comdat
	.weak	_ZNSt6vectorIiSaIiEEC1ERKS0_
	.align	2
	.type	_ZNSt6vectorIiSaIiEEC1ERKS0_,@function
	.ent	_ZNSt6vectorIiSaIiEEC1ERKS0_ # @_ZNSt6vectorIiSaIiEEC1ERKS0_
_ZNSt6vectorIiSaIiEEC1ERKS0_:
	.cfi_startproc
	.frame	$sp,40,$ra
	.mask 	0x80000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -40
$tmp25:
	.cfi_def_cfa_offset 40
	sw	$ra, 36($sp)            # 4-byte Folded Spill
$tmp26:
	.cfi_offset 31, -4
	.cprestore	16
	sw	$4, 32($sp)
	sw	$5, 24($sp)
	lw	$4, 32($sp)
	lw	$25, %call16(_ZNSt6vectorIiSaIiEEC2ERKS0_)($gp)
	jalr	$25
	nop
	lw	$gp, 16($sp)
	lw	$ra, 36($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 40
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_ZNSt6vectorIiSaIiEEC1ERKS0_
$tmp27:
	.size	_ZNSt6vectorIiSaIiEEC1ERKS0_, ($tmp27)-_ZNSt6vectorIiSaIiEEC1ERKS0_
	.cfi_endproc

	.section	.text._ZNSaIiEC1Ev,"axG",@progbits,_ZNSaIiEC1Ev,comdat
	.weak	_ZNSaIiEC1Ev
	.align	2
	.type	_ZNSaIiEC1Ev,@function
	.ent	_ZNSaIiEC1Ev            # @_ZNSaIiEC1Ev
_ZNSaIiEC1Ev:
	.cfi_startproc
	.frame	$sp,32,$ra
	.mask 	0x80000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -32
$tmp30:
	.cfi_def_cfa_offset 32
	sw	$ra, 28($sp)            # 4-byte Folded Spill
$tmp31:
	.cfi_offset 31, -4
	.cprestore	16
	sw	$4, 24($sp)
	lw	$25, %call16(_ZNSaIiEC2Ev)($gp)
	jalr	$25
	nop
	lw	$gp, 16($sp)
	lw	$ra, 28($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 32
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_ZNSaIiEC1Ev
$tmp32:
	.size	_ZNSaIiEC1Ev, ($tmp32)-_ZNSaIiEC1Ev
	.cfi_endproc

	.section	.text._ZNSaIiED1Ev,"axG",@progbits,_ZNSaIiED1Ev,comdat
	.weak	_ZNSaIiED1Ev
	.align	2
	.type	_ZNSaIiED1Ev,@function
	.ent	_ZNSaIiED1Ev            # @_ZNSaIiED1Ev
_ZNSaIiED1Ev:
	.cfi_startproc
	.frame	$sp,32,$ra
	.mask 	0x80000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -32
$tmp35:
	.cfi_def_cfa_offset 32
	sw	$ra, 28($sp)            # 4-byte Folded Spill
$tmp36:
	.cfi_offset 31, -4
	.cprestore	16
	sw	$4, 24($sp)
	lw	$25, %call16(_ZNSaIiED2Ev)($gp)
	jalr	$25
	nop
	lw	$gp, 16($sp)
	lw	$ra, 28($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 32
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_ZNSaIiED1Ev
$tmp37:
	.size	_ZNSaIiED1Ev, ($tmp37)-_ZNSaIiED1Ev
	.cfi_endproc

	.section	.text._ZNSt6vectorIiSaIiEE9push_backERKi,"axG",@progbits,_ZNSt6vectorIiSaIiEE9push_backERKi,comdat
	.weak	_ZNSt6vectorIiSaIiEE9push_backERKi
	.align	2
	.type	_ZNSt6vectorIiSaIiEE9push_backERKi,@function
	.ent	_ZNSt6vectorIiSaIiEE9push_backERKi # @_ZNSt6vectorIiSaIiEE9push_backERKi
_ZNSt6vectorIiSaIiEE9push_backERKi:
	.cfi_startproc
	.frame	$sp,56,$ra
	.mask 	0x80010000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -56
$tmp40:
	.cfi_def_cfa_offset 56
	sw	$ra, 52($sp)            # 4-byte Folded Spill
	sw	$16, 48($sp)            # 4-byte Folded Spill
$tmp41:
	.cfi_offset 31, -4
$tmp42:
	.cfi_offset 16, -8
	.cprestore	16
	sw	$4, 40($sp)
	sw	$5, 32($sp)
	lw	$16, 40($sp)
	lw	$2, 8($16)
	lw	$3, 4($16)
	beq	$3, $2, $BB5_2
	nop
# BB#1:
	lw	$5, 4($16)
	lw	$6, 32($sp)
	lw	$25, %call16(_ZN9__gnu_cxx13new_allocatorIiE9constructEPiRKi)($gp)
	addu	$4, $zero, $16
	jalr	$25
	nop
	lw	$gp, 16($sp)
	lw	$2, 4($16)
	addiu	$2, $2, 4
	sw	$2, 4($16)
	b	$BB5_3
	nop
$BB5_2:
	lw	$25, %call16(_ZNSt6vectorIiSaIiEE3endEv)($gp)
	addu	$4, $zero, $16
	jalr	$25
	nop
	lw	$gp, 16($sp)
	sw	$2, 24($sp)
	lw	$6, 32($sp)
	lw	$25, %call16(_ZNSt6vectorIiSaIiEE13_M_insert_auxEN9__gnu_cxx17__normal_iteratorIPiS1_EERKi)($gp)
	addu	$4, $zero, $16
	addu	$5, $zero, $2
	jalr	$25
	nop
	lw	$gp, 16($sp)
$BB5_3:
	lw	$16, 48($sp)            # 4-byte Folded Reload
	lw	$ra, 52($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 56
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_ZNSt6vectorIiSaIiEE9push_backERKi
$tmp43:
	.size	_ZNSt6vectorIiSaIiEE9push_backERKi, ($tmp43)-_ZNSt6vectorIiSaIiEE9push_backERKi
	.cfi_endproc

	.section	.text._ZNSt6vectorIiSaIiEED1Ev,"axG",@progbits,_ZNSt6vectorIiSaIiEED1Ev,comdat
	.weak	_ZNSt6vectorIiSaIiEED1Ev
	.align	2
	.type	_ZNSt6vectorIiSaIiEED1Ev,@function
	.ent	_ZNSt6vectorIiSaIiEED1Ev # @_ZNSt6vectorIiSaIiEED1Ev
_ZNSt6vectorIiSaIiEED1Ev:
	.cfi_startproc
	.frame	$sp,32,$ra
	.mask 	0x80000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -32
$tmp46:
	.cfi_def_cfa_offset 32
	sw	$ra, 28($sp)            # 4-byte Folded Spill
$tmp47:
	.cfi_offset 31, -4
	.cprestore	16
	sw	$4, 24($sp)
	lw	$25, %call16(_ZNSt6vectorIiSaIiEED2Ev)($gp)
	jalr	$25
	nop
	lw	$gp, 16($sp)
	lw	$ra, 28($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 32
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_ZNSt6vectorIiSaIiEED1Ev
$tmp48:
	.size	_ZNSt6vectorIiSaIiEED1Ev, ($tmp48)-_ZNSt6vectorIiSaIiEED1Ev
	.cfi_endproc

	.section	.text._ZN9__gnu_cxx13new_allocatorIiE9constructEPiRKi,"axG",@progbits,_ZN9__gnu_cxx13new_allocatorIiE9constructEPiRKi,comdat
	.weak	_ZN9__gnu_cxx13new_allocatorIiE9constructEPiRKi
	.align	2
	.type	_ZN9__gnu_cxx13new_allocatorIiE9constructEPiRKi,@function
	.ent	_ZN9__gnu_cxx13new_allocatorIiE9constructEPiRKi # @_ZN9__gnu_cxx13new_allocatorIiE9constructEPiRKi
_ZN9__gnu_cxx13new_allocatorIiE9constructEPiRKi:
	.cfi_startproc
	.frame	$sp,24,$ra
	.mask 	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -24
$tmp50:
	.cfi_def_cfa_offset 24
	sw	$4, 16($sp)
	sw	$5, 8($sp)
	sw	$6, 0($sp)
	lw	$2, 8($sp)
	beq	$2, $zero, $BB7_2
	nop
# BB#1:
	lw	$3, 0($sp)
	lw	$3, 0($3)
	sw	$3, 0($2)
$BB7_2:
	addiu	$sp, $sp, 24
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_ZN9__gnu_cxx13new_allocatorIiE9constructEPiRKi
$tmp51:
	.size	_ZN9__gnu_cxx13new_allocatorIiE9constructEPiRKi, ($tmp51)-_ZN9__gnu_cxx13new_allocatorIiE9constructEPiRKi
	.cfi_endproc

	.section	.text._ZNSt6vectorIiSaIiEE13_M_insert_auxEN9__gnu_cxx17__normal_iteratorIPiS1_EERKi,"axG",@progbits,_ZNSt6vectorIiSaIiEE13_M_insert_auxEN9__gnu_cxx17__normal_iteratorIPiS1_EERKi,comdat
	.weak	_ZNSt6vectorIiSaIiEE13_M_insert_auxEN9__gnu_cxx17__normal_iteratorIPiS1_EERKi
	.align	2
	.type	_ZNSt6vectorIiSaIiEE13_M_insert_auxEN9__gnu_cxx17__normal_iteratorIPiS1_EERKi,@function
	.ent	_ZNSt6vectorIiSaIiEE13_M_insert_auxEN9__gnu_cxx17__normal_iteratorIPiS1_EERKi # @_ZNSt6vectorIiSaIiEE13_M_insert_auxEN9__gnu_cxx17__normal_iteratorIPiS1_EERKi
_ZNSt6vectorIiSaIiEE13_M_insert_auxEN9__gnu_cxx17__normal_iteratorIPiS1_EERKi:
	.cfi_startproc
	.cfi_personality 0, __gxx_personality_v0
$eh_func_begin8:
	.cfi_lsda 0, $exception8
	.frame	$sp,152,$ra
	.mask 	0x801f0000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -152
$tmp87:
	.cfi_def_cfa_offset 152
	sw	$ra, 148($sp)           # 4-byte Folded Spill
	sw	$20, 144($sp)           # 4-byte Folded Spill
	sw	$19, 140($sp)           # 4-byte Folded Spill
	sw	$18, 136($sp)           # 4-byte Folded Spill
	sw	$17, 132($sp)           # 4-byte Folded Spill
	sw	$16, 128($sp)           # 4-byte Folded Spill
$tmp88:
	.cfi_offset 31, -4
$tmp89:
	.cfi_offset 20, -8
$tmp90:
	.cfi_offset 19, -12
$tmp91:
	.cfi_offset 18, -16
$tmp92:
	.cfi_offset 17, -20
$tmp93:
	.cfi_offset 16, -24
	.cprestore	16
	sw	$4, 120($sp)
	sw	$5, 112($sp)
	sw	$6, 104($sp)
	lw	$16, 120($sp)
	lw	$2, 8($16)
	lw	$3, 4($16)
	beq	$3, $2, $BB8_2
	nop
# BB#1:
	lw	$5, 4($16)
	addiu	$6, $5, -4
	lw	$25, %call16(_ZN9__gnu_cxx13new_allocatorIiE9constructEPiRKi)($gp)
	addu	$4, $zero, $16
	jalr	$25
	nop
	lw	$gp, 16($sp)
	lw	$2, 4($16)
	addiu	$2, $2, 4
	sw	$2, 4($16)
	lw	$2, 104($sp)
	lw	$2, 0($2)
	sw	$2, 100($sp)
	lw	$25, %call16(_ZNK9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEE4baseEv)($gp)
	addiu	$17, $sp, 112
	addu	$4, $zero, $17
	jalr	$25
	nop
	lw	$gp, 16($sp)
	lw	$4, 0($2)
	lw	$2, 4($16)
	addiu	$5, $2, -8
	addiu	$6, $2, -4
	lw	$25, %call16(_ZSt13copy_backwardIPiS0_ET0_T_S2_S1_)($gp)
	jalr	$25
	nop
	lw	$gp, 16($sp)
	lw	$16, 100($sp)
	lw	$25, %call16(_ZNK9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEEdeEv)($gp)
	addu	$4, $zero, $17
	jalr	$25
	nop
	lw	$gp, 16($sp)
	sw	$16, 0($2)
	b	$BB8_17
	nop
$BB8_2:
	lw	$25, %call16(_ZNKSt6vectorIiSaIiEE4sizeEv)($gp)
	addu	$4, $zero, $16
	jalr	$25
	nop
	lw	$gp, 16($sp)
	addu	$17, $zero, $2
	addu	$18, $zero, $3
	sw	$18, 92($sp)
	sw	$17, 88($sp)
	lw	$25, %call16(_ZNKSt6vectorIiSaIiEE8max_sizeEv)($gp)
	addu	$4, $zero, $16
	jalr	$25
	nop
	lw	$gp, 16($sp)
	xor	$2, $17, $2
	xor	$3, $18, $3
	or	$2, $3, $2
	beq	$2, $zero, $BB8_26
	nop
# BB#3:
	lw	$2, 88($sp)
	lw	$3, 92($sp)
	or	$2, $3, $2
	beq	$2, $zero, $BB8_4
	nop
# BB#5:
	lw	$3, 92($sp)
	addu	$2, $3, $3
	sltu	$3, $2, $3
	lw	$4, 88($sp)
	addu	$3, $3, $4
	addu	$3, $4, $3
	b	$BB8_6
	nop
$BB8_4:
	addiu	$2, $zero, 1
	addiu	$3, $zero, 0
$BB8_6:
	sw	$3, 80($sp)
	sw	$2, 84($sp)
	lw	$4, 92($sp)
	sltu	$2, $2, $4
	lw	$5, 88($sp)
	xor	$4, $3, $5
	sltu	$3, $3, $5
	xori	$3, $3, 1
	xori	$2, $2, 1
	movz	$3, $2, $4
	bne	$3, $zero, $BB8_8
	nop
# BB#7:
	lw	$25, %call16(_ZNKSt6vectorIiSaIiEE8max_sizeEv)($gp)
	addu	$4, $zero, $16
	jalr	$25
	nop
	lw	$gp, 16($sp)
	sw	$3, 84($sp)
	sw	$2, 80($sp)
$BB8_8:
	lw	$7, 84($sp)
	lw	$6, 80($sp)
	lw	$25, %call16(_ZNSt12_Vector_baseIiSaIiEE11_M_allocateEm)($gp)
	addu	$4, $zero, $16
	jalr	$25
	nop
	lw	$gp, 16($sp)
	sw	$2, 72($sp)
	sw	$2, 64($sp)
	lw	$17, 0($16)
$tmp52:
	lw	$25, %call16(_ZNK9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEE4baseEv)($gp)
	addiu	$4, $sp, 112
	jalr	$25
	nop
	lw	$gp, 16($sp)
$tmp53:
# BB#9:
	lw	$18, 72($sp)
	lw	$19, 0($2)
$tmp54:
	lw	$25, %call16(_ZNSt12_Vector_baseIiSaIiEE19_M_get_Tp_allocatorEv)($gp)
	addu	$4, $zero, $16
	jalr	$25
	nop
	lw	$gp, 16($sp)
$tmp55:
# BB#10:
	lw	$25, %call16(_ZNSaIiEC1ERKS_)($gp)
	addiu	$20, $sp, 48
	addu	$4, $zero, $20
	addu	$5, $zero, $2
	jalr	$25
	nop
	lw	$gp, 16($sp)
$tmp56:
	lw	$25, %call16(_ZSt22__uninitialized_copy_aIPiS0_iET0_T_S2_S1_SaIT1_E)($gp)
	addu	$4, $zero, $17
	addu	$5, $zero, $19
	addu	$6, $zero, $18
	addu	$7, $zero, $20
	jalr	$25
	nop
	lw	$gp, 16($sp)
$tmp57:
# BB#11:
	sw	$2, 64($sp)
	lw	$25, %call16(_ZNSaIiED1Ev)($gp)
	addiu	$4, $sp, 48
	jalr	$25
	nop
	lw	$gp, 16($sp)
	lw	$6, 104($sp)
	lw	$5, 64($sp)
$tmp59:
	lw	$25, %call16(_ZN9__gnu_cxx13new_allocatorIiE9constructEPiRKi)($gp)
	addu	$4, $zero, $16
	jalr	$25
	nop
	lw	$gp, 16($sp)
$tmp60:
# BB#12:
	lw	$2, 64($sp)
	addiu	$2, $2, 4
	sw	$2, 64($sp)
$tmp61:
	lw	$25, %call16(_ZNK9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEE4baseEv)($gp)
	addiu	$4, $sp, 112
	jalr	$25
	nop
	lw	$gp, 16($sp)
$tmp62:
# BB#13:
	lw	$17, 64($sp)
	lw	$18, 4($16)
	lw	$19, 0($2)
$tmp63:
	lw	$25, %call16(_ZNSt12_Vector_baseIiSaIiEE19_M_get_Tp_allocatorEv)($gp)
	addu	$4, $zero, $16
	jalr	$25
	nop
	lw	$gp, 16($sp)
$tmp64:
# BB#14:
	lw	$25, %call16(_ZNSaIiEC1ERKS_)($gp)
	addiu	$20, $sp, 40
	addu	$4, $zero, $20
	addu	$5, $zero, $2
	jalr	$25
	nop
	lw	$gp, 16($sp)
$tmp66:
	lw	$25, %call16(_ZSt22__uninitialized_copy_aIPiS0_iET0_T_S2_S1_SaIT1_E)($gp)
	addu	$4, $zero, $19
	addu	$5, $zero, $18
	addu	$6, $zero, $17
	addu	$7, $zero, $20
	jalr	$25
	nop
	lw	$gp, 16($sp)
$tmp67:
# BB#15:
	sw	$2, 64($sp)
	lw	$25, %call16(_ZNSaIiED1Ev)($gp)
	addiu	$4, $sp, 40
	jalr	$25
	nop
	lw	$gp, 16($sp)
	lw	$17, 4($16)
	lw	$18, 0($16)
	lw	$25, %call16(_ZNSt12_Vector_baseIiSaIiEE19_M_get_Tp_allocatorEv)($gp)
	addu	$4, $zero, $16
	jalr	$25
	nop
	lw	$gp, 16($sp)
	lw	$25, %call16(_ZNSaIiEC1ERKS_)($gp)
	addiu	$19, $sp, 24
	addu	$4, $zero, $19
	addu	$5, $zero, $2
	jalr	$25
	nop
	lw	$gp, 16($sp)
$tmp82:
	lw	$25, %call16(_ZSt8_DestroyIPiiEvT_S1_SaIT0_E)($gp)
	addu	$4, $zero, $18
	addu	$5, $zero, $17
	addu	$6, $zero, $19
	jalr	$25
	nop
	lw	$gp, 16($sp)
$tmp83:
# BB#16:
	lw	$25, %call16(_ZNSaIiED1Ev)($gp)
	addiu	$4, $sp, 24
	jalr	$25
	nop
	lw	$gp, 16($sp)
	lw	$5, 0($16)
	lw	$2, 8($16)
	sltu	$3, $2, $5
	addiu	$4, $zero, 0
	addu	$3, $3, $4
	subu	$3, $zero, $3
	subu	$2, $2, $5
	srl	$2, $2, 2
	sll	$4, $3, 30
	or	$7, $2, $4
	sra	$6, $3, 2
	lw	$25, %call16(_ZNSt12_Vector_baseIiSaIiEE13_M_deallocateEPim)($gp)
	addu	$4, $zero, $16
	jalr	$25
	nop
	lw	$gp, 16($sp)
	lw	$2, 72($sp)
	sw	$2, 0($16)
	lw	$2, 64($sp)
	sw	$2, 4($16)
	lw	$2, 84($sp)
	sll	$2, $2, 2
	lw	$3, 72($sp)
	addu	$2, $3, $2
	sw	$2, 8($16)
$BB8_17:
	lw	$16, 128($sp)           # 4-byte Folded Reload
	lw	$17, 132($sp)           # 4-byte Folded Reload
	lw	$18, 136($sp)           # 4-byte Folded Reload
	lw	$19, 140($sp)           # 4-byte Folded Reload
	lw	$20, 144($sp)           # 4-byte Folded Reload
	lw	$ra, 148($sp)           # 4-byte Folded Reload
	addiu	$sp, $sp, 152
	jr	$ra
	nop
$BB8_19:
$tmp58:
	lw	$gp, 16($sp)
	sw	$4, 60($sp)
	sw	$5, 56($sp)
	lw	$25, %call16(_ZNSaIiED1Ev)($gp)
	addiu	$4, $sp, 48
	b	$BB8_21
	nop
$BB8_18:
$tmp65:
	lw	$gp, 16($sp)
	sw	$4, 60($sp)
	sw	$5, 56($sp)
	b	$BB8_22
	nop
$BB8_20:
$tmp68:
	lw	$gp, 16($sp)
	sw	$4, 60($sp)
	sw	$5, 56($sp)
	lw	$25, %call16(_ZNSaIiED1Ev)($gp)
	addiu	$4, $sp, 40
$BB8_21:
	jalr	$25
	nop
	lw	$gp, 16($sp)
$BB8_22:
	lw	$4, 60($sp)
	lw	$25, %call16(__cxa_begin_catch)($gp)
	jalr	$25
	nop
	lw	$gp, 16($sp)
	lw	$17, 64($sp)
	lw	$18, 72($sp)
$tmp69:
	lw	$25, %call16(_ZNSt12_Vector_baseIiSaIiEE19_M_get_Tp_allocatorEv)($gp)
	addu	$4, $zero, $16
	jalr	$25
	nop
	lw	$gp, 16($sp)
$tmp70:
# BB#23:
	lw	$25, %call16(_ZNSaIiEC1ERKS_)($gp)
	addiu	$19, $sp, 32
	addu	$4, $zero, $19
	addu	$5, $zero, $2
	jalr	$25
	nop
	lw	$gp, 16($sp)
$tmp71:
	lw	$25, %call16(_ZSt8_DestroyIPiiEvT_S1_SaIT0_E)($gp)
	addu	$4, $zero, $18
	addu	$5, $zero, $17
	addu	$6, $zero, $19
	jalr	$25
	nop
	lw	$gp, 16($sp)
$tmp72:
# BB#24:
	lw	$25, %call16(_ZNSaIiED1Ev)($gp)
	addiu	$4, $sp, 32
	jalr	$25
	nop
	lw	$gp, 16($sp)
	lw	$7, 84($sp)
	lw	$6, 80($sp)
	lw	$5, 72($sp)
$tmp74:
	lw	$25, %call16(_ZNSt12_Vector_baseIiSaIiEE13_M_deallocateEPim)($gp)
	addu	$4, $zero, $16
	jalr	$25
	nop
	lw	$gp, 16($sp)
$tmp75:
# BB#25:
$tmp76:
	lw	$25, %call16(__cxa_rethrow)($gp)
	jalr	$25
	nop
	lw	$gp, 16($sp)
$tmp77:
	b	$BB8_26
	nop
$BB8_27:
$tmp78:
	lw	$gp, 16($sp)
	sw	$4, 60($sp)
	sw	$5, 56($sp)
	b	$BB8_29
	nop
$BB8_30:
$tmp84:
	lw	$gp, 16($sp)
	sw	$4, 60($sp)
	sw	$5, 56($sp)
	lw	$25, %call16(_ZNSaIiED1Ev)($gp)
	addiu	$4, $sp, 24
	jalr	$25
	nop
	lw	$gp, 16($sp)
	b	$BB8_31
	nop
$BB8_28:
$tmp73:
	lw	$gp, 16($sp)
	sw	$4, 60($sp)
	sw	$5, 56($sp)
	lw	$25, %call16(_ZNSaIiED1Ev)($gp)
	addiu	$4, $sp, 32
	jalr	$25
	nop
	lw	$gp, 16($sp)
$BB8_29:
$tmp79:
	lw	$25, %call16(__cxa_end_catch)($gp)
	jalr	$25
	nop
	lw	$gp, 16($sp)
$tmp80:
$BB8_31:
	lw	$4, 60($sp)
	lw	$25, %call16(_Unwind_Resume)($gp)
	jalr	$25
	nop
	lw	$gp, 16($sp)
$BB8_26:
	lw	$2, %got($.str)($gp)
	addiu	$4, $2, %lo($.str)
	lw	$25, %call16(_ZSt20__throw_length_errorPKc)($gp)
	jalr	$25
	nop
	lw	$gp, 16($sp)
$BB8_32:
$tmp81:
	lw	$gp, 16($sp)
	lw	$25, %call16(_ZSt9terminatev)($gp)
	jalr	$25
	nop
	lw	$gp, 16($sp)
	.set	macro
	.set	reorder
	.end	_ZNSt6vectorIiSaIiEE13_M_insert_auxEN9__gnu_cxx17__normal_iteratorIPiS1_EERKi
$tmp94:
	.size	_ZNSt6vectorIiSaIiEE13_M_insert_auxEN9__gnu_cxx17__normal_iteratorIPiS1_EERKi, ($tmp94)-_ZNSt6vectorIiSaIiEE13_M_insert_auxEN9__gnu_cxx17__normal_iteratorIPiS1_EERKi
	.cfi_endproc
$eh_func_end8:
	.section	.gcc_except_table,"a",@progbits
	.align	2
GCC_except_table8:
$exception8:
	.byte	255                     # @LPStart Encoding = omit
	.byte	0                       # @TType Encoding = absptr
	.ascii	 "\200\002"             # @TType base offset
	.byte	3                       # Call site Encoding = udata4
	.ascii	 "\367\001"             # Call site table length
$set25 = ($eh_func_begin8)-($eh_func_begin8) # >> Call Site 1 <<
	.4byte	($set25)
$set26 = ($tmp52)-($eh_func_begin8)     #   Call between $eh_func_begin8 and $tmp52
	.4byte	($set26)
	.4byte	0                       #     has no landing pad
	.byte	0                       #   On action: cleanup
$set27 = ($tmp52)-($eh_func_begin8)     # >> Call Site 2 <<
	.4byte	($set27)
$set28 = ($tmp55)-($tmp52)              #   Call between $tmp52 and $tmp55
	.4byte	($set28)
$set29 = ($tmp65)-($eh_func_begin8)     #     jumps to $tmp65
	.4byte	($set29)
	.byte	1                       #   On action: 1
$set30 = ($tmp55)-($eh_func_begin8)     # >> Call Site 3 <<
	.4byte	($set30)
$set31 = ($tmp56)-($tmp55)              #   Call between $tmp55 and $tmp56
	.4byte	($set31)
	.4byte	0                       #     has no landing pad
	.byte	0                       #   On action: cleanup
$set32 = ($tmp56)-($eh_func_begin8)     # >> Call Site 4 <<
	.4byte	($set32)
$set33 = ($tmp57)-($tmp56)              #   Call between $tmp56 and $tmp57
	.4byte	($set33)
$set34 = ($tmp58)-($eh_func_begin8)     #     jumps to $tmp58
	.4byte	($set34)
	.byte	1                       #   On action: 1
$set35 = ($tmp57)-($eh_func_begin8)     # >> Call Site 5 <<
	.4byte	($set35)
$set36 = ($tmp59)-($tmp57)              #   Call between $tmp57 and $tmp59
	.4byte	($set36)
	.4byte	0                       #     has no landing pad
	.byte	0                       #   On action: cleanup
$set37 = ($tmp59)-($eh_func_begin8)     # >> Call Site 6 <<
	.4byte	($set37)
$set38 = ($tmp64)-($tmp59)              #   Call between $tmp59 and $tmp64
	.4byte	($set38)
$set39 = ($tmp65)-($eh_func_begin8)     #     jumps to $tmp65
	.4byte	($set39)
	.byte	1                       #   On action: 1
$set40 = ($tmp64)-($eh_func_begin8)     # >> Call Site 7 <<
	.4byte	($set40)
$set41 = ($tmp66)-($tmp64)              #   Call between $tmp64 and $tmp66
	.4byte	($set41)
	.4byte	0                       #     has no landing pad
	.byte	0                       #   On action: cleanup
$set42 = ($tmp66)-($eh_func_begin8)     # >> Call Site 8 <<
	.4byte	($set42)
$set43 = ($tmp67)-($tmp66)              #   Call between $tmp66 and $tmp67
	.4byte	($set43)
$set44 = ($tmp68)-($eh_func_begin8)     #     jumps to $tmp68
	.4byte	($set44)
	.byte	1                       #   On action: 1
$set45 = ($tmp67)-($eh_func_begin8)     # >> Call Site 9 <<
	.4byte	($set45)
$set46 = ($tmp82)-($tmp67)              #   Call between $tmp67 and $tmp82
	.4byte	($set46)
	.4byte	0                       #     has no landing pad
	.byte	0                       #   On action: cleanup
$set47 = ($tmp82)-($eh_func_begin8)     # >> Call Site 10 <<
	.4byte	($set47)
$set48 = ($tmp83)-($tmp82)              #   Call between $tmp82 and $tmp83
	.4byte	($set48)
$set49 = ($tmp84)-($eh_func_begin8)     #     jumps to $tmp84
	.4byte	($set49)
	.byte	0                       #   On action: cleanup
$set50 = ($tmp83)-($eh_func_begin8)     # >> Call Site 11 <<
	.4byte	($set50)
$set51 = ($tmp69)-($tmp83)              #   Call between $tmp83 and $tmp69
	.4byte	($set51)
	.4byte	0                       #     has no landing pad
	.byte	0                       #   On action: cleanup
$set52 = ($tmp69)-($eh_func_begin8)     # >> Call Site 12 <<
	.4byte	($set52)
$set53 = ($tmp70)-($tmp69)              #   Call between $tmp69 and $tmp70
	.4byte	($set53)
$set54 = ($tmp78)-($eh_func_begin8)     #     jumps to $tmp78
	.4byte	($set54)
	.byte	0                       #   On action: cleanup
$set55 = ($tmp70)-($eh_func_begin8)     # >> Call Site 13 <<
	.4byte	($set55)
$set56 = ($tmp71)-($tmp70)              #   Call between $tmp70 and $tmp71
	.4byte	($set56)
	.4byte	0                       #     has no landing pad
	.byte	0                       #   On action: cleanup
$set57 = ($tmp71)-($eh_func_begin8)     # >> Call Site 14 <<
	.4byte	($set57)
$set58 = ($tmp72)-($tmp71)              #   Call between $tmp71 and $tmp72
	.4byte	($set58)
$set59 = ($tmp73)-($eh_func_begin8)     #     jumps to $tmp73
	.4byte	($set59)
	.byte	0                       #   On action: cleanup
$set60 = ($tmp72)-($eh_func_begin8)     # >> Call Site 15 <<
	.4byte	($set60)
$set61 = ($tmp74)-($tmp72)              #   Call between $tmp72 and $tmp74
	.4byte	($set61)
	.4byte	0                       #     has no landing pad
	.byte	0                       #   On action: cleanup
$set62 = ($tmp74)-($eh_func_begin8)     # >> Call Site 16 <<
	.4byte	($set62)
$set63 = ($tmp77)-($tmp74)              #   Call between $tmp74 and $tmp77
	.4byte	($set63)
$set64 = ($tmp78)-($eh_func_begin8)     #     jumps to $tmp78
	.4byte	($set64)
	.byte	0                       #   On action: cleanup
$set65 = ($tmp77)-($eh_func_begin8)     # >> Call Site 17 <<
	.4byte	($set65)
$set66 = ($tmp79)-($tmp77)              #   Call between $tmp77 and $tmp79
	.4byte	($set66)
	.4byte	0                       #     has no landing pad
	.byte	0                       #   On action: cleanup
$set67 = ($tmp79)-($eh_func_begin8)     # >> Call Site 18 <<
	.4byte	($set67)
$set68 = ($tmp80)-($tmp79)              #   Call between $tmp79 and $tmp80
	.4byte	($set68)
$set69 = ($tmp81)-($eh_func_begin8)     #     jumps to $tmp81
	.4byte	($set69)
	.byte	1                       #   On action: 1
$set70 = ($tmp80)-($eh_func_begin8)     # >> Call Site 19 <<
	.4byte	($set70)
$set71 = ($eh_func_end8)-($tmp80)       #   Call between $tmp80 and $eh_func_end8
	.4byte	($set71)
	.4byte	0                       #     has no landing pad
	.byte	0                       #   On action: cleanup
	.byte	1                       # >> Action Record 1 <<
                                        #   Catch TypeInfo 1
	.byte	0                       #   No further actions
                                        # >> Catch TypeInfos <<
	.4byte	0                       # TypeInfo 1
	.align	2

	.section	.text._ZNSt6vectorIiSaIiEE3endEv,"axG",@progbits,_ZNSt6vectorIiSaIiEE3endEv,comdat
	.weak	_ZNSt6vectorIiSaIiEE3endEv
	.align	2
	.type	_ZNSt6vectorIiSaIiEE3endEv,@function
	.ent	_ZNSt6vectorIiSaIiEE3endEv # @_ZNSt6vectorIiSaIiEE3endEv
_ZNSt6vectorIiSaIiEE3endEv:
	.cfi_startproc
	.frame	$sp,40,$ra
	.mask 	0x80000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -40
$tmp97:
	.cfi_def_cfa_offset 40
	sw	$ra, 36($sp)            # 4-byte Folded Spill
$tmp98:
	.cfi_offset 31, -4
	.cprestore	16
	sw	$4, 24($sp)
	addiu	$5, $4, 4
	lw	$25, %call16(_ZN9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEEC1ERKS1_)($gp)
	addiu	$4, $sp, 32
	jalr	$25
	nop
	lw	$gp, 16($sp)
	lw	$2, 32($sp)
	lw	$ra, 36($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 40
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_ZNSt6vectorIiSaIiEE3endEv
$tmp99:
	.size	_ZNSt6vectorIiSaIiEE3endEv, ($tmp99)-_ZNSt6vectorIiSaIiEE3endEv
	.cfi_endproc

	.section	.text._ZN9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEEC1ERKS1_,"axG",@progbits,_ZN9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEEC1ERKS1_,comdat
	.weak	_ZN9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEEC1ERKS1_
	.align	2
	.type	_ZN9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEEC1ERKS1_,@function
	.ent	_ZN9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEEC1ERKS1_ # @_ZN9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEEC1ERKS1_
_ZN9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEEC1ERKS1_:
	.cfi_startproc
	.frame	$sp,40,$ra
	.mask 	0x80000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -40
$tmp102:
	.cfi_def_cfa_offset 40
	sw	$ra, 36($sp)            # 4-byte Folded Spill
$tmp103:
	.cfi_offset 31, -4
	.cprestore	16
	sw	$4, 32($sp)
	sw	$5, 24($sp)
	lw	$4, 32($sp)
	lw	$25, %call16(_ZN9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEEC2ERKS1_)($gp)
	jalr	$25
	nop
	lw	$gp, 16($sp)
	lw	$ra, 36($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 40
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_ZN9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEEC1ERKS1_
$tmp104:
	.size	_ZN9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEEC1ERKS1_, ($tmp104)-_ZN9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEEC1ERKS1_
	.cfi_endproc

	.section	.text._ZN9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEEC2ERKS1_,"axG",@progbits,_ZN9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEEC2ERKS1_,comdat
	.weak	_ZN9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEEC2ERKS1_
	.align	2
	.type	_ZN9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEEC2ERKS1_,@function
	.ent	_ZN9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEEC2ERKS1_ # @_ZN9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEEC2ERKS1_
_ZN9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEEC2ERKS1_:
	.cfi_startproc
	.frame	$sp,16,$ra
	.mask 	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -16
$tmp106:
	.cfi_def_cfa_offset 16
	sw	$4, 8($sp)
	sw	$5, 0($sp)
	lw	$2, 0($5)
	lw	$3, 8($sp)
	sw	$2, 0($3)
	addiu	$sp, $sp, 16
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_ZN9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEEC2ERKS1_
$tmp107:
	.size	_ZN9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEEC2ERKS1_, ($tmp107)-_ZN9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEEC2ERKS1_
	.cfi_endproc

	.section	.text._ZSt13copy_backwardIPiS0_ET0_T_S2_S1_,"axG",@progbits,_ZSt13copy_backwardIPiS0_ET0_T_S2_S1_,comdat
	.weak	_ZSt13copy_backwardIPiS0_ET0_T_S2_S1_
	.align	2
	.type	_ZSt13copy_backwardIPiS0_ET0_T_S2_S1_,@function
	.ent	_ZSt13copy_backwardIPiS0_ET0_T_S2_S1_ # @_ZSt13copy_backwardIPiS0_ET0_T_S2_S1_
_ZSt13copy_backwardIPiS0_ET0_T_S2_S1_:
	.cfi_startproc
	.frame	$sp,56,$ra
	.mask 	0x80000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -56
$tmp110:
	.cfi_def_cfa_offset 56
	sw	$ra, 52($sp)            # 4-byte Folded Spill
$tmp111:
	.cfi_offset 31, -4
	.cprestore	16
	sw	$4, 48($sp)
	sw	$5, 40($sp)
	sw	$6, 32($sp)
	addiu	$2, $zero, 0
	sb	$2, 28($sp)
	sb	$zero, 24($sp)
	lw	$6, 32($sp)
	lw	$5, 40($sp)
	lw	$4, 48($sp)
	lw	$25, %call16(_ZNSt22__copy_backward_normalILb0ELb0EE10__copy_b_nIPiS2_EET0_T_S4_S3_)($gp)
	jalr	$25
	nop
	lw	$gp, 16($sp)
	lw	$ra, 52($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 56
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_ZSt13copy_backwardIPiS0_ET0_T_S2_S1_
$tmp112:
	.size	_ZSt13copy_backwardIPiS0_ET0_T_S2_S1_, ($tmp112)-_ZSt13copy_backwardIPiS0_ET0_T_S2_S1_
	.cfi_endproc

	.section	.text._ZNK9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEE4baseEv,"axG",@progbits,_ZNK9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEE4baseEv,comdat
	.weak	_ZNK9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEE4baseEv
	.align	2
	.type	_ZNK9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEE4baseEv,@function
	.ent	_ZNK9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEE4baseEv # @_ZNK9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEE4baseEv
_ZNK9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEE4baseEv:
	.cfi_startproc
	.frame	$sp,8,$ra
	.mask 	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -8
$tmp114:
	.cfi_def_cfa_offset 8
	sw	$4, 0($sp)
	addu	$2, $zero, $4
	addiu	$sp, $sp, 8
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_ZNK9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEE4baseEv
$tmp115:
	.size	_ZNK9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEE4baseEv, ($tmp115)-_ZNK9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEE4baseEv
	.cfi_endproc

	.section	.text._ZNK9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEEdeEv,"axG",@progbits,_ZNK9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEEdeEv,comdat
	.weak	_ZNK9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEEdeEv
	.align	2
	.type	_ZNK9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEEdeEv,@function
	.ent	_ZNK9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEEdeEv # @_ZNK9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEEdeEv
_ZNK9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEEdeEv:
	.cfi_startproc
	.frame	$sp,8,$ra
	.mask 	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -8
$tmp117:
	.cfi_def_cfa_offset 8
	sw	$4, 0($sp)
	lw	$2, 0($4)
	addiu	$sp, $sp, 8
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_ZNK9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEEdeEv
$tmp118:
	.size	_ZNK9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEEdeEv, ($tmp118)-_ZNK9__gnu_cxx17__normal_iteratorIPiSt6vectorIiSaIiEEEdeEv
	.cfi_endproc

	.section	.text._ZNKSt6vectorIiSaIiEE4sizeEv,"axG",@progbits,_ZNKSt6vectorIiSaIiEE4sizeEv,comdat
	.weak	_ZNKSt6vectorIiSaIiEE4sizeEv
	.align	2
	.type	_ZNKSt6vectorIiSaIiEE4sizeEv,@function
	.ent	_ZNKSt6vectorIiSaIiEE4sizeEv # @_ZNKSt6vectorIiSaIiEE4sizeEv
_ZNKSt6vectorIiSaIiEE4sizeEv:
	.cfi_startproc
	.frame	$sp,8,$ra
	.mask 	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -8
$tmp120:
	.cfi_def_cfa_offset 8
	sw	$4, 0($sp)
	lw	$2, 0($4)
	lw	$3, 4($4)
	sltu	$4, $3, $2
	addiu	$5, $zero, 0
	addu	$4, $4, $5
	subu	$4, $zero, $4
	subu	$2, $3, $2
	srl	$2, $2, 2
	sll	$3, $4, 30
	or	$3, $2, $3
	sra	$2, $4, 2
	addiu	$sp, $sp, 8
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_ZNKSt6vectorIiSaIiEE4sizeEv
$tmp121:
	.size	_ZNKSt6vectorIiSaIiEE4sizeEv, ($tmp121)-_ZNKSt6vectorIiSaIiEE4sizeEv
	.cfi_endproc

	.section	.text._ZNKSt6vectorIiSaIiEE8max_sizeEv,"axG",@progbits,_ZNKSt6vectorIiSaIiEE8max_sizeEv,comdat
	.weak	_ZNKSt6vectorIiSaIiEE8max_sizeEv
	.align	2
	.type	_ZNKSt6vectorIiSaIiEE8max_sizeEv,@function
	.ent	_ZNKSt6vectorIiSaIiEE8max_sizeEv # @_ZNKSt6vectorIiSaIiEE8max_sizeEv
_ZNKSt6vectorIiSaIiEE8max_sizeEv:
	.cfi_startproc
	.frame	$sp,32,$ra
	.mask 	0x80000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -32
$tmp124:
	.cfi_def_cfa_offset 32
	sw	$ra, 28($sp)            # 4-byte Folded Spill
$tmp125:
	.cfi_offset 31, -4
	.cprestore	16
	sw	$4, 24($sp)
	lw	$25, %call16(_ZNKSt12_Vector_baseIiSaIiEE19_M_get_Tp_allocatorEv)($gp)
	jalr	$25
	nop
	lw	$gp, 16($sp)
	lw	$25, %call16(_ZNK9__gnu_cxx13new_allocatorIiE8max_sizeEv)($gp)
	addu	$4, $zero, $2
	jalr	$25
	nop
	lw	$gp, 16($sp)
	lw	$ra, 28($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 32
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_ZNKSt6vectorIiSaIiEE8max_sizeEv
$tmp126:
	.size	_ZNKSt6vectorIiSaIiEE8max_sizeEv, ($tmp126)-_ZNKSt6vectorIiSaIiEE8max_sizeEv
	.cfi_endproc

	.section	.text._ZNSt12_Vector_baseIiSaIiEE11_M_allocateEm,"axG",@progbits,_ZNSt12_Vector_baseIiSaIiEE11_M_allocateEm,comdat
	.weak	_ZNSt12_Vector_baseIiSaIiEE11_M_allocateEm
	.align	2
	.type	_ZNSt12_Vector_baseIiSaIiEE11_M_allocateEm,@function
	.ent	_ZNSt12_Vector_baseIiSaIiEE11_M_allocateEm # @_ZNSt12_Vector_baseIiSaIiEE11_M_allocateEm
_ZNSt12_Vector_baseIiSaIiEE11_M_allocateEm:
	.cfi_startproc
	.frame	$sp,48,$ra
	.mask 	0x80000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -48
$tmp129:
	.cfi_def_cfa_offset 48
	sw	$ra, 44($sp)            # 4-byte Folded Spill
$tmp130:
	.cfi_offset 31, -4
	.cprestore	24
	sw	$4, 40($sp)
	sw	$7, 36($sp)
	sw	$6, 32($sp)
	lw	$4, 40($sp)
	sw	$zero, 16($sp)
	lw	$25, %call16(_ZN9__gnu_cxx13new_allocatorIiE8allocateEmPKv)($gp)
	jalr	$25
	nop
	lw	$gp, 24($sp)
	lw	$ra, 44($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 48
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_ZNSt12_Vector_baseIiSaIiEE11_M_allocateEm
$tmp131:
	.size	_ZNSt12_Vector_baseIiSaIiEE11_M_allocateEm, ($tmp131)-_ZNSt12_Vector_baseIiSaIiEE11_M_allocateEm
	.cfi_endproc

	.section	.text._ZSt22__uninitialized_copy_aIPiS0_iET0_T_S2_S1_SaIT1_E,"axG",@progbits,_ZSt22__uninitialized_copy_aIPiS0_iET0_T_S2_S1_SaIT1_E,comdat
	.weak	_ZSt22__uninitialized_copy_aIPiS0_iET0_T_S2_S1_SaIT1_E
	.align	2
	.type	_ZSt22__uninitialized_copy_aIPiS0_iET0_T_S2_S1_SaIT1_E,@function
	.ent	_ZSt22__uninitialized_copy_aIPiS0_iET0_T_S2_S1_SaIT1_E # @_ZSt22__uninitialized_copy_aIPiS0_iET0_T_S2_S1_SaIT1_E
_ZSt22__uninitialized_copy_aIPiS0_iET0_T_S2_S1_SaIT1_E:
	.cfi_startproc
	.frame	$sp,48,$ra
	.mask 	0x80000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -48
$tmp134:
	.cfi_def_cfa_offset 48
	sw	$ra, 44($sp)            # 4-byte Folded Spill
$tmp135:
	.cfi_offset 31, -4
	.cprestore	16
	sw	$4, 40($sp)
	sw	$5, 32($sp)
	sw	$6, 24($sp)
	lw	$5, 32($sp)
	lw	$4, 40($sp)
	lw	$25, %call16(_ZSt18uninitialized_copyIPiS0_ET0_T_S2_S1_)($gp)
	jalr	$25
	nop
	lw	$gp, 16($sp)
	lw	$ra, 44($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 48
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_ZSt22__uninitialized_copy_aIPiS0_iET0_T_S2_S1_SaIT1_E
$tmp136:
	.size	_ZSt22__uninitialized_copy_aIPiS0_iET0_T_S2_S1_SaIT1_E, ($tmp136)-_ZSt22__uninitialized_copy_aIPiS0_iET0_T_S2_S1_SaIT1_E
	.cfi_endproc

	.section	.text._ZNSaIiEC1ERKS_,"axG",@progbits,_ZNSaIiEC1ERKS_,comdat
	.weak	_ZNSaIiEC1ERKS_
	.align	2
	.type	_ZNSaIiEC1ERKS_,@function
	.ent	_ZNSaIiEC1ERKS_         # @_ZNSaIiEC1ERKS_
_ZNSaIiEC1ERKS_:
	.cfi_startproc
	.frame	$sp,40,$ra
	.mask 	0x80000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -40
$tmp139:
	.cfi_def_cfa_offset 40
	sw	$ra, 36($sp)            # 4-byte Folded Spill
$tmp140:
	.cfi_offset 31, -4
	.cprestore	16
	sw	$4, 32($sp)
	sw	$5, 24($sp)
	lw	$4, 32($sp)
	lw	$25, %call16(_ZNSaIiEC2ERKS_)($gp)
	jalr	$25
	nop
	lw	$gp, 16($sp)
	lw	$ra, 36($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 40
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_ZNSaIiEC1ERKS_
$tmp141:
	.size	_ZNSaIiEC1ERKS_, ($tmp141)-_ZNSaIiEC1ERKS_
	.cfi_endproc

	.section	.text._ZNSt12_Vector_baseIiSaIiEE19_M_get_Tp_allocatorEv,"axG",@progbits,_ZNSt12_Vector_baseIiSaIiEE19_M_get_Tp_allocatorEv,comdat
	.weak	_ZNSt12_Vector_baseIiSaIiEE19_M_get_Tp_allocatorEv
	.align	2
	.type	_ZNSt12_Vector_baseIiSaIiEE19_M_get_Tp_allocatorEv,@function
	.ent	_ZNSt12_Vector_baseIiSaIiEE19_M_get_Tp_allocatorEv # @_ZNSt12_Vector_baseIiSaIiEE19_M_get_Tp_allocatorEv
_ZNSt12_Vector_baseIiSaIiEE19_M_get_Tp_allocatorEv:
	.cfi_startproc
	.frame	$sp,8,$ra
	.mask 	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -8
$tmp143:
	.cfi_def_cfa_offset 8
	sw	$4, 0($sp)
	addu	$2, $zero, $4
	addiu	$sp, $sp, 8
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_ZNSt12_Vector_baseIiSaIiEE19_M_get_Tp_allocatorEv
$tmp144:
	.size	_ZNSt12_Vector_baseIiSaIiEE19_M_get_Tp_allocatorEv, ($tmp144)-_ZNSt12_Vector_baseIiSaIiEE19_M_get_Tp_allocatorEv
	.cfi_endproc

	.section	.text._ZSt8_DestroyIPiiEvT_S1_SaIT0_E,"axG",@progbits,_ZSt8_DestroyIPiiEvT_S1_SaIT0_E,comdat
	.weak	_ZSt8_DestroyIPiiEvT_S1_SaIT0_E
	.align	2
	.type	_ZSt8_DestroyIPiiEvT_S1_SaIT0_E,@function
	.ent	_ZSt8_DestroyIPiiEvT_S1_SaIT0_E # @_ZSt8_DestroyIPiiEvT_S1_SaIT0_E
_ZSt8_DestroyIPiiEvT_S1_SaIT0_E:
	.cfi_startproc
	.frame	$sp,40,$ra
	.mask 	0x80000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -40
$tmp147:
	.cfi_def_cfa_offset 40
	sw	$ra, 36($sp)            # 4-byte Folded Spill
$tmp148:
	.cfi_offset 31, -4
	.cprestore	16
	sw	$4, 32($sp)
	sw	$5, 24($sp)
	lw	$4, 32($sp)
	lw	$25, %call16(_ZSt8_DestroyIPiEvT_S1_)($gp)
	jalr	$25
	nop
	lw	$gp, 16($sp)
	lw	$ra, 36($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 40
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_ZSt8_DestroyIPiiEvT_S1_SaIT0_E
$tmp149:
	.size	_ZSt8_DestroyIPiiEvT_S1_SaIT0_E, ($tmp149)-_ZSt8_DestroyIPiiEvT_S1_SaIT0_E
	.cfi_endproc

	.section	.text._ZNSt12_Vector_baseIiSaIiEE13_M_deallocateEPim,"axG",@progbits,_ZNSt12_Vector_baseIiSaIiEE13_M_deallocateEPim,comdat
	.weak	_ZNSt12_Vector_baseIiSaIiEE13_M_deallocateEPim
	.align	2
	.type	_ZNSt12_Vector_baseIiSaIiEE13_M_deallocateEPim,@function
	.ent	_ZNSt12_Vector_baseIiSaIiEE13_M_deallocateEPim # @_ZNSt12_Vector_baseIiSaIiEE13_M_deallocateEPim
_ZNSt12_Vector_baseIiSaIiEE13_M_deallocateEPim:
	.cfi_startproc
	.frame	$sp,48,$ra
	.mask 	0x80000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -48
$tmp152:
	.cfi_def_cfa_offset 48
	sw	$ra, 44($sp)            # 4-byte Folded Spill
$tmp153:
	.cfi_offset 31, -4
	.cprestore	16
	sw	$4, 40($sp)
	sw	$5, 32($sp)
	sw	$7, 28($sp)
	sw	$6, 24($sp)
	lw	$2, 32($sp)
	beq	$2, $zero, $BB22_2
	nop
# BB#1:
	lw	$4, 40($sp)
	lw	$7, 28($sp)
	lw	$6, 24($sp)
	lw	$5, 32($sp)
	lw	$25, %call16(_ZN9__gnu_cxx13new_allocatorIiE10deallocateEPim)($gp)
	jalr	$25
	nop
	lw	$gp, 16($sp)
$BB22_2:
	lw	$ra, 44($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 48
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_ZNSt12_Vector_baseIiSaIiEE13_M_deallocateEPim
$tmp154:
	.size	_ZNSt12_Vector_baseIiSaIiEE13_M_deallocateEPim, ($tmp154)-_ZNSt12_Vector_baseIiSaIiEE13_M_deallocateEPim
	.cfi_endproc

	.section	.text._ZN9__gnu_cxx13new_allocatorIiE10deallocateEPim,"axG",@progbits,_ZN9__gnu_cxx13new_allocatorIiE10deallocateEPim,comdat
	.weak	_ZN9__gnu_cxx13new_allocatorIiE10deallocateEPim
	.align	2
	.type	_ZN9__gnu_cxx13new_allocatorIiE10deallocateEPim,@function
	.ent	_ZN9__gnu_cxx13new_allocatorIiE10deallocateEPim # @_ZN9__gnu_cxx13new_allocatorIiE10deallocateEPim
_ZN9__gnu_cxx13new_allocatorIiE10deallocateEPim:
	.cfi_startproc
	.frame	$sp,48,$ra
	.mask 	0x80000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -48
$tmp157:
	.cfi_def_cfa_offset 48
	sw	$ra, 44($sp)            # 4-byte Folded Spill
$tmp158:
	.cfi_offset 31, -4
	.cprestore	16
	sw	$4, 40($sp)
	sw	$5, 32($sp)
	sw	$7, 28($sp)
	sw	$6, 24($sp)
	lw	$4, 32($sp)
	lw	$25, %call16(_ZdlPv)($gp)
	jalr	$25
	nop
	lw	$gp, 16($sp)
	lw	$ra, 44($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 48
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_ZN9__gnu_cxx13new_allocatorIiE10deallocateEPim
$tmp159:
	.size	_ZN9__gnu_cxx13new_allocatorIiE10deallocateEPim, ($tmp159)-_ZN9__gnu_cxx13new_allocatorIiE10deallocateEPim
	.cfi_endproc

	.section	.text._ZSt8_DestroyIPiEvT_S1_,"axG",@progbits,_ZSt8_DestroyIPiEvT_S1_,comdat
	.weak	_ZSt8_DestroyIPiEvT_S1_
	.align	2
	.type	_ZSt8_DestroyIPiEvT_S1_,@function
	.ent	_ZSt8_DestroyIPiEvT_S1_ # @_ZSt8_DestroyIPiEvT_S1_
_ZSt8_DestroyIPiEvT_S1_:
	.cfi_startproc
	.frame	$sp,48,$ra
	.mask 	0x80000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -48
$tmp162:
	.cfi_def_cfa_offset 48
	sw	$ra, 44($sp)            # 4-byte Folded Spill
$tmp163:
	.cfi_offset 31, -4
	.cprestore	16
	sw	$4, 40($sp)
	sw	$5, 32($sp)
	lw	$4, 40($sp)
	lw	$25, %call16(_ZSt13__destroy_auxIPiEvT_S1_St11__true_type)($gp)
	jalr	$25
	nop
	lw	$gp, 16($sp)
	lw	$ra, 44($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 48
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_ZSt8_DestroyIPiEvT_S1_
$tmp164:
	.size	_ZSt8_DestroyIPiEvT_S1_, ($tmp164)-_ZSt8_DestroyIPiEvT_S1_
	.cfi_endproc

	.section	.text._ZSt13__destroy_auxIPiEvT_S1_St11__true_type,"axG",@progbits,_ZSt13__destroy_auxIPiEvT_S1_St11__true_type,comdat
	.weak	_ZSt13__destroy_auxIPiEvT_S1_St11__true_type
	.align	2
	.type	_ZSt13__destroy_auxIPiEvT_S1_St11__true_type,@function
	.ent	_ZSt13__destroy_auxIPiEvT_S1_St11__true_type # @_ZSt13__destroy_auxIPiEvT_S1_St11__true_type
_ZSt13__destroy_auxIPiEvT_S1_St11__true_type:
	.cfi_startproc
	.frame	$sp,24,$ra
	.mask 	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -24
$tmp166:
	.cfi_def_cfa_offset 24
	sw	$4, 16($sp)
	sw	$5, 8($sp)
	addiu	$sp, $sp, 24
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_ZSt13__destroy_auxIPiEvT_S1_St11__true_type
$tmp167:
	.size	_ZSt13__destroy_auxIPiEvT_S1_St11__true_type, ($tmp167)-_ZSt13__destroy_auxIPiEvT_S1_St11__true_type
	.cfi_endproc

	.section	.text._ZNSaIiEC2ERKS_,"axG",@progbits,_ZNSaIiEC2ERKS_,comdat
	.weak	_ZNSaIiEC2ERKS_
	.align	2
	.type	_ZNSaIiEC2ERKS_,@function
	.ent	_ZNSaIiEC2ERKS_         # @_ZNSaIiEC2ERKS_
_ZNSaIiEC2ERKS_:
	.cfi_startproc
	.frame	$sp,40,$ra
	.mask 	0x80000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -40
$tmp170:
	.cfi_def_cfa_offset 40
	sw	$ra, 36($sp)            # 4-byte Folded Spill
$tmp171:
	.cfi_offset 31, -4
	.cprestore	16
	sw	$4, 32($sp)
	sw	$5, 24($sp)
	lw	$4, 32($sp)
	lw	$25, %call16(_ZN9__gnu_cxx13new_allocatorIiEC2ERKS1_)($gp)
	jalr	$25
	nop
	lw	$gp, 16($sp)
	lw	$ra, 36($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 40
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_ZNSaIiEC2ERKS_
$tmp172:
	.size	_ZNSaIiEC2ERKS_, ($tmp172)-_ZNSaIiEC2ERKS_
	.cfi_endproc

	.section	.text._ZN9__gnu_cxx13new_allocatorIiEC2ERKS1_,"axG",@progbits,_ZN9__gnu_cxx13new_allocatorIiEC2ERKS1_,comdat
	.weak	_ZN9__gnu_cxx13new_allocatorIiEC2ERKS1_
	.align	2
	.type	_ZN9__gnu_cxx13new_allocatorIiEC2ERKS1_,@function
	.ent	_ZN9__gnu_cxx13new_allocatorIiEC2ERKS1_ # @_ZN9__gnu_cxx13new_allocatorIiEC2ERKS1_
_ZN9__gnu_cxx13new_allocatorIiEC2ERKS1_:
	.cfi_startproc
	.frame	$sp,16,$ra
	.mask 	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -16
$tmp174:
	.cfi_def_cfa_offset 16
	sw	$4, 8($sp)
	sw	$5, 0($sp)
	addiu	$sp, $sp, 16
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_ZN9__gnu_cxx13new_allocatorIiEC2ERKS1_
$tmp175:
	.size	_ZN9__gnu_cxx13new_allocatorIiEC2ERKS1_, ($tmp175)-_ZN9__gnu_cxx13new_allocatorIiEC2ERKS1_
	.cfi_endproc

	.section	.text._ZSt18uninitialized_copyIPiS0_ET0_T_S2_S1_,"axG",@progbits,_ZSt18uninitialized_copyIPiS0_ET0_T_S2_S1_,comdat
	.weak	_ZSt18uninitialized_copyIPiS0_ET0_T_S2_S1_
	.align	2
	.type	_ZSt18uninitialized_copyIPiS0_ET0_T_S2_S1_,@function
	.ent	_ZSt18uninitialized_copyIPiS0_ET0_T_S2_S1_ # @_ZSt18uninitialized_copyIPiS0_ET0_T_S2_S1_
_ZSt18uninitialized_copyIPiS0_ET0_T_S2_S1_:
	.cfi_startproc
	.frame	$sp,56,$ra
	.mask 	0x80000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -56
$tmp178:
	.cfi_def_cfa_offset 56
	sw	$ra, 52($sp)            # 4-byte Folded Spill
$tmp179:
	.cfi_offset 31, -4
	.cprestore	16
	sw	$4, 48($sp)
	sw	$5, 40($sp)
	sw	$6, 32($sp)
	lw	$5, 40($sp)
	lw	$4, 48($sp)
	lw	$25, %call16(_ZSt24__uninitialized_copy_auxIPiS0_ET0_T_S2_S1_St11__true_type)($gp)
	jalr	$25
	nop
	lw	$gp, 16($sp)
	lw	$ra, 52($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 56
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_ZSt18uninitialized_copyIPiS0_ET0_T_S2_S1_
$tmp180:
	.size	_ZSt18uninitialized_copyIPiS0_ET0_T_S2_S1_, ($tmp180)-_ZSt18uninitialized_copyIPiS0_ET0_T_S2_S1_
	.cfi_endproc

	.section	.text._ZSt24__uninitialized_copy_auxIPiS0_ET0_T_S2_S1_St11__true_type,"axG",@progbits,_ZSt24__uninitialized_copy_auxIPiS0_ET0_T_S2_S1_St11__true_type,comdat
	.weak	_ZSt24__uninitialized_copy_auxIPiS0_ET0_T_S2_S1_St11__true_type
	.align	2
	.type	_ZSt24__uninitialized_copy_auxIPiS0_ET0_T_S2_S1_St11__true_type,@function
	.ent	_ZSt24__uninitialized_copy_auxIPiS0_ET0_T_S2_S1_St11__true_type # @_ZSt24__uninitialized_copy_auxIPiS0_ET0_T_S2_S1_St11__true_type
_ZSt24__uninitialized_copy_auxIPiS0_ET0_T_S2_S1_St11__true_type:
	.cfi_startproc
	.frame	$sp,56,$ra
	.mask 	0x80000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -56
$tmp183:
	.cfi_def_cfa_offset 56
	sw	$ra, 52($sp)            # 4-byte Folded Spill
$tmp184:
	.cfi_offset 31, -4
	.cprestore	16
	sw	$4, 48($sp)
	sw	$5, 40($sp)
	sw	$6, 32($sp)
	lw	$5, 40($sp)
	lw	$4, 48($sp)
	lw	$25, %call16(_ZSt4copyIPiS0_ET0_T_S2_S1_)($gp)
	jalr	$25
	nop
	lw	$gp, 16($sp)
	lw	$ra, 52($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 56
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_ZSt24__uninitialized_copy_auxIPiS0_ET0_T_S2_S1_St11__true_type
$tmp185:
	.size	_ZSt24__uninitialized_copy_auxIPiS0_ET0_T_S2_S1_St11__true_type, ($tmp185)-_ZSt24__uninitialized_copy_auxIPiS0_ET0_T_S2_S1_St11__true_type
	.cfi_endproc

	.section	.text._ZSt4copyIPiS0_ET0_T_S2_S1_,"axG",@progbits,_ZSt4copyIPiS0_ET0_T_S2_S1_,comdat
	.weak	_ZSt4copyIPiS0_ET0_T_S2_S1_
	.align	2
	.type	_ZSt4copyIPiS0_ET0_T_S2_S1_,@function
	.ent	_ZSt4copyIPiS0_ET0_T_S2_S1_ # @_ZSt4copyIPiS0_ET0_T_S2_S1_
_ZSt4copyIPiS0_ET0_T_S2_S1_:
	.cfi_startproc
	.frame	$sp,56,$ra
	.mask 	0x80000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -56
$tmp188:
	.cfi_def_cfa_offset 56
	sw	$ra, 52($sp)            # 4-byte Folded Spill
$tmp189:
	.cfi_offset 31, -4
	.cprestore	16
	sw	$4, 48($sp)
	sw	$5, 40($sp)
	sw	$6, 32($sp)
	addiu	$2, $zero, 0
	sb	$2, 28($sp)
	sb	$zero, 24($sp)
	lw	$6, 32($sp)
	lw	$5, 40($sp)
	lw	$4, 48($sp)
	lw	$25, %call16(_ZNSt13__copy_normalILb0ELb0EE8__copy_nIPiS2_EET0_T_S4_S3_)($gp)
	jalr	$25
	nop
	lw	$gp, 16($sp)
	lw	$ra, 52($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 56
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_ZSt4copyIPiS0_ET0_T_S2_S1_
$tmp190:
	.size	_ZSt4copyIPiS0_ET0_T_S2_S1_, ($tmp190)-_ZSt4copyIPiS0_ET0_T_S2_S1_
	.cfi_endproc

	.section	.text._ZNSt13__copy_normalILb0ELb0EE8__copy_nIPiS2_EET0_T_S4_S3_,"axG",@progbits,_ZNSt13__copy_normalILb0ELb0EE8__copy_nIPiS2_EET0_T_S4_S3_,comdat
	.weak	_ZNSt13__copy_normalILb0ELb0EE8__copy_nIPiS2_EET0_T_S4_S3_
	.align	2
	.type	_ZNSt13__copy_normalILb0ELb0EE8__copy_nIPiS2_EET0_T_S4_S3_,@function
	.ent	_ZNSt13__copy_normalILb0ELb0EE8__copy_nIPiS2_EET0_T_S4_S3_ # @_ZNSt13__copy_normalILb0ELb0EE8__copy_nIPiS2_EET0_T_S4_S3_
_ZNSt13__copy_normalILb0ELb0EE8__copy_nIPiS2_EET0_T_S4_S3_:
	.cfi_startproc
	.frame	$sp,48,$ra
	.mask 	0x80000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -48
$tmp193:
	.cfi_def_cfa_offset 48
	sw	$ra, 44($sp)            # 4-byte Folded Spill
$tmp194:
	.cfi_offset 31, -4
	.cprestore	16
	sw	$4, 40($sp)
	sw	$5, 32($sp)
	sw	$6, 24($sp)
	lw	$5, 32($sp)
	lw	$4, 40($sp)
	lw	$25, %call16(_ZSt10__copy_auxIPiS0_ET0_T_S2_S1_)($gp)
	jalr	$25
	nop
	lw	$gp, 16($sp)
	lw	$ra, 44($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 48
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_ZNSt13__copy_normalILb0ELb0EE8__copy_nIPiS2_EET0_T_S4_S3_
$tmp195:
	.size	_ZNSt13__copy_normalILb0ELb0EE8__copy_nIPiS2_EET0_T_S4_S3_, ($tmp195)-_ZNSt13__copy_normalILb0ELb0EE8__copy_nIPiS2_EET0_T_S4_S3_
	.cfi_endproc

	.section	.text._ZSt10__copy_auxIPiS0_ET0_T_S2_S1_,"axG",@progbits,_ZSt10__copy_auxIPiS0_ET0_T_S2_S1_,comdat
	.weak	_ZSt10__copy_auxIPiS0_ET0_T_S2_S1_
	.align	2
	.type	_ZSt10__copy_auxIPiS0_ET0_T_S2_S1_,@function
	.ent	_ZSt10__copy_auxIPiS0_ET0_T_S2_S1_ # @_ZSt10__copy_auxIPiS0_ET0_T_S2_S1_
_ZSt10__copy_auxIPiS0_ET0_T_S2_S1_:
	.cfi_startproc
	.frame	$sp,56,$ra
	.mask 	0x80000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -56
$tmp198:
	.cfi_def_cfa_offset 56
	sw	$ra, 52($sp)            # 4-byte Folded Spill
$tmp199:
	.cfi_offset 31, -4
	.cprestore	16
	sw	$4, 48($sp)
	sw	$5, 40($sp)
	sw	$6, 32($sp)
	addiu	$2, $zero, 1
	sb	$2, 28($sp)
	lw	$6, 32($sp)
	lw	$5, 40($sp)
	lw	$4, 48($sp)
	lw	$25, %call16(_ZNSt6__copyILb1ESt26random_access_iterator_tagE4copyIiEEPT_PKS3_S6_S4_)($gp)
	jalr	$25
	nop
	lw	$gp, 16($sp)
	lw	$ra, 52($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 56
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_ZSt10__copy_auxIPiS0_ET0_T_S2_S1_
$tmp200:
	.size	_ZSt10__copy_auxIPiS0_ET0_T_S2_S1_, ($tmp200)-_ZSt10__copy_auxIPiS0_ET0_T_S2_S1_
	.cfi_endproc

	.section	.text._ZNSt6__copyILb1ESt26random_access_iterator_tagE4copyIiEEPT_PKS3_S6_S4_,"axG",@progbits,_ZNSt6__copyILb1ESt26random_access_iterator_tagE4copyIiEEPT_PKS3_S6_S4_,comdat
	.weak	_ZNSt6__copyILb1ESt26random_access_iterator_tagE4copyIiEEPT_PKS3_S6_S4_
	.align	2
	.type	_ZNSt6__copyILb1ESt26random_access_iterator_tagE4copyIiEEPT_PKS3_S6_S4_,@function
	.ent	_ZNSt6__copyILb1ESt26random_access_iterator_tagE4copyIiEEPT_PKS3_S6_S4_ # @_ZNSt6__copyILb1ESt26random_access_iterator_tagE4copyIiEEPT_PKS3_S6_S4_
_ZNSt6__copyILb1ESt26random_access_iterator_tagE4copyIiEEPT_PKS3_S6_S4_:
	.cfi_startproc
	.frame	$sp,56,$ra
	.mask 	0x80010000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -56
$tmp203:
	.cfi_def_cfa_offset 56
	sw	$ra, 52($sp)            # 4-byte Folded Spill
	sw	$16, 48($sp)            # 4-byte Folded Spill
$tmp204:
	.cfi_offset 31, -4
$tmp205:
	.cfi_offset 16, -8
	.cprestore	16
	sw	$4, 40($sp)
	sw	$5, 32($sp)
	sw	$6, 24($sp)
	lw	$5, 40($sp)
	lw	$2, 32($sp)
	subu	$2, $2, $5
	addiu	$16, $zero, -4
	and	$2, $2, $16
	lw	$25, %call16(memmove)($gp)
	addu	$4, $zero, $6
	addu	$6, $zero, $2
	jalr	$25
	nop
	lw	$gp, 16($sp)
	lw	$2, 40($sp)
	lw	$3, 32($sp)
	subu	$2, $3, $2
	and	$2, $2, $16
	lw	$3, 24($sp)
	addu	$2, $3, $2
	lw	$16, 48($sp)            # 4-byte Folded Reload
	lw	$ra, 52($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 56
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_ZNSt6__copyILb1ESt26random_access_iterator_tagE4copyIiEEPT_PKS3_S6_S4_
$tmp206:
	.size	_ZNSt6__copyILb1ESt26random_access_iterator_tagE4copyIiEEPT_PKS3_S6_S4_, ($tmp206)-_ZNSt6__copyILb1ESt26random_access_iterator_tagE4copyIiEEPT_PKS3_S6_S4_
	.cfi_endproc

	.section	.text._ZN9__gnu_cxx13new_allocatorIiE8allocateEmPKv,"axG",@progbits,_ZN9__gnu_cxx13new_allocatorIiE8allocateEmPKv,comdat
	.weak	_ZN9__gnu_cxx13new_allocatorIiE8allocateEmPKv
	.align	2
	.type	_ZN9__gnu_cxx13new_allocatorIiE8allocateEmPKv,@function
	.ent	_ZN9__gnu_cxx13new_allocatorIiE8allocateEmPKv # @_ZN9__gnu_cxx13new_allocatorIiE8allocateEmPKv
_ZN9__gnu_cxx13new_allocatorIiE8allocateEmPKv:
	.cfi_startproc
	.frame	$sp,56,$ra
	.mask 	0x80030000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -56
$tmp209:
	.cfi_def_cfa_offset 56
	sw	$ra, 52($sp)            # 4-byte Folded Spill
	sw	$17, 48($sp)            # 4-byte Folded Spill
	sw	$16, 44($sp)            # 4-byte Folded Spill
$tmp210:
	.cfi_offset 31, -4
$tmp211:
	.cfi_offset 17, -8
$tmp212:
	.cfi_offset 16, -12
	.cprestore	16
	sw	$4, 40($sp)
	sw	$7, 36($sp)
	sw	$6, 32($sp)
	lw	$2, 72($sp)
	sw	$2, 24($sp)
	lw	$16, 32($sp)
	lw	$17, 36($sp)
	lw	$4, 40($sp)
	lw	$25, %call16(_ZNK9__gnu_cxx13new_allocatorIiE8max_sizeEv)($gp)
	jalr	$25
	nop
	lw	$gp, 16($sp)
	sltu	$4, $3, $17
	xor	$3, $16, $2
	sltu	$2, $2, $16
	xori	$2, $2, 1
	xori	$4, $4, 1
	movz	$2, $4, $3
	beq	$2, $zero, $BB34_1
	nop
# BB#2:
	lw	$2, 32($sp)
	sll	$3, $2, 2
	lw	$2, 36($sp)
	srl	$4, $2, 30
	or	$4, $3, $4
	sll	$5, $2, 2
	lw	$25, %call16(_Znwm)($gp)
	jalr	$25
	nop
	lw	$gp, 16($sp)
	lw	$16, 44($sp)            # 4-byte Folded Reload
	lw	$17, 48($sp)            # 4-byte Folded Reload
	lw	$ra, 52($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 56
	jr	$ra
	nop
$BB34_1:
	lw	$25, %call16(_ZSt17__throw_bad_allocv)($gp)
	jalr	$25
	nop
	lw	$gp, 16($sp)
	.set	macro
	.set	reorder
	.end	_ZN9__gnu_cxx13new_allocatorIiE8allocateEmPKv
$tmp213:
	.size	_ZN9__gnu_cxx13new_allocatorIiE8allocateEmPKv, ($tmp213)-_ZN9__gnu_cxx13new_allocatorIiE8allocateEmPKv
	.cfi_endproc

	.section	.text._ZNK9__gnu_cxx13new_allocatorIiE8max_sizeEv,"axG",@progbits,_ZNK9__gnu_cxx13new_allocatorIiE8max_sizeEv,comdat
	.weak	_ZNK9__gnu_cxx13new_allocatorIiE8max_sizeEv
	.align	2
	.type	_ZNK9__gnu_cxx13new_allocatorIiE8max_sizeEv,@function
	.ent	_ZNK9__gnu_cxx13new_allocatorIiE8max_sizeEv # @_ZNK9__gnu_cxx13new_allocatorIiE8max_sizeEv
_ZNK9__gnu_cxx13new_allocatorIiE8max_sizeEv:
	.cfi_startproc
	.frame	$sp,8,$ra
	.mask 	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -8
$tmp215:
	.cfi_def_cfa_offset 8
	sw	$4, 0($sp)
	lui	$2, 16383
	ori	$2, $2, 65535
	addiu	$3, $zero, -1
	addiu	$sp, $sp, 8
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_ZNK9__gnu_cxx13new_allocatorIiE8max_sizeEv
$tmp216:
	.size	_ZNK9__gnu_cxx13new_allocatorIiE8max_sizeEv, ($tmp216)-_ZNK9__gnu_cxx13new_allocatorIiE8max_sizeEv
	.cfi_endproc

	.section	.text._ZNKSt12_Vector_baseIiSaIiEE19_M_get_Tp_allocatorEv,"axG",@progbits,_ZNKSt12_Vector_baseIiSaIiEE19_M_get_Tp_allocatorEv,comdat
	.weak	_ZNKSt12_Vector_baseIiSaIiEE19_M_get_Tp_allocatorEv
	.align	2
	.type	_ZNKSt12_Vector_baseIiSaIiEE19_M_get_Tp_allocatorEv,@function
	.ent	_ZNKSt12_Vector_baseIiSaIiEE19_M_get_Tp_allocatorEv # @_ZNKSt12_Vector_baseIiSaIiEE19_M_get_Tp_allocatorEv
_ZNKSt12_Vector_baseIiSaIiEE19_M_get_Tp_allocatorEv:
	.cfi_startproc
	.frame	$sp,8,$ra
	.mask 	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -8
$tmp218:
	.cfi_def_cfa_offset 8
	sw	$4, 0($sp)
	addu	$2, $zero, $4
	addiu	$sp, $sp, 8
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_ZNKSt12_Vector_baseIiSaIiEE19_M_get_Tp_allocatorEv
$tmp219:
	.size	_ZNKSt12_Vector_baseIiSaIiEE19_M_get_Tp_allocatorEv, ($tmp219)-_ZNKSt12_Vector_baseIiSaIiEE19_M_get_Tp_allocatorEv
	.cfi_endproc

	.section	.text._ZNSt22__copy_backward_normalILb0ELb0EE10__copy_b_nIPiS2_EET0_T_S4_S3_,"axG",@progbits,_ZNSt22__copy_backward_normalILb0ELb0EE10__copy_b_nIPiS2_EET0_T_S4_S3_,comdat
	.weak	_ZNSt22__copy_backward_normalILb0ELb0EE10__copy_b_nIPiS2_EET0_T_S4_S3_
	.align	2
	.type	_ZNSt22__copy_backward_normalILb0ELb0EE10__copy_b_nIPiS2_EET0_T_S4_S3_,@function
	.ent	_ZNSt22__copy_backward_normalILb0ELb0EE10__copy_b_nIPiS2_EET0_T_S4_S3_ # @_ZNSt22__copy_backward_normalILb0ELb0EE10__copy_b_nIPiS2_EET0_T_S4_S3_
_ZNSt22__copy_backward_normalILb0ELb0EE10__copy_b_nIPiS2_EET0_T_S4_S3_:
	.cfi_startproc
	.frame	$sp,48,$ra
	.mask 	0x80000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -48
$tmp222:
	.cfi_def_cfa_offset 48
	sw	$ra, 44($sp)            # 4-byte Folded Spill
$tmp223:
	.cfi_offset 31, -4
	.cprestore	16
	sw	$4, 40($sp)
	sw	$5, 32($sp)
	sw	$6, 24($sp)
	lw	$5, 32($sp)
	lw	$4, 40($sp)
	lw	$25, %call16(_ZSt19__copy_backward_auxIPiS0_ET0_T_S2_S1_)($gp)
	jalr	$25
	nop
	lw	$gp, 16($sp)
	lw	$ra, 44($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 48
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_ZNSt22__copy_backward_normalILb0ELb0EE10__copy_b_nIPiS2_EET0_T_S4_S3_
$tmp224:
	.size	_ZNSt22__copy_backward_normalILb0ELb0EE10__copy_b_nIPiS2_EET0_T_S4_S3_, ($tmp224)-_ZNSt22__copy_backward_normalILb0ELb0EE10__copy_b_nIPiS2_EET0_T_S4_S3_
	.cfi_endproc

	.section	.text._ZSt19__copy_backward_auxIPiS0_ET0_T_S2_S1_,"axG",@progbits,_ZSt19__copy_backward_auxIPiS0_ET0_T_S2_S1_,comdat
	.weak	_ZSt19__copy_backward_auxIPiS0_ET0_T_S2_S1_
	.align	2
	.type	_ZSt19__copy_backward_auxIPiS0_ET0_T_S2_S1_,@function
	.ent	_ZSt19__copy_backward_auxIPiS0_ET0_T_S2_S1_ # @_ZSt19__copy_backward_auxIPiS0_ET0_T_S2_S1_
_ZSt19__copy_backward_auxIPiS0_ET0_T_S2_S1_:
	.cfi_startproc
	.frame	$sp,56,$ra
	.mask 	0x80000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -56
$tmp227:
	.cfi_def_cfa_offset 56
	sw	$ra, 52($sp)            # 4-byte Folded Spill
$tmp228:
	.cfi_offset 31, -4
	.cprestore	16
	sw	$4, 48($sp)
	sw	$5, 40($sp)
	sw	$6, 32($sp)
	addiu	$2, $zero, 1
	sb	$2, 28($sp)
	lw	$6, 32($sp)
	lw	$5, 40($sp)
	lw	$4, 48($sp)
	lw	$25, %call16(_ZNSt15__copy_backwardILb1ESt26random_access_iterator_tagE8__copy_bIiEEPT_PKS3_S6_S4_)($gp)
	jalr	$25
	nop
	lw	$gp, 16($sp)
	lw	$ra, 52($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 56
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_ZSt19__copy_backward_auxIPiS0_ET0_T_S2_S1_
$tmp229:
	.size	_ZSt19__copy_backward_auxIPiS0_ET0_T_S2_S1_, ($tmp229)-_ZSt19__copy_backward_auxIPiS0_ET0_T_S2_S1_
	.cfi_endproc

	.section	.text._ZNSt15__copy_backwardILb1ESt26random_access_iterator_tagE8__copy_bIiEEPT_PKS3_S6_S4_,"axG",@progbits,_ZNSt15__copy_backwardILb1ESt26random_access_iterator_tagE8__copy_bIiEEPT_PKS3_S6_S4_,comdat
	.weak	_ZNSt15__copy_backwardILb1ESt26random_access_iterator_tagE8__copy_bIiEEPT_PKS3_S6_S4_
	.align	2
	.type	_ZNSt15__copy_backwardILb1ESt26random_access_iterator_tagE8__copy_bIiEEPT_PKS3_S6_S4_,@function
	.ent	_ZNSt15__copy_backwardILb1ESt26random_access_iterator_tagE8__copy_bIiEEPT_PKS3_S6_S4_ # @_ZNSt15__copy_backwardILb1ESt26random_access_iterator_tagE8__copy_bIiEEPT_PKS3_S6_S4_
_ZNSt15__copy_backwardILb1ESt26random_access_iterator_tagE8__copy_bIiEEPT_PKS3_S6_S4_:
	.cfi_startproc
	.frame	$sp,56,$ra
	.mask 	0x80000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -56
$tmp232:
	.cfi_def_cfa_offset 56
	sw	$ra, 52($sp)            # 4-byte Folded Spill
$tmp233:
	.cfi_offset 31, -4
	.cprestore	16
	sw	$4, 48($sp)
	sw	$5, 40($sp)
	sw	$6, 32($sp)
	lw	$2, 48($sp)
	lw	$3, 40($sp)
	sltu	$4, $3, $2
	addiu	$5, $zero, 0
	addu	$4, $4, $5
	subu	$4, $zero, $4
	sra	$5, $4, 2
	sw	$5, 24($sp)
	subu	$2, $3, $2
	sll	$3, $4, 30
	srl	$4, $2, 2
	or	$3, $4, $3
	sw	$3, 28($sp)
	sll	$3, $3, 2
	lw	$4, 32($sp)
	subu	$4, $4, $3
	addiu	$3, $zero, -4
	and	$6, $2, $3
	lw	$5, 48($sp)
	lw	$25, %call16(memmove)($gp)
	jalr	$25
	nop
	lw	$gp, 16($sp)
	lw	$2, 28($sp)
	sll	$2, $2, 2
	lw	$3, 32($sp)
	subu	$2, $3, $2
	lw	$ra, 52($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 56
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_ZNSt15__copy_backwardILb1ESt26random_access_iterator_tagE8__copy_bIiEEPT_PKS3_S6_S4_
$tmp234:
	.size	_ZNSt15__copy_backwardILb1ESt26random_access_iterator_tagE8__copy_bIiEEPT_PKS3_S6_S4_, ($tmp234)-_ZNSt15__copy_backwardILb1ESt26random_access_iterator_tagE8__copy_bIiEEPT_PKS3_S6_S4_
	.cfi_endproc

	.section	.text._ZNSt6vectorIiSaIiEED2Ev,"axG",@progbits,_ZNSt6vectorIiSaIiEED2Ev,comdat
	.weak	_ZNSt6vectorIiSaIiEED2Ev
	.align	2
	.type	_ZNSt6vectorIiSaIiEED2Ev,@function
	.ent	_ZNSt6vectorIiSaIiEED2Ev # @_ZNSt6vectorIiSaIiEED2Ev
_ZNSt6vectorIiSaIiEED2Ev:
	.cfi_startproc
	.cfi_personality 0, __gxx_personality_v0
$eh_func_begin40:
	.cfi_lsda 0, $exception40
	.frame	$sp,64,$ra
	.mask 	0x800f0000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -64
$tmp246:
	.cfi_def_cfa_offset 64
	sw	$ra, 60($sp)            # 4-byte Folded Spill
	sw	$19, 56($sp)            # 4-byte Folded Spill
	sw	$18, 52($sp)            # 4-byte Folded Spill
	sw	$17, 48($sp)            # 4-byte Folded Spill
	sw	$16, 44($sp)            # 4-byte Folded Spill
$tmp247:
	.cfi_offset 31, -4
$tmp248:
	.cfi_offset 19, -8
$tmp249:
	.cfi_offset 18, -12
$tmp250:
	.cfi_offset 17, -16
$tmp251:
	.cfi_offset 16, -20
	.cprestore	16
	addu	$16, $zero, $4
	sw	$16, 40($sp)
	lw	$17, 4($16)
	lw	$18, 0($16)
$tmp235:
	lw	$25, %call16(_ZNSt12_Vector_baseIiSaIiEE19_M_get_Tp_allocatorEv)($gp)
	jalr	$25
	nop
	lw	$gp, 16($sp)
$tmp236:
# BB#1:
	lw	$25, %call16(_ZNSaIiEC1ERKS_)($gp)
	addiu	$19, $sp, 32
	addu	$4, $zero, $19
	addu	$5, $zero, $2
	jalr	$25
	nop
	lw	$gp, 16($sp)
$tmp238:
	lw	$25, %call16(_ZSt8_DestroyIPiiEvT_S1_SaIT0_E)($gp)
	addu	$4, $zero, $18
	addu	$5, $zero, $17
	addu	$6, $zero, $19
	jalr	$25
	nop
	lw	$gp, 16($sp)
$tmp239:
# BB#2:
	lw	$25, %call16(_ZNSaIiED1Ev)($gp)
	addiu	$4, $sp, 32
	jalr	$25
	nop
	lw	$gp, 16($sp)
	lw	$25, %call16(_ZNSt12_Vector_baseIiSaIiEED2Ev)($gp)
	addu	$4, $zero, $16
	jalr	$25
	nop
	lw	$gp, 16($sp)
	lw	$16, 44($sp)            # 4-byte Folded Reload
	lw	$17, 48($sp)            # 4-byte Folded Reload
	lw	$18, 52($sp)            # 4-byte Folded Reload
	lw	$19, 56($sp)            # 4-byte Folded Reload
	lw	$ra, 60($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 64
	jr	$ra
	nop
$BB40_3:
$tmp237:
	lw	$gp, 16($sp)
	sw	$4, 28($sp)
	sw	$5, 24($sp)
	b	$BB40_5
	nop
$BB40_4:
$tmp240:
	lw	$gp, 16($sp)
	sw	$4, 28($sp)
	sw	$5, 24($sp)
	lw	$25, %call16(_ZNSaIiED1Ev)($gp)
	addiu	$4, $sp, 32
	jalr	$25
	nop
	lw	$gp, 16($sp)
$BB40_5:
$tmp241:
	lw	$25, %call16(_ZNSt12_Vector_baseIiSaIiEED2Ev)($gp)
	addu	$4, $zero, $16
	jalr	$25
	nop
	lw	$gp, 16($sp)
$tmp242:
# BB#6:
	lw	$4, 28($sp)
	lw	$25, %call16(_Unwind_Resume)($gp)
	jalr	$25
	nop
	lw	$gp, 16($sp)
$BB40_7:
$tmp243:
	lw	$gp, 16($sp)
	lw	$25, %call16(_ZSt9terminatev)($gp)
	jalr	$25
	nop
	lw	$gp, 16($sp)
	.set	macro
	.set	reorder
	.end	_ZNSt6vectorIiSaIiEED2Ev
$tmp252:
	.size	_ZNSt6vectorIiSaIiEED2Ev, ($tmp252)-_ZNSt6vectorIiSaIiEED2Ev
	.cfi_endproc
$eh_func_end40:
	.section	.gcc_except_table,"a",@progbits
	.align	2
GCC_except_table40:
$exception40:
	.byte	255                     # @LPStart Encoding = omit
	.byte	0                       # @TType Encoding = absptr
	.asciz	 "\326\200\200"         # @TType base offset
	.byte	3                       # Call site Encoding = udata4
	.byte	78                      # Call site table length
$set72 = ($tmp235)-($eh_func_begin40)   # >> Call Site 1 <<
	.4byte	($set72)
$set73 = ($tmp236)-($tmp235)            #   Call between $tmp235 and $tmp236
	.4byte	($set73)
$set74 = ($tmp237)-($eh_func_begin40)   #     jumps to $tmp237
	.4byte	($set74)
	.byte	0                       #   On action: cleanup
$set75 = ($tmp236)-($eh_func_begin40)   # >> Call Site 2 <<
	.4byte	($set75)
$set76 = ($tmp238)-($tmp236)            #   Call between $tmp236 and $tmp238
	.4byte	($set76)
	.4byte	0                       #     has no landing pad
	.byte	0                       #   On action: cleanup
$set77 = ($tmp238)-($eh_func_begin40)   # >> Call Site 3 <<
	.4byte	($set77)
$set78 = ($tmp239)-($tmp238)            #   Call between $tmp238 and $tmp239
	.4byte	($set78)
$set79 = ($tmp240)-($eh_func_begin40)   #     jumps to $tmp240
	.4byte	($set79)
	.byte	0                       #   On action: cleanup
$set80 = ($tmp239)-($eh_func_begin40)   # >> Call Site 4 <<
	.4byte	($set80)
$set81 = ($tmp241)-($tmp239)            #   Call between $tmp239 and $tmp241
	.4byte	($set81)
	.4byte	0                       #     has no landing pad
	.byte	0                       #   On action: cleanup
$set82 = ($tmp241)-($eh_func_begin40)   # >> Call Site 5 <<
	.4byte	($set82)
$set83 = ($tmp242)-($tmp241)            #   Call between $tmp241 and $tmp242
	.4byte	($set83)
$set84 = ($tmp243)-($eh_func_begin40)   #     jumps to $tmp243
	.4byte	($set84)
	.byte	1                       #   On action: 1
$set85 = ($tmp242)-($eh_func_begin40)   # >> Call Site 6 <<
	.4byte	($set85)
$set86 = ($eh_func_end40)-($tmp242)     #   Call between $tmp242 and $eh_func_end40
	.4byte	($set86)
	.4byte	0                       #     has no landing pad
	.byte	0                       #   On action: cleanup
	.byte	1                       # >> Action Record 1 <<
                                        #   Catch TypeInfo 1
	.byte	0                       #   No further actions
                                        # >> Catch TypeInfos <<
	.4byte	0                       # TypeInfo 1
	.align	2

	.section	.text._ZNSt12_Vector_baseIiSaIiEED2Ev,"axG",@progbits,_ZNSt12_Vector_baseIiSaIiEED2Ev,comdat
	.weak	_ZNSt12_Vector_baseIiSaIiEED2Ev
	.align	2
	.type	_ZNSt12_Vector_baseIiSaIiEED2Ev,@function
	.ent	_ZNSt12_Vector_baseIiSaIiEED2Ev # @_ZNSt12_Vector_baseIiSaIiEED2Ev
_ZNSt12_Vector_baseIiSaIiEED2Ev:
	.cfi_startproc
	.cfi_personality 0, __gxx_personality_v0
$eh_func_begin41:
	.cfi_lsda 0, $exception41
	.frame	$sp,48,$ra
	.mask 	0x80010000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -48
$tmp258:
	.cfi_def_cfa_offset 48
	sw	$ra, 44($sp)            # 4-byte Folded Spill
	sw	$16, 40($sp)            # 4-byte Folded Spill
$tmp259:
	.cfi_offset 31, -4
$tmp260:
	.cfi_offset 16, -8
	.cprestore	16
	addu	$16, $zero, $4
	sw	$16, 32($sp)
	lw	$5, 0($16)
	lw	$2, 8($16)
	sltu	$3, $2, $5
	addiu	$4, $zero, 0
	addu	$3, $3, $4
	subu	$3, $zero, $3
	subu	$2, $2, $5
	srl	$2, $2, 2
	sll	$4, $3, 30
	or	$7, $2, $4
	sra	$6, $3, 2
$tmp253:
	lw	$25, %call16(_ZNSt12_Vector_baseIiSaIiEE13_M_deallocateEPim)($gp)
	addu	$4, $zero, $16
	jalr	$25
	nop
	lw	$gp, 16($sp)
$tmp254:
# BB#1:
	lw	$25, %call16(_ZNSt12_Vector_baseIiSaIiEE12_Vector_implD1Ev)($gp)
	addu	$4, $zero, $16
	jalr	$25
	nop
	lw	$gp, 16($sp)
	lw	$16, 40($sp)            # 4-byte Folded Reload
	lw	$ra, 44($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 48
	jr	$ra
	nop
$BB41_2:
$tmp255:
	lw	$gp, 16($sp)
	sw	$4, 28($sp)
	sw	$5, 24($sp)
	lw	$25, %call16(_ZNSt12_Vector_baseIiSaIiEE12_Vector_implD1Ev)($gp)
	addu	$4, $zero, $16
	jalr	$25
	nop
	lw	$gp, 16($sp)
	lw	$4, 28($sp)
	lw	$25, %call16(_Unwind_Resume)($gp)
	jalr	$25
	nop
	lw	$gp, 16($sp)
	.set	macro
	.set	reorder
	.end	_ZNSt12_Vector_baseIiSaIiEED2Ev
$tmp261:
	.size	_ZNSt12_Vector_baseIiSaIiEED2Ev, ($tmp261)-_ZNSt12_Vector_baseIiSaIiEED2Ev
	.cfi_endproc
$eh_func_end41:
	.section	.gcc_except_table,"a",@progbits
	.align	2
GCC_except_table41:
$exception41:
	.byte	255                     # @LPStart Encoding = omit
	.byte	0                       # @TType Encoding = absptr
	.asciz	 "\234"                 # @TType base offset
	.byte	3                       # Call site Encoding = udata4
	.byte	26                      # Call site table length
$set87 = ($tmp253)-($eh_func_begin41)   # >> Call Site 1 <<
	.4byte	($set87)
$set88 = ($tmp254)-($tmp253)            #   Call between $tmp253 and $tmp254
	.4byte	($set88)
$set89 = ($tmp255)-($eh_func_begin41)   #     jumps to $tmp255
	.4byte	($set89)
	.byte	0                       #   On action: cleanup
$set90 = ($tmp254)-($eh_func_begin41)   # >> Call Site 2 <<
	.4byte	($set90)
$set91 = ($eh_func_end41)-($tmp254)     #   Call between $tmp254 and $eh_func_end41
	.4byte	($set91)
	.4byte	0                       #     has no landing pad
	.byte	0                       #   On action: cleanup
	.align	2

	.section	.text._ZNSt12_Vector_baseIiSaIiEE12_Vector_implD1Ev,"axG",@progbits,_ZNSt12_Vector_baseIiSaIiEE12_Vector_implD1Ev,comdat
	.weak	_ZNSt12_Vector_baseIiSaIiEE12_Vector_implD1Ev
	.align	2
	.type	_ZNSt12_Vector_baseIiSaIiEE12_Vector_implD1Ev,@function
	.ent	_ZNSt12_Vector_baseIiSaIiEE12_Vector_implD1Ev # @_ZNSt12_Vector_baseIiSaIiEE12_Vector_implD1Ev
_ZNSt12_Vector_baseIiSaIiEE12_Vector_implD1Ev:
	.cfi_startproc
	.frame	$sp,32,$ra
	.mask 	0x80000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -32
$tmp264:
	.cfi_def_cfa_offset 32
	sw	$ra, 28($sp)            # 4-byte Folded Spill
$tmp265:
	.cfi_offset 31, -4
	.cprestore	16
	sw	$4, 24($sp)
	lw	$25, %call16(_ZNSt12_Vector_baseIiSaIiEE12_Vector_implD2Ev)($gp)
	jalr	$25
	nop
	lw	$gp, 16($sp)
	lw	$ra, 28($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 32
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_ZNSt12_Vector_baseIiSaIiEE12_Vector_implD1Ev
$tmp266:
	.size	_ZNSt12_Vector_baseIiSaIiEE12_Vector_implD1Ev, ($tmp266)-_ZNSt12_Vector_baseIiSaIiEE12_Vector_implD1Ev
	.cfi_endproc

	.section	.text._ZNSt12_Vector_baseIiSaIiEE12_Vector_implD2Ev,"axG",@progbits,_ZNSt12_Vector_baseIiSaIiEE12_Vector_implD2Ev,comdat
	.weak	_ZNSt12_Vector_baseIiSaIiEE12_Vector_implD2Ev
	.align	2
	.type	_ZNSt12_Vector_baseIiSaIiEE12_Vector_implD2Ev,@function
	.ent	_ZNSt12_Vector_baseIiSaIiEE12_Vector_implD2Ev # @_ZNSt12_Vector_baseIiSaIiEE12_Vector_implD2Ev
_ZNSt12_Vector_baseIiSaIiEE12_Vector_implD2Ev:
	.cfi_startproc
	.frame	$sp,32,$ra
	.mask 	0x80000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -32
$tmp269:
	.cfi_def_cfa_offset 32
	sw	$ra, 28($sp)            # 4-byte Folded Spill
$tmp270:
	.cfi_offset 31, -4
	.cprestore	16
	sw	$4, 24($sp)
	lw	$25, %call16(_ZNSaIiED2Ev)($gp)
	jalr	$25
	nop
	lw	$gp, 16($sp)
	lw	$ra, 28($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 32
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_ZNSt12_Vector_baseIiSaIiEE12_Vector_implD2Ev
$tmp271:
	.size	_ZNSt12_Vector_baseIiSaIiEE12_Vector_implD2Ev, ($tmp271)-_ZNSt12_Vector_baseIiSaIiEE12_Vector_implD2Ev
	.cfi_endproc

	.section	.text._ZNSaIiED2Ev,"axG",@progbits,_ZNSaIiED2Ev,comdat
	.weak	_ZNSaIiED2Ev
	.align	2
	.type	_ZNSaIiED2Ev,@function
	.ent	_ZNSaIiED2Ev            # @_ZNSaIiED2Ev
_ZNSaIiED2Ev:
	.cfi_startproc
	.frame	$sp,32,$ra
	.mask 	0x80000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -32
$tmp274:
	.cfi_def_cfa_offset 32
	sw	$ra, 28($sp)            # 4-byte Folded Spill
$tmp275:
	.cfi_offset 31, -4
	.cprestore	16
	sw	$4, 24($sp)
	lw	$25, %call16(_ZN9__gnu_cxx13new_allocatorIiED2Ev)($gp)
	jalr	$25
	nop
	lw	$gp, 16($sp)
	lw	$ra, 28($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 32
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_ZNSaIiED2Ev
$tmp276:
	.size	_ZNSaIiED2Ev, ($tmp276)-_ZNSaIiED2Ev
	.cfi_endproc

	.section	.text._ZN9__gnu_cxx13new_allocatorIiED2Ev,"axG",@progbits,_ZN9__gnu_cxx13new_allocatorIiED2Ev,comdat
	.weak	_ZN9__gnu_cxx13new_allocatorIiED2Ev
	.align	2
	.type	_ZN9__gnu_cxx13new_allocatorIiED2Ev,@function
	.ent	_ZN9__gnu_cxx13new_allocatorIiED2Ev # @_ZN9__gnu_cxx13new_allocatorIiED2Ev
_ZN9__gnu_cxx13new_allocatorIiED2Ev:
	.cfi_startproc
	.frame	$sp,8,$ra
	.mask 	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -8
$tmp278:
	.cfi_def_cfa_offset 8
	sw	$4, 0($sp)
	addiu	$sp, $sp, 8
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_ZN9__gnu_cxx13new_allocatorIiED2Ev
$tmp279:
	.size	_ZN9__gnu_cxx13new_allocatorIiED2Ev, ($tmp279)-_ZN9__gnu_cxx13new_allocatorIiED2Ev
	.cfi_endproc

	.section	.text._ZNSt6vectorIiSaIiEEC2ERKS0_,"axG",@progbits,_ZNSt6vectorIiSaIiEEC2ERKS0_,comdat
	.weak	_ZNSt6vectorIiSaIiEEC2ERKS0_
	.align	2
	.type	_ZNSt6vectorIiSaIiEEC2ERKS0_,@function
	.ent	_ZNSt6vectorIiSaIiEEC2ERKS0_ # @_ZNSt6vectorIiSaIiEEC2ERKS0_
_ZNSt6vectorIiSaIiEEC2ERKS0_:
	.cfi_startproc
	.frame	$sp,40,$ra
	.mask 	0x80000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -40
$tmp282:
	.cfi_def_cfa_offset 40
	sw	$ra, 36($sp)            # 4-byte Folded Spill
$tmp283:
	.cfi_offset 31, -4
	.cprestore	16
	sw	$4, 32($sp)
	sw	$5, 24($sp)
	lw	$4, 32($sp)
	lw	$25, %call16(_ZNSt12_Vector_baseIiSaIiEEC2ERKS0_)($gp)
	jalr	$25
	nop
	lw	$gp, 16($sp)
	lw	$ra, 36($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 40
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_ZNSt6vectorIiSaIiEEC2ERKS0_
$tmp284:
	.size	_ZNSt6vectorIiSaIiEEC2ERKS0_, ($tmp284)-_ZNSt6vectorIiSaIiEEC2ERKS0_
	.cfi_endproc

	.section	.text._ZNSt12_Vector_baseIiSaIiEEC2ERKS0_,"axG",@progbits,_ZNSt12_Vector_baseIiSaIiEEC2ERKS0_,comdat
	.weak	_ZNSt12_Vector_baseIiSaIiEEC2ERKS0_
	.align	2
	.type	_ZNSt12_Vector_baseIiSaIiEEC2ERKS0_,@function
	.ent	_ZNSt12_Vector_baseIiSaIiEEC2ERKS0_ # @_ZNSt12_Vector_baseIiSaIiEEC2ERKS0_
_ZNSt12_Vector_baseIiSaIiEEC2ERKS0_:
	.cfi_startproc
	.frame	$sp,40,$ra
	.mask 	0x80000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -40
$tmp287:
	.cfi_def_cfa_offset 40
	sw	$ra, 36($sp)            # 4-byte Folded Spill
$tmp288:
	.cfi_offset 31, -4
	.cprestore	16
	sw	$4, 32($sp)
	sw	$5, 24($sp)
	lw	$4, 32($sp)
	lw	$25, %call16(_ZNSt12_Vector_baseIiSaIiEE12_Vector_implC1ERKS0_)($gp)
	jalr	$25
	nop
	lw	$gp, 16($sp)
	lw	$ra, 36($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 40
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_ZNSt12_Vector_baseIiSaIiEEC2ERKS0_
$tmp289:
	.size	_ZNSt12_Vector_baseIiSaIiEEC2ERKS0_, ($tmp289)-_ZNSt12_Vector_baseIiSaIiEEC2ERKS0_
	.cfi_endproc

	.section	.text._ZNSt12_Vector_baseIiSaIiEE12_Vector_implC1ERKS0_,"axG",@progbits,_ZNSt12_Vector_baseIiSaIiEE12_Vector_implC1ERKS0_,comdat
	.weak	_ZNSt12_Vector_baseIiSaIiEE12_Vector_implC1ERKS0_
	.align	2
	.type	_ZNSt12_Vector_baseIiSaIiEE12_Vector_implC1ERKS0_,@function
	.ent	_ZNSt12_Vector_baseIiSaIiEE12_Vector_implC1ERKS0_ # @_ZNSt12_Vector_baseIiSaIiEE12_Vector_implC1ERKS0_
_ZNSt12_Vector_baseIiSaIiEE12_Vector_implC1ERKS0_:
	.cfi_startproc
	.frame	$sp,40,$ra
	.mask 	0x80000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -40
$tmp292:
	.cfi_def_cfa_offset 40
	sw	$ra, 36($sp)            # 4-byte Folded Spill
$tmp293:
	.cfi_offset 31, -4
	.cprestore	16
	sw	$4, 32($sp)
	sw	$5, 24($sp)
	lw	$4, 32($sp)
	lw	$25, %call16(_ZNSt12_Vector_baseIiSaIiEE12_Vector_implC2ERKS0_)($gp)
	jalr	$25
	nop
	lw	$gp, 16($sp)
	lw	$ra, 36($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 40
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_ZNSt12_Vector_baseIiSaIiEE12_Vector_implC1ERKS0_
$tmp294:
	.size	_ZNSt12_Vector_baseIiSaIiEE12_Vector_implC1ERKS0_, ($tmp294)-_ZNSt12_Vector_baseIiSaIiEE12_Vector_implC1ERKS0_
	.cfi_endproc

	.section	.text._ZNSt12_Vector_baseIiSaIiEE12_Vector_implC2ERKS0_,"axG",@progbits,_ZNSt12_Vector_baseIiSaIiEE12_Vector_implC2ERKS0_,comdat
	.weak	_ZNSt12_Vector_baseIiSaIiEE12_Vector_implC2ERKS0_
	.align	2
	.type	_ZNSt12_Vector_baseIiSaIiEE12_Vector_implC2ERKS0_,@function
	.ent	_ZNSt12_Vector_baseIiSaIiEE12_Vector_implC2ERKS0_ # @_ZNSt12_Vector_baseIiSaIiEE12_Vector_implC2ERKS0_
_ZNSt12_Vector_baseIiSaIiEE12_Vector_implC2ERKS0_:
	.cfi_startproc
	.frame	$sp,48,$ra
	.mask 	0x80010000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -48
$tmp297:
	.cfi_def_cfa_offset 48
	sw	$ra, 44($sp)            # 4-byte Folded Spill
	sw	$16, 40($sp)            # 4-byte Folded Spill
$tmp298:
	.cfi_offset 31, -4
$tmp299:
	.cfi_offset 16, -8
	.cprestore	16
	sw	$4, 32($sp)
	sw	$5, 24($sp)
	lw	$16, 32($sp)
	lw	$25, %call16(_ZNSaIiEC2ERKS_)($gp)
	addu	$4, $zero, $16
	jalr	$25
	nop
	lw	$gp, 16($sp)
	sw	$zero, 0($16)
	sw	$zero, 4($16)
	sw	$zero, 8($16)
	lw	$16, 40($sp)            # 4-byte Folded Reload
	lw	$ra, 44($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 48
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_ZNSt12_Vector_baseIiSaIiEE12_Vector_implC2ERKS0_
$tmp300:
	.size	_ZNSt12_Vector_baseIiSaIiEE12_Vector_implC2ERKS0_, ($tmp300)-_ZNSt12_Vector_baseIiSaIiEE12_Vector_implC2ERKS0_
	.cfi_endproc

	.section	.text._ZNSaIiEC2Ev,"axG",@progbits,_ZNSaIiEC2Ev,comdat
	.weak	_ZNSaIiEC2Ev
	.align	2
	.type	_ZNSaIiEC2Ev,@function
	.ent	_ZNSaIiEC2Ev            # @_ZNSaIiEC2Ev
_ZNSaIiEC2Ev:
	.cfi_startproc
	.frame	$sp,32,$ra
	.mask 	0x80000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -32
$tmp303:
	.cfi_def_cfa_offset 32
	sw	$ra, 28($sp)            # 4-byte Folded Spill
$tmp304:
	.cfi_offset 31, -4
	.cprestore	16
	sw	$4, 24($sp)
	lw	$25, %call16(_ZN9__gnu_cxx13new_allocatorIiEC2Ev)($gp)
	jalr	$25
	nop
	lw	$gp, 16($sp)
	lw	$ra, 28($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 32
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_ZNSaIiEC2Ev
$tmp305:
	.size	_ZNSaIiEC2Ev, ($tmp305)-_ZNSaIiEC2Ev
	.cfi_endproc

	.section	.text._ZN9__gnu_cxx13new_allocatorIiEC2Ev,"axG",@progbits,_ZN9__gnu_cxx13new_allocatorIiEC2Ev,comdat
	.weak	_ZN9__gnu_cxx13new_allocatorIiEC2Ev
	.align	2
	.type	_ZN9__gnu_cxx13new_allocatorIiEC2Ev,@function
	.ent	_ZN9__gnu_cxx13new_allocatorIiEC2Ev # @_ZN9__gnu_cxx13new_allocatorIiEC2Ev
_ZN9__gnu_cxx13new_allocatorIiEC2Ev:
	.cfi_startproc
	.frame	$sp,8,$ra
	.mask 	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -8
$tmp307:
	.cfi_def_cfa_offset 8
	sw	$4, 0($sp)
	addiu	$sp, $sp, 8
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_ZN9__gnu_cxx13new_allocatorIiEC2Ev
$tmp308:
	.size	_ZN9__gnu_cxx13new_allocatorIiEC2Ev, ($tmp308)-_ZN9__gnu_cxx13new_allocatorIiEC2Ev
	.cfi_endproc

	.type	gI,@object              # @gI
	.section	.sdata,"aw",@progbits
	.globl	gI
	.align	2
gI:
	.4byte	100                     # 0x64
	.size	gI, 4

	.type	$.str,@object           # @.str
	.section	.rodata.str1.1,"aMS",@progbits,1
$.str:
	.asciz	 "vector::_M_insert_aux"
	.size	$.str, 22


