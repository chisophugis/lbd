	.section .mdebug.abi32
	.previous
	.file	"ch_test_8_1.bc"
	.text
	.globl	main
	.align	2
	.type	main,@function
	.ent	main                    # @main
main:
	.cfi_startproc
	.frame	$sp,16,$ra
	.mask 	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -16
$tmp1:
	.cfi_def_cfa_offset 16
	sw	$zero, 12($sp)
	addiu	$2, $zero, 12
	sb	$2, 8($sp)
	sb	$2, 9($sp)
	addiu	$2, $zero, 2
	sb	$2, 10($sp)
	lbu	$2, 9($sp)
	sb	$2, 4($sp)
	addu	$2, $zero, $zero
	addiu	$sp, $sp, 16
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	main
$tmp2:
	.size	main, ($tmp2)-main
	.cfi_endproc


