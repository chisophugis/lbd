	.section .mdebug.abi32
	.previous
	.file	"ch6_1_3.bc"
	.text
	.globl	main
	.align	2
	.type	main,@function
	.ent	main                    # @main
main:
	.cfi_startproc
	.frame	$sp,16,$lr
	.mask 	0x00000000,0
	.set	noreorder
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -16
$tmp1:
	.cfi_def_cfa_offset 16
	addiu	$2, $zero, 0
	st	$2, 12($sp)
	addiu	$3, $zero, 5
	st	$3, 4($sp)
	st	$2, 0($sp)
	st	$2, 0($sp)
	addiu	$2, $zero, 3
$BB0_1:                                 # =>This Inner Loop Header: Depth=1
	lw	$3, 0($sp)
	cmp	$3, $2
	jne	$BB0_4
	jmp	$BB0_2
$BB0_2:                                 #   in Loop: Header=BB0_1 Depth=1
	lw	$3, 0($sp)
	lw	$4, 8($sp)
	add	$3, $4, $3
	st	$3, 8($sp)
# BB#3:                                 #   in Loop: Header=BB0_1 Depth=1
	lw	$3, 0($sp)
	addiu	$3, $3, 1
	st	$3, 0($sp)
	jmp	$BB0_1
$BB0_4:
	addiu	$2, $zero, 0
	st	$2, 0($sp)
	addiu	$2, $zero, 3
$BB0_5:                                 # =>This Inner Loop Header: Depth=1
	lw	$3, 0($sp)
	cmp	$3, $2
	jeq	$BB0_8
	jmp	$BB0_6
$BB0_6:                                 #   in Loop: Header=BB0_5 Depth=1
	lw	$3, 0($sp)
	lw	$4, 8($sp)
	add	$3, $4, $3
	st	$3, 8($sp)
# BB#7:                                 #   in Loop: Header=BB0_5 Depth=1
	lw	$3, 0($sp)
	addiu	$3, $3, 1
	st	$3, 0($sp)
	jmp	$BB0_5
$BB0_8:
	addiu	$2, $zero, 0
	st	$2, 0($sp)
	addiu	$2, $zero, 4
$BB0_9:                                 # =>This Inner Loop Header: Depth=1
	lw	$3, 0($sp)
	cmp	$3, $2
	jlt	$BB0_12
	jmp	$BB0_10
$BB0_10:                                #   in Loop: Header=BB0_9 Depth=1
	lw	$3, 0($sp)
	lw	$4, 8($sp)
	add	$3, $4, $3
	st	$3, 8($sp)
# BB#11:                                #   in Loop: Header=BB0_9 Depth=1
	lw	$3, 0($sp)
	addiu	$3, $3, 1
	st	$3, 0($sp)
	jmp	$BB0_9
$BB0_12:
	addiu	$2, $zero, 0
	st	$2, 0($sp)
	addiu	$2, $zero, 4
$BB0_13:                                # =>This Inner Loop Header: Depth=1
	lw	$3, 0($sp)
	cmp	$3, $2
	jlt	$BB0_16
	jmp	$BB0_14
$BB0_14:                                #   in Loop: Header=BB0_13 Depth=1
	lw	$3, 0($sp)
	lw	$4, 8($sp)
	add	$3, $4, $3
	st	$3, 8($sp)
# BB#15:                                #   in Loop: Header=BB0_13 Depth=1
	lw	$3, 0($sp)
	addiu	$3, $3, 1
	st	$3, 0($sp)
	jmp	$BB0_13
$BB0_16:
	addiu	$2, $zero, 0
	st	$2, 0($sp)
$BB0_17:                                # =>This Inner Loop Header: Depth=1
	lw	$2, 4($sp)
	lw	$3, 0($sp)
	cmp	$3, $2
	jne	$BB0_20
	jmp	$BB0_18
$BB0_18:                                #   in Loop: Header=BB0_17 Depth=1
	lw	$2, 8($sp)
	addiu	$2, $2, 1
	st	$2, 8($sp)
# BB#19:                                #   in Loop: Header=BB0_17 Depth=1
	lw	$2, 0($sp)
	addiu	$2, $2, 1
	st	$2, 0($sp)
	jmp	$BB0_17
$BB0_20:
	addiu	$2, $zero, 0
	st	$2, 0($sp)
$BB0_21:                                # =>This Inner Loop Header: Depth=1
	lw	$2, 4($sp)
	lw	$3, 0($sp)
	cmp	$3, $2
	jeq	$BB0_24
	jmp	$BB0_22
$BB0_22:                                #   in Loop: Header=BB0_21 Depth=1
	lw	$2, 8($sp)
	addiu	$2, $2, 1
	st	$2, 8($sp)
# BB#23:                                #   in Loop: Header=BB0_21 Depth=1
	lw	$2, 0($sp)
	addiu	$2, $2, 1
	st	$2, 0($sp)
	jmp	$BB0_21
$BB0_24:
	addiu	$2, $zero, 0
	st	$2, 0($sp)
$BB0_25:                                # =>This Inner Loop Header: Depth=1
	lw	$2, 4($sp)
	lw	$3, 0($sp)
	cmp	$3, $2
	jge	$BB0_28
	jmp	$BB0_26
$BB0_26:                                #   in Loop: Header=BB0_25 Depth=1
	lw	$2, 8($sp)
	addiu	$2, $2, 1
	st	$2, 8($sp)
# BB#27:                                #   in Loop: Header=BB0_25 Depth=1
	lw	$2, 0($sp)
	addiu	$2, $2, 1
	st	$2, 0($sp)
	jmp	$BB0_25
$BB0_28:
	addiu	$2, $zero, 7
	st	$2, 0($sp)
$BB0_29:                                # =>This Inner Loop Header: Depth=1
	lw	$2, 0($sp)
	lw	$3, 4($sp)
	cmp	$3, $2
	jle	$BB0_32
	jmp	$BB0_30
$BB0_30:                                #   in Loop: Header=BB0_29 Depth=1
	lw	$2, 8($sp)
	addiu	$2, $2, -1
	st	$2, 8($sp)
# BB#31:                                #   in Loop: Header=BB0_29 Depth=1
	lw	$2, 0($sp)
	addiu	$2, $2, -1
	st	$2, 0($sp)
	jmp	$BB0_29
$BB0_32:
	addiu	$2, $zero, 0
	st	$2, 0($sp)
$BB0_33:                                # =>This Inner Loop Header: Depth=1
	lw	$2, 4($sp)
	lw	$3, 0($sp)
	cmp	$3, $2
	jgt	$BB0_36
	jmp	$BB0_34
$BB0_34:                                #   in Loop: Header=BB0_33 Depth=1
	lw	$2, 8($sp)
	addiu	$2, $2, 1
	st	$2, 8($sp)
# BB#35:                                #   in Loop: Header=BB0_33 Depth=1
	lw	$2, 0($sp)
	addiu	$2, $2, 1
	st	$2, 0($sp)
	jmp	$BB0_33
$BB0_36:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB0_40 Depth 2
                                        #     Child Loop BB0_37 Depth 2
	addiu	$2, $zero, 7
	st	$2, 0($sp)
$BB0_37:                                #   Parent Loop BB0_36 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	lw	$2, 4($sp)
	lw	$3, 0($sp)
	cmp	$3, $2
	jlt	$BB0_40
	jmp	$BB0_38
$BB0_38:                                #   in Loop: Header=BB0_37 Depth=2
	lw	$2, 8($sp)
	addiu	$2, $2, -1
	st	$2, 8($sp)
# BB#39:                                #   in Loop: Header=BB0_37 Depth=2
	lw	$2, 0($sp)
	addiu	$2, $2, -1
	st	$2, 0($sp)
	jmp	$BB0_37
$BB0_40:                                #   Parent Loop BB0_36 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	addiu	$2, $zero, 6
	lw	$3, 0($sp)
	cmp	$3, $2
	jgt	$BB0_43
	jmp	$BB0_41
$BB0_41:                                #   in Loop: Header=BB0_40 Depth=2
	lw	$2, 8($sp)
	addiu	$2, $2, 1
	st	$2, 8($sp)
	lw	$2, 0($sp)
	addiu	$2, $2, 1
	st	$2, 0($sp)
	addiu	$2, $zero, 3
	lw	$3, 8($sp)
	cmp	$3, $2
	jgt	$BB0_40
	jmp	$BB0_42
$BB0_42:                                #   in Loop: Header=BB0_40 Depth=2
	lw	$3, 8($sp)
	cmp	$3, $2
	jne	$BB0_40
	jmp	$BB0_43
$BB0_43:                                #   in Loop: Header=BB0_36 Depth=1
	addiu	$2, $zero, 3
	lw	$3, 8($sp)
	cmp	$3, $2
	jeq	$BB0_36
	jmp	$BB0_44
$BB0_44:
	addiu	$sp, $sp, 16
	ret	$lr
	.set	macro
	.set	reorder
	.end	main
$tmp2:
	.size	main, ($tmp2)-main
	.cfi_endproc


