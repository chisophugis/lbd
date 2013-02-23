#if 1
asm("st	$0, 0($sp)");
//asm("st	$0, 4($sp)");
//asm("ld	$2, 4($sp)");
asm("li $3, 0x00800000");
#else
asm("sw	$0, 0($sp)");
//asm("sw	$0, 4($sp)");
//asm("lw	$2, 4($sp)");
//asm("li $3, 0x00800000");
#endif