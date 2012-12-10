	.section .mdebug.abi32
	.previous
	.file	"ch7_1_4.bc"
	.text
	.globl	_Z8multiplyii
	.align	2
	.type	_Z8multiplyii,@function
	.ent	_Z8multiplyii           # @_Z8multiplyii
_Z8multiplyii:
	.frame	$sp,8,$lr
	.mask 	0x00000000,0
	.set	noreorder
	.set	nomacro
# BB#0:                                 # %entry
	addiu	$sp, $sp, -8
	lw	$2, 8($sp)
	st	$2, 4($sp)
	lw	$2, 12($sp)
	st	$2, 0($sp)
	addiu	$sp, $sp, 8
	ret	$lr
	.set	macro
	.set	reorder
	.end	_Z8multiplyii
$tmp1:
	.size	_Z8multiplyii, ($tmp1)-_Z8multiplyii

	.globl	_Z3addii
	.align	2
	.type	_Z3addii,@function
	.ent	_Z3addii                # @_Z3addii
_Z3addii:
	.frame	$sp,8,$lr
	.mask 	0x00000000,0
	.set	noreorder
	.set	nomacro
# BB#0:                                 # %entry
	addiu	$sp, $sp, -8
	lw	$2, 8($sp)
	st	$2, 4($sp)
	lw	$2, 12($sp)
	st	$2, 0($sp)
	addiu	$sp, $sp, 8
	ret	$lr
	.set	macro
	.set	reorder
	.end	_Z3addii
$tmp3:
	.size	_Z3addii, ($tmp3)-_Z3addii

	.globl	_Z4maddiii
	.align	2
	.type	_Z4maddiii,@function
	.ent	_Z4maddiii              # @_Z4maddiii
_Z4maddiii:
	.frame	$sp,40,$lr
	.mask 	0x00004080,-4
	.set	noreorder
	.cpload	$t9
	.set	nomacro
# BB#0:                                 # %entry
	addiu	$sp, $sp, -40
	BUNDLE                          # 4-byte Folded Spill
	BUNDLE                          # 4-byte Folded Spill
	lw	$2, 40($sp)
	st	$2, 28($sp)
	lw	$2, 44($sp)
	st	$2, 24($sp)
	lw	$7, 48($sp)
	st	$7, 20($sp)
	lw	$2, 28($sp)
	lw	$3, 24($sp)
	st	$3, 4($sp)
	st	$2, 0($sp)
	lw	$6, %call24(_Z8multiplyii)($gp)
	jalr	$6
	st	$2, 4($sp)
	st	$7, 0($sp)
	lw	$6, %call24(_Z3addii)($gp)
	jalr	$6
	lw	$7, 32($sp)             # 4-byte Folded Reload
	lw	$lr, 36($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 40
	ret	$lr
	.set	macro
	.set	reorder
	.end	_Z4maddiii
$tmp6:
	.size	_Z4maddiii, ($tmp6)-_Z4maddiii

	.globl	main
	.align	2
	.type	main,@function
	.ent	main                    # @main
main:
	.frame	$sp,48,$lr
	.mask 	0x00004000,-4
	.set	noreorder
	.cpload	$t9
	.set	nomacro
# BB#0:                                 # %entry
	addiu	$sp, $sp, -48
	BUNDLE                          # 4-byte Folded Spill
	addiu	$2, $zero, 0
	st	$2, 40($sp)
	addiu	$2, $zero, 5
	st	$2, 36($sp)
	st	$2, 8($sp)
	addiu	$2, $zero, 2
	st	$2, 4($sp)
	addiu	$2, $zero, 1
	st	$2, 0($sp)
	lw	$6, %call24(_Z4maddiii)($gp)
	jalr	$6
	st	$2, 32($sp)
	lw	$lr, 44($sp)            # 4-byte Folded Reload
	addiu	$sp, $sp, 48
	ret	$lr
	.set	macro
	.set	reorder
	.end	main
$tmp9:
	.size	main, ($tmp9)-main


