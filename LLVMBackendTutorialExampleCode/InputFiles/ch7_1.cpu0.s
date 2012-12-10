	.section .mdebug.abi32
	.previous
	.file	"ch7_1.bc"
	.text
	.globl	_Z5sum_iiiiiii
	.align	2
	.type	_Z5sum_iiiiiii,@function
	.ent	_Z5sum_iiiiiii          # @_Z5sum_iiiiiii
_Z5sum_iiiiiii:
	.cfi_startproc
	.frame	$sp,32,$lr
	.mask 	0x00000000,0
	.set	noreorder
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -32
$tmp1:
	.cfi_def_cfa_offset 32
	lw	$2, 32($sp)
	st	$2, 28($sp)
	lw	$2, 36($sp)
	st	$2, 24($sp)
	lw	$2, 40($sp)
	st	$2, 20($sp)
	lw	$2, 44($sp)
	st	$2, 16($sp)
	lw	$2, 48($sp)
	st	$2, 12($sp)
	lw	$2, 52($sp)
	st	$2, 8($sp)
	lw	$3, 24($sp)
	lw	$4, 28($sp)
	add	$3, $4, $3
	lw	$4, 20($sp)
	add	$3, $3, $4
	lw	$4, 16($sp)
	add	$3, $3, $4
	lw	$4, 12($sp)
	add	$3, $3, $4
	add	$2, $3, $2
	st	$2, 4($sp)
	addiu	$sp, $sp, 32
	ret	$lr
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
	.frame	$sp,48,$lr
	.mask 	0x00004000,-4
	.set	noreorder
	.cpload	$t9
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -48
$tmp5:
	.cfi_def_cfa_offset 48
	BUNDLE                          # 4-byte Folded Spill
$tmp6:
	.cfi_offset 14, -4
	.cprestore	24
	addiu	$2, $zero, 0
	st	$2, 40($sp)
	addiu	$2, $zero, 6
	st	$2, 20($sp)
	addiu	$2, $zero, 5
	st	$2, 16($sp)
	addiu	$2, $zero, 4
	st	$2, 12($sp)
	addiu	$2, $zero, 3
	st	$2, 8($sp)
	addiu	$2, $zero, 2
	st	$2, 4($sp)
	addiu	$2, $zero, 1
	st	$2, 0($sp)
	lw	$6, %call24(_Z5sum_iiiiiii)($gp)
	jalr	$6
	lw	$gp, 24($sp)
	st	$2, 36($sp)
	lw	$lr, 44($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 48
	ret	$lr
	.set	macro
	.set	reorder
	.end	main
$tmp7:
	.size	main, ($tmp7)-main
	.cfi_endproc


