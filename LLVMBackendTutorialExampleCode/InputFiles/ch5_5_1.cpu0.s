	.section .mdebug.abi32
	.previous
	.file	"ch5_5_1.bc"
	.text
	.globl	main
	.align	2
	.type	main,@function
	.ent	main                    # @main
main:
	.cfi_startproc
	.frame	$sp,24,$lr
	.mask 	0x00000000,0
	.set	noreorder
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -24
$tmp1:
	.cfi_def_cfa_offset 24
	addiu	$2, $zero, 0
	st	$2, 20($sp)
	addiu	$3, $zero, 1
	st	$3, 16($sp)
	addiu	$3, $zero, 2
	st	$3, 12($sp)
	st	$2, 8($sp)
	addiu	$3, $zero, -5
	st	$3, 4($sp)
	st	$2, 0($sp)
	lw	$2, 12($sp)
	lw	$3, 4($sp)
	udiv	$2, $3, $2
	st	$2, 0($sp)
	lw	$2, 16($sp)
	sra	$2, $2, 2
	st	$2, 8($sp)
	addiu	$sp, $sp, 24
	ret	$lr
	.set	macro
	.set	reorder
	.end	main
$tmp2:
	.size	main, ($tmp2)-main
	.cfi_endproc


