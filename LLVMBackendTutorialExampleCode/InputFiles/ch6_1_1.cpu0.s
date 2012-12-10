	.section .mdebug.abi32
	.previous
	.file	"ch6_1_1.bc"
	.text
	.globl	main
	.align	2
	.type	main,@function
	.ent	main                    # @main
main:
	.frame	$sp,40,$lr
	.mask 	0x00000000,0
	.set	noreorder
	.set	nomacro
# BB#0:                                 # %entry
	addiu	$sp, $sp, -40
	addiu	$2, $zero, 0
	st	$2, 36($sp)
	st	$2, 32($sp)
	addiu	$3, $zero, 1
	st	$3, 28($sp)
	addiu	$3, $zero, 2
	st	$3, 24($sp)
	addiu	$3, $zero, 3
	st	$3, 20($sp)
	addiu	$3, $zero, 4
	st	$3, 16($sp)
	addiu	$3, $zero, 5
	st	$3, 12($sp)
	addiu	$3, $zero, 6
	st	$3, 8($sp)
	addiu	$3, $zero, 7
	st	$3, 4($sp)
	addiu	$3, $zero, 8
	st	$3, 0($sp)
	lw	$3, 32($sp)
	cmp	$3, $2
	jne	$BB0_2
	jmp	$BB0_1
$BB0_1:                                 # %if.then
	lw	$2, 32($sp)
	addiu	$2, $2, 1
	st	$2, 32($sp)
$BB0_2:                                 # %if.end
	addiu	$2, $zero, 0
	lw	$3, 28($sp)
	cmp	$3, $2
	jeq	$BB0_4
	jmp	$BB0_3
$BB0_3:                                 # %if.then2
	lw	$2, 28($sp)
	addiu	$2, $2, 1
	st	$2, 28($sp)
$BB0_4:                                 # %if.end4
	addiu	$2, $zero, 1
	lw	$3, 24($sp)
	cmp	$3, $2
	jlt	$BB0_6
	jmp	$BB0_5
$BB0_5:                                 # %if.then6
	lw	$2, 24($sp)
	addiu	$2, $2, 1
	st	$2, 24($sp)
$BB0_6:                                 # %if.end8
	addiu	$2, $zero, 0
	lw	$3, 20($sp)
	cmp	$3, $2
	jlt	$BB0_8
	jmp	$BB0_7
$BB0_7:                                 # %if.then10
	lw	$2, 20($sp)
	addiu	$2, $2, 1
	st	$2, 20($sp)
$BB0_8:                                 # %if.end12
	addiu	$2, $zero, -1
	lw	$3, 16($sp)
	cmp	$3, $2
	jgt	$BB0_10
	jmp	$BB0_9
$BB0_9:                                 # %if.then14
	lw	$2, 16($sp)
	addiu	$2, $2, 1
	st	$2, 16($sp)
$BB0_10:                                # %if.end16
	addiu	$2, $zero, 0
	lw	$3, 12($sp)
	cmp	$3, $2
	jgt	$BB0_12
	jmp	$BB0_11
$BB0_11:                                # %if.then18
	lw	$2, 12($sp)
	addiu	$2, $2, 1
	st	$2, 12($sp)
$BB0_12:                                # %if.end20
	addiu	$2, $zero, 1
	lw	$3, 8($sp)
	cmp	$3, $2
	jgt	$BB0_14
	jmp	$BB0_13
$BB0_13:                                # %if.then22
	lw	$2, 8($sp)
	addiu	$2, $2, 1
	st	$2, 8($sp)
$BB0_14:                                # %if.end24
	addiu	$2, $zero, 1
	lw	$3, 4($sp)
	cmp	$3, $2
	jlt	$BB0_16
	jmp	$BB0_15
$BB0_15:                                # %if.then26
	lw	$2, 4($sp)
	addiu	$2, $2, 1
	st	$2, 4($sp)
$BB0_16:                                # %if.end28
	lw	$2, 4($sp)
	lw	$3, 0($sp)
	cmp	$3, $2
	jge	$BB0_18
	jmp	$BB0_17
$BB0_17:                                # %if.then30
	lw	$2, 0($sp)
	addiu	$2, $2, 1
	st	$2, 0($sp)
$BB0_18:                                # %if.end32
	lw	$2, 28($sp)
	lw	$3, 32($sp)
	cmp	$3, $2
	jeq	$BB0_20
	jmp	$BB0_19
$BB0_19:                                # %if.then34
	lw	$2, 32($sp)
	addiu	$2, $2, 1
	st	$2, 32($sp)
$BB0_20:                                # %if.end36
	addiu	$sp, $sp, 40
	ret	$lr
	.set	macro
	.set	reorder
	.end	main
$tmp1:
	.size	main, ($tmp1)-main


