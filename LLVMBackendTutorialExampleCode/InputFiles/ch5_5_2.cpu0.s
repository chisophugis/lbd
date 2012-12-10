	.section .mdebug.abi32
	.previous
	.file	"ch5_5_2.bc"
	.text
	.globl	main
	.align	2
	.type	main,@function
	.ent	main                    # @main
main:
	.frame	$sp,16,$lr
	.mask 	0x00000000,0
	.set	noreorder
	.set	nomacro
# BB#0:                                 # %entry
	addiu	$sp, $sp, -16
	addiu	$2, $zero, 0
	st	$2, 12($sp)
	addiu	$2, $zero, 3
	st	$2, 8($sp)
	addiu	$2, $sp, 8
	st	$2, 4($sp)
	addiu	$sp, $sp, 16
	ret	$lr
	.set	macro
	.set	reorder
	.end	main
$tmp1:
	.size	main, ($tmp1)-main


