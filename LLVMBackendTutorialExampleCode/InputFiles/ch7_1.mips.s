	.section .mdebug.abi32
	.previous
	.file	"ch7_1.bc"
	.text
	.globl	_Z5sum_iiiiiii
	.align	2
	.type	_Z5sum_iiiiiii,@function
	.ent	_Z5sum_iiiiiii          # @_Z5sum_iiiiiii
_Z5sum_iiiiiii:
	.cfi_startproc
	.frame	$sp,32,$ra
	.mask 	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -32
$tmp1:
	.cfi_def_cfa_offset 32
	sw	$4, 28($sp)
	sw	$5, 24($sp)
	sw	$6, 20($sp)
	sw	$7, 16($sp)
	lw	$2, 48($sp)
	sw	$2, 12($sp)
	lw	$2, 52($sp)
	sw	$2, 8($sp)
	lw	$3, 24($sp)
	lw	$4, 28($sp)
	addu	$3, $4, $3
	lw	$4, 20($sp)
	addu	$3, $3, $4
	lw	$4, 16($sp)
	addu	$3, $3, $4
	lw	$4, 12($sp)
	addu	$3, $3, $4
	addu	$2, $3, $2
	sw	$2, 4($sp)
	addiu	$sp, $sp, 32
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	_Z5sum_iiiiiii
$tmp2:
	.size	_Z5sum_iiiiiii, ($tmp2)-_Z5sum_iiiiiii
	.cfi_endproc

	.globl	main
	.align	2
	.type	main,@function
	.ent	main                    # @main
main:
	.cfi_startproc
	.frame	$sp,48,$ra
	.mask 	0x80000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$25
	.set	nomacro
# BB#0:
	addiu	$sp, $sp, -48
$tmp5:
	.cfi_def_cfa_offset 48
	sw	$ra, 44($sp)            # 4-byte Folded Spill
$tmp6:
	.cfi_offset 31, -4
	.cprestore	24
	sw	$zero, 40($sp)
	addiu	$2, $zero, 6
	sw	$2, 20($sp)
	addiu	$2, $zero, 5
	sw	$2, 16($sp)
	lw	$25, %call16(_Z5sum_iiiiiii)($gp)
	addiu	$4, $zero, 1
	addiu	$5, $zero, 2
	addiu	$6, $zero, 3
	addiu	$7, $zero, 4
	jalr	$25
	nop
	lw	$gp, 24($sp)
	sw	$2, 36($sp)
	lw	$ra, 44($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 48
	jr	$ra
	nop
	.set	macro
	.set	reorder
	.end	main
$tmp7:
	.size	main, ($tmp7)-main
	.cfi_endproc


