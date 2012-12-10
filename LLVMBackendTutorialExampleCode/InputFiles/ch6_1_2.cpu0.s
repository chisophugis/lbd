	.section .mdebug.abi32
	.previous
	.file	"ch6_1_2.bc"
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
	addiu	$3, $zero, 5
	st	$3, 8($sp)
	st	$2, 4($sp)
	addiu	$3, $sp, 8
	st	$3, 0($sp)
	lw	$3, 8($sp)
	xor	$4, $3, $2
	addiu	$5, $zero, 1
	xor	$4, $4, $5
	and	$4, $4, $5
	st	$4, 4($sp)
	cmp	$3, $2
	jeq	$BB0_2
	jmp	$BB0_1
$BB0_2:                                 # %if.else
	addiu	$2, $zero, -1
	lw	$3, 4($sp)
	cmp	$3, $2
	jgt	$BB0_4
	jmp	$BB0_3
$BB0_4:                                 # %if.else3
	addiu	$2, $zero, 1
	lw	$3, 4($sp)
	cmp	$3, $2
	jlt	$BB0_6
	jmp	$BB0_5
$BB0_5:                                 # %if.then5
	lw	$2, 8($sp)
	addiu	$3, $2, 1
	st	$3, 8($sp)
	st	$2, 8($sp)
	jmp	$BB0_8
$BB0_1:                                 # %if.then
	lw	$2, 4($sp)
	lw	$3, 8($sp)
	add	$2, $3, $2
	st	$2, 8($sp)
	jmp	$BB0_8
$BB0_3:                                 # %if.then2
	lw	$2, 8($sp)
	addiu	$3, $2, -1
	st	$3, 8($sp)
	st	$2, 8($sp)
	jmp	$BB0_8
$BB0_6:                                 # %if.else6
	addiu	$2, $zero, 0
	lw	$3, 4($sp)
	cmp	$3, $2
	jeq	$BB0_8
	jmp	$BB0_7
$BB0_7:                                 # %if.then8
	lw	$2, 4($sp)
	lw	$3, 8($sp)
	sub	$2, $3, $2
	st	$2, 8($sp)
$BB0_8:                                 # %if.end11
	addiu	$sp, $sp, 16
	ret	$lr
	.set	macro
	.set	reorder
	.end	main
$tmp1:
	.size	main, ($tmp1)-main


