.. _sec-appendix-inst-discuss:

Appendix C: instructions discuss
=================================

This chapter discuss other backend instructions.

Use cpu0 official LDI instead of ADDiu
--------------------------------------

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


Implicit operand
-----------------

LLVM IR is a 3 address form (4 tuple <opcode, %1, %2, %3) which match the 
current RISC cpu0 (like Mips). 
So, it seems no "move" IR DAG. 
Because "move a, b" can be replaced by "lw a, b_offset($sp)" for local 
variable, or can be replaced by "addu $a, $0,$ b". 
The cpu0 is same as Mips. 
Base on this reason, the move instruction is useless even though it supplied by 
the cpu0 author.

For the old CPU or Micro Processor (MCU), like PIC, 8051 and old intel processor. 
These CPU/MCU need memory saving and not aim to high level of program (such as 
C) only (they aim to assembly code program too). 
These CPU/MCU need implicit operand, maybe use ACC (accumulate register). 

It will translate,

.. code-block:: c++

  c = a + b + d; 
  
into,

.. code-block:: c++

	mtacc   Addr(12) // Move b To Acc
	add     Addr(16) // Add a To Acc
	add     Addr(4)  // Add d To Acc
	mfacc   Addr(8)  // Move Acc To c

Above code also can be coded by programmer who use assembly language directly 
in MCU or BIOS programm since maybe the code size is just 4KB or less.

Since cpu0 is a 32 bits (code size can be 4GB), it use Store and Load 
instructions for memory address access only. 
Other instructions (include add), use register to register style operation.
We change the implicit operand support in this section. 
It's just a demonstration with this design, not fully support. 
The purpose is telling reader how to implement this style of CPU/MCU backend. 
Run 8/8_2/Cpu0 with ch_move.cpp will get the following result,

.. code-block:: c++

  // ch_move.cpp
  int main()
  {
    int a = 1;
    int b = 2;
    int c = 0;
    int d = 4;
    int e = 5;
  
    c = a + b + d + e;
    
    return 0;
  }

.. code-block:: bash

  ld  $3, 12($sp) // $3 is a
  ld  $4, 16($sp) // $4 is b
  mtacc $4        // Move b To Acc
  add $3          // Add a To Acc
  ld  $4, 4($sp)  // $4 is d
  add $4          // Add d To Acc
  mfacc $3        // Move Acc to $3
  addiu $3, $3, 5 // Add e(=5) to $3
  st  $3, 8($sp)


To support this implicit operand, ACC. 
The following code is added to 8/8_2.cpp.

.. code-block:: c++

  // Cpu0RegisterInfo.td 
  ...
  let Namespace = "Cpu0" in {
    // General Purpose Registers
    def ZERO : Cpu0GPRReg< 0, "ZERO">, DwarfRegNum<[0]>;
    ...
    def ACC : Register<"acc">, DwarfRegNum<[20]>;
  }
  ...
  def RACC : RegisterClass<"Cpu0", [i32], 32, (add ACC)>;
  
  
  // Cpu0InstrInfo.td 
  ...
  class MoveFromACC<bits<8> op, string instr_asm, RegisterClass RC,
             list<Register> UseRegs>:
    FL<op, (outs RC:$ra), (ins),
     !strconcat(instr_asm, "\t$ra"), [], IIAlu> {
    let rb = 0;
    let imm16 = 0;
    let Uses = UseRegs;
    let neverHasSideEffects = 1;
  }
  
  class MoveToACC<bits<8> op, string instr_asm, RegisterClass RC,
           list<Register> DefRegs>:
    FL<op, (outs), (ins RC:$ra),
     !strconcat(instr_asm, "\t$ra"), [], IIAlu> {
    let rb = 0;
    let imm16 = 0;
    let Defs = DefRegs;
    let neverHasSideEffects = 1;
  }
  
  class ArithLogicUniR2<bits<8> op, string instr_asm, RegisterClass RC1,
           RegisterClass RC2, list<Register> DefRegs>:
    FL<op, (outs), (ins RC1:$accum, RC2:$ra),
     !strconcat(instr_asm, "\t$ra"), [], IIAlu> {
    let rb = 0;
    let imm16 = 0;
    let Defs = DefRegs;
    let neverHasSideEffects = 1;
  }
  ...
  //def ADD     : ArithLogicR<0x13, "add", add, IIAlu, CPURegs, 1>;
  ...
  def MFACC : MoveFromACC<0x44, "mfacc", CPURegs, [ACC]>;
  def MTACC : MoveToACC<0x45, "mtacc", CPURegs, [ACC]>;
  def ADD   : ArithLogicUniR2<0x46, "add", RACC, CPURegs, [ACC]>;
  ...
  def : Pat<(add RACC:$lhs, CPURegs:$rhs),
        (ADD RACC:$lhs, CPURegs:$rhs)>;
  
  def : Pat<(add CPURegs:$lhs, CPURegs:$rhs),
        (ADD (MTACC CPURegs:$lhs), CPURegs:$rhs)>;
  
  
  // Cpu0InstrInfo.cpp
  ... 
  //- Called when DestReg and SrcReg belong to different Register Class.
  void Cpu0InstrInfo::
  copyPhysReg(MachineBasicBlock &MBB,
        MachineBasicBlock::iterator I, DebugLoc DL,
        unsigned DestReg, unsigned SrcReg,
        bool KillSrc) const {
    unsigned Opc = 0, ZeroReg = 0;
  
    if (Cpu0::CPURegsRegClass.contains(DestReg)) { // Copy to CPU Reg.
    ...
    else if (SrcReg == Cpu0::ACC)
      Opc = Cpu0::MFACC, SrcReg = 0;
    }
    else if (Cpu0::CPURegsRegClass.contains(SrcReg)) { // Copy from CPU Reg.
    ...
    else if (DestReg == Cpu0::ACC)
      Opc = Cpu0::MTACC, DestReg = 0;
    }
    ...
  }

  
Explain the code as follows,

.. code-block:: bash

  ld  $3, 12($sp) // $3 is a
  ld  $4, 16($sp) // $4 is b
  
  mtacc $4      // Move b To Acc
  // After meet first a+b IR, it call this pattern,
  //  def : Pat<(add CPURegs:$lhs, CPURegs:$rhs),
  //        (ADD (MTACC CPURegs:$lhs), CPURegs:$rhs)>;
  // After this pattern translation, the DestReg class change from CPU0Regs to 
  //  RACC according the following code of copyPhysReg(). copyPhysReg() is called 
  //  when DestReg and SrcReg belong to different Register Class.
  //
  //  if (DestReg)
  //    MIB.addReg(DestReg, RegState::Define);
  //
  //  if (ZeroReg)
  //    MIB.addReg(ZeroReg);
  //
  //  if (SrcReg)
  //    MIB.addReg(SrcReg, getKillRegState(KillSrc));

  add $3      // Add a To Acc
  // Apply this pattern since the DestReg class is RACC
  //  def : Pat<(add RACC:$lhs, CPURegs:$rhs),
  //        (ADD RACC:$lhs, CPURegs:$rhs)>;

  ld  $4, 4($sp)  // $4 is d
  add $4      // Add d To Acc
  // Apply the pattern as above since the DestReg class is RACC

  mfacc $3    // Move Acc to $3
  // Compiler/backend can use ADDiu since e is 5. But it add MFACC before ADDiu 
  //  since the DestReg class is RACC. Translate to CPU0Regs class by MFACC and 
  //  apply ADDiu since ADDiu use CPU0Regs as operands.
  addiu $3, $3, 5 // Add e(=5) to $3
  st  $3, 8($sp)




.. _section CPU0 processor architecture:
    http://jonathan2251.github.com/lbd/llvmstructure.html#cpu0-processor-
    architecture
