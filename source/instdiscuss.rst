.. _sec-appendix-old-llvm-ver:

Appendix C: instructions discuss
=================================

Use cpu0 official LDI instead of ADDiu
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

According cpu0 web site instruction definition. 
There is no addiu instruction definition. 
We add **addiu** instruction because we find this instruction is more powerful 
and reasonable than **ldi** instruction. 
We highlight this change in `section CPU0 processor architecture`_. 
Even with that, we show you how to replace our **addiu** with **ldi** according 
the cpu0 original design. 
4/4_2/Cpu0 is the code changes for use **ldi** instruction. 
This changes replace **addiu** with **ldi** in Cpu0InstrInfo.td and modify 
Cpu0FrameLowering.cpp as follows,

.. code-block:: c++

  // Cpu0InstrInfo.td
  ...
    
  /// Arithmetic Instructions (ALU Immediate)
  def LDI     : MoveImm<0x08, "ldi", add, simm16, immSExt16, CPURegs>;
  // add defined in include/llvm/Target/TargetSelectionDAG.td, line 315 (def add).
  //def ADDiu   : ArithLogicI<0x09, "addiu", add, simm16, immSExt16, CPURegs>;
  ...
    
  // Small immediates
    
  def : Pat<(i32 immSExt16:$in),
            (LDI ZERO, imm:$in)>;
    
  // hi/lo relocs
  def : Pat<(Cpu0Hi tglobaladdr:$in), (SHL (LDI ZERO, tglobaladdr:$in), 16)>;
  // Expect cpu0 add LUi support, like Mips
  //def : Pat<(Cpu0Hi tglobaladdr:$in), (LUi tglobaladdr:$in)>;
  def : Pat<(Cpu0Lo tglobaladdr:$in), (LDI ZERO, tglobaladdr:$in)>;
    
  def : Pat<(add CPURegs:$hi, (Cpu0Lo tglobaladdr:$lo)),
            (ADD CPURegs:$hi, (LDI ZERO, tglobaladdr:$lo))>;
    
  // gp_rel relocs
  def : Pat<(add CPURegs:$gp, (Cpu0GPRel tglobaladdr:$in)),
            (ADD CPURegs:$gp, (LDI ZERO, tglobaladdr:$in))>;
    
  def : Pat<(not CPURegs:$in),
             (XOR CPURegs:$in, (LDI ZERO, 1))>;
    
  // Cpu0FrameLowering.cpp
  ...
  void Cpu0FrameLowering::emitPrologue(MachineFunction &MF) const {
    ...
    // Adjust stack.
    if (isInt<16>(-StackSize)) {
      // ldi fp, (-stacksize)
      // add sp, sp, fp
      BuildMI(MBB, MBBI, dl, TII.get(Cpu0::LDI), Cpu0::FP).addReg(Cpu0::FP)
                                                          .addImm(-StackSize);
      BuildMI(MBB, MBBI, dl, TII.get(Cpu0::ADD), SP).addReg(SP).addReg(Cpu0::FP);
    }
    ...
  }
    
  void Cpu0FrameLowering::emitEpilogue(MachineFunction &MF,
                                   MachineBasicBlock &MBB) const {
    ...
    // Adjust stack.
    if (isInt<16>(-StackSize)) {
      // ldi fp, (-stacksize)
      // add sp, sp, fp
      BuildMI(MBB, MBBI, dl, TII.get(Cpu0::LDI), Cpu0::FP).addReg(Cpu0::FP)
                                                          .addImm(-StackSize);
      BuildMI(MBB, MBBI, dl, TII.get(Cpu0::ADD), SP).addReg(SP).addReg(Cpu0::FP);
    }
    ...
  }

As above code, we use **add** IR binary instruction (1 register operand and 1 
immediate operand, and the register operand is fixed with ZERO) in our solution 
since we didn't find the **move** IR unary instruction. 
This code is correct since all the immediate value is translated into 
**“ldi Zero, imm/address”**. 
And **(add CPURegs:$gp, $imm16)** is translated into 
**(ADD CPURegs:$gp, (LDI ZERO, $imm16))**. 
Let's run 4/4_2/Cpu0 with ch4_4.cpp to get the correct result 
below. 
As you will see, **“addiu $sp, $sp, -24”** will be replaced with the pair 
instructions of **“ldi $fp, -24”** and **“add $sp, $sp, $fp”**. 
Since the $sp pointer adjustment is so frequently occurs (it occurs in every 
function entry and exit point), 
we reserve the $fp to the pair of stack adjustment instructions **“ldi”** and 
**“add”**. 
If we didn't reserve the dedicate registers $fp and $sp, it need to save 
and restore them in the stack adjustment. 
It meaning more instructions running cost in this. 
Anyway, the pair of **“ldi”** and **“add”** to adjust stack pointer is double 
in cost compete to **“addiu”**, that's the benefit we mentioned in 
`section CPU0 processor architecture`_.

.. code-block:: bash

  118-165-66-82:InputFiles Jonathan$ /Users/Jonathan/llvm/test/cmake_
  debug_build/bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=asm 
  ch4_4.bc -o ch4_4.cpu0.s
  118-165-66-82:InputFiles Jonathan$ cat ch4_4.cpu0.s 
    .section .mdebug.abi32
    .previous
    .file "ch4_4.bc"
    .text
    .globl  main
    .align  2
    .type main,@function
    .ent  main                    # @main
  main:
    .cfi_startproc
    .frame  $sp,24,$lr
    .mask   0x00000000,0
    .set  noreorder
    .set  nomacro
  # BB#0:
    ldi $fp, -24
    add $sp, $sp, $fp
  $tmp1:
    .cfi_def_cfa_offset 24
    ldi $2, 0
    st  $2, 20($sp)
    ldi $3, 1
    st  $3, 16($sp)
    ldi $3, 2
    st  $3, 12($sp)
    st  $2, 8($sp)
    ldi $3, -5
    st  $3, 4($sp)
    st  $2, 0($sp)
    ld  $2, 12($sp)
    ld  $3, 4($sp)
    udiv  $2, $3, $2
    st  $2, 0($sp)
    ld  $2, 16($sp)
    sra $2, $2, 2
    st  $2, 8($sp)
    ldi $fp, 24
    add $sp, $sp, $fp
    ret $lr
    .set  macro
    .set  reorder
    .end  main
  $tmp2:
    .size main, ($tmp2)-main
    .cfi_endproc



.. _section CPU0 processor architecture:
    http://jonathan2251.github.com/lbd/llvmstructure.html#cpu0-processor-
    architecture
