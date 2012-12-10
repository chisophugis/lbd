	.section .mdebug.abi32
	.previous
	.file	"ch4_2.bc"
	.text
	.globl	main
	.align	2
	.type	main,@function
	.ent	main                    # @main
main:
	.frame	$sp,72,$lr
	.mask 	0x00000000,0
	.set	noreorder
	.set	nomacro
# BB#0:                                 # %entry
	addiu	$sp, $sp, -72
	addiu	$2, $zero, 0
	st	$2, 68($sp)
	addiu	$3, $zero, 5
	st	$3, 64($sp)
	addiu	$3, $zero, 2
	st	$3, 60($sp)
	st	$2, 56($sp)
	st	$2, 52($sp)
	st	$2, 20($sp)
	addiu	$3, $zero, -5
	st	$3, 16($sp)
	st	$2, 12($sp)
	st	$2, 8($sp)
	lw	$2, 60($sp)
	lw	$3, 64($sp)
	add	$2, $3, $2
	st	$2, 56($sp)
	lw	$2, 60($sp)
	lw	$3, 64($sp)
	sub	$2, $3, $2
	st	$2, 52($sp)
	lw	$2, 60($sp)
	lw	$3, 64($sp)
	mul	$2, $3, $2
	st	$2, 48($sp)
	lw	$2, 60($sp)
	lw	$3, 64($sp)
	div	$2, $3, $2
	st	$2, 44($sp)
	lw	$2, 60($sp)
	lw	$3, 64($sp)
	and	$2, $3, $2
	st	$2, 40($sp)
	lw	$2, 60($sp)
	lw	$3, 64($sp)
	or	$2, $3, $2
	st	$2, 36($sp)
	lw	$2, 60($sp)
	lw	$3, 64($sp)
	xor	$2, $3, $2
	st	$2, 32($sp)
	lw	$2, 64($sp)
	shl	$2, $2, 2
	st	$2, 28($sp)
	lw	$2, 16($sp)
	shl	$2, $2, 2
	st	$2, 4($sp)
	lw	$2, 16($sp)
	shr	$2, $2, 2
	st	$2, 12($sp)
	addiu	$sp, $sp, 72
	ret	$lr
	.set	macro
	.set	reorder
	.end	main
$tmp1:
	.size	main, ($tmp1)-main


