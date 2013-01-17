.. _sec-controlflow:

Control flow statements
=======================

This chapter illustrates the corresponding IR for control flow statements, like 
**“if else”**, **“while”** and **“for”** loop statements in C, and how to 
translate these control flow statements of llvm IR into cpu0 instructions. 

Control flow statement
-----------------------

Run ch7_1_1.cpp with clang will get result as follows,

.. code-block:: c++

    // ch7_1_1.cpp
    int main()
    {
        unsigned int a = 0;
        int b = 1;
        int c = 2;
        int d = 3;
        int e = 4;
        int f = 5;
        int g = 6;
        int h = 7;
        int i = 8;
        
        if (a == 0) {
            a++;
        }
        if (b != 0) {
            b++;
        }
        if (c > 0) {
            c++;
        }
        if (d >= 0) {
            d++;
        }
        if (e < 0) {
            e++;
        }
        if (f <= 0) {
            f++;
        }
        if (g <= 1) {
            g++;
        }
        if (h >= 1) {
            h++;
        }
        if (i < h) {
            i++;
        }
        if (a != b) {
            a++;
        }
        
        return a;
    }

.. code-block:: bash

    ; ModuleID = 'ch7_1_1.bc'
    target datalayout = "e-p:32:32:32-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:32:64-
    f32:32:32-f64:32:64-v64:64:64-v128:128:128-a0:0:64-f80:128:128-n8:16:32-S128"
    target triple = "i386-apple-macosx10.8.0"
    
    define i32 @main() nounwind ssp {
    entry:
      %retval = alloca i32, align 4
      %a = alloca i32, align 4
      %b = alloca i32, align 4
      %c = alloca i32, align 4
      %d = alloca i32, align 4
      %e = alloca i32, align 4
      %f = alloca i32, align 4
      %g = alloca i32, align 4
      %h = alloca i32, align 4
      %i = alloca i32, align 4
      store i32 0, i32* %retval
      store i32 0, i32* %a, align 4
      store i32 1, i32* %b, align 4
      store i32 2, i32* %c, align 4
      store i32 3, i32* %d, align 4
      store i32 4, i32* %e, align 4
      store i32 5, i32* %f, align 4
      store i32 6, i32* %g, align 4
      store i32 7, i32* %h, align 4
      store i32 8, i32* %i, align 4
      %0 = load i32* %a, align 4
      %cmp = icmp eq i32 %0, 0
      br i1 %cmp, label %if.then, label %if.end
    
    if.then:                                        ; preds = %entry
      %1 = load i32* %a, align 4
      %inc = add i32 %1, 1
      store i32 %inc, i32* %a, align 4
      br label %if.end
    
    if.end:                                         ; preds = %if.then, %entry
      %2 = load i32* %b, align 4
      %cmp1 = icmp ne i32 %2, 0
      br i1 %cmp1, label %if.then2, label %if.end4
    
    if.then2:                                       ; preds = %if.end
      %3 = load i32* %b, align 4
      %inc3 = add nsw i32 %3, 1
      store i32 %inc3, i32* %b, align 4
      br label %if.end4
    
    if.end4:                                        ; preds = %if.then2, %if.end
      %4 = load i32* %c, align 4
      %cmp5 = icmp sgt i32 %4, 0
      br i1 %cmp5, label %if.then6, label %if.end8
    
    if.then6:                                       ; preds = %if.end4
      %5 = load i32* %c, align 4
      %inc7 = add nsw i32 %5, 1
      store i32 %inc7, i32* %c, align 4
      br label %if.end8
    
    if.end8:                                        ; preds = %if.then6, %if.end4
      %6 = load i32* %d, align 4
      %cmp9 = icmp sge i32 %6, 0
      br i1 %cmp9, label %if.then10, label %if.end12
    
    if.then10:                                      ; preds = %if.end8
      %7 = load i32* %d, align 4
      %inc11 = add nsw i32 %7, 1
      store i32 %inc11, i32* %d, align 4
      br label %if.end12
    
    if.end12:                                       ; preds = %if.then10, %if.end8
      %8 = load i32* %e, align 4
      %cmp13 = icmp slt i32 %8, 0
      br i1 %cmp13, label %if.then14, label %if.end16
    
    if.then14:                                      ; preds = %if.end12
      %9 = load i32* %e, align 4
      %inc15 = add nsw i32 %9, 1
      store i32 %inc15, i32* %e, align 4
      br label %if.end16
    
    if.end16:                                       ; preds = %if.then14, %if.end12
      %10 = load i32* %f, align 4
      %cmp17 = icmp sle i32 %10, 0
      br i1 %cmp17, label %if.then18, label %if.end20
    
    if.then18:                                      ; preds = %if.end16
      %11 = load i32* %f, align 4
      %inc19 = add nsw i32 %11, 1
      store i32 %inc19, i32* %f, align 4
      br label %if.end20
    
    if.end20:                                       ; preds = %if.then18, %if.end16
      %12 = load i32* %g, align 4
      %cmp21 = icmp sle i32 %12, 1
      br i1 %cmp21, label %if.then22, label %if.end24
    
    if.then22:                                      ; preds = %if.end20
      %13 = load i32* %g, align 4
      %inc23 = add nsw i32 %13, 1
      store i32 %inc23, i32* %g, align 4
      br label %if.end24
    
    if.end24:                                       ; preds = %if.then22, %if.end20
      %14 = load i32* %h, align 4
      %cmp25 = icmp sge i32 %14, 1
      br i1 %cmp25, label %if.then26, label %if.end28
    
    if.then26:                                      ; preds = %if.end24
      %15 = load i32* %h, align 4
      %inc27 = add nsw i32 %15, 1
      store i32 %inc27, i32* %h, align 4
      br label %if.end28
    
    if.end28:                                       ; preds = %if.then26, %if.end24
      %16 = load i32* %i, align 4
      %17 = load i32* %h, align 4
      %cmp29 = icmp slt i32 %16, %17
      br i1 %cmp29, label %if.then30, label %if.end32
    
    if.then30:                                      ; preds = %if.end28
      %18 = load i32* %i, align 4
      %inc31 = add nsw i32 %18, 1
      store i32 %inc31, i32* %i, align 4
      br label %if.end32
    
    if.end32:                                       ; preds = %if.then30, %if.end28
      %19 = load i32* %a, align 4
      %20 = load i32* %b, align 4
      %cmp33 = icmp ne i32 %19, %20
      br i1 %cmp33, label %if.then34, label %if.end36
    
    if.then34:                                      ; preds = %if.end32
      %21 = load i32* %a, align 4
      %inc35 = add i32 %21, 1
      store i32 %inc35, i32* %a, align 4
      br label %if.end36
    
    if.end36:                                       ; preds = %if.then34, %if.end32
      %22 = load i32* %a, align 4
      ret i32 %22
    }


The **“icmp ne”** stand for integer compare NotEqual, **“slt”** stand for Set 
Less Than, **“sle”** stand for Set Less Equal. 
Run version 6/2/Cpu0 with ``llc  -view-isel-dags`` or ``-debug`` option, you 
can see it has translated **if** statement into 
(br (brcond (%1, setcc(%2, Constant<c>, setne)), BasicBlock_02), BasicBlock_01).
Ignore %1, we get the form (br (brcond (setcc(%2, Constant<c>, setne)), 
BasicBlock_02), BasicBlock_01). 
For explanation, We list the IR DAG as follows,

.. code-block:: bash

    %cond=setcc(%2, Constant<c>, setne)
    brcond %cond, BasicBlock_02
    br BasicBlock_01
        We want to translate them into cpu0 instructions DAG as follows,
    addiu %3, ZERO, Constant<c>
    cmp %2, %3
    jne BasicBlock_02
    jmp BasicBlock_01

For the first addiu instruction as above which move Constant<c> into register, 
we have defined it before by the following code,

.. code-block:: c++

    // Cpu0InstrInfo.td
    ...
    // Small immediates
    def : Pat<(i32 immSExt16:$in),
              (ADDiu ZERO, imm:$in)>;
    
    // Arbitrary immediates
    def : Pat<(i32 imm:$imm),
              (OR (SHL (ADDiu ZERO, (HI16 imm:$imm)), 16), 
              (ADDiu ZERO, (LO16 imm:$imm)))>;

For the last IR br, we translate unconditional branch (br BasicBlock_01) into 
jmp BasicBlock_01 by the following pattern definition,

.. code-block:: c++

    def brtarget    : Operand<OtherVT> {
      let EncoderMethod = "getBranchTargetOpValue";
      let OperandType = "OPERAND_PCREL";
      let DecoderMethod = "DecodeBranchTarget";
    }
    ...
    // Unconditional branch
    class UncondBranch<bits<8> op, string instr_asm>:
      BranchBase<op, (outs), (ins brtarget:$imm24),
                 !strconcat(instr_asm, "\t$imm24"), [(br bb:$imm24)], IIBranch> {
      let isBranch = 1;
      let isTerminator = 1;
      let isBarrier = 1;
      let hasDelaySlot = 0;
    }
    ...
    def JMP     : UncondBranch<0x26, "jmp">;

The pattern [(br bb:$imm24)] in class UncondBranch is translated into jmp 
machine instruction.
The other two cpu0 instructions translation is more complicate than simple 
one-to-one IR to machine instruction translation we have experienced until now. 
To solve this chained IR to machine instructions translation, we define the 
following pattern,

.. code-block:: c++

    // brcond patterns
    multiclass BrcondPats<RegisterClass RC, Instruction JEQOp, Instruction JNEOp, 
      Instruction JLTOp, Instruction JGTOp, Instruction JLEOp, Instruction JGEOp, 
      Instruction CMPOp> {
    ...
    def : Pat<(brcond (i32 (setne RC:$lhs, RC:$rhs)), bb:$dst),
              (JNEOp (CMPOp RC:$lhs, RC:$rhs), bb:$dst)>;
    ...
    def : Pat<(brcond RC:$cond, bb:$dst),
              (JNEOp (CMPOp RC:$cond, ZEROReg), bb:$dst)>;

Above definition support (setne RC:$lhs, RC:$rhs) register to register compare. 
There are other compare pattern like, seteq, setlt, ... . In addition to seteq, 
setne, ..., we define setueq, setune, ...,  by reference Mips code even though we 
didn't find how setune came from. 
We have tried to define unsigned int type, but clang still generate setne 
instead of setune. 
Pattern search order is according their appear order in context. 
The last pattern (brcond RC:$cond, bb:$dst) is meaning branch to $dst 
if $cond != 0, it is equal to (JNEOp (CMPOp RC:$cond, ZEROReg), bb:$dst) in 
cpu0 translation.

The CMP instruction will set the result to register SW, and then JNE check the 
condition based on SW status. Since SW is a reserved register, it will be 
correct even an instruction is inserted between CMP and JNE as follows,

.. code-block:: c++

    cmp %2, %3
    addiu $r1, $r2, 3   // $r1 register never be allocated to $SW
    jne BasicBlock_02

The reserved registers setting by the following function code we defined before,

.. code-block:: c++
    
    // Cpu0RegisterInfo.cpp
    ...
    // pure virtual method
    BitVector Cpu0RegisterInfo::
    getReservedRegs(const MachineFunction &MF) const {
      static const uint16_t ReservedCPURegs[] = {
        Cpu0::ZERO, Cpu0::AT, Cpu0::GP, Cpu0::FP,
        Cpu0::SW, Cpu0::SP, Cpu0::LR, Cpu0::PC
      };
      BitVector Reserved(getNumRegs());
      typedef TargetRegisterClass::iterator RegIter;
    
      for (unsigned I = 0; I < array_lengthof(ReservedCPURegs); ++I)
        Reserved.set(ReservedCPURegs[I]);
    
      // If GP is dedicated as a global base register, reserve it.
      if (MF.getInfo<Cpu0FunctionInfo>()->globalBaseRegFixed()) {
        Reserved.set(Cpu0::GP);
      }
    
      return Reserved;
    }

Although the following definition in Cpu0RegisterInfo.td has no real effect in 
Reserved Registers, you should comment the Reserved Registers in it for 
readability.

.. code-block:: c++

    // Cpu0RegisterInfo.td
    ...
    //===----------------------------------------------------------------------===//
    // Register Classes
    //===----------------------------------------------------------------------===//
    
    def CPURegs : RegisterClass<"Cpu0", [i32], 32, (add
      // Return Values and Arguments
      V0, V1, A0, A1, 
      // Not preserved across procedure calls
      T9, 
      // Callee save
      S0, S1, S2, 
      // Reserved
      ZERO, AT, GP, FP, SW, SP, LR, PC)>;

7/1/Cpu0 include support for control flow statement. 
Run with it as well as the following ``llc`` option, you can get the obj file 
and dump it's content by hexdump as follows,

.. code-block:: c++

    118-165-79-206:InputFiles Jonathan$ cat ch7_1_1.cpu0.s 
    ...
        ld  $3, 32($sp)
        cmp $3, $2
        jne $BB0_2
        jmp $BB0_1
    $BB0_1:                                 # %if.then
        ld  $2, 32($sp)
        addiu   $2, $2, 1
        st  $2, 32($sp)
    $BB0_2:                                 # %if.end
        ld  $2, 28($sp)
    ...

.. code-block:: bash
    
    118-165-79-206:InputFiles Jonathan$ /Users/Jonathan/llvm/test/
    cmake_debug_build/bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=obj 
    ch7_1_1.bc -o ch7_1_1.cpu0.o

    118-165-79-206:InputFiles Jonathan$ hexdump ch7_1_1.cpu0.o 
        // jmp offset is 0x10=16 bytes which is correct
    0000080 ............................ 10 20 20 02 21 00 00 10
    
    0000090 26 00 00 00 ...............................................

The immediate value of jne (op 0x21) is 16; The offset between jne and $BB0_2 
is 20 (5 words = 5*4 bytes). Suppose the jne address is X, then the label 
$BB0_2 is X+20. 
Cpu0 is a RISC cpu0 with 3 stages of pipeline which are fetch, decode and 
execution according to cpu0 web site information. 
The cpu0 do branch instruction execution at decode stage which like mips. 
After the jne instruction fetched, the PC (Program Counter) is X+4 since cpu0 
update PC at fetch stage. 
The $BB0_2 address is equal to PC+16 for the jne branch instruction execute at 
decode stage. 
List and explain this again as follows,

.. code-block:: bash

                    // Fetch instruction stage for jne instruction. The fetch stage 
                    // can be divided into 2 cycles. First cycle fetch the 
                    // instruction. Second cycle adjust PC = PC+4. 
        jne $BB0_2  // Do jne compare in decode stage. PC = X+4 at this stage. 
                    // When jne immediate value is 16, PC = PC+16. It will fetch 
                    //  X+20 which equal to label $BB0_2 instruction, ld $2, 28($sp). 
        jmp $BB0_1 
    $BB0_1:                                 # %if.then
        ld  $2, 32($sp)
        addiu   $2, $2, 1
        st  $2, 32($sp)
    $BB0_2:                                 # %if.end
        ld  $2, 28($sp)

If cpu0 do **"jne"** compare in execution stage, then we should set PC=PC+12, 
offset of ($BB0_2, jn e $BB02) – 8, in this example.

Cpu0 is for teaching purpose and didn't consider the performance with design. 
In reality, the conditional branch is important in performance of CPU design. 
According bench mark information, every 7 instructions will meet 1 branch 
instruction in average. 
Cpu0 take 2 instructions for conditional branch, (jne(cmp...)), while Mips use 
one instruction (bne).

Finally we list the code added for full support of control flow statement,

.. code-block:: c++

    // Cpu0MCCodeEmitter.cpp
    /// getBranchTargetOpValue - Return binary encoding of the branch
    /// target operand. If the machine operand requires relocation,
    /// record the relocation and return zero.
    unsigned Cpu0MCCodeEmitter::
    getBranchTargetOpValue(const MCInst &MI, unsigned OpNo,
                           SmallVectorImpl<MCFixup> &Fixups) const {
    
      const MCOperand &MO = MI.getOperand(OpNo);
      assert(MO.isExpr() && "getBranchTargetOpValue expects only expressions");
    
      const MCExpr *Expr = MO.getExpr();
      Fixups.push_back(MCFixup::Create(0, Expr,
                                       MCFixupKind(Cpu0::fixup_Cpu0_PC24)));
      return 0;
    }
    
    // Cpu0MCInstLower.cpp
    MCOperand Cpu0MCInstLower::LowerSymbolOperand(const MachineOperand &MO,
                                                  MachineOperandType MOTy,
                                                  unsigned Offset) const {
      ...
      switch(MO.getTargetFlags()) {
      default:                   llvm_unreachable("Invalid target flag!");
      case Cpu0II::MO_NO_FLAG:   Kind = MCSymbolRefExpr::VK_None; break;
      ...
      }
      ...
      switch (MOTy) {
      case MachineOperand::MO_MachineBasicBlock:
        Symbol = MO.getMBB()->getSymbol();
        break;
      ...
    }
    
    MCOperand Cpu0MCInstLower::LowerOperand(const MachineOperand& MO,
                                            unsigned offset) const {
      MachineOperandType MOTy = MO.getType();
    
      switch (MOTy) {
      default: llvm_unreachable("unknown operand type");
      case MachineOperand::MO_Register:
      ...
      case MachineOperand::MO_MachineBasicBlock:
      case MachineOperand::MO_GlobalAddress:
      case MachineOperand::MO_BlockAddress:
      ...
      }
      ...
    }
    
    // Cpu0ISelLowering.cpp
    Cpu0TargetLowering::
    Cpu0TargetLowering(Cpu0TargetMachine &TM)
      : TargetLowering(TM, new Cpu0TargetObjectFile()),
        Subtarget(&TM.getSubtarget<Cpu0Subtarget>()) {
      ...
      // Used by legalize types to correctly generate the setcc result.
      // Without this, every float setcc comes with a AND/OR with the result,
      // we don't want this, since the fpcmp result goes to a flag register,
      // which is used implicitly by brcond and select operations.
      AddPromotedToType(ISD::SETCC, MVT::i1, MVT::i32);
      ...
      setOperationAction(ISD::BRCOND,             MVT::Other, Custom);
      
      // Operations not directly supported by Cpu0.
      setOperationAction(ISD::BR_CC,             MVT::Other, Expand);
      ...
    }
    
    // Cpu0InstrFormats.td
    class BranchBase<bits<8> op, dag outs, dag ins, string asmstr,
                      list<dag> pattern, InstrItinClass itin>:
      Cpu0Inst<outs, ins, asmstr, pattern, itin, FrmL>
    {
      bits<24> imm24;
    
      let Opcode = op;
    
      let Inst{23-0}  = imm24;
    }
    
    // Cpu0InstrInfo.td
    // Instruction operand types
    def brtarget    : Operand<OtherVT> {
      let EncoderMethod = "getBranchTargetOpValue";
      let OperandType = "OPERAND_PCREL";
      let DecoderMethod = "DecodeBranchTarget";
    }
    ...
    /// Conditional Branch
    class CBranch<bits<8> op, string instr_asm, RegisterClass RC>:
      BranchBase<op, (outs), (ins RC:$cond, brtarget:$imm24),
                 !strconcat(instr_asm, "\t$imm24"),
                 [], IIBranch> {
      let isBranch = 1;
      let isTerminator = 1;
      let hasDelaySlot = 0;
    }
    
    // Unconditional branch
    class UncondBranch<bits<8> op, string instr_asm>:
      BranchBase<op, (outs), (ins brtarget:$imm24),
                 !strconcat(instr_asm, "\t$imm24"), [(br bb:$imm24)], IIBranch> {
      let isBranch = 1;
      let isTerminator = 1;
      let isBarrier = 1;
      let hasDelaySlot = 0;
    }
    ...
    /// Jump and Branch Instructions
    def JEQ     : CBranch<0x20, "jeq", CPURegs>;
    def JNE     : CBranch<0x21, "jne", CPURegs>;
    def JLT     : CBranch<0x22, "jlt", CPURegs>;
    def JGT     : CBranch<0x23, "jgt", CPURegs>;
    def JLE     : CBranch<0x24, "jle", CPURegs>;
    def JGE     : CBranch<0x25, "jge", CPURegs>;
    def JMP     : UncondBranch<0x26, "jmp">;
    ...
    // brcond patterns
    multiclass BrcondPats<RegisterClass RC, Instruction JEQOp, 
      Instruction JNEOp, Instruction JLTOp, Instruction JGTOp, 
      Instruction JLEOp, Instruction JGEOp, Instruction CMPOp, 
      Register ZEROReg> {          
    def : Pat<(brcond (i32 (seteq RC:$lhs, RC:$rhs)), bb:$dst),
              (JEQOp (CMPOp RC:$lhs, RC:$rhs), bb:$dst)>;
    def : Pat<(brcond (i32 (setueq RC:$lhs, RC:$rhs)), bb:$dst),
              (JEQOp (CMPOp RC:$lhs, RC:$rhs), bb:$dst)>;
    def : Pat<(brcond (i32 (setne RC:$lhs, RC:$rhs)), bb:$dst),
              (JNEOp (CMPOp RC:$lhs, RC:$rhs), bb:$dst)>;
    def : Pat<(brcond (i32 (setune RC:$lhs, RC:$rhs)), bb:$dst),
              (JNEOp (CMPOp RC:$lhs, RC:$rhs), bb:$dst)>;
    def : Pat<(brcond (i32 (setlt RC:$lhs, RC:$rhs)), bb:$dst),
              (JLTOp (CMPOp RC:$lhs, RC:$rhs), bb:$dst)>;
    def : Pat<(brcond (i32 (setult RC:$lhs, RC:$rhs)), bb:$dst),
              (JLTOp (CMPOp RC:$lhs, RC:$rhs), bb:$dst)>;
    def : Pat<(brcond (i32 (setgt RC:$lhs, RC:$rhs)), bb:$dst),
              (JGTOp (CMPOp RC:$lhs, RC:$rhs), bb:$dst)>;
    def : Pat<(brcond (i32 (setugt RC:$lhs, RC:$rhs)), bb:$dst),
              (JGTOp (CMPOp RC:$lhs, RC:$rhs), bb:$dst)>;
    def : Pat<(brcond (i32 (setle RC:$lhs, RC:$rhs)), bb:$dst),
              (JLEOp (CMPOp RC:$rhs, RC:$lhs), bb:$dst)>;
    def : Pat<(brcond (i32 (setule RC:$lhs, RC:$rhs)), bb:$dst),
              (JLEOp (CMPOp RC:$rhs, RC:$lhs), bb:$dst)>;
    def : Pat<(brcond (i32 (setge RC:$lhs, RC:$rhs)), bb:$dst),
              (JGEOp (CMPOp RC:$lhs, RC:$rhs), bb:$dst)>;
    def : Pat<(brcond (i32 (setuge RC:$lhs, RC:$rhs)), bb:$dst),
              (JGEOp (CMPOp RC:$lhs, RC:$rhs), bb:$dst)>;
    
    def : Pat<(brcond RC:$cond, bb:$dst),
              (JNEOp (CMPOp RC:$cond, ZEROReg), bb:$dst)>;
    }
    
    defm : BrcondPats<CPURegs, JEQ, JNE, JLT, JGT, JLE, JGE, CMP, ZERO>;

The ch7_1_2.cpp is for **“nest if”** test. The ch7_1_3.cpp is the 
**“for loop”** as well as **“while loop”**, **“continue”**, **“break”**, 
**“goto”** test. 
You can run with them if you like to test more.

Finally, 7/1/Cpu0 support the local array definition by add the LowerCall() 
empty function in Cpu0ISelLowering.cpp as follows,

.. code-block:: c++

  // Cpu0ISelLowering.cpp
  SDValue
  Cpu0TargetLowering::LowerCall(TargetLowering::CallLoweringInfo &CLI,
                  SmallVectorImpl<SDValue> &InVals) const {
    return CLI.Chain;
  }


With this LowerCall(), it can translate ch7_1_4.cpp, ch7_1_4.bc to 
ch7_1_4.cpu0.s as follows,

.. code-block:: c++

    // ch7_1_4.cpp
    int main()
    {
        int a[3]={0, 1, 2};
        
        return 0;
    }

.. code-block:: bash

    ; ModuleID = 'ch7_1_4 .bc'
    target datalayout = "e-p:32:32:32-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:32:64-
    f32:32:32-f64:32:64-v64:64:64-v128:128:128-a0:0:64-f80:128:128-n8:16:32-S128"
    target triple = "i386-apple-macosx10.8.0"
    
    @_ZZ4mainE1a = private unnamed_addr constant [3 x i32] [i32 0, i32 1, i32 2], 
    align 4
    
    define i32 @main() nounwind ssp {
    entry:
      %retval = alloca i32, align 4
      %a = alloca [3 x i32], align 4
      store i32 0, i32* %retval
      %0 = bitcast [3 x i32]* %a to i8*
      call void @llvm.memcpy.p0i8.p0i8.i32(i8* %0, i8* bitcast ([3 x i32]* 
        @_ZZ4mainE1a to i8*), i32 12, i32 4, i1 false)
      ret i32 0
    }
    
    118-165-79-206:InputFiles Jonathan$ cat ch7_1_4.cpu0.s 
        .section .mdebug.abi32
        .previous
        .file   "ch7_1_4.bc"
        .text
        .globl  main
        .align  2
        .type   main,@function
        .ent    main                    # @main
    main:
        .frame  $sp,24,$lr
        .mask   0x00000000,0
        .set    noreorder
        .cpload $t9
        .set    nomacro
    # BB#0:                                 # %entry
        addiu   $sp, $sp, -24
        ld  $2, %got(__stack_chk_guard)($gp)
        ld  $3, 0($2)
        st  $3, 20($sp)
        addiu   $3, $zero, 0
        st  $3, 16($sp)
        ld  $3, %got($_ZZ4mainE1a)($gp)
        addiu   $3, $3, %lo($_ZZ4mainE1a)
        ld  $4, 8($3)
        st  $4, 12($sp)
        ld  $4, 4($3)
        st  $4, 8($sp)
        ld  $3, 0($3)
        st  $3, 4($sp)
        ld  $2, 0($2)
        ld  $3, 20($sp)
        cmp $2, $3
        jne $BB0_2
        jmp $BB0_1
    $BB0_1:                                 # %SP_return
        addiu   $sp, $sp, 24
        ret $lr
    $BB0_2:                                 # %CallStackCheckFailBlk
        .set    macro
        .set    reorder
        .end    main
    $tmp1:
        .size   main, ($tmp1)-main
    
        .type   $_ZZ4mainE1a,@object    # @_ZZ4mainE1a
        .section    .rodata,"a",@progbits
        .align  2
    $_ZZ4mainE1a:
        .4byte  0                       # 0x0
        .4byte  1                       # 0x1
        .4byte  2                       # 0x2
        .size   $_ZZ4mainE1a, 12

The ch7_1_5.cpp is for test C operators **==, !=, &&, ||**. No code need to 
add since we have take care them before. 
But it can be test only when the control flow statement support is ready, as 
follows,

.. code-block:: c++

  // ch7_1_5.cpp
  int main()
  {
    unsigned int a = 0;
    int b = 1;
    int c = 2;
    
    if ((a == 0 && b == 2) || (c != 2)) {
      a++;
    }
    
    return 0;
  }

.. code-block:: bash

  118-165-78-230:InputFiles Jonathan$ clang -c ch7_1_5.cpp -emit-llvm -o ch7_1_5.bc
  118-165-78-230:InputFiles Jonathan$ /Users/Jonathan/llvm/test/cmake_debug_build/
  bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=asm ch7_1_5.bc -o 
  ch7_1_5.cpu0.s
  118-165-78-230:InputFiles Jonathan$ cat ch7_1_5.cpu0.s 
    .section .mdebug.abi32
    .previous
    .file "ch7_1_5.bc"
    .text
    .globl  main
    .align  2
    .type main,@function
    .ent  main                    # @main
  main:
    .cfi_startproc
    .frame  $sp,16,$lr
    .mask   0x00000000,0
    .set  noreorder
    .set  nomacro
  # BB#0:
    addiu $sp, $sp, -16
  $tmp1:
    .cfi_def_cfa_offset 16
    addiu $3, $zero, 0
    st  $3, 12($sp)
    st  $3, 8($sp)
    addiu $2, $zero, 1
    st  $2, 4($sp)
    addiu $2, $zero, 2
    st  $2, 0($sp)
    ld  $4, 8($sp)
    cmp $4, $3
    jne $BB0_2		// a != 0
    jmp $BB0_1
  $BB0_1:			// a == 0
    ld  $3, 4($sp)
    cmp $3, $2
    jeq $BB0_3		// b == 2
    jmp $BB0_2
  $BB0_2:
    ld  $3, 0($sp)
    cmp $3, $2		// c == 2
    jeq $BB0_4
    jmp $BB0_3
  $BB0_3:			// (a == 0 && b == 2) || (c != 2)
    ld  $2, 8($sp)
    addiu $2, $2, 1	// a++
    st  $2, 8($sp)
  $BB0_4:
    addiu $sp, $sp, 16
    ret $lr
    .set  macro
    .set  reorder
    .end  main
  $tmp2:
    .size main, ($tmp2)-main
    .cfi_endproc


RISC CPU knowledge
-------------------

As mentioned in the previous section, cpu0 is a RISC (Reduced Instruction Set 
Computer) CPU with 3 stages of pipeline. 
RISC CPU is full in world. 
Even the X86 of CISC (Complex Instruction Set Computer) is RISC inside. 
(It translate CISC instruction into micro-instruction which do pipeline as 
RISC). Knowledge with RISC will make you satisfied in compiler design. 
List these two excellent books we have read which include the real RISC CPU 
knowledge needed for reference. 
Sure, there are many books in Computer Architecture, and some of them contain 
real RISC CPU knowledge needed, but these two are what we read.

Computer Organization and Design: The Hardware/Software Interface (The Morgan 
Kaufmann Series in Computer Architecture and Design)

Computer Architecture: A Quantitative Approach (The Morgan Kaufmann Series in 
Computer Architecture and Design) 

The book of “Computer Organization and Design: The Hardware/Software Interface” 
(there are 4 editions until the book is written) is for the introduction 
(simple). 
“Computer Architecture: A Quantitative Approach” (there are 5 editions until 
the book is written) is more complicate and deep in CPU architecture. 

