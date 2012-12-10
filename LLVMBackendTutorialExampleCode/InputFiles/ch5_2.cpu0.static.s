	.section .mdebug.abi32
	.previous
	.file	"ch5_2.bc"
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
	ldi	$2, %hi(date)
	shl	$2, $2, 16
	ldi	$3, %lo(date)
	add	$2, $2, $3
	lw	$2, 8($2)
	st	$2, 8($sp)
	ldi	$2, %hi(a)
	shl	$2, $2, 16
	ldi	$3, %lo(a)
	add	$2, $2, $3
	lw	$2, 4($2)
	st	$2, 4($sp)
	addiu	$sp, $sp, 16
	ret	$lr
	.set	macro
	.set	reorder
	.end	main
$tmp1:
	.size	main, ($tmp1)-main

	.type	date,@object            # @date
	.data
	.globl	date
	.align	2
date:
	.4byte	2012                    # 0x7dc
	.4byte	10                      # 0xa
	.4byte	12                      # 0xc
	.size	date, 12

	.type	a,@object               # @a
	.globl	a
	.align	2
a:
	.4byte	2012                    # 0x7dc
	.4byte	10                      # 0xa
	.4byte	12                      # 0xc
	.size	a, 12


