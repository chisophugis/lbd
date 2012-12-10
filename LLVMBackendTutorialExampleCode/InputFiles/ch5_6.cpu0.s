	.section .mdebug.abi32
	.previous
	.file	"ch5_6.bc"
	.text
	.globl	main
	.align	2
	.type	main,@function
	.ent	main                    # @main
main:
	.frame	$sp,8,$lr
	.mask 	0x00000000,0
	.set	noreorder
	.set	nomacro
# BB#0:                                 # %entry
	addiu	$sp, $sp, -8
	addiu	$2, $zero, 0
	st	$2, 4($sp)
	addiu	$2, $zero, 11
	st	$2, 0($sp)
	addiu	$2, $zero, 10922
	shl	$2, $2, 16
	addiu	$3, $zero, 43691
	or	$3, $2, $3
	addiu	$2, $zero, 12
	mult	$2, $3
	mfhi	$3
	shr	$4, $3, 31
	sra	$3, $3, 1
	add	$3, $3, $4
	mul	$3, $3, $2
	sub	$2, $2, $3
	st	$2, 0($sp)
	addiu	$sp, $sp, 8
	ret	$lr
	.set	macro
	.set	reorder
	.end	main
$tmp1:
	.size	main, ($tmp1)-main


