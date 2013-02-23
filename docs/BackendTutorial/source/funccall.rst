.. _sec-funccall:

Function call
==============

The subroutine/function call of backend code translation is supported in this 
chapter. 
A lots of code needed in function call. We break it down according llvm 
supplied interface for easy to explanation. 
This chapter start from introducing the Mips stack frame structure since we 
borrow many part of ABI from it. 
Although each CPU has it's own ABI, most of RISC CPUs ABI are similar. 
In addition to support fixed number of arguments function call, cpu0 also 
upport variable number of arguments since C/C++ support this feature. 
Supply Mips ABI and assemble language manual on internet link in this chapter 
for your reference. 
The section “4.5 DAG Lowering” of tricore_llvm.pdf contains some knowledge 
about Lowering process. Section “4.5.1 Calling Conventions” of tricore_llvm.pdf 
is the related materials you can reference.

This chapter is more complicate than any of the previous chapter. 
It include stack frame and the related ABI support. 
If you have problem in reading the stack frame illustrated in the first three 
sections of this chapter, you can read the appendix B of “Procedure Call 
Convention” of book “Computer Organization and Design” which listed in 
section “RISC CPU knowledge” of chapter “Control flow statement” [#]_, 
“Run Time Memory” of compiler book, or “Function Call Sequence”  and 
“Stack Frame” of Mips ABI.

Mips stack frame
-----------------

The first thing for design the cpu0 function call is deciding how to pass 
arguments in function call. There are two options. 
The first is pass arguments all in stack. 
Second is pass arguments in the registers which are reserved for function 
arguments, and put the other arguments in stack if it over the number of 
registers reserved for function call. For example, Mips pass the first 4 
arguments in register $a0, $a1, $a2, $a3, and the other arguments in stack 
if it over 4 arguments. :num:`Figure #funccall-f1` is the Mips stack frame.

.. _funccall-f1:
.. figure:: ../Fig/funccall/1.png
    :height: 531 px
    :width: 688 px
    :scale: 100 %
    :align: center

    Mips stack frame
    
Run ``llc -march=mips`` for ch8_1.bc, you will get the following result. 
See comment **"//"**.

.. code-block:: c++

  // ch8_1.cpp
  int sum_i(int x1, int x2, int x3, int x4, int x5, int x6)
  {
      int sum = x1 + x2 + x3 + x4 + x5 + x6;
        
      return sum; 
  }
    
  int main()
  {
      int a = sum_i(1, 2, 3, 4, 5, 6);
        
      return a;
  }

.. code-block:: bash

  118-165-78-230:InputFiles Jonathan$ clang -c ch8_1.cpp -emit-llvm -o ch8_1.bc
  118-165-78-230:InputFiles Jonathan$ /Users/Jonathan/llvm/test/cmake_debug_build/
  bin/Debug/llc -march=mips -relocation-model=pic -filetype=asm ch8_1.bc -o 
  ch8_1.mips.s
  118-165-78-230:InputFiles Jonathan$ cat ch8_1.mips.s 
    .section .mdebug.abi32
    .previous
    .file "ch8_1.bc"
    .text
    .globl  _Z5sum_iiiiiii
    .align  2
    .type _Z5sum_iiiiiii,@function
    .set  nomips16                # @_Z5sum_iiiiiii
    .ent  _Z5sum_iiiiiii
  _Z5sum_iiiiiii:
    .cfi_startproc
    .frame  $sp,32,$ra
    .mask   0x00000000,0
    .fmask  0x00000000,0
    .set  noreorder
    .set  nomacro
    .set  noat
  # BB#0:
    addiu $sp, $sp, -32
  $tmp1:
    .cfi_def_cfa_offset 32
    sw  $4, 28($sp)
    sw  $5, 24($sp)
    sw  $6, 20($sp)
    sw  $7, 16($sp)
    lw  $1, 48($sp) // load argument 5
    sw  $1, 12($sp)
    lw  $1, 52($sp) // load argument 6
    sw  $1, 8($sp)
    lw  $2, 24($sp)
    lw  $3, 28($sp)
    addu  $2, $3, $2
    lw  $3, 20($sp)
    addu  $2, $2, $3
    lw  $3, 16($sp)
    addu  $2, $2, $3
    lw  $3, 12($sp)
    addu  $2, $2, $3
    addu  $2, $2, $1
    sw  $2, 4($sp)
    jr  $ra
    addiu $sp, $sp, 32
    .set  at
    .set  macro
    .set  reorder
    .end  _Z5sum_iiiiiii
  $tmp2:
    .size _Z5sum_iiiiiii, ($tmp2)-_Z5sum_iiiiiii
    .cfi_endproc
  
    .globl  main
    .align  2
    .type main,@function
    .set  nomips16                # @main
    .ent  main
  main:
    .cfi_startproc
    .frame  $sp,40,$ra
    .mask   0x80000000,-4
    .fmask  0x00000000,0
    .set  noreorder
    .set  nomacro
    .set  noat
  # BB#0:
    lui $2, %hi(_gp_disp)
    addiu $2, $2, %lo(_gp_disp)
    addiu $sp, $sp, -40
  $tmp5:
    .cfi_def_cfa_offset 40
    sw  $ra, 36($sp)            # 4-byte Folded Spill
  $tmp6:
    .cfi_offset 31, -4
    addu  $gp, $2, $25
    sw  $zero, 32($sp)
    addiu $1, $zero, 6
    sw  $1, 20($sp) // Save argument 6 to 20($sp)
    addiu $1, $zero, 5
    sw  $1, 16($sp) // Save argument 5 to 16($sp)
    lw  $25, %call16(_Z5sum_iiiiiii)($gp)
    addiu $4, $zero, 1    // Pass argument 1 to $4 (=$a0)
    addiu $5, $zero, 2    // Pass argument 2 to $5 (=$a1)
    addiu $6, $zero, 3
    jalr  $25
    addiu $7, $zero, 4
    sw  $2, 28($sp)
    lw  $ra, 36($sp)            # 4-byte Folded Reload
    jr  $ra
    addiu $sp, $sp, 40
    .set  at
    .set  macro
    .set  reorder
    .end  main
  $tmp7:
    .size main, ($tmp7)-main
    .cfi_endproc


From the mips assembly code generated as above, we know it save the first 4 
arguments to $a0..$a3 and last 2 arguments to 16($sp) and 20($sp). 
:num:`Figure #funccall-f2` is the arguments location for example code 
ch8_1.cpp. 
It load argument 5 from 48($sp) in sum_i() since the argument 5 is saved to 
16($sp) in main(). 
The stack size of sum_i() is 32, so 16+32($sp) is the location of incoming 
argument 5.

.. _funccall-f2:
.. figure:: ../Fig/funccall/2.png
    :height: 577 px
    :width: 740 px
    :scale: 100 %
    :align: center

    Mips arguments location in stack frame


The 007-2418-003.pdf in [#]_ is the Mips assembly language manual. 
[#]_ is Mips Application Binary Interface which include the 
:num:`Figure #funccall-f1`.

Load incoming arguments from stack frame
-----------------------------------------

From last section, to support function call, we need implementing the arguments 
pass mechanism with stack frame. Before do that, let's run the old version of 
code 7/1/Cpu0 with ch8_1.cpp and see what happen.

.. code-block:: bash

  118-165-79-31:InputFiles Jonathan$ /Users/Jonathan/llvm/test/
  cmake_debug_build/bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=asm 
  ch8_1.bc -o ch8_1.cpu0.s
  Assertion failed: (InVals.size() == Ins.size() && "LowerFormalArguments didn't 
  emit the correct number of values!"), function LowerArguments, file /Users/
  Jonathan/llvm/test/src/lib/CodeGen/SelectionDAG/
  SelectionDAGBuilder.cpp, ...
  ...
  0.  Program arguments: /Users/Jonathan/llvm/test/cmake_debug_build/
  bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=asm ch8_1.bc -o 
  ch8_1.cpu0.s 
  1.  Running pass 'Function Pass Manager' on module 'ch8_1.bc'.
  2.  Running pass 'CPU0 DAG->DAG Pattern Instruction Selection' on function 
  '@_Z5sum_iiiiiii'
  Illegal instruction: 4

Since 7/1/Cpu0 define the LowerFormalArguments() with empty, we get the error 
message as above. 
Before define LowerFormalArguments(), we have to choose how to pass arguments 
in function call. We choose pass arguments all in stack frame. 
We don't reserve any dedicated register for arguments passing since cpu0 has 
only 16 registers while Mips has 32 registers. Cpu0CallingConv.td is defined 
for cpu0 passing rule as follows,

.. code-block:: c++

  // Cpu0CallingConv.td
  ...
  def RetCC_Cpu0EABI : CallingConv<[ 
    // i32 are returned in registers V0, V1, A0, A1
    CCIfType<[i32], CCAssignToReg<[V0, V1, A0, A1]>>
  ]>;
    
  //===----------------------------------------------------------------------===//
  // Cpu0 EABI Calling Convention
  //===----------------------------------------------------------------------===//
    
  def CC_Cpu0EABI : CallingConv<[
    // Promote i8/i16 arguments to i32.
    CCIfType<[i8, i16], CCPromoteToType<i32>>,
    // Integer values get stored in stack slots that are 4 bytes in
    // size and 4-byte aligned.
    CCIfType<[i32], CCAssignToStack<4, 4>>
  ]>;
    
    
  //===----------------------------------------------------------------------===//
  // Cpu0 Calling Convention Dispatch
  //===----------------------------------------------------------------------===//
    
  def CC_Cpu0 : CallingConv<[
    CCDelegateTo<CC_Cpu0EABI>
  ]>;
    
    
  def RetCC_Cpu0 : CallingConv<[
    CCDelegateTo<RetCC_Cpu0EABI>
  ]>;
    
  def CSR_O32 : CalleeSavedRegs<(add LR, FP,
                                     (sequence "S%u", 2, 0))>;


As above, CC_Cpu0 is the cpu0 Calling Convention which delegate to CC_Cpu0EABI 
and define the CC_Cpu0EABI. 
The reason we don't define the Calling Convention directly in CC_Cpu0 is that 
a real general CPU like Mips can have several Calling Convention. 
Combine with the mechanism of "section Target Registration" [#]_ which llvm 
supplied, we can use different Calling Convention in  different target. 
Although cpu0 only have a Calling Convention right now, define with a dedicate 
Call Convention name (CC_Cpu0EABI in this example) is a better solution for 
system expand, and naming your Calling Convention. CC_Cpu0EABI as above, say it 
pass arguments in stack frame.

Function LowerFormalArguments() charge function incoming arguments creation. 
We define it as follows,

.. code-block:: c++

  // Cpu0ISelLowering.cpp
  ...
  /// LowerFormalArguments - transform physical registers into virtual registers
  /// and generate load operations for arguments places on the stack.
  SDValue
  Cpu0TargetLowering::LowerFormalArguments(SDValue Chain,
                                           CallingConv::ID CallConv,
                                           bool isVarArg,
                                        const SmallVectorImpl<ISD::InputArg> &Ins,
                                           DebugLoc dl, SelectionDAG &DAG,
                                           SmallVectorImpl<SDValue> &InVals)
                                            const {
    MachineFunction &MF = DAG.getMachineFunction();
    MachineFrameInfo *MFI = MF.getFrameInfo();
    Cpu0FunctionInfo *Cpu0FI = MF.getInfo<Cpu0FunctionInfo>();
    
    Cpu0FI->setVarArgsFrameIndex(0);
    
    // Used with vargs to acumulate store chains.
    std::vector<SDValue> OutChains;
    
    // Assign locations to all of the incoming arguments.
    SmallVector<CCValAssign, 16> ArgLocs;
    CCState CCInfo(CallConv, isVarArg, DAG.getMachineFunction(),
                   getTargetMachine(), ArgLocs, *DAG.getContext());
                             
    CCInfo.AnalyzeFormalArguments(Ins, CC_Cpu0);
    
    Function::const_arg_iterator FuncArg =
      DAG.getMachineFunction().getFunction()->arg_begin();
    int LastFI = 0;// Cpu0FI->LastInArgFI is 0 at the entry of this function.
    
    for (unsigned i = 0, e = ArgLocs.size(); i != e; ++i, ++FuncArg) {
      CCValAssign &VA = ArgLocs[i];
      EVT ValVT = VA.getValVT();
      ISD::ArgFlagsTy Flags = Ins[i].Flags;
      bool IsRegLoc = VA.isRegLoc();
    
      if (Flags.isByVal()) {
        assert(Flags.getByValSize() &&
               "ByVal args of size 0 should have been ignored by front-end."); 
        continue;
      }
      // sanity check
      assert(VA.isMemLoc());
    
      // The stack pointer offset is relative to the caller stack frame.
      LastFI = MFI->CreateFixedObject(ValVT.getSizeInBits()/8,
                                      VA.getLocMemOffset(), true);
    
      // Create load nodes to retrieve arguments from the stack
      SDValue FIN = DAG.getFrameIndex(LastFI, getPointerTy());
      InVals.push_back(DAG.getLoad(ValVT, dl, Chain, FIN,
                                   MachinePointerInfo::getFixedStack(LastFI),
                                     false, false, false, 0));
    }
    Cpu0FI->setLastInArgFI(LastFI);
    // All stores are grouped in one node to allow the matching between
    // the size of Ins and InVals. This only happens when on varg functions
    if (!OutChains.empty()) {
      OutChains.push_back(Chain);
      Chain = DAG.getNode(ISD::TokenFactor, dl, MVT::Other,
                          &OutChains[0], OutChains.size());
    }
    return Chain;
  }


Refresh "section Global variable" [#]_, we handled global 
variable translation by create the IR DAG in LowerGlobalAddress() first, and 
then do the Instruction Selection by their corresponding machine instruction 
DAG in Cpu0InstrInfo.td. 
LowerGlobalAddress() is called when ``llc`` meet the global variable access. 
LowerFormalArguments() work with the same way. 
It is called when function is entered. 
It get incoming arguments information by CCInfo(CallConv,..., ArgLocs, ...) 
before enter **“for loop”**. In ch8_1.cpp, there are 6 arguments in sum_i(...) 
function call and we use the stack frame only for arguments passing without 
any arguments pass in registers. 
So ArgLocs.size() is 6, each argument information is in ArgLocs[i] and 
ArgLocs[i].isMemLoc() is true. 
In **“for loop”**, it create each frame index object by LastFI = 
MFI->CreateFixedObject(ValVT.getSizeInBits()/8,VA.getLocMemOffset(), true) and 
FIN = DAG.getFrameIndex(LastFI, getPointerTy()). 
And then create IR DAG load node and put the load node into vector InVals by 
InVals.push_back(DAG.getLoad(ValVT, dl, Chain, FIN, 
MachinePointerInfo::getFixedStack(LastFI), false, false, false, 0)). 
Cpu0FI->setVarArgsFrameIndex(0) and Cpu0FI->setLastInArgFI(LastFI) are called 
when before and after above work. In ch8_1.cpp example, LowerFormalArguments() 
will be called twice. First time is for sum_i() which will create 6 load DAG 
for 6 incoming arguments passing into this function. 
Second time is for main() which didn't create any load DAG for no incoming 
argument passing into main(). 
In addition to LowerFormalArguments() which create the load DAG, we need to 
define the loadRegFromStackSlot() to issue the machine instruction 
**“ld $r, offset($sp)”** to load incoming arguments from stack frame offset.
GetMemOperand(..., FI, ...) return the Memory location of the frame index 
variable, which is the offset.

.. code-block:: c++
    
  // Cpu0InstrInfo.cpp
  ...
  static MachineMemOperand* GetMemOperand(MachineBasicBlock &MBB, int FI,
                                          unsigned Flag) {
    MachineFunction &MF = *MBB.getParent();
    MachineFrameInfo &MFI = *MF.getFrameInfo();
    unsigned Align = MFI.getObjectAlignment(FI);
    
    return MF.getMachineMemOperand(MachinePointerInfo::getFixedStack(FI), Flag,
                                   MFI.getObjectSize(FI), Align);
  }
    
  void Cpu0InstrInfo::
  loadRegFromStackSlot(MachineBasicBlock &MBB, MachineBasicBlock::iterator I,
                       unsigned DestReg, int FI,
                       const TargetRegisterClass *RC,
                       const TargetRegisterInfo *TRI) const
  {
    DebugLoc DL;
    if (I != MBB.end()) DL = I->getDebugLoc();
    MachineMemOperand *MMO = GetMemOperand(MBB, FI, MachineMemOperand::MOLoad);
    unsigned Opc = 0;
    
    if (RC == Cpu0::CPURegsRegisterClass)
      Opc = Cpu0::LD;
    assert(Opc && "Register class not handled!");
    BuildMI(MBB, I, DL, get(Opc), DestReg).addFrameIndex(FI).addImm(0)
      .addMemOperand(MMO);
  }


In addition to Calling Convention and LowerFormalArguments(), 8/2/Cpu0 add the 
following code for cpu0 instructions **swi** (Software Interrupt), **jsub** and 
**jalr** (function call) definition and printing.

.. code-block:: c++

  // Cpu0InstrFormats.td
  ...
  // Cpu0 Pseudo Instructions Format
  class Cpu0Pseudo<dag outs, dag ins, string asmstr, list<dag> pattern>:
        Cpu0Inst<outs, ins, asmstr, pattern, IIPseudo, Pseudo> {
    let isCodeGenOnly = 1;
    let isPseudo = 1;
  }
    
  // Cpu0InstrInfo.td
  ...
  def SDT_Cpu0JmpLink      : SDTypeProfile<0, 1, [SDTCisVT<0, iPTR>]>;
  ...
  // Call
  def Cpu0JmpLink : SDNode<"Cpu0ISD::JmpLink",SDT_Cpu0JmpLink,
                           [SDNPHasChain, SDNPOutGlue, SDNPOptInGlue,
                            SDNPVariadic]>;
  ...
  def jmptarget   : Operand<OtherVT> {
    let EncoderMethod = "getJumpTargetOpValue";
  }
  ...
  def calltarget  : Operand<iPTR> {
    let EncoderMethod = "getJumpTargetOpValue";
  }
  ...
  // Jump and Link (Call)
  let isCall=1, hasDelaySlot=0 in {
    class JumpLink<bits<8> op, string instr_asm>:
      FJ<op, (outs), (ins calltarget:$target, variable_ops),
         !strconcat(instr_asm, "\t$target"), [(Cpu0JmpLink imm:$target)],
         IIBranch> {
         let DecoderMethod = "DecodeJumpTarget";
         }
    
    class JumpLinkReg<bits<8> op, string instr_asm,
                      RegisterClass RC>:
      FA<op, (outs), (ins RC:$rb, variable_ops),
         !strconcat(instr_asm, "\t$rb"), [(Cpu0JmpLink RC:$rb)], IIBranch> {
      let rc = 0;
      let ra = 14;
      let shamt = 0;
    }
  }
  ...
  /// Jump and Branch Instructions
  def SWI  : JumpLink<0x2A, "swi">;
  def JSUB : JumpLink<0x2B, "jsub">;
  ...
  def IRET    : JumpFR<0x2D, "iret", CPURegs>;
  def JALR    : JumpLinkReg<0x2E, "jalr", CPURegs>;
  ...
  def : Pat<(Cpu0JmpLink (i32 tglobaladdr:$dst)),
            (JSUB tglobaladdr:$dst)>;
  ...
    
  // Cpu0InstPrinter.cpp
  ...
  static void printExpr(const MCExpr *Expr, raw_ostream &OS) {
    switch (Kind) {
    ...
    case MCSymbolRefExpr::VK_Cpu0_GOT_CALL:  OS << "%call24("; break;
    ...
    }
  ...
  }
    
  // Cpu0MCCodeEmitter.cpp
  ...
  unsigned Cpu0MCCodeEmitter::
  getMachineOpValue(const MCInst &MI, const MCOperand &MO,
                    SmallVectorImpl<MCFixup> &Fixups) const {
  ...
    switch(cast<MCSymbolRefExpr>(Expr)->getKind()) {
    ...
    case MCSymbolRefExpr::VK_Cpu0_GOT_CALL:
      FixupKind = Cpu0::fixup_Cpu0_CALL24;
      break;
    ...
    }
  ...
  }
    
  // Cpu0MachineFucntion.h
  class Cpu0FunctionInfo : public MachineFunctionInfo {
    ...
      /// VarArgsFrameIndex - FrameIndex for start of varargs area.
    int VarArgsFrameIndex;
  
    // Range of frame object indices.
    // InArgFIRange: Range of indices of all frame objects created during call to
    //               LowerFormalArguments.
    // OutArgFIRange: Range of indices of all frame objects created during call to
    //                LowerCall except for the frame object for restoring $gp.
    std::pair<int, int> InArgFIRange, OutArgFIRange;
    int GPFI; // Index of the frame object for restoring $gp
    mutable int DynAllocFI; // Frame index of dynamically allocated stack area.
    unsigned MaxCallFrameSize;
  
  public:
    Cpu0FunctionInfo(MachineFunction& MF)
    : MF(MF), GlobalBaseReg(0),
      VarArgsFrameIndex(0), InArgFIRange(std::make_pair(-1, 0)),
      OutArgFIRange(std::make_pair(-1, 0)), GPFI(0), DynAllocFI(0),
      MaxCallFrameSize(0)
      {}
      
    bool isInArgFI(int FI) const {
      return FI <= InArgFIRange.first && FI >= InArgFIRange.second;
    }
    void setLastInArgFI(int FI) { InArgFIRange.second = FI; }
    
    void extendOutArgFIRange(int FirstFI, int LastFI) {
      if (!OutArgFIRange.second)
        // this must be the first time this function was called.
        OutArgFIRange.first = FirstFI;
      OutArgFIRange.second = LastFI;
    }
    
    int getGPFI() const { return GPFI; }
    void setGPFI(int FI) { GPFI = FI; }
    bool needGPSaveRestore() const { return getGPFI(); }
    bool isGPFI(int FI) const { return GPFI && GPFI == FI; }
    
    // The first call to this function creates a frame object for dynamically
    // allocated stack area.
    int getDynAllocFI() const {
      if (!DynAllocFI)
        DynAllocFI = MF.getFrameInfo()->CreateFixedObject(4, 0, true);
    
      return DynAllocFI;
    }
    bool isDynAllocFI(int FI) const { return DynAllocFI && DynAllocFI == FI; }
    ...
    int getVarArgsFrameIndex() const { return VarArgsFrameIndex; }
    void setVarArgsFrameIndex(int Index) { VarArgsFrameIndex = Index; }
    
    unsigned getMaxCallFrameSize() const { return MaxCallFrameSize; }
    void setMaxCallFrameSize(unsigned S) { MaxCallFrameSize = S; }
  };


After above changes, you can run 8/2/Cpu0 with ch8_1.cpp and see what happens 
in the following,

.. code-block:: bash

  118-165-79-83:InputFiles Jonathan$ /Users/Jonathan/llvm/test/
  cmake_debug_build/bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=asm 
  ch8_1.bc -o ch8_1.cpu0.s
  Assertion failed: ((CLI.IsTailCall || InVals.size() == CLI.Ins.size()) && 
  "LowerCall didn't emit the correct number of values!"), function LowerCallTo, 
  file /Users/Jonathan/llvm/test/src/lib/CodeGen/SelectionDAG/SelectionDAGBuilder.
  cpp, ...
  ...
  0.  Program arguments: /Users/Jonathan/llvm/test/cmake_debug_build/
  bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=asm ch8_1.bc -o 
  ch8_1.cpu0.s 
  1.  Running pass 'Function Pass Manager' on module 'ch8_1.bc'.
  2.  Running pass 'CPU0 DAG->DAG Pattern Instruction Selection' on function 
  '@main'
  Illegal instruction: 4
  
Now, the LowerFormalArguments() has the correct number, but LowerCall() has not  
the correct number of values!


Store outgoing arguments to stack frame
----------------------------------------

:num:`Figure #funccall-f2` depicted two steps to take care arguments passing. 
One is store outgoing arguments in caller function, and the other is load 
incoming arguments in callee function. 
We defined LowerFormalArguments() for **“load incoming arguments”** in callee 
function last section. 
Now, we will finish **“store outgoing arguments”** in caller function. 
LowerCall() is responsible to do this. The implementation as follows,

.. code-block:: c++

  // Cpu0ISelLowering.cpp
  ...
  SDValue
  Cpu0TargetLowering::LowerCall(TargetLowering::CallLoweringInfo &CLI,
                  SmallVectorImpl<SDValue> &InVals) const {
    SelectionDAG &DAG                     = CLI.DAG;
    DebugLoc &dl                          = CLI.DL;
    SmallVector<ISD::OutputArg, 32> &Outs = CLI.Outs;
    SmallVector<SDValue, 32> &OutVals     = CLI.OutVals;
    SmallVector<ISD::InputArg, 32> &Ins   = CLI.Ins;
    SDValue InChain                       = CLI.Chain;
    SDValue Callee                        = CLI.Callee;
    bool &isTailCall                      = CLI.IsTailCall;
    CallingConv::ID CallConv              = CLI.CallConv;
    bool isVarArg                         = CLI.IsVarArg;
  
    MachineFunction &MF = DAG.getMachineFunction();
    MachineFrameInfo *MFI = MF.getFrameInfo();
    const TargetFrameLowering *TFL = MF.getTarget().getFrameLowering();
    bool IsPIC = getTargetMachine().getRelocationModel() == Reloc::PIC_;
    Cpu0FunctionInfo *Cpu0FI = MF.getInfo<Cpu0FunctionInfo>();
  
    // Analyze operands of the call, assigning locations to each operand.
    SmallVector<CCValAssign, 16> ArgLocs;
    CCState CCInfo(CallConv, isVarArg, DAG.getMachineFunction(),
                   getTargetMachine(), ArgLocs, *DAG.getContext());
  
    CCInfo.AnalyzeCallOperands(Outs, CC_Cpu0);
  
    // Get a count of how many bytes are to be pushed on the stack.
    unsigned NextStackOffset = CCInfo.getNextStackOffset();
  
    // If this is the first call, create a stack frame object that points to
    // a location to which .cprestore saves $gp.
    if (IsPIC && Cpu0FI->globalBaseRegFixed() && !Cpu0FI->getGPFI())
      Cpu0FI->setGPFI(MFI->CreateFixedObject(4, 0, true));
    // Get the frame index of the stack frame object that points to the location
    // of dynamically allocated area on the stack.
    int DynAllocFI = Cpu0FI->getDynAllocFI();
    unsigned MaxCallFrameSize = Cpu0FI->getMaxCallFrameSize();
  
    if (MaxCallFrameSize < NextStackOffset) {
      Cpu0FI->setMaxCallFrameSize(NextStackOffset);
  
      // Set the offsets relative to $sp of the $gp restore slot and dynamically
      // allocated stack space. These offsets must be aligned to a boundary
      // determined by the stack alignment of the ABI.
      unsigned StackAlignment = TFL->getStackAlignment();
      NextStackOffset = (NextStackOffset + StackAlignment - 1) /
                         StackAlignment * StackAlignment;
  
      MFI->setObjectOffset(DynAllocFI, NextStackOffset);
    }
    // Chain is the output chain of the last Load/Store or CopyToReg node.
    // ByValChain is the output chain of the last Memcpy node created for copying
    // byval arguments to the stack.
    SDValue Chain, CallSeqStart, ByValChain;
    SDValue NextStackOffsetVal = DAG.getIntPtrConstant(NextStackOffset, true);
    Chain = CallSeqStart = DAG.getCALLSEQ_START(InChain, NextStackOffsetVal);
    ByValChain = InChain;
  
    // With EABI is it possible to have 16 args on registers.
    SmallVector<std::pair<unsigned, SDValue>, 16> RegsToPass;
    SmallVector<SDValue, 8> MemOpChains;
  
    int FirstFI = -MFI->getNumFixedObjects() - 1, LastFI = 0;
  
    // Walk the register/memloc assignments, inserting copies/loads.
    for (unsigned i = 0, e = ArgLocs.size(); i != e; ++i) {
      SDValue Arg = OutVals[i];
      CCValAssign &VA = ArgLocs[i];
      MVT ValVT = VA.getValVT(), LocVT = VA.getLocVT();
      ISD::ArgFlagsTy Flags = Outs[i].Flags;
  
      // ByVal Arg.
      if (Flags.isByVal()) {
        assert("!!!Error!!!, Flags.isByVal()==true");
        assert(Flags.getByValSize() &&
               "ByVal args of size 0 should have been ignored by front-end.");
        continue;
      }
  
      // Register can't get to this point...
      assert(VA.isMemLoc());
  
      // Create the frame index object for this incoming parameter
      LastFI = MFI->CreateFixedObject(ValVT.getSizeInBits()/8,
                                      VA.getLocMemOffset(), true);
      SDValue PtrOff = DAG.getFrameIndex(LastFI, getPointerTy());
  
      // emit ISD::STORE whichs stores the
      // parameter value to a stack Location
      MemOpChains.push_back(DAG.getStore(Chain, dl, Arg, PtrOff,
                                         MachinePointerInfo(), false, false, 0));
    }
  
    // Extend range of indices of frame objects for outgoing arguments that were
    // created during this function call. Skip this step if no such objects were
    // created.
    if (LastFI)
      Cpu0FI->extendOutArgFIRange(FirstFI, LastFI);
  
    // If a memcpy has been created to copy a byval arg to a stack, replace the
    // chain input of CallSeqStart with ByValChain.
    if (InChain != ByValChain)
      DAG.UpdateNodeOperands(CallSeqStart.getNode(), ByValChain,
                             NextStackOffsetVal);
  
    // Transform all store nodes into one single node because all store
    // nodes are independent of each other.
    if (!MemOpChains.empty())
      Chain = DAG.getNode(ISD::TokenFactor, dl, MVT::Other,
                            &MemOpChains[0], MemOpChains.size());
  
    // If the callee is a GlobalAddress/ExternalSymbol node (quite common, every
    // direct call is) turn it into a TargetGlobalAddress/TargetExternalSymbol
    // node so that legalize doesn't hack it.
    unsigned char OpFlag;
    bool IsPICCall = IsPIC; // true if calls are translated to jalr $25
    bool GlobalOrExternal = false;
    SDValue CalleeLo;
  
    if (GlobalAddressSDNode *G = dyn_cast<GlobalAddressSDNode>(Callee)) {
      OpFlag = IsPICCall ? Cpu0II::MO_GOT_CALL : Cpu0II::MO_NO_FLAG;
      Callee = DAG.getTargetGlobalAddress(G->getGlobal(), dl,
                                            getPointerTy(), 0, OpFlag);
      GlobalOrExternal = true;
    }
    else if (ExternalSymbolSDNode *S = dyn_cast<ExternalSymbolSDNode>(Callee)) {
      if (!IsPIC) // static
        OpFlag = Cpu0II::MO_NO_FLAG;
      else // O32 & PIC
        OpFlag = Cpu0II::MO_GOT_CALL;
      Callee = DAG.getTargetExternalSymbol(S->getSymbol(), getPointerTy(),
                                           OpFlag);
      GlobalOrExternal = true;
    }
  
    SDValue InFlag;
  
    // Create nodes that load address of callee and copy it to T9
    if (IsPICCall) {
      if (GlobalOrExternal) {
        // Load callee address
        Callee = DAG.getNode(Cpu0ISD::Wrapper, dl, getPointerTy(),
                             GetGlobalReg(DAG, getPointerTy()), Callee);
        SDValue LoadValue = DAG.getLoad(getPointerTy(), dl, DAG.getEntryNode(),
                                        Callee, MachinePointerInfo::getGOT(),
                                        false, false, false, 0);
  
      // Use GOT+LO if callee has internal linkage.
        if (CalleeLo.getNode()) {
          SDValue Lo = DAG.getNode(Cpu0ISD::Lo, dl, getPointerTy(), CalleeLo);
          Callee = DAG.getNode(ISD::ADD, dl, getPointerTy(), LoadValue, Lo);
        } else
          Callee = LoadValue;
      }
    }
  
    // T9 should contain the address of the callee function if
    // -reloction-model=pic or it is an indirect call.
    if (IsPICCall || !GlobalOrExternal) {
      // copy to T9
      unsigned T9Reg = Cpu0::T9;
      Chain = DAG.getCopyToReg(Chain, dl, T9Reg, Callee, SDValue(0, 0));
      InFlag = Chain.getValue(1);
      Callee = DAG.getRegister(T9Reg, getPointerTy());
    }
  
    // Cpu0JmpLink = #chain, #target_address, #opt_in_flags...
    //             = Chain, Callee, Reg#1, Reg#2, ...
    //
    // Returns a chain & a flag for retval copy to use.
    SDVTList NodeTys = DAG.getVTList(MVT::Other, MVT::Glue);
    SmallVector<SDValue, 8> Ops;
    Ops.push_back(Chain);
    Ops.push_back(Callee);
  
    // Add argument registers to the end of the list so that they are
    // known live into the call.
    for (unsigned i = 0, e = RegsToPass.size(); i != e; ++i)
    Ops.push_back(DAG.getRegister(RegsToPass[i].first,
                    RegsToPass[i].second.getValueType()));
  
    // Add a register mask operand representing the call-preserved registers.
    const TargetRegisterInfo *TRI = getTargetMachine().getRegisterInfo();
    const uint32_t *Mask = TRI->getCallPreservedMask(CallConv);
    assert(Mask && "Missing call preserved mask for calling convention");
    Ops.push_back(DAG.getRegisterMask(Mask));
  
    if (InFlag.getNode())
    Ops.push_back(InFlag);
  
    Chain  = DAG.getNode(Cpu0ISD::JmpLink, dl, NodeTys, &Ops[0], Ops.size());
    InFlag = Chain.getValue(1);
  
    // Create the CALLSEQ_END node.
    Chain = DAG.getCALLSEQ_END(Chain,
                 DAG.getIntPtrConstant(NextStackOffset, true),
                 DAG.getIntPtrConstant(0, true), InFlag);
    InFlag = Chain.getValue(1);
  
    // Handle result values, copying them out of physregs into vregs that we
    // return.
    return LowerCallResult(Chain, InFlag, CallConv, isVarArg,
               Ins, dl, DAG, InVals);
  }
  
  /// LowerCallResult - Lower the result values of a call into the
  /// appropriate copies out of appropriate physical registers.
  SDValue
  Cpu0TargetLowering::LowerCallResult(SDValue Chain, SDValue InFlag,
                    CallingConv::ID CallConv, bool isVarArg,
                    const SmallVectorImpl<ISD::InputArg> &Ins,
                    DebugLoc dl, SelectionDAG &DAG,
                    SmallVectorImpl<SDValue> &InVals) const {
    // Assign locations to each value returned by this call.
    SmallVector<CCValAssign, 16> RVLocs;
    CCState CCInfo(CallConv, isVarArg, DAG.getMachineFunction(),
                   getTargetMachine(), RVLocs, *DAG.getContext());
  
    CCInfo.AnalyzeCallResult(Ins, RetCC_Cpu0);
  
    // Copy all of the result registers out of their specified physreg.
    for (unsigned i = 0; i != RVLocs.size(); ++i) {
      Chain = DAG.getCopyFromReg(Chain, dl, RVLocs[i].getLocReg(),
                                 RVLocs[i].getValVT(), InFlag).getValue(1);
      InFlag = Chain.getValue(2);
      InVals.push_back(Chain.getValue(0));
    }
  
    return Chain;
  }


Just like load incoming arguments from stack frame, we call 
CCInfo(CallConv,..., ArgLocs, ...) to get outgoing arguments information before 
enter **“for loop”** and set stack alignment with 8 bytes. 
They're almost same in **“for loop”** with LowerFormalArguments(), except 
LowerCall() create store DAG vector instead of load DAG vector. 
After the **“for loop”**, it create **“ld $6, %call24(_Z5sum_iiiiiii)($gp)”** 
and jalr $6 for calling subroutine (the $6 is $t9) in PIC mode.
DAG.getCALLSEQ_START() and DAG.getCALLSEQ_END() are set before the 
**“for loop”** and after call subroutine, they insert CALLSEQ_START, 
CALLSEQ_END, and translate into pseudo machine instructions !ADJCALLSTACKDOWN, 
!ADJCALLSTACKUP later according Cpu0InstrInfo.td definition as follows.

.. code-block:: c++

  // Cpu0InstrInfo.td
  ...
  def SDT_Cpu0CallSeqStart : SDCallSeqStart<[SDTCisVT<0, i32>]>;
  def SDT_Cpu0CallSeqEnd   : SDCallSeqEnd<[SDTCisVT<0, i32>, SDTCisVT<1, i32>]>;
  ...
  // These are target-independent nodes, but have target-specific formats.
  def callseq_start : SDNode<"ISD::CALLSEQ_START", SDT_Cpu0CallSeqStart,
                             [SDNPHasChain, SDNPOutGlue]>;
  def callseq_end   : SDNode<"ISD::CALLSEQ_END", SDT_Cpu0CallSeqEnd,
                             [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue]>;
    
  //===----------------------------------------------------------------------===//
  // Pseudo instructions
  //===----------------------------------------------------------------------===//
    
  // As stack alignment is always done with addiu, we need a 16-bit immediate
  let Defs = [SP], Uses = [SP] in {
  def ADJCALLSTACKDOWN : Cpu0Pseudo<(outs), (ins uimm16:$amt),
                                    "!ADJCALLSTACKDOWN $amt",
                                    [(callseq_start timm:$amt)]>;
  def ADJCALLSTACKUP   : Cpu0Pseudo<(outs), (ins uimm16:$amt1, uimm16:$amt2),
                                    "!ADJCALLSTACKUP $amt1",
                                    [(callseq_end timm:$amt1, timm:$amt2)]>;
  }
    
    
Like load incoming arguments, we need to implement storeRegToStackSlot() for 
store outgoing arguments to stack frame offset.
    
.. code-block:: c++
    
  // Cpu0InstrInfo.cpp
  ...
  //- st SrcReg, MMO(FI)
  void Cpu0InstrInfo::
  storeRegToStackSlot(MachineBasicBlock &MBB, MachineBasicBlock::iterator I,
                      unsigned SrcReg, bool isKill, int FI,
                      const TargetRegisterClass *RC,
                      const TargetRegisterInfo *TRI) const {
    DebugLoc DL;
    if (I != MBB.end()) DL = I->getDebugLoc();
    MachineMemOperand *MMO = GetMemOperand(MBB, FI, MachineMemOperand::MOStore);
    
    unsigned Opc = 0;
    
    if (RC == Cpu0::CPURegsRegisterClass)
      Opc = Cpu0::ST;
    assert(Opc && "Register class not handled!");
    BuildMI(MBB, I, DL, get(Opc)).addReg(SrcReg, getKillRegState(isKill))
      .addFrameIndex(FI).addImm(0).addMemOperand(MMO);
  }

Now, let's run 8/3/Cpu0 with ch8_1.cpp to get result as follows (see comment 
//),

.. code-block:: bash

  118-165-78-230:InputFiles Jonathan$ /Users/Jonathan/llvm/test/cmake_debug_build/
  bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=asm ch8_1.bc -o 
  ch8_1.cpu0.s
  118-165-78-230:InputFiles Jonathan$ cat ch8_1.cpu0.s 
    .section .mdebug.abi32
    .previous
    .file "ch8_1.bc"
    .text
    .globl  _Z5sum_iiiiiii
    .align  2
    .type _Z5sum_iiiiiii,@function
    .ent  _Z5sum_iiiiiii          # @_Z5sum_iiiiiii
  _Z5sum_iiiiiii:
    .cfi_startproc
    .frame  $sp,32,$lr
    .mask   0x00000000,0
    .set  noreorder
    .set  nomacro
  # BB#0:
    addiu $sp, $sp, -32
  $tmp1:
    .cfi_def_cfa_offset 32
    ld  $2, 32($sp)
    st  $2, 28($sp)
    ld  $2, 36($sp)
    st  $2, 24($sp)
    ld  $2, 40($sp)
    st  $2, 20($sp)
    ld  $2, 44($sp)
    st  $2, 16($sp)
    ld  $2, 48($sp)
    st  $2, 12($sp)
    ld  $2, 52($sp)
    st  $2, 8($sp)
    ld  $3, 24($sp)
    ld  $4, 28($sp)
    add $3, $4, $3
    ld  $4, 20($sp)
    add $3, $3, $4
    ld  $4, 16($sp)
    add $3, $3, $4
    ld  $4, 12($sp)
    add $3, $3, $4
    add $2, $3, $2
    st  $2, 4($sp)
    addiu $sp, $sp, 32
    ret $lr
    .set  macro
    .set  reorder
    .end  _Z5sum_iiiiiii
  $tmp2:
    .size _Z5sum_iiiiiii, ($tmp2)-_Z5sum_iiiiiii
    .cfi_endproc
  
    .globl  main
    .align  2
    .type main,@function
    .ent  main                    # @main
  main:
    .cfi_startproc
    .frame  $sp,40,$lr
    .mask   0x00004000,-4
    .set  noreorder
    .cpload $t9
    .set  nomacro
  # BB#0:
    addiu $sp, $sp, -40
  $tmp5:
    .cfi_def_cfa_offset 40
    st  $lr, 36($sp)            # 4-byte Folded Spill
  $tmp6:
    .cfi_offset 14, -4
    addiu $2, $zero, 0
    st  $2, 32($sp)
    !ADJCALLSTACKDOWN 24
    addiu $2, $zero, 6
    st  $2, 60($sp) // wrong offset
    addiu $2, $zero, 5
    st  $2, 56($sp)
    addiu $2, $zero, 4
    st  $2, 52($sp)
    addiu $2, $zero, 3
    st  $2, 48($sp)
    addiu $2, $zero, 2
    st  $2, 44($sp)
    addiu $2, $zero, 1
    st  $2, 40($sp)
    ld  $6, %call24(_Z5sum_iiiiiii)($gp)
    jalr  $6
    !ADJCALLSTACKUP 24
    st  $2, 28($sp)
    ld  $lr, 36($sp)            # 4-byte Folded Reload
    addiu $sp, $sp, 40
    ret $lr
    .set  macro
    .set  reorder
    .end  main
  $tmp7:
    .size main, ($tmp7)-main
    .cfi_endproc


It store the arguments to wrong offset. 
We will fix this issue and take care !ADJCALLSTACKUP and !ADJCALLSTACKDOWN in 
next two sections.


Fix the wrong offset in storing arguments to stack frame
---------------------------------------------------------

To fix the wrong offset in storing arguments, we modify the following code 
in eliminateFrameIndex() as follows. 
The code as below is modified in 8/4/Cpu0 to set the caller outgoing 
arguments into spOffset($sp) (8/3/Cpu0 set them to pOffset+stackSize($sp).

.. code-block:: c++

  // Cpu0RegisterInfo.cpp
  ...
  void Cpu0RegisterInfo::
  eliminateFrameIndex(MachineBasicBlock::iterator II, int SPAdj,
                      RegScavenger *RS) const {
    ...
    Cpu0FunctionInfo *Cpu0FI = MF.getInfo<Cpu0FunctionInfo>();
    ...
    if (Cpu0FI->isOutArgFI(FrameIndex) || Cpu0FI->isDynAllocFI(FrameIndex) ||
        (FrameIndex >= MinCSFI && FrameIndex <= MaxCSFI))
      FrameReg = Cpu0::SP;
    else
      FrameReg = getFrameRegister(MF);
    ...
    // Calculate final offset.
    // - There is no need to change the offset if the frame object is one of the
    //   following: an outgoing argument, pointer to a dynamically allocated
    //   stack space or a $gp restore location,
    // - If the frame object is any of the following, its offset must be adjusted
    //   by adding the size of the stack:
    //   incoming argument, callee-saved register location or local variable.
    if (Cpu0FI->isOutArgFI(FrameIndex) || Cpu0FI->isGPFI(FrameIndex) ||
        Cpu0FI->isDynAllocFI(FrameIndex))
      Offset = spOffset;
    else
      Offset = spOffset + (int64_t)stackSize;
    Offset    += MI.getOperand(i+1).getImm();
    ...
  }
    
  // Cpu0MachineFunction.h
  ...
  /// SRetReturnReg - Some subtargets require that sret lowering includes
  /// returning the value of the returned struct in a register. This field
  /// holds the virtual register into which the sret argument is passed.
  unsigned SRetReturnReg;
  ...
  Cpu0FunctionInfo(MachineFunction& MF)
  : MF(MF), SRetReturnReg(0)
  ...
  bool isOutArgFI(int FI) const {
    return FI <= OutArgFIRange.first && FI >= OutArgFIRange.second;
  }
  ...
  unsigned getSRetReturnReg() const { return SRetReturnReg; }
  void setSRetReturnReg(unsigned Reg) { SRetReturnReg = Reg; }
  ...


Run 8/4/Cpu0 with ch8_1.cpp will get the following result. 
It correct arguements offset im main() from (0+40)$sp, (8+40)$sp, ..., to 
(0)$sp, (8)$sp, ..., where the stack size is 40 in main().

.. code-block:: bash

  118-165-78-230:InputFiles Jonathan$ /Users/Jonathan/llvm/test/cmake_debug_build/
  bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=asm ch8_1.bc -o 
  ch8_1.cpu0.s
  118-165-78-230:InputFiles Jonathan$ cat ch8_1.cpu0.s 
    ...
    !ADJCALLSTACKDOWN 24
    addiu $2, $zero, 6
    st  $2, 20($sp)		// Correct offset
    addiu $2, $zero, 5
    st  $2, 16($sp)
    addiu $2, $zero, 4
    st  $2, 12($sp)
    addiu $2, $zero, 3
    st  $2, 8($sp)
    addiu $2, $zero, 2
    st  $2, 4($sp)
    addiu $2, $zero, 1
    st  $2, 0($sp)
    ld  $6, %call24(_Z5sum_iiiiiii)($gp)
    jalr  $6
    !ADJCALLSTACKUP 24
    ...


The incoming arguments is the formal arguments defined in compiler and program 
language books. The outgoing arguments is the actual arguments.
Summary callee incoming arguments and caller outgoing arguments as 
:num:`Figure #funccall-f3`.

.. _funccall-f3:
.. figure:: ../Table/funccall/1.png
    :height: 156 px
    :width: 697 px
    :scale: 100 %
    :align: center

    Callee incoming arguments and caller outgoing arguments



Pseudo hook instruction ADJCALLSTACKDOWN and ADJCALLSTACKUP
------------------------------------------------------------

To fix the !ADJSTACKDOWN and !1ADJSTACKUP, we call Cpu0GenInstrInfo(Cpu0::
ADJCALLSTACKDOWN, Cpu0::ADJCALLSTACKUP) in Cpu0InstrInfo() constructor 
function and define eliminateCallFramePseudoInstr() as follows, 

.. code-block:: c++

  // Cpu0InstrInfo.cpp
  ...
  Cpu0InstrInfo::Cpu0InstrInfo(Cpu0TargetMachine &tm)
    : Cpu0GenInstrInfo(Cpu0::ADJCALLSTACKDOWN, Cpu0::ADJCALLSTACKUP),
  ...
  
  // Cpu0RegisterInfo.cpp
  ...
  // Cpu0
  // This function eliminate ADJCALLSTACKDOWN,
  // ADJCALLSTACKUP pseudo instructions
  void Cpu0RegisterInfo::
  eliminateCallFramePseudoInstr(MachineFunction &MF, MachineBasicBlock &MBB,
                  MachineBasicBlock::iterator I) const {
    // Simply discard ADJCALLSTACKDOWN, ADJCALLSTACKUP instructions.
    MBB.erase(I);
  }

With above definition, eliminateCallFramePseudoInstr() will be called when 
llvm meet pseudo instructions ADJCALLSTACKDOWN and ADJCALLSTACKUP. 
We just discard these 2 pseudo instructions. 
Run 8/5/Cpu0 with ch8_1.cpp will get the following result.

.. code-block:: bash

  118-165-78-230:InputFiles Jonathan$ /Users/Jonathan/llvm/test/cmake_debug_build/
  bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=asm ch8_1.bc -o 
  ch8_1.cpu0.s
  118-165-78-230:InputFiles Jonathan$ cat ch8_1.cpu0.s 
    .section .mdebug.abi32
    .previous
    .file "ch8_1.bc"
    .text
    .globl  _Z5sum_iiiiiii
    .align  2
    .type _Z5sum_iiiiiii,@function
    .ent  _Z5sum_iiiiiii          # @_Z5sum_iiiiiii
  _Z5sum_iiiiiii:
    .cfi_startproc
    .frame  $sp,32,$lr
    .mask   0x00000000,0
    .set  noreorder
    .set  nomacro
  # BB#0:
    addiu $sp, $sp, -32
  $tmp1:
    .cfi_def_cfa_offset 32
    ld  $2, 32($sp)
    st  $2, 28($sp)
    ld  $2, 36($sp)
    st  $2, 24($sp)
    ld  $2, 40($sp)
    st  $2, 20($sp)
    ld  $2, 44($sp)
    st  $2, 16($sp)
    ld  $2, 48($sp)
    st  $2, 12($sp)
    ld  $2, 52($sp)
    st  $2, 8($sp)
    ld  $3, 24($sp)
    ld  $4, 28($sp)
    add $3, $4, $3
    ld  $4, 20($sp)
    add $3, $3, $4
    ld  $4, 16($sp)
    add $3, $3, $4
    ld  $4, 12($sp)
    add $3, $3, $4
    add $2, $3, $2
    st  $2, 4($sp)
    addiu $sp, $sp, 32
    ret $lr
    .set  macro
    .set  reorder
    .end  _Z5sum_iiiiiii
  $tmp2:
    .size _Z5sum_iiiiiii, ($tmp2)-_Z5sum_iiiiiii
    .cfi_endproc
  
    .globl  main
    .align  2
    .type main,@function
    .ent  main                    # @main
  main:
    .cfi_startproc
    .frame  $sp,64,$lr
    .mask   0x00004000,-4
    .set  noreorder
    .cpload $t9
    .set  nomacro
  # BB#0:
    addiu $sp, $sp, -64
  $tmp5:
    .cfi_def_cfa_offset 64
    st  $lr, 60($sp)            # 4-byte Folded Spill
  $tmp6:
    .cfi_offset 14, -4
    addiu $2, $zero, 0
    st  $2, 56($sp)
    addiu $2, $zero, 6
    st  $2, 20($sp)
    addiu $2, $zero, 5
    st  $2, 16($sp)
    addiu $2, $zero, 4
    st  $2, 12($sp)
    addiu $2, $zero, 3
    st  $2, 8($sp)
    addiu $2, $zero, 2
    st  $2, 4($sp)
    addiu $2, $zero, 1
    st  $2, 0($sp)
    ld  $6, %call24(_Z5sum_iiiiiii)($gp)
    jalr  $6
    st  $2, 52($sp)
    ld  $lr, 60($sp)            # 4-byte Folded Reload
    addiu $sp, $sp, 64
    ret $lr
    .set  macro
    .set  reorder
    .end  main
  $tmp7:
    .size main, ($tmp7)-main
    .cfi_endproc


Handle $gp register in PIC addressing mode
-------------------------------------------

In "section Global variable" [5]_, we mentioned two addressing 
mode, the static address mode and PIC (position-independent code) mode. 
We also mentioned, one example of PIC mode is used in share library. 
Share library usually can be loaded in different memory address decided at run 
time. 
The static mode (absolute address mode) is usually designed to load in specific 
memory address decided at compile time. 
Since share library can be loaded in different memory address, the global 
variable address cannot be decided at compile time. 
But, we can caculate the distance between the global variable address and 
shared library function if they will be loaded to the contiguous memory space 
together.

Let's run 8/6/Cpu0 with ch8_2.cpp to get the following result of we putting the 
comment in it for explanation.

.. code-block:: bash

  118-165-78-230:InputFiles Jonathan$ cat ch8_2.cpu0.s
  _Z5sum_iiiiiii:
  ...
      .cpload $t9 // assign $gp = $t9 by loader when loader load re-entry 
                  //  function (shared library) of _Z5sum_iiiiiii
      .set    nomacro
  # BB#0:
      addiu   $sp, $sp, -32
  $tmp1:
      .cfi_def_cfa_offset 32
  ...
      ld  $3, %got(gI)($gp)   // %got(gI) is offset of (gI - _Z5sum_iiiiiii)
  ...
      ret $lr
      .set    macro
      .set    reorder
      .end    _Z5sum_iiiiiii
  ...
      .ent    main                    # @main
  main:
      .cfi_startproc
  ...
      .cpload $t9
      .set    nomacro
  ...
      .cprestore  24  	// save $gp to 24($sp)
      addiu   $2, $zero, 0
  ...
      ld  $6, %call24(_Z5sum_iiiiiii)($gp)
      jalr    $6      	// $t9 register number is 6, meaning $6 and %t9 are the 
                      	//  same register
      ld  $gp, 24($sp)	// restore $gp from 24($sp)
  ...
      .end    main
  $tmp7:
      .size   main, ($tmp7)-main
      .cfi_endproc
    
      .type   gI,@object              # @gI
      .data
      .globl  gI
      .align  2
  gI:
      .4byte  100                     # 0x64
      .size   gI, 4

As above code comment, **“.cprestore 24”** is a pseudo instruction for saving 
**$gp** to **24($sp)**; Instruction **“ld $gp, 24($sp)”** will restore the $gp. 
In other word, $gp is caller saved register, so main() need to save/restore $gp 
before/after call the shared library _Z5sum_iiiiiii() function. 
In _Z5sum_iiiiiii() function, we translate global variable gI address by 
**“ld $3, %got(gI)($gp)”** where %got(gI) is offset of (gI - _Z5sum_iiiiiii) 
(we can write our cpu0 compiler to produce obj code by calculate the offset 
value).

According the original cpu0 web site information, it only support **“jsub”** 24 
bits address range access. 
We add **“jalr”** to cpu0 and expand it to 32 bit address. We did this change for 
two reason. One is cpu0 can be expand to 32 bit address space by only add this 
instruction. 
The other is cpu0 is designed for teaching purpose, this book has the same 
purpose for llvm backend design. We reserve **“jalr”** as PIC mode for shared 
library or dynamic loading code to demonstrate the caller how to handle the 
caller saved register $gp in calling the shared library and the shared library 
how to use $gp to access global variable address. This solution is popular in 
reality and deserve change cpu0 official design as a compiler book. 

Now, as the following code added in 8/6/Cpu0, we can issue **“.cprestore”** in 
emitPrologue() and emit ld $gp, ($gp save slot on stack) after jalr by create 
file Cpu0EmitGPRestore.cpp which run as a function pass.

.. code-block:: c++

  // # CMakeLists.txt
  ...
  add_llvm_target(Cpu0CodeGen
    ...
    Cpu0EmitGPRestore.cpp
  ...
  
  // Cpu0TargetMachine.cpp
  ...
  bool Cpu0PassConfig::addPreRegAlloc() {
    // Do not restore $gp if target is Cpu064.
    // In N32/64, $gp is a callee-saved register.
  
    addPass(createCpu0EmitGPRestorePass(getCpu0TargetMachine()));
    return true;
  }
  
  // Cpu0.h
    ...
    FunctionPass *createCpu0EmitGPRestorePass(Cpu0TargetMachine &TM);
  
  // Cpu0FrameLowering.cpp
  ...
  void Cpu0FrameLowering::emitPrologue(MachineFunction &MF) const {
    ...
    unsigned RegSize = 4;
    unsigned LocalVarAreaOffset = Cpu0FI->needGPSaveRestore() ?
    (MFI->getObjectOffset(Cpu0FI->getGPFI()) + RegSize) :
    Cpu0FI->getMaxCallFrameSize();
    ...
    // Restore GP from the saved stack location
    if (Cpu0FI->needGPSaveRestore()) {
      unsigned Offset = MFI->getObjectOffset(Cpu0FI->getGPFI());
      BuildMI(MBB, MBBI, dl, TII.get(Cpu0::CPRESTORE)).addImm(Offset)
        .addReg(Cpu0::GP);
    }
  }
  
  // Cpu0InstrInfo.td
  ...
  // When handling PIC code the assembler needs .cpload and .cprestore
  // directives. If the real instructions corresponding these directives
  // are used, we have the same behavior, but get also a bunch of warnings
  // from the assembler.
  let neverHasSideEffects = 1 in
  def CPRESTORE : Cpu0Pseudo<(outs), (ins i32imm:$loc, CPURegs:$gp),
                 ".cprestore\t$loc", []>;
  
  
  // Cpu0SelLowering.cpp
  ...
  SDValue
  Cpu0TargetLowering::LowerCall(TargetLowering::CallLoweringInfo &CLI,
                                SmallVectorImpl<SDValue> &InVals) const {
    ...
    // If this is the first call, create a stack frame object that points to
    // a location to which .cprestore saves $gp.
    if (IsPIC && Cpu0FI->globalBaseRegFixed() && !Cpu0FI->getGPFI())
    ...
    if (MaxCallFrameSize < NextStackOffset) {
      if (Cpu0FI->needGPSaveRestore())
        MFI->setObjectOffset(Cpu0FI->getGPFI(), NextStackOffset);
    ...
  }
  
  // Cpu0EmitGPRestore.cpp
  //===-- Cpu0EmitGPRestore.cpp - Emit GP Restore Instruction ---------------===//
  //
  //                     The LLVM Compiler Infrastructure
  //
  // This file is distributed under the University of Illinois Open Source
  // License. See LICENSE.TXT for details.
  //
  //===----------------------------------------------------------------------===//
  //
  // This pass emits instructions that restore $gp right
  // after jalr instructions.
  //
  //===----------------------------------------------------------------------===//
  
  #define DEBUG_TYPE "emit-gp-restore"
  
  #include "Cpu0.h"
  #include "Cpu0TargetMachine.h"
  #include "Cpu0MachineFunction.h"
  #include "llvm/CodeGen/MachineFunctionPass.h"
  #include "llvm/CodeGen/MachineInstrBuilder.h"
  #include "llvm/Target/TargetInstrInfo.h"
  #include "llvm/ADT/Statistic.h"
  
  using namespace llvm;
  
  namespace {
    struct Inserter : public MachineFunctionPass {
  
    TargetMachine &TM;
    const TargetInstrInfo *TII;
  
    static char ID;
    Inserter(TargetMachine &tm)
      : MachineFunctionPass(ID), TM(tm), TII(tm.getInstrInfo()) { }
  
    virtual const char *getPassName() const {
      return "Cpu0 Emit GP Restore";
    }
  
    bool runOnMachineFunction(MachineFunction &F);
    };
    char Inserter::ID = 0;
  } // end of anonymous namespace
  
  bool Inserter::runOnMachineFunction(MachineFunction &F) {
    Cpu0FunctionInfo *Cpu0FI = F.getInfo<Cpu0FunctionInfo>();
  
    if ((TM.getRelocationModel() != Reloc::PIC_) ||
      (!Cpu0FI->globalBaseRegFixed()))
    return false;
  
    bool Changed = false;
    int FI = Cpu0FI->getGPFI();
  
    for (MachineFunction::iterator MFI = F.begin(), MFE = F.end();
        MFI != MFE; ++MFI) {
      MachineBasicBlock& MBB = *MFI;
      MachineBasicBlock::iterator I = MFI->begin();
    
       /// IsLandingPad - Indicate that this basic block is entered via an
      /// exception handler.
      // If MBB is a landing pad, insert instruction that restores $gp after
      // EH_LABEL.
      if (MBB.isLandingPad()) {
        // Find EH_LABEL first.
        for (; I->getOpcode() != TargetOpcode::EH_LABEL; ++I) ;
  
        // Insert ld.
        ++I;
        DebugLoc dl = I != MBB.end() ? I->getDebugLoc() : DebugLoc();
        BuildMI(MBB, I, dl, TII->get(Cpu0::LD), Cpu0::GP).addFrameIndex(FI)
                               .addImm(0);
        Changed = true;
      }
  
      while (I != MFI->end()) {
        if (I->getOpcode() != Cpu0::JALR) {
          ++I;
          continue;
        }
  
        DebugLoc dl = I->getDebugLoc();
        // emit ld $gp, ($gp save slot on stack) after jalr
        BuildMI(MBB, ++I, dl, TII->get(Cpu0::LD), Cpu0::GP).addFrameIndex(FI)
                                 .addImm(0);
        Changed = true;
      }
    }
  
    return Changed;
  }
  
  /// createCpu0EmitGPRestorePass - Returns a pass that emits instructions that
  /// restores $gp clobbered by jalr instructions.
  FunctionPass *llvm::createCpu0EmitGPRestorePass(Cpu0TargetMachine &tm) {
    return new Inserter(tm);
  }
  
  //===-- Cpu0MachineFunctionInfo.h - Private data used for Cpu0 ----*- C++ -*-=//
  ...
  class Cpu0FunctionInfo : public MachineFunctionInfo {
    ...
    bool EmitNOAT;
  
  public:
    Cpu0FunctionInfo(MachineFunction& MF)
    : ...
    MaxCallFrameSize(0), EmitNOAT(false)
    ...
    bool getEmitNOAT() const { return EmitNOAT; }
    void setEmitNOAT() { EmitNOAT = true; }
  
  };
  
  } // end of namespace llvm
  
  #endif // CPU0_MACHINE_FUNCTION_INFO_H
  
  //  Cpu0AsmPrinter.cpp
  ...
  void Cpu0AsmPrinter::EmitInstrWithMacroNoAT(const MachineInstr *MI) {
    MCInst TmpInst;
  
    MCInstLowering.Lower(MI, TmpInst);
    OutStreamer.EmitRawText(StringRef("\t.set\tmacro"));
    if (Cpu0FI->getEmitNOAT())
      OutStreamer.EmitRawText(StringRef("\t.set\tat"));
    OutStreamer.EmitInstruction(TmpInst);
    if (Cpu0FI->getEmitNOAT())
      OutStreamer.EmitRawText(StringRef("\t.set\tnoat"));
    OutStreamer.EmitRawText(StringRef("\t.set\tnomacro"));
  }
  
  void Cpu0AsmPrinter::EmitInstruction(const MachineInstr *MI) {
    ...
    unsigned Opc = MI->getOpcode();
    MCInst TmpInst0;
    SmallVector<MCInst, 4> MCInsts;
  
    switch (Opc) {
    case Cpu0::CPRESTORE: {
      const MachineOperand &MO = MI->getOperand(0);
      assert(MO.isImm() && "CPRESTORE's operand must be an immediate.");
      int64_t Offset = MO.getImm();
  
      if (OutStreamer.hasRawTextSupport()) {
        if (!isInt<16>(Offset)) {
          EmitInstrWithMacroNoAT(MI);
          return;
        }
      } else {
        MCInstLowering.LowerCPRESTORE(Offset, MCInsts);
  
        for (SmallVector<MCInst, 4>::iterator I = MCInsts.begin();
           I != MCInsts.end(); ++I)
        OutStreamer.EmitInstruction(*I);
  
        return;
      }
  
      break;
    }
    default:
      break;
    }
  
    MCInstLowering.Lower(MI, TmpInst0);
    OutStreamer.EmitInstruction(TmpInst0);
  }
  
  void Cpu0AsmPrinter::EmitFunctionBodyStart() {
    ...
    if (OutStreamer.hasRawTextSupport()) {
      ...
      if (Cpu0FI->getEmitNOAT())
        OutStreamer.EmitRawText(StringRef("\t.set\tnoat"));
    } else if (EmitCPLoad) {
      SmallVector<MCInst, 4> MCInsts;
      MCInstLowering.LowerCPLOAD(MCInsts);
      for (SmallVector<MCInst, 4>::iterator I = MCInsts.begin();
         I != MCInsts.end(); ++I)
        OutStreamer.EmitInstruction(*I);
    }
  }
  
  // Cpu0MCInstLower.cpp
  ...
  sstatic void CreateMCInst(MCInst& Inst, unsigned Opc, const MCOperand& Opnd0,
               const MCOperand& Opnd1,
               const MCOperand& Opnd2 = MCOperand()) {
    Inst.setOpcode(Opc);
    Inst.addOperand(Opnd0);
    Inst.addOperand(Opnd1);
    if (Opnd2.isValid())
    Inst.addOperand(Opnd2);
  }
  
  // Lower ".cpload $reg" to
  //  "addiu $gp, $zero, %hi(_gp_disp)"
  //  "shl   $gp, $gp, 16"
  //  "addiu $gp, $gp, %lo(_gp_disp)"
  //  "addu  $gp, $gp, $t9"
  void Cpu0MCInstLower::LowerCPLOAD(SmallVector<MCInst, 4>& MCInsts) {
    MCOperand GPReg = MCOperand::CreateReg(Cpu0::GP);
    MCOperand T9Reg = MCOperand::CreateReg(Cpu0::T9);
    MCOperand ZEROReg = MCOperand::CreateReg(Cpu0::ZERO);
    StringRef SymName("_gp_disp");
    const MCSymbol *Sym = Ctx->GetOrCreateSymbol(SymName);
    const MCSymbolRefExpr *MCSym;
  
    MCSym = MCSymbolRefExpr::Create(Sym, MCSymbolRefExpr::VK_Cpu0_ABS_HI, *Ctx);
    MCOperand SymHi = MCOperand::CreateExpr(MCSym);
    MCSym = MCSymbolRefExpr::Create(Sym, MCSymbolRefExpr::VK_Cpu0_ABS_LO, *Ctx);
    MCOperand SymLo = MCOperand::CreateExpr(MCSym);
  
    MCInsts.resize(4);
  
    CreateMCInst(MCInsts[0], Cpu0::ADDiu, GPReg, ZEROReg, SymHi);
    CreateMCInst(MCInsts[1], Cpu0::SHL, GPReg, GPReg, MCOperand::CreateImm(16));
    CreateMCInst(MCInsts[2], Cpu0::ADDiu, GPReg, GPReg, SymLo);
    CreateMCInst(MCInsts[3], Cpu0::ADD, GPReg, GPReg, T9Reg);
  }
  
  // Lower ".cprestore offset" to "st $gp, offset($sp)".
  void Cpu0MCInstLower::LowerCPRESTORE(int64_t Offset,
                     SmallVector<MCInst, 4>& MCInsts) {
    assert(isInt<32>(Offset) && (Offset >= 0) &&
       "Imm operand of .cprestore must be a non-negative 32-bit value.");
  
    MCOperand SPReg = MCOperand::CreateReg(Cpu0::SP), BaseReg = SPReg;
    MCOperand GPReg = MCOperand::CreateReg(Cpu0::GP);
    MCOperand ZEROReg = MCOperand::CreateReg(Cpu0::ZERO);
  
    if (!isInt<16>(Offset)) {
      unsigned Hi = ((Offset + 0x8000) >> 16) & 0xffff;
      Offset &= 0xffff;
      MCOperand ATReg = MCOperand::CreateReg(Cpu0::AT);
      BaseReg = ATReg;
    
      // addiu   at,zero,hi
      // shl     at,at,16
      // add     at,at,sp
      MCInsts.resize(3);
      CreateMCInst(MCInsts[0], Cpu0::ADDiu, ATReg, ZEROReg, MCOperand::CreateImm(Hi));
      CreateMCInst(MCInsts[1], Cpu0::SHL, ATReg, ATReg, MCOperand::CreateImm(16));
      CreateMCInst(MCInsts[2], Cpu0::ADD, ATReg, ATReg, SPReg);
    }
  
    MCInst St;
    CreateMCInst(St, Cpu0::ST, GPReg, BaseReg, MCOperand::CreateImm(Offset));
    MCInsts.push_back(St);
  }


The above added code of Cpu0AsmPrinter.cpp will call the LowerCPLOAD() and 
LowerCPRESTORE() when user run with ``llc -filetype=obj``. 
The above added code of Cpu0MCInstLower.cpp take care the .cpload and 
.cprestore machine instructions. 
It translate pseudo asm .cpload into four machine instructions, and .cprestore 
into one machine instruction as below. 
As mentioned in "section Global variable" [5]_. 
When the share library main() function be loaded, the loader will set the 
$t9 value to $gp when meet **“.cpload $t9”**. 
After that, the $gp value is $t9 which point to main(), and the global variable 
address is the relative address to main(). 
The _gp_disp is zero as the following reason from Mips ABI.

.. code-block:: c++

  // Lower ".cpload $reg" to
  //  "addiu $gp, $zero, %hi(_gp_disp)"
  //  "shl   $gp, $gp, 16"
  //  "addiu $gp, $gp, %lo(_gp_disp)"
  //  "addu  $gp, $gp, $t9"
  
  // Lower ".cprestore offset" to "st $gp, offset($sp)".

.. note::

  // **Mips ABI: _gp_disp**
  After calculating the gp, a function allocates the local stack space and saves 
  the gp on the stack, so it can be restored after subsequent function calls. 
  In other words, the gp is a caller saved register. 
  
  ...
  
  _gp_disp represents the offset between the beginning of the function and the 
  global offset table. 
  Various optimizations are possible in this code example and the others that 
  follow. 
  For example, the calculation of gp need not be done for a position-independent 
  function that is strictly local to an object module. 


By run with ``llc -filetype=obj``, the .cpload and .cprestore are translated into 
machine code as follows,

.. code-block:: bash

  118-165-76-131:InputFiles Jonathan$ /Users/Jonathan/llvm/test/
  cmake_debug_build/bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=
  obj ch8_2.bc -o ch8_2.cpu0.o
  118-165-76-131:InputFiles Jonathan$ hexdump  ch8_2.cpu0.o
  ...
  // .cpload machine instructions "09 a0 00 00 to 13 aa 60 00"
  0000030 00 0a 00 07 09 a0 00 00 1e aa 00 10 09 aa 00 00
  0000040 13 aa 60 00 09 dd ff e0 00 2d 00 20 01 2d 00 1c
  ...

  // .cpload machine instructions "09 a0 00 00 to 13 aa 60 00"
  00000b0 09 dd 00 20 2c 00 00 00 09 a0 00 00 1e aa 00 10
  00000c0 09 aa 00 00 13 aa 60 00 09 dd ff b8 01 ed 00 44
  // .cprestore machine instruction “ 01 ad 00 18”
  00000d0 01 ad 00 18 09 20 00 00 01 2d 00 40 09 20 00 06
  ...
  
  118-165-67-25:InputFiles Jonathan$ cat ch8_2.cpu0.s
  ...
    .ent  _Z5sum_iiiiiii          # @_Z5sum_iiiiiii
  _Z5sum_iiiiiii:
  ...
    .cpload $t9 // assign $gp = $t9 by loader when loader load re-entry function 
                // (shared library) of _Z5sum_iiiiiii
    .set  nomacro
  # BB#0:
  ...
    .ent  main                    # @main
  ...
    .cpload $t9
    .set  nomacro
  ...
    .cprestore  24  // save $gp to 24($sp)
  ...

Run ``llc -static`` will call jsub instruction instead of jalr as follows,

.. code-block:: bash

  118-165-76-131:InputFiles Jonathan$ /Users/Jonathan/llvm/test/
  cmake_debug_build/bin/Debug/llc -march=cpu0 -relocation-model=static -filetype=
  asm ch8_2.bc -o ch8_2.cpu0.s
  118-165-76-131:InputFiles Jonathan$ cat ch8_2.cpu0.s
  ...
    jsub  _Z5sum_iiiiiii
  ...

Run with ``llc -obj``, you can find the Cx of **“jsub Cx”** is 0 since the Cx 
is calculated by linker as below. 
Mips has the same 0 in it's jal instruction. 
The ch8_1_2.cpp, ch8_1_3.cpp and ch8_1_4.cpp are example code more for test. 

.. code-block:: bash

  // jsub _Z5sum_iiiiiii translate into 2B 00 00 00
  00F0: 2B 00 00 00 01 2D 00 34 00 ED 00 3C 09 DD 00 40 



Variable number of arguments
-----------------------------

Until now, we support fixed number of arguments in formal function definition 
(Incoming Arguments). 
This section support variable number of arguments since C language support 
this feature.
Run 8/6/Cpu0 with ch8_3.cpp to get the following error,

.. code-block:: c++

  // ch8_3.cpp
  //#include <stdio.h>
  #include <stdarg.h>
  
  int sum_i(int amount, ...)
  {
    int i = 0;
    int val = 0;
    int sum = 0;
    
    va_list vl;
    va_start(vl, amount);
    for (i = 0; i < amount; i++)
    {
    val = va_arg(vl, int);
    sum += val;
    }
    va_end(vl);
    
    return sum; 
  }
  
  int main()
  {
    int a = sum_i(6, 0, 1, 2, 3, 4, 5);
  //  printf("a = %d\n", a);
    
    return a;
  }

.. code-block:: bash

  118-165-78-230:InputFiles Jonathan$ clang -target `llvm-config --host-target` -c 
  ch8_3.cpp -emit-llvm -o ch8_3.bc
  118-165-78-230:InputFiles Jonathan$ /Users/Jonathan/llvm/test/cmake_debug_build/
  bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=asm ch8_3.bc -o 
  ch8_3.cpu0.s
  LLVM ERROR: Cannot select: 0x7f8b6902fd10: ch = vastart 0x7f8b6902fa10, 
  0x7f8b6902fb10, 0x7f8b6902fc10 [ORD=9] [ID=22]
    0x7f8b6902fb10: i32 = FrameIndex<5> [ORD=7] [ID=9]
  In function: _Z5sum_iiz

Run 8/7/Cpu0 with ch8_3.cpp as well as clang option, 
**clang -target `llvm-config --host-target`**, to get the following result,

.. code-block:: bash

  118-165-76-131:InputFiles Jonathan$ clang -target `llvm-config --host-target` -c 
  ch8_3.cpp -emit-llvm -o ch8_3.bc
  118-165-76-131:InputFiles Jonathan$ /Users/Jonathan/llvm/test/
  cmake_debug_build/bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=asm 
  ch8_3.bc -o ch8_3.cpu0.s
  118-165-76-131:InputFiles Jonathan$ cat ch8_3.cpu0.s
    .section .mdebug.abi32
    .previous
    .file "ch8_3.bc"
    .text
    .globl  _Z5sum_iiz
    .align  2
    .type _Z5sum_iiz,@function
    .ent  _Z5sum_iiz              # @_Z5sum_iiz
  _Z5sum_iiz:
    .frame  $sp,24,$lr
    .mask   0x00000000,0
    .set  noreorder
    .set  nomacro
  # BB#0:
    addiu $sp, $sp, -24
    ld  $2, 24($sp)     // amount
    st  $2, 20($sp)     // amount
    addiu $2, $zero, 0
    st  $2, 16($sp)     // i
    st  $2, 12($sp)     // val
    st  $2, 8($sp)      // sum
    addiu $3, $sp, 28
    st  $3, 4($sp)      // arg_ptr = 2nd argument = &arg[1], 
                // since &arg[0] = 24($sp)
    st  $2, 16($sp)
  $BB0_1:                                 # =>This Inner Loop Header: Depth=1
    ld  $2, 20($sp)
    ld  $3, 16($sp)
    cmp $3, $2        // compare(i, amount)
    jge $BB0_4
    jmp $BB0_2
  $BB0_2:                                 #   in Loop: Header=BB0_1 Depth=1 
                // i < amount
    ld  $2, 4($sp)
    addiu $3, $2, 4   // arg_ptr  + 4
    st  $3, 4($sp)  
    ld  $2, 0($2)     // *arg_ptr
    st  $2, 12($sp)
    ld  $3, 8($sp)      // sum
    add $2, $3, $2      // sum += *arg_ptr
    st  $2, 8($sp)
  # BB#3:                                 #   in Loop: Header=BB0_1 Depth=1
                // i >= amount
    ld  $2, 16($sp)
    addiu $2, $2, 1   // i++
    st  $2, 16($sp)
    jmp $BB0_1
  $BB0_4:
    addiu $sp, $sp, 24
    ret $lr
    .set  macro
    .set  reorder
    .end  _Z5sum_iiz
  $tmp1:
    .size _Z5sum_iiz, ($tmp1)-_Z5sum_iiz
  
    .globl  main
    .align  2
    .type main,@function
    .ent  main                    # @main
  main:
    .frame  $sp,88,$lr
    .mask   0x00004000,-4
    .set  noreorder
    .cpload $t9
    .set  nomacro
  # BB#0:
    addiu $sp, $sp, -88
    st  $lr, 84($sp)            # 4-byte Folded Spill
    .cprestore  32
    addiu $2, $zero, 0
    st  $2, 80($sp)
    addiu $3, $zero, 5
    st  $3, 24($sp)
    addiu $3, $zero, 4
    st  $3, 20($sp)
    addiu $3, $zero, 3
    st  $3, 16($sp)
    addiu $3, $zero, 2
    st  $3, 12($sp)
    addiu $3, $zero, 1
    st  $3, 8($sp)
    st  $2, 4($sp)
    addiu $2, $zero, 6
    st  $2, 0($sp)
    ld  $6, %call24(_Z5sum_iiz)($gp)
    jalr  $6
    ld  $gp, 32($sp)
    st  $2, 76($sp)
    ld  $lr, 84($sp)            # 4-byte Folded Reload
    addiu $sp, $sp, 88
    ret $lr
    .set  macro
    .set  reorder
    .end  main
  $tmp4:
    .size main, ($tmp4)-main


The analysis of output ch8_3.cpu0.s as above in comment. 
As above code, in # BB#0, we get the first argument **“amount”** from 
**“ld $2, 24($sp)”** since the stack size of the callee function 
**“_Z5sum_iiz()”** is 24. And set argument pointer, arg_ptr, to 28($sp), 
&arg[1]. 
Next, check i < amount in block $BB0_1. If  i < amount, than enter into $BB0_2. 
In $BB0_2, it do sum += *arg_ptr as well as arg_ptr+=4.
In # BB#3, do i+=1.

To support variable number of arguments, the following code needed to 
add in 8/7/Cpu0. 
The ch8_3_2.cpp is C++ template example code, it can be translated into cpu0 
backend code too.

.. code-block:: c++

  // Cpu0TargetLowering.cpp
  ...
  Cpu0TargetLowering::
  Cpu0TargetLowering(Cpu0TargetMachine &TM)
    : TargetLowering(TM, new Cpu0TargetObjectFile()),
    Subtarget(&TM.getSubtarget<Cpu0Subtarget>()) {
    ...
    setOperationAction(ISD::VASTART,            MVT::Other, Custom);
    ...
    // Support va_arg(): variable numbers (not fixed numbers) of arguments 
    //  (parameters) for function all
    setOperationAction(ISD::VAARG,             MVT::Other, Expand);
    setOperationAction(ISD::VACOPY,            MVT::Other, Expand);
    setOperationAction(ISD::VAEND,             MVT::Other, Expand);
    ...
  }
  ...
  
  SDValue Cpu0TargetLowering::
  LowerOperation(SDValue Op, SelectionDAG &DAG) const
  {
    switch (Op.getOpcode())
    {
    ...
    case ISD::VASTART:            return LowerVASTART(Op, DAG);
    }
    return SDValue();
  }
  
  ...
  SDValue Cpu0TargetLowering::LowerVASTART(SDValue Op, SelectionDAG &DAG) const {
    MachineFunction &MF = DAG.getMachineFunction();
    Cpu0FunctionInfo *FuncInfo = MF.getInfo<Cpu0FunctionInfo>();
  
    DebugLoc dl = Op.getDebugLoc();
    SDValue FI = DAG.getFrameIndex(FuncInfo->getVarArgsFrameIndex(),
                   getPointerTy());
  
    // vastart just stores the address of the VarArgsFrameIndex slot into the
    // memory location argument.
    const Value *SV = cast<SrcValueSDNode>(Op.getOperand(2))->getValue();
    return DAG.getStore(Op.getOperand(0), dl, FI, Op.getOperand(1),
              MachinePointerInfo(SV), false, false, 0);
  }
  ...
  SDValue
  Cpu0TargetLowering::LowerFormalArguments(SDValue Chain,
                       CallingConv::ID CallConv,
                       bool isVarArg,
                      const SmallVectorImpl<ISD::InputArg> &Ins,
                       DebugLoc dl, SelectionDAG &DAG,
                       SmallVectorImpl<SDValue> &InVals)
                        const {
    ...
    if (isVarArg) {
    unsigned RegSize = Cpu0::CPURegsRegClass.getSize();
    // Offset of the first variable argument from stack pointer.
    int FirstVaArgOffset = RegSize;
  
    // Record the frame index of the first variable argument
    // which is a value necessary to VASTART.
    LastFI = MFI->CreateFixedObject(RegSize, FirstVaArgOffset, true);
    Cpu0FI->setVarArgsFrameIndex(LastFI);
    }
    ...
  }


.. code-block:: c++

  // ch8_3_2.cpp
  ...
  //#include <stdio.h>
  #include <stdarg.h>
  
  template<class T>
  T sum(T amount, ...)
  {
    T i = 0;
    T val = 0;
    T sum = 0;
    
    va_list vl;
    va_start(vl, amount);
    for (i = 0; i < amount; i++)
    {
      val = va_arg(vl, T);
      sum += val;
    }
    va_end(vl);
    
    return sum; 
  }
  
  int main()
  {
    int a = sum<int>(6, 1, 2, 3, 4, 5, 6);
    //  printf("a = %d\n", a);
    
    return a;
  }

Mips qemu reference [#]_, you can download and run it with gcc to verify the 
result with printf() function. We will verify the code correction in chapter 
"Run backend" through the CPU0 Verilog language machine.


Correct the return of main()
----------------------------

Run 8/7/Cpu0 with ch6_2.cpp to get the incorrect main return (return register 
$2 is not 0) as follows,

.. code-block:: c++

  struct Date
  {
    int year;
    int month;
    int day;
  };
  
  Date date = {2012, 10, 12};
  int a[3] = {2012, 10, 12};
  
  int main()
  {
    int day = date.day;
    int i = a[1];
  
    return 0;
  }

.. code-block:: bash

  118-165-78-31:InputFiles Jonathan$ clang -c ch6_2.cpp -emit-llvm -o ch6_2.bc
  118-165-78-31:InputFiles Jonathan$ /Users/Jonathan/llvm/test/cmake_debug_build/
  bin/Debug/llc -march=cpu0 -relocation-model=static -filetype=asm ch6_2.bc -o 
  ch6_2.cpu0.static.s
  118-165-78-31:InputFiles Jonathan$ cat ch6_2.cpu0.static.s 
    .section .mdebug.abi32
    .previous
    .file "ch6_2.bc"
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
    addiu $2, $zero, 0
    st  $2, 12($sp)
    addiu $2, $zero, %hi(date)
    shl $2, $2, 16
    addiu $2, $2, %lo(date)
    ld  $2, 8($2)
    st  $2, 8($sp)
    addiu $2, $zero, %hi(a)
    shl $2, $2, 16
    addiu $2, $2, %lo(a)
    ld  $2, 4($2)
    st  $2, 4($sp)
    addiu $sp, $sp, 16
    ret $lr
    .set  macro
    .set  reorder
    .end  main
  ...


The LowerReturn() modified in 8/8/Cpu0 as below. 
It add the live out register $2 to function (main() as this example), and copy 
the OutVals[0] (0 as this example) to $2. Then call DAG.getNode(..., Flag) 
where Flag contains $2 and OutVals[0] information.  

.. code-block:: c++

  // Cpu0ISelLowering.cpp
  ...
  SDValue
  Cpu0TargetLowering::LowerReturn(SDValue Chain,
                  CallingConv::ID CallConv, bool isVarArg,
                  const SmallVectorImpl<ISD::OutputArg> &Outs,
                  const SmallVectorImpl<SDValue> &OutVals,
                  DebugLoc dl, SelectionDAG &DAG) const {
  
    // CCValAssign - represent the assignment of
    // the return value to a location
    SmallVector<CCValAssign, 16> RVLocs;
  
    // CCState - Info about the registers and stack slot.
    CCState CCInfo(CallConv, isVarArg, DAG.getMachineFunction(),
       getTargetMachine(), RVLocs, *DAG.getContext());
  
    // Analize return values.
    CCInfo.AnalyzeReturn(Outs, RetCC_Cpu0);
  
    // If this is the first return lowered for this function, add
    // the regs to the liveout set for the function.
    if (DAG.getMachineFunction().getRegInfo().liveout_empty()) {
      for (unsigned i = 0; i != RVLocs.size(); ++i)
        if (RVLocs[i].isRegLoc())
          DAG.getMachineFunction().getRegInfo().addLiveOut(RVLocs[i].getLocReg());
    }
  
    SDValue Flag;
  
    // Copy the result values into the output registers.
    for (unsigned i = 0; i != RVLocs.size(); ++i) {
      CCValAssign &VA = RVLocs[i];
      assert(VA.isRegLoc() && "Can only return in registers!");
  
      Chain = DAG.getCopyToReg(Chain, dl, VA.getLocReg(), OutVals[i], Flag);
  
      // guarantee that all emitted copies are
      // stuck together, avoiding something bad
      Flag = Chain.getValue(1);
    }
  
    // Return on Cpu0 is always a "jr $ra"
    if (Flag.getNode())
      return DAG.getNode(Cpu0ISD::Ret, dl, MVT::Other,
                 Chain, DAG.getRegister(Cpu0::LR, MVT::i32), Flag);
    else // Return Void
      return DAG.getNode(Cpu0ISD::Ret, dl, MVT::Other,
                 Chain, DAG.getRegister(Cpu0::LR, MVT::i32));
  }
  
Run 8/8/Cpu0 to get the correct result (return register $2 is 0) as follows, 

.. code-block:: bash

  118-165-78-31:InputFiles Jonathan$ /Users/Jonathan/llvm/test/cmake_debug_build/
  bin/Debug/llc -march=cpu0 -relocation-model=static -filetype=asm ch6_2.bc -o 
  ch6_2.cpu0.static.s
  118-165-78-31:InputFiles Jonathan$ cat ch6_2.cpu0.static.s 
    .section .mdebug.abi32
    .previous
    .file "ch6_2.bc"
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
    addiu $2, $zero, 0
    st  $2, 12($sp)
    addiu $3, $zero, %hi(date)
    shl $3, $3, 16
    addiu $3, $3, %lo(date)
    ld  $3, 8($3)
    st  $3, 8($sp)
    addiu $3, $zero, %hi(a)
    shl $3, $3, 16
    addiu $3, $3, %lo(a)
    ld  $3, 4($3)
    st  $3, 4($sp)
    addiu $sp, $sp, 16
    ret $lr
    .set  macro
    .set  reorder
    .end  main
  $tmp2:
    .size main, ($tmp2)-main
    .cfi_endproc
  
    .type date,@object            # @date
    .data
    .globl  date
    .align  2
  date:
    .4byte  2012                    # 0x7dc
    .4byte  10                      # 0xa
    .4byte  12                      # 0xc
    .size date, 12
  
    .type a,@object               # @a
    .globl  a
    .align  2
  a:
    .4byte  2012                    # 0x7dc
    .4byte  10                      # 0xa
    .4byte  12                      # 0xc
    .size a, 12


Verify DIV for operator %
--------------------------

Now, let's run 8/8/Cpu0 with ch4_6_2.cpp to get the result as below. 
It translate **“(b+1)%c”** into **“div $zero, $3, $2”** and **“mfhi $2”**.

.. code-block:: c++

  // ch4_6_2.cpp
  #include <stdlib.h>
  
  int main()
  {
    int b = 11;
  //  unsigned int b = 11;
    int c = rand();
    
    b = (b+1)%c;
    
    return b;
  }

.. code-block:: bash

  118-165-70-242:InputFiles Jonathan$ clang -c ch4_6_2.cpp -I/Applications/
  Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/
  MacOSX10.8.sdk/usr/include/ -emit-llvm -o ch4_6_2.bc
  118-165-70-242:InputFiles Jonathan$ /Users/Jonathan/llvm/test/cmake
  _debug_build/bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=asm 
  ch4_6_2.bc -o ch4_6_2.cpu0.s
  118-165-70-242:InputFiles Jonathan$ cat ch4_6_2.cpu0.s 
    ...
    div $zero, $3, $2
    mfhi  $2
    ...


Structure type support
-----------------------

Run 8/8 with ch8_9_1 will get the error message as follows,

.. code-block:: c++

  // ch8_9_1.cpp
  struct Date
  {
    int year;
    int month;
    int day;
    int hour;
    int minute;
    int second;
  };
  Date gDate = {2012, 10, 12, 1, 2, 3};
  
  struct Time
  {
    int hour;
    int minute;
    int second;
  };
  Time gTime = {2, 20, 30};
  
  Date getDate()
  { 
    return gDate;
  }
  
  Date copyDate(Date date)
  { 
    return date;
  }
  
  Date copyDate(Date* date)
  { 
    return *date;
  }
  
  Time copyTime(Time time)
  { 
    return time;
  }
  
  Time copyTime(Time* time)
  { 
    return *time;
  }
  
  int main()
  {
    Time time1 = {1, 10, 12};
    Date date1 = getDate();
    Date date2 = copyDate(date1);
    Date date3 = copyDate(&date1);
    Time time2 = copyTime(time1);
    Time time3 = copyTime(&time1);
  
    return 0;
  }


.. code-block:: bash

  JonathantekiiMac:InputFiles Jonathan$ clang -c ch8_9_1.cpp -emit-llvm -o 
  ch8_9_1.bc
  JonathantekiiMac:InputFiles Jonathan$ /Users/Jonathan/llvm/test/
  cmake_debug_build/bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=asm 
  ch8_9_1.bc -o ch8_9_1.cpu0.s
  Assertion failed: (InVals.size() == Ins.size() && "LowerFormalArguments didn't 
  emit the correct number of values!")...
  ...


8/9/Cpu0 with the following code added to support the structure type in 
function call. 

.. code-block:: c++

  // Cpu0ISelLowering.cpp
  ...
  // AddLiveIn - This helper function adds the specified physical register to the
  // MachineFunction as a live in value.  It also creates a corresponding
  // virtual register for it.
  static unsigned
  AddLiveIn(MachineFunction &MF, unsigned PReg, const TargetRegisterClass *RC)
  {
    assert(RC->contains(PReg) && "Not the correct regclass!");
    unsigned VReg = MF.getRegInfo().createVirtualRegister(RC);
    MF.getRegInfo().addLiveIn(PReg, VReg);
    return VReg;
  }
  ...
  //===----------------------------------------------------------------------===//
  //                  Call Calling Convention Implementation
  //===----------------------------------------------------------------------===//
  
  static const unsigned IntRegsSize = 2;
  
  static const uint16_t IntRegs[] = {
    Cpu0::A0, Cpu0::A1
  };
  
  // Write ByVal Arg to arg registers and stack.
  static void
  WriteByValArg(SDValue& ByValChain, SDValue Chain, DebugLoc dl,
          SmallVector<std::pair<unsigned, SDValue>, 16>& RegsToPass,
          SmallVector<SDValue, 8>& MemOpChains, int& LastFI,
          MachineFrameInfo *MFI, SelectionDAG &DAG, SDValue Arg,
          const CCValAssign &VA, const ISD::ArgFlagsTy& Flags,
          MVT PtrType, bool isLittle) {
    unsigned LocMemOffset = VA.getLocMemOffset();
    unsigned Offset = 0;
    uint32_t RemainingSize = Flags.getByValSize();
    unsigned ByValAlign = Flags.getByValAlign();
  
    if (RemainingSize == 0)
      return;
  
    // Create a fixed object on stack at offset LocMemOffset and copy
    // remaining part of byval arg to it using memcpy.
    SDValue Src = DAG.getNode(ISD::ADD, dl, MVT::i32, Arg,
                DAG.getConstant(Offset, MVT::i32));
    LastFI = MFI->CreateFixedObject(RemainingSize, LocMemOffset, true);
    SDValue Dst = DAG.getFrameIndex(LastFI, PtrType);
    ByValChain = DAG.getMemcpy(ByValChain, dl, Dst, Src,
                               DAG.getConstant(RemainingSize, MVT::i32),
                               std::min(ByValAlign, (unsigned)4),
                               /*isVolatile=*/false, /*AlwaysInline=*/false,
                               MachinePointerInfo(0), MachinePointerInfo(0));
  }
  ...
  SDValue
  Cpu0TargetLowering::LowerCall(TargetLowering::CallLoweringInfo &CLI,
                  SmallVectorImpl<SDValue> &InVals) const {
    ...
    // Walk the register/memloc assignments, inserting copies/loads.
    for (unsigned i = 0, e = ArgLocs.size(); i != e; ++i) {
    ...
    // ByVal Arg.
    if (Flags.isByVal()) {
      ...
      WriteByValArg(ByValChain, Chain, dl, RegsToPass, MemOpChains, LastFI,
            MFI, DAG, Arg, VA, Flags, getPointerTy(),
            Subtarget->isLittle());
      ...
    }
    ...
    }
    ...
  }
  ...
  //===----------------------------------------------------------------------===//
  //             Formal Arguments Calling Convention Implementation
  //===----------------------------------------------------------------------===//
  static void ReadByValArg(MachineFunction &MF, SDValue Chain, DebugLoc dl,
               std::vector<SDValue>& OutChains,
               SelectionDAG &DAG, unsigned NumWords, SDValue FIN,
               const CCValAssign &VA, const ISD::ArgFlagsTy& Flags,
               const Argument *FuncArg) {
    unsigned LocMem = VA.getLocMemOffset();
    unsigned FirstWord = LocMem / 4;
  
    // copy register A0 - A1 to frame object
    for (unsigned i = 0; i < NumWords; ++i) {
      unsigned CurWord = FirstWord + i;
      if (CurWord >= IntRegsSize)
        break;
  
      unsigned SrcReg = IntRegs[CurWord];
      unsigned Reg = AddLiveIn(MF, SrcReg, &Cpu0::CPURegsRegClass);
      SDValue StorePtr = DAG.getNode(ISD::ADD, dl, MVT::i32, FIN,
                                     DAG.getConstant(i * 4, MVT::i32));
      SDValue Store = DAG.getStore(Chain, dl, DAG.getRegister(Reg, MVT::i32),
                                   StorePtr, MachinePointerInfo(FuncArg, i * 4),
                                   false, false, 0);
    OutChains.push_back(Store);
    }
  }
  ...
  SDValue
  Cpu0TargetLowering::LowerFormalArguments(SDValue Chain,
                       CallingConv::ID CallConv,
                       bool isVarArg,
                      const SmallVectorImpl<ISD::InputArg> &Ins,
                       DebugLoc dl, SelectionDAG &DAG,
                       SmallVectorImpl<SDValue> &InVals)
                        const {
    ...
    for (unsigned i = 0, e = ArgLocs.size(); i != e; ++i, ++FuncArg) {
    ...
    if (Flags.isByVal()) {
      assert(Flags.getByValSize() &&
         "ByVal args of size 0 should have been ignored by front-end."); 
      unsigned NumWords = (Flags.getByValSize() + 3) / 4;
      LastFI = MFI->CreateFixedObject(NumWords * 4, VA.getLocMemOffset(),
                      true);
      SDValue FIN = DAG.getFrameIndex(LastFI, getPointerTy());
      InVals.push_back(FIN);
      ReadByValArg(MF, Chain, dl, OutChains, DAG, NumWords, FIN, VA, Flags,
             &*FuncArg);
      continue;
    }
    ...
    }
    // The cpu0 ABIs for returning structs by value requires that we copy
    // the sret argument into $v0 for the return. Save the argument into
    // a virtual register so that we can access it from the return points.
    if (DAG.getMachineFunction().getFunction()->hasStructRetAttr()) {
      unsigned Reg = Cpu0FI->getSRetReturnReg();
      if (!Reg) {
        Reg = MF.getRegInfo().createVirtualRegister(getRegClassFor(MVT::i32));
        Cpu0FI->setSRetReturnReg(Reg);
      }
      SDValue Copy = DAG.getCopyToReg(DAG.getEntryNode(), dl, Reg, InVals[0]);
      Chain = DAG.getNode(ISD::TokenFactor, dl, MVT::Other, Copy, Chain);
    }
    ...
  }
  ...
  SDValue
  Cpu0TargetLowering::LowerReturn(SDValue Chain,
                  CallingConv::ID CallConv, bool isVarArg,
                  const SmallVectorImpl<ISD::OutputArg> &Outs,
                  const SmallVectorImpl<SDValue> &OutVals,
                  DebugLoc dl, SelectionDAG &DAG) const {
    ...
    // The cpu0 ABIs for returning structs by value requires that we copy
    // the sret argument into $v0 for the return. We saved the argument into
    // a virtual register in the entry block, so now we copy the value out
    // and into $v0.
    if (DAG.getMachineFunction().getFunction()->hasStructRetAttr()) {
      MachineFunction &MF      = DAG.getMachineFunction();
      Cpu0FunctionInfo *Cpu0FI = MF.getInfo<Cpu0FunctionInfo>();
      unsigned Reg = Cpu0FI->getSRetReturnReg();
  
      if (!Reg)
        llvm_unreachable("sret virtual register not created in the entry block");
      SDValue Val = DAG.getCopyFromReg(Chain, dl, Reg, getPointerTy());
  
      Chain = DAG.getCopyToReg(Chain, dl, Cpu0::V0, Val, Flag);
      Flag = Chain.getValue(1);
    }
    ...
  }

In addition to above code, we have defined the calling convention at early of 
this chapter as follows,

.. code-block:: c++

  def RetCC_Cpu0EABI : CallingConv<[
    // i32 are returned in registers V0, V1, A0, A1
    CCIfType<[i32], CCAssignToReg<[V0, V1, A0, A1]>>
  ]>;


It meaning for the return value, we keep it in registers V0, V1, A0, A1 if the 
return value didn't over 4 registers size; If it over 4 size, cpu0 will save 
them with pointer.
For explanation, let's run 8/9/Cpu0 with ch8_9_1.cpp and explain with this 
example.

.. code-block:: bash

  JonathantekiiMac:InputFiles Jonathan$ cat ch8_9_1.cpu0.s
    .section .mdebug.abi32
    .previous
    .file "ch8_9_1.bc"
    .text
    .globl  _Z7getDatev
    .align  2
    .type _Z7getDatev,@function
    .ent  _Z7getDatev             # @_Z7getDatev
  _Z7getDatev:
    .cfi_startproc
    .frame  $sp,0,$lr
    .mask   0x00000000,0
    .set  noreorder
    .cpload $t9
    .set  nomacro
  # BB#0:
    ld  $2, 0($sp)        // $2 is 192($sp)
    ld  $3, %got(gDate)($gp)  // $3 is &gDate
    ld  $4, 20($3)        // save gDate contents to 212..192($sp)
    st  $4, 20($2)
    ld  $4, 16($3)
    st  $4, 16($2)
    ld  $4, 12($3)
    st  $4, 12($2)
    ld  $4, 8($3)
    st  $4, 8($2)
    ld  $4, 4($3)
    st  $4, 4($2)
    ld  $3, 0($3)
    st  $3, 0($2)
    ret $lr
    .set  macro
    .set  reorder
    .end  _Z7getDatev
  $tmp0:
    .size _Z7getDatev, ($tmp0)-_Z7getDatev
    .cfi_endproc
  
    .globl  _Z8copyDate4Date
    .align  2
    .type _Z8copyDate4Date,@function
    .ent  _Z8copyDate4Date        # @_Z8copyDate4Date
  _Z8copyDate4Date:
    .cfi_startproc
    .frame  $sp,0,$lr
    .mask   0x00000000,0
    .set  noreorder
    .set  nomacro
  # BB#0:
    st  $5, 4($sp)
    ld  $2, 0($sp)        // $2 = 168($sp)
    ld  $3, 24($sp)
    st  $3, 20($2)        // copy date1, 24..4($sp), to date2, 
    ld  $3, 20($sp)       //  188..168($sp)
    st  $3, 16($2)
    ld  $3, 16($sp)
    st  $3, 12($2)
    ld  $3, 12($sp)
    st  $3, 8($2)
    ld  $3, 8($sp)
    st  $3, 4($2)
    ld  $3, 4($sp)
    st  $3, 0($2)
    ret $lr
    .set  macro
    .set  reorder
    .end  _Z8copyDate4Date
  $tmp1:
    .size _Z8copyDate4Date, ($tmp1)-_Z8copyDate4Date
    .cfi_endproc
  
    .globl  _Z8copyDateP4Date
    .align  2
    .type _Z8copyDateP4Date,@function
    .ent  _Z8copyDateP4Date       # @_Z8copyDateP4Date
  _Z8copyDateP4Date:
    .cfi_startproc
    .frame  $sp,8,$lr
    .mask   0x00000000,0
    .set  noreorder
    .set  nomacro
  # BB#0:
    addiu $sp, $sp, -8
  $tmp3:
    .cfi_def_cfa_offset 8
    ld  $2, 8($sp)        // $2 = 120($sp of main) date2
    ld  $3, 12($sp)       // $3 = 192($sp of main) date1
    st  $3, 0($sp)
    ld  $4, 20($3)        // copy date1, 212..192($sp of main), 
    st  $4, 20($2)        //  to date2, 140..120($sp of main)
    ld  $4, 16($3)
    st  $4, 16($2)
    ld  $4, 12($3)
    st  $4, 12($2)
    ld  $4, 8($3)
    st  $4, 8($2)
    ld  $4, 4($3)
    st  $4, 4($2)
    ld  $3, 0($3)
    st  $3, 0($2)
    addiu $sp, $sp, 8
    ret $lr
    .set  macro
    .set  reorder
    .end  _Z8copyDateP4Date
  $tmp4:
    .size _Z8copyDateP4Date, ($tmp4)-_Z8copyDateP4Date
    .cfi_endproc
  
    .globl  _Z8copyTime4Time
    .align  2
    .type _Z8copyTime4Time,@function
    .ent  _Z8copyTime4Time        # @_Z8copyTime4Time
  _Z8copyTime4Time:
    .cfi_startproc
    .frame  $sp,64,$lr
    .mask   0x00000000,0
    .set  noreorder
    .set  nomacro
  # BB#0:
    addiu $sp, $sp, -64
  $tmp6:
    .cfi_def_cfa_offset 64
    ld  $2, 68($sp)       // save 8..0 ($sp of main) to 24..16($sp)
    st  $2, 20($sp)
    ld  $2, 64($sp)
    st  $2, 16($sp)
    ld  $2, 72($sp)
    st  $2, 24($sp)
    st  $2, 40($sp)       // save 8($sp of main) to 40($sp)
    ld  $2, 20($sp)       // time1.minute, save time1.minute and 
    st  $2, 36($sp)       //  time1.second to 36..32($sp)
    ld  $2, 16($sp)       // time1.second
    st  $2, 32($sp)
    ld  $2, 40($sp)       // $2 = 8($sp of main) = time1.hour
    st  $2, 56($sp)       // copy time1 to 56..48($sp)
    ld  $2, 36($sp)
    st  $2, 52($sp)
    ld  $2, 32($sp)
    st  $2, 48($sp)
    ld  $2, 48($sp)       // copy time1 to 8..0($sp)
    ld  $3, 52($sp)
    ld  $4, 56($sp)
    st  $4, 8($sp)
    st  $3, 4($sp)
    st  $2, 0($sp)
    ld  $2, 0($sp)        // put time1 to $2, $3 and $4 ($v0, $v1 and $a0)
    ld  $3, 4($sp)
    ld  $4, 8($sp)
    addiu $sp, $sp, 64
    ret $lr
    .set  macro
    .set  reorder
    .end  _Z8copyTime4Time
  $tmp7:
    .size _Z8copyTime4Time, ($tmp7)-_Z8copyTime4Time
    .cfi_endproc
  
    .globl  _Z8copyTimeP4Time
    .align  2
    .type _Z8copyTimeP4Time,@function
    .ent  _Z8copyTimeP4Time       # @_Z8copyTimeP4Time
  _Z8copyTimeP4Time:
    .cfi_startproc
    .frame  $sp,40,$lr
    .mask   0x00000000,0
    .set  noreorder
    .set  nomacro
  # BB#0:
    addiu $sp, $sp, -40
  $tmp9:
    .cfi_def_cfa_offset 40
    ld  $2, 40($sp)       // 216($sp of main)
    st  $2, 16($sp)
    ld  $3, 8($2)       // copy time1, 224..216($sp of main) to 
    st  $3, 32($sp)       //  32..24($sp), 8..0($sp) and $2, $3, $4
    ld  $3, 4($2)
    st  $3, 28($sp)
    ld  $2, 0($2)
    st  $2, 24($sp)
    ld  $2, 24($sp)
    ld  $3, 28($sp)
    ld  $4, 32($sp)
    st  $4, 8($sp)
    st  $3, 4($sp)
    st  $2, 0($sp)
    ld  $2, 0($sp)
    ld  $3, 4($sp)
    ld  $4, 8($sp)
    addiu $sp, $sp, 40
    ret $lr
    .set  macro
    .set  reorder
    .end  _Z8copyTimeP4Time
  $tmp10:
    .size _Z8copyTimeP4Time, ($tmp10)-_Z8copyTimeP4Time
    .cfi_endproc
  
    .globl  main
    .align  2
    .type main,@function
    .ent  main                    # @main
  main:
    .cfi_startproc
    .frame  $sp,248,$lr
    .mask   0x00004180,-4
    .set  noreorder
    .cpload $t9
    .set  nomacro
  # BB#0:
    addiu $sp, $sp, -248
  $tmp13:
    .cfi_def_cfa_offset 248
    st  $lr, 244($sp)           # 4-byte Folded Spill
    st  $8, 240($sp)            # 4-byte Folded Spill
    st  $7, 236($sp)            # 4-byte Folded Spill
  $tmp14:
    .cfi_offset 14, -4
  $tmp15:
    .cfi_offset 8, -8
  $tmp16:
    .cfi_offset 7, -12
    .cprestore  16
    addiu $7, $zero, 0
    st  $7, 232($sp)
    ld  $2, %got($_ZZ4mainE5time1)($gp)
    addiu $2, $2, %lo($_ZZ4mainE5time1)
    ld  $3, 8($2)     // save initial value to time1, 224..216($sp)
    st  $3, 224($sp)
    ld  $3, 4($2)
    st  $3, 220($sp)
    ld  $2, 0($2)
    st  $2, 216($sp)
    addiu $8, $sp, 192
    st  $8, 0($sp)      // *(0($sp)) = 192($sp)
    ld  $6, %call24(_Z7getDatev)($gp) // copy gDate contents to date1, 212..192($sp)
    jalr  $6
    ld  $gp, 16($sp)
    ld  $2, 212($sp)    // copy 212..192($sp) to 164..144($sp)
    st  $2, 164($sp)
    ld  $2, 208($sp)
    st  $2, 160($sp)
    ld  $2, 204($sp)
    st  $2, 156($sp)
    ld  $2, 200($sp)
    st  $2, 152($sp)
    ld  $2, 196($sp)
    st  $2, 148($sp)
    ld  $2, 192($sp)
    st  $2, 144($sp)
    ld  $2, 164($sp)    // copy 164..144($sp) to 24..4($sp)
    st  $2, 24($sp)
    ld  $2, 160($sp)
    st  $2, 20($sp)
    ld  $2, 156($sp)
    st  $2, 16($sp)
    ld  $2, 152($sp)
    st  $2, 12($sp)
    ld  $2, 148($sp)
    st  $2, 8($sp)
    ld  $2, 144($sp)
    st  $2, 4($sp)
    addiu $2, $sp, 168
    st  $2, 0($sp)      // *0($sp) = 168($sp)
    ld  $6, %call24(_Z8copyDate4Date)($gp)
    jalr  $6
    ld  $gp, 16($sp)
    st  $8, 4($sp)      // 4($sp) = 192($sp) date1
    addiu $2, $sp, 120
    st  $2, 0($sp)      // *0($sp) = 120($sp) date2
    ld  $6, %call24(_Z8copyDateP4Date)($gp)
    jalr  $6
    ld  $gp, 16($sp)
    ld  $2, 224($sp)    // save time1 to arguments passing location, 
    st  $2, 96($sp)     //  8..0($sp)
    ld  $2, 220($sp)
    st  $2, 92($sp)
    ld  $2, 216($sp)
    st  $2, 88($sp)
    ld  $2, 88($sp)
    ld  $3, 92($sp)
    ld  $4, 96($sp)
    st  $4, 8($sp)
    st  $3, 4($sp)
    st  $2, 0($sp)
    ld  $6, %call24(_Z8copyTime4Time)($gp)
    jalr  $6
    ld  $gp, 16($sp)
    st  $3, 76($sp)     // save return value time2 from $2, $3, $4 to
    st  $2, 72($sp)     //   80..72($sp) and 112..104($sp)
    st  $4, 80($sp)
    ld  $2, 72($sp)
    ld  $3, 76($sp)
    ld  $4, 80($sp)
    st  $4, 112($sp)
    st  $3, 108($sp)
    st  $2, 104($sp)
    addiu $2, $sp, 216
    st  $2, 0($sp)      // *(0($sp)) = 216($sp)
    ld  $6, %call24(_Z8copyTimeP4Time)($gp)
    jalr  $6
    ld  $gp, 16($sp)
    st  $3, 44($sp)     // save return value time3 from $2, $3, $4 to
    st  $2, 40($sp)     //  48..44($sp) 64..56($sp)
    st  $4, 48($sp)
    ld  $2, 40($sp)
    ld  $3, 44($sp)
    ld  $4, 48($sp)
    st  $4, 64($sp)
    st  $3, 60($sp)
    st  $2, 56($sp)
    add $2, $zero, $7   // return 0 by $2, ($7 is 0)
                
    ld  $7, 236($sp)            # 4-byte Folded Reload // restore callee saved
    ld  $8, 240($sp)            # 4-byte Folded Reload //  registers $s0, $s1 
    ld  $lr, 244($sp)           # 4-byte Folded Reload //  ($7, $8)
    addiu $sp, $sp, 248
    ret $lr
    .set  macro
    .set  reorder
    .end  main
  $tmp17:
    .size main, ($tmp17)-main
    .cfi_endproc
  
    .type gDate,@object           # @gDate
    .data
    .globl  gDate
    .align  2
  gDate:
    .4byte  2012                    # 0x7dc
    .4byte  10                      # 0xa
    .4byte  12                      # 0xc
    .4byte  1                       # 0x1
    .4byte  2                       # 0x2
    .4byte  3                       # 0x3
    .size gDate, 24
  
    .type gTime,@object           # @gTime
    .globl  gTime
    .align  2
  gTime:
    .4byte  2                       # 0x2
    .4byte  20                      # 0x14
    .4byte  30                      # 0x1e
    .size gTime, 12
  
    .type $_ZZ4mainE5time1,@object # @_ZZ4mainE5time1
    .section  .rodata,"a",@progbits
    .align  2
  $_ZZ4mainE5time1:
    .4byte  1                       # 0x1
    .4byte  10                      # 0xa
    .4byte  12                      # 0xc
    .size $_ZZ4mainE5time1, 12


In LowerCall(), Flags.isByVal() will be true if the outgoing arguments over 4 
registers size, then it will call WriteByValArg(..., getPointerTy(), ...) to 
save those arguments to stack as offset. 
For example code of ch8_9_1.cpp, Flags.isByVal() is true for copyDate(date1) 
outgoing arguments, since the date1 is type of Date which contains 6 integers 
(year, month, day, hour, minute, second). 
But Flags.isByVal() is false for copyTime(time1) since type Time is a struct 
contains 3 integers (hour, minute, second).
So, if you mark WriteByValArg(..., getPointerTy(), ...), the result will 
missing the following code in caller, main(),

.. code-block:: bash

    ld  $2, 164($sp)    // copy 164..144($sp) to 24..4($sp)
    st  $2, 24($sp)
    ld  $2, 160($sp)
    st  $2, 20($sp)
    ld  $2, 156($sp)
    st  $2, 16($sp)
    ld  $2, 152($sp)
    st  $2, 12($sp)
    ld  $2, 148($sp)
    st  $2, 8($sp)
    ld  $2, 144($sp)
    st  $2, 4($sp)		// will missing the above code
    
    addiu $2, $sp, 168
    st  $2, 0($sp)      // *0($sp) = 168($sp)
    ld  $6, %call24(_Z8copyDate4Date)($gp)

In LowerFormalArguments(), the "if (Flags.isByVal())" getting the incoming 
arguments which corresponding the outgoing arguments of LowerCall().

LowerFormalArguments() is called when a function is entered while LowerReturn() 
is called when a function is left, reference [#]_.
The former save the return register to virtual register while the later load the 
virtual register back to return register. 
Since the return value is "struct type" and over 4 registers size, it save 
pointer (struct address) to return register.
List the code and their effect as follows,

.. code-block:: c++

  SDValue
  Cpu0TargetLowering::LowerFormalArguments(SDValue Chain,
                       CallingConv::ID CallConv,
                       bool isVarArg,
                      const SmallVectorImpl<ISD::InputArg> &Ins,
                       DebugLoc dl, SelectionDAG &DAG,
                       SmallVectorImpl<SDValue> &InVals)
                        const {
    ...
    // The cpu0 ABIs for returning structs by value requires that we copy
    // the sret argument into $v0 for the return. Save the argument into
    // a virtual register so that we can access it from the return points.
    if (DAG.getMachineFunction().getFunction()->hasStructRetAttr()) {
    unsigned Reg = Cpu0FI->getSRetReturnReg();
    if (!Reg) {
      Reg = MF.getRegInfo().createVirtualRegister(getRegClassFor(MVT::i32));
      Cpu0FI->setSRetReturnReg(Reg);
    }
    SDValue Copy = DAG.getCopyToReg(DAG.getEntryNode(), dl, Reg, InVals[0]);
    Chain = DAG.getNode(ISD::TokenFactor, dl, MVT::Other, Copy, Chain);
    }
    ...
  }

.. code-block:: bash

    addiu $2, $sp, 168
    st  $2, 0($sp)      // *0($sp) = 168($sp); LowerFormalArguments(): 
                        //  return register is $2, virtual register is 
                        //  0($sp)
    ld  $6, %call24(_Z8copyDate4Date)($gp)


.. code-block:: c++

  SDValue
  Cpu0TargetLowering::LowerReturn(SDValue Chain,
                  CallingConv::ID CallConv, bool isVarArg,
                  const SmallVectorImpl<ISD::OutputArg> &Outs,
                  const SmallVectorImpl<SDValue> &OutVals,
                  DebugLoc dl, SelectionDAG &DAG) const {
    ...
    // The cpu0 ABIs for returning structs by value requires that we copy
    // the sret argument into $v0 for the return. We saved the argument into
    // a virtual register in the entry block, so now we copy the value out
    // and into $v0.
    if (DAG.getMachineFunction().getFunction()->hasStructRetAttr()) {
    MachineFunction &MF      = DAG.getMachineFunction();
    Cpu0FunctionInfo *Cpu0FI = MF.getInfo<Cpu0FunctionInfo>();
    unsigned Reg = Cpu0FI->getSRetReturnReg();
  
    if (!Reg)
      llvm_unreachable("sret virtual register not created in the entry block");
    SDValue Val = DAG.getCopyFromReg(Chain, dl, Reg, getPointerTy());
  
    Chain = DAG.getCopyToReg(Chain, dl, Cpu0::V0, Val, Flag);
    Flag = Chain.getValue(1);
    }
    ...
  }

.. code-block:: bash

    .globl  _Z8copyDateP4Date
    .align  2
    .type _Z8copyDateP4Date,@function
    .ent  _Z8copyDate4Date        # @_Z8copyDate4Date
  _Z8copyDate4Date:
    .cfi_startproc
    .frame  $sp,0,$lr
    .mask   0x00000000,0
    .set  noreorder
    .set  nomacro
  # BB#0:
    st  $5, 4($sp)
    ld  $2, 0($sp)        // $2 = 168($sp); LowerReturn(): virtual 
                          //  register is 0($sp), return register is $2 
    ld  $3, 24($sp)
    st  $3, 20($2)        // copy date1, 24..4($sp), to date2, 
    ld  $3, 20($sp)       //  188..168($sp)
    st  $3, 16($2)
    ld  $3, 16($sp)
    st  $3, 12($2)
    ld  $3, 12($sp)
    st  $3, 8($2)
    ld  $3, 8($sp)
    st  $3, 4($2)
    ld  $3, 4($sp)
    st  $3, 0($2)
    ret $lr
    .set  macro
    .set  reorder
    .end  _Z8copyDate4Date

The ch8_9_2.cpp include C++ class "Date" implementation. 
It can been translated into cpu0 backend too since the front end (clang in this 
example) translate them into C language form.
You can also mark the "hasStructRetAttr() if" part from both of above functions, 
the output cpu0 code will use $3 instead of $2 as return register as follows,

.. code-block:: bash

    .globl  _Z8copyDateP4Date
    .align  2
    .type _Z8copyDateP4Date,@function
    .ent  _Z8copyDateP4Date       # @_Z8copyDateP4Date
  _Z8copyDateP4Date:
    .cfi_startproc
    .frame  $sp,8,$lr
    .mask   0x00000000,0
    .set  noreorder
    .set  nomacro
  # BB#0:
    addiu $sp, $sp, -8
  $tmp3:
    .cfi_def_cfa_offset 8
    ld  $2, 12($sp)
    st  $2, 0($sp)
    ld  $4, 20($2)
    ld  $3, 8($sp)
    st  $4, 20($3)
    ld  $4, 16($2)
    st  $4, 16($3)
    ld  $4, 12($2)
    st  $4, 12($3)
    ld  $4, 8($2)
    st  $4, 8($3)
    ld  $4, 4($2)
    st  $4, 4($3)
    ld  $2, 0($2)
    st  $2, 0($3)
    addiu $sp, $sp, 8
    ret $lr
    .set  macro
    .set  reorder
    .end  _Z8copyDateP4Date
  

Summary of this chapter
------------------------

Until now, we have 5,850 lines of source code around in 8/7/Cpu0. 
The cpu0 backend code now can take care the integer function call and control 
statement just like the llvm front end tutorial example code. 
Look back the chapter of “Back end structure”, there are 3,000 lines of source 
code with taking three instructions only. 
With this 95% more of code, it can translate tens of instructions, global 
variable, control flow statement and function call.
Now the cpu0 backend is not just a toy. 
It can translate the C++ OOP language into cpu0 instructions without much 
effort.
Because the most complex things in language, such as C++ syntex, is handle by 
front end. 
LLVM is a real structure follow the compiler theory, any backend of LLVM can 
benefit from this structure.
A couple of thousands code can translate OOP language into your backend.
And your backend will grow up automatically via the front end support more and 
more language.


.. [#] http://jonathan2251.github.com/lbd/ctrlflow.html#risc-cpu-knowledge

.. [#] https://www.dropbox.com/sh/2pkh1fewlq2zag9/OHnrYn2nOs/doc/MIPSproAssemblyLanguageProgrammerGuide 

.. [#] http://www.linux-mips.org/pub/linux/mips/doc/ABI/mipsabi.pdf

.. [#] http://jonathan2251.github.com/lbd/llvmstructure.html#target-registration

.. [#] http://jonathan2251.github.com/lbd/globalvar.html#global-variable

.. [#] http://developer.mips.com/clang-llvm/

.. [#] section "4.5.1 Calling Conventions" of tricore_llvm.pdf
