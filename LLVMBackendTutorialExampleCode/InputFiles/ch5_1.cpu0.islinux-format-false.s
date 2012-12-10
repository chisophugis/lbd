	.section .mdebug.abi32
	.previous
	.file	"ch5_1.bc"
	.text
	.globl	main
	.align	2
	.type	main,@function
	.ent	main                    # @main
main:
	.cfi_startproc
	.frame	$sp,8,$lr
	.mask 	0x00000000,0
	.set	noreorder
	.set	nomacro
# BB#0:
	ldi	$fp, -8
	add	$sp, $sp, $fp
$tmp1:
	.cfi_def_cfa_offset 8
	ldi	$2, 0
	st	$2, 4($sp)
	st	$2, 0($sp)
	ldi	$2, %gp_rel(gI)
	add	$2, $gp, $2
	lw	$2, 0($2)
	st	$2, 0($sp)
	ldi	$fp, 8
	add	$sp, $sp, $fp
	ret	$lr
	.set	macro
	.set	reorder
	.end	main
$tmp2:
	.size	main, ($tmp2)-main
	.cfi_endproc

	.type	gI,@object              # @gI
	.section	.sdata,"aw",@progbits
	.globl	gI
	.align	2
gI:
	.4byte	100                     # 0x64
	.size	gI, 4


