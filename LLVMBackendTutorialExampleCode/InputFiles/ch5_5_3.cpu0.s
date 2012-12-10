	.section .mdebug.abi32
	.previous
	.file	"ch5_5_3.bc"
	.text
	.globl	main
	.align	2
	.type	main,@function
	.ent	main                    # @main
main:
	.frame	$sp,8,$lr
	.mask 	0x00000000,0
	.set	noreorder
	.cpload	$t9
	.set	nomacro
# BB#0:                                 # %entry
	addiu	$sp, $sp, -8
	addiu	$2, $zero, 0
	st	$2, 4($sp)
	lw	$2, %got(date)($gp)
	addiu	$3, $2, 4
	st	$3, 0($sp)
	lw	$3, 4($2)
	addiu	$3, $3, 1
	st	$3, 4($2)
	lw	$2, %got(a)($gp)
	addiu	$2, $2, 8
	st	$2, 0($sp)
	addiu	$sp, $sp, 8
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
	.4byte	2011                    # 0x7db
	.4byte	11                      # 0xb
	.4byte	13                      # 0xd
	.size	a, 12


