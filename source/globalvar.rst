.. _sec-globalvars:

Global variables, structs and arrays
====================================

In the previous two chapters, we only access the local variables. 
This chapter will deal global variable access translation. 
After that, introducing the types of struct and array as well as  
their corresponding llvm IR statement, and how the cpu0 
translate these llvm IR statements in `section Array and struct support`_. 

The global variable DAG translation is different from the previous DAG 
translation we have now. 
It create DAG nodes at run time in our backend C++ code according the 
``llc -relocation-model`` option while the others of DAG just do IR DAG to 
Machine DAG translation directly according the input file IR DAG.


Global variable
----------------

6/1/Cpu0 support the global variable, let's compile ch6_1.cpp with this version 
first, and explain the code changes after that.

.. code-block:: c++

  // ch6_1.cpp
  int gI = 100; 
  int main() 
  { 
    int c = 0; 
    
    c = gI; 
    
    return c; 
  } 

.. code-block:: bash

  118-165-66-82:InputFiles Jonathan$ llvm-dis ch6_1.bc -o ch6_1.ll 
  118-165-66-82:InputFiles Jonathan$ cat ch6_1.ll
  ; ModuleID = 'ch6_1.bc'
  target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-
  f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:
  32:64-S128"
  target triple = "x86_64-apple-macosx10.8.0"
  
  @gI = global i32 100, align 4
  
  define i32 @main() nounwind uwtable ssp {
    %1 = alloca i32, align 4
    %c = alloca i32, align 4
    store i32 0, i32* %1
    store i32 0, i32* %c, align 4
    %2 = load i32* @gI, align 4
    store i32 %2, i32* %c, align 4
    %3 = load i32* %c, align 4
    ret i32 %3
  }
  
  118-165-66-82:InputFiles Jonathan$ /Users/Jonathan/llvm/test/cmake_
  debug_build/bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=asm 
  ch6_1.bc -o ch6_1.cpu0.s
  118-165-66-82:InputFiles Jonathan$ cat ch6_1.cpu0.s
    .section .mdebug.abi32
    .previous
    .file "ch6_1.bc"
    .text
    .globl  main
    .align  2
    .type main,@function
    .ent  main                    # @main
  main:
    .cfi_startproc
    .frame  $sp,8,$lr
    .mask   0x00000000,0
    .set  noreorder
    .cpload $t9
    .set  nomacro
  # BB#0:
    addiu $sp, $sp, -8
  $tmp1:
    .cfi_def_cfa_offset 8
    addiu $2, $zero, 0
    st  $2, 4($sp)
    st  $2, 0($sp)
    ld  $2, %got(gI)($gp)
    ld  $2, 0($2)
    st  $2, 0($sp)
    addiu $sp, $sp, 8
    ret $lr
    .set  macro
    .set  reorder
    .end  main
  $tmp2:
    .size main, ($tmp2)-main
    .cfi_endproc
  
    .type gI,@object              # @gI
    .data
    .globl  gI
    .align  2
  gI:
    .4byte  100                     # 0x64
    .size gI, 4


As above code, it translate **“load i32* @gI, align 4”** into 
**“ld  $2, %got(gI)($gp)”** for ``llc -march=cpu0 -relocation-model=pic``, 
position-independent mode. 
More specifically, it translate the global integer variable gI address into 
offset of register gp and load from $gp+(the offset) into register $2. 


Static mode
~~~~~~~~~~~~

We can also translate it with absolute address mode by following command,

.. code-block:: bash

  118-165-66-82:InputFiles Jonathan$ /Users/Jonathan/llvm/test/cmake_
  debug_build/bin/Debug/llc -march=cpu0 -relocation-model=static -filetype=asm 
  ch6_1.bc -o ch6_1.cpu0.static.s
  118-165-66-82:InputFiles Jonathan$ cat ch6_1.cpu0.static.s 
    ...
    addiu $2, $zero, %hi(gI)
    shl $2, $2, 16
    addiu $2, $2, %lo(gI)
    ld  $2, 0($2) 

Above code, it loads the high address part of gI absolute address (16 bits) to 
register $2 and shift 16 bits. 
Now, the register $2 got it's high part of gI absolute address. 
Next, it loads the low part of gI absolute address into register 3. 
Finally, add register $2 and $3 into $2, and loads the content of address 
$2+offset 0 into register $2. 
The ``llc -relocation-model=static`` is for static link mode which binding the 
address in static, compile/link time, not dynamic/run time. 
In this mode, you can also translate code with the following command,

.. code-block:: bash

  118-165-66-82:InputFiles Jonathan$ /Users/Jonathan/llvm/test/cmake_
  debug_build/bin/Debug/llc -march=cpu0 -relocation-model=static -cpu0-islinux-f
  ormat=false -filetype=asm ch6_1.bc -o ch6_1.cpu0.islinux-format-false.s
  118-165-66-82:InputFiles Jonathan$ cat ch6_1.cpu0.islinux-format-false.s 
    ...
    st  $2, 0($sp)
    addiu $2, $gp, %gp_rel(gI)
    ld  $2, 0($2)
    ...
    .section  .sdata,"aw",@progbits
    .globl  gI

As above, it translate code with ``llc -relocation-model=static 
-cpu0-islinux-format=false``. 
The -cpu0-islinux-format default is true which will allocate global variables 
in data section. 
With setting false, it will allocate global variables in sdata section. 
Section data and sdata are areas for global variable with initial value, 
int gI = 100 in this example. 
Section bss and sbss are areas for global variables without initial value 
(for example, int gI;). 
Allocate variables in sdata or sbss sections is addressable by 16 bits + $gp. 
The static mode with -cpu0-islinux-format=false is still static mode 
(variable is binding in compile/link time) even it's use $gp relative address. 
The $gp content is assigned at compile/link time, changed only at program be 
loaded, and is fixed during running the program; while the -relocation-model=pic 
the $gp can be changed during program running. 
For example, if $gp is assigned to start of .sdata like this example, then 
%gp_rel(gI) = (the relative address distance between gI and $gp) (is 0 in this 
case). 
When sdata is loaded into address x, then the gI variable can be got from 
address x+0 where x is the address stored in $gp, 0 is the value of $gp_rel(gI).

To support global variable, first add **IsLinuxOpt** command variable to 
Cpu0Subtarget.cpp. 
After that, user can run llc with argument ``llc -cpu0-islinux-format=false`` 
to specify **IsLinuxOpt** to false. 
The **IsLinuxOpt** is defaulted to true if without specify it. 
About the **cl** command variable, you can refer to [#]_ further.

.. code-block:: c++

  //  Cpu0Subtarget.cpp
  static cl::opt<bool>
  IsLinuxOpt("cpu0-islinux-format", cl::Hidden, cl::init(true),
                   cl::desc("Always use linux format."));
    
Next add the following code to Cpu0ISelLowering.cpp.

.. code-block:: c++

  //  Cpu0ISelLowering.cpp
  Cpu0TargetLowering::
  Cpu0TargetLowering(Cpu0TargetMachine &TM)
    : TargetLowering(TM, new Cpu0TargetObjectFile()),
      Subtarget(&TM.getSubtarget<Cpu0Subtarget>()) {
     ...
    // Cpu0 Custom Operations
    setOperationAction(ISD::GlobalAddress,      MVT::i32,   Custom);
    ...
  }
  ...
  SDValue Cpu0TargetLowering::
  LowerOperation(SDValue Op, SelectionDAG &DAG) const
  {
    switch (Op.getOpcode())
    {
      case ISD::GlobalAddress:      return LowerGlobalAddress(Op, DAG);
    }
    return SDValue();
  }
    
  //===----------------------------------------------------------------------===//
  //  Lower helper functions
  //===----------------------------------------------------------------------===//
    
  //===----------------------------------------------------------------------===//
  //  Misc Lower Operation implementation
  //===----------------------------------------------------------------------===//
    
  SDValue Cpu0TargetLowering::LowerGlobalAddress(SDValue Op,
                                                 SelectionDAG &DAG) const {
    // FIXME there isn't actually debug info here
    DebugLoc dl = Op.getDebugLoc();
    const GlobalValue *GV = cast<GlobalAddressSDNode>(Op)->getGlobal();
    
    if (getTargetMachine().getRelocationModel() != Reloc::PIC_) {
      SDVTList VTs = DAG.getVTList(MVT::i32);
    
      Cpu0TargetObjectFile &TLOF = (Cpu0TargetObjectFile&)getObjFileLowering();
    
      // %gp_rel relocation
      if (TLOF.IsGlobalInSmallSection(GV, getTargetMachine())) {
        SDValue GA = DAG.getTargetGlobalAddress(GV, dl, MVT::i32, 0,
                                                Cpu0II::MO_GPREL);
        SDValue GPRelNode = DAG.getNode(Cpu0ISD::GPRel, dl, VTs, &GA, 1);
        SDValue GOT = DAG.getGLOBAL_OFFSET_TABLE(MVT::i32);
        return DAG.getNode(ISD::ADD, dl, MVT::i32, GOT, GPRelNode);
      }
      // %hi/%lo relocation
      SDValue GAHi = DAG.getTargetGlobalAddress(GV, dl, MVT::i32, 0,
                                                Cpu0II::MO_ABS_HI);
      SDValue GALo = DAG.getTargetGlobalAddress(GV, dl, MVT::i32, 0,
                                                Cpu0II::MO_ABS_LO);
      SDValue HiPart = DAG.getNode(Cpu0ISD::Hi, dl, VTs, &GAHi, 1);
      SDValue Lo = DAG.getNode(Cpu0ISD::Lo, dl, MVT::i32, GALo);
      return DAG.getNode(ISD::ADD, dl, MVT::i32, HiPart, Lo);
    }
    
    EVT ValTy = Op.getValueType();
    bool HasGotOfst = (GV->hasInternalLinkage() ||
                       (GV->hasLocalLinkage() && !isa<Function>(GV)));
    unsigned GotFlag = (HasGotOfst ? Cpu0II::MO_GOT : Cpu0II::MO_GOT16);
    SDValue GA = DAG.getTargetGlobalAddress(GV, dl, ValTy, 0, GotFlag);
    GA = DAG.getNode(Cpu0ISD::Wrapper, dl, ValTy, GetGlobalReg(DAG, ValTy), GA);
    SDValue ResNode = DAG.getLoad(ValTy, dl, DAG.getEntryNode(), GA,
                                  MachinePointerInfo(), false, false, false, 0);
    // On functions and global targets not internal linked only
    // a load from got/GP is necessary for PIC to work.
    if (!HasGotOfst)
      return ResNode;
    SDValue GALo = DAG.getTargetGlobalAddress(GV, dl, ValTy, 0,
                                                          Cpu0II::MO_ABS_LO);
    SDValue Lo = DAG.getNode(Cpu0ISD::Lo, dl, ValTy, GALo);
    return DAG.getNode(ISD::ADD, dl, ValTy, ResNode, Lo);
  }

The setOperationAction(ISD::GlobalAddress, MVT::i32, Custom) tells ``llc`` that 
we implement global address operation in C++ function 
Cpu0TargetLowering::LowerOperation() and llvm will call this function only when 
llvm want to translate IR DAG of loading global variable into machine code. 
Since may have many Custom type of setOperationAction(ISD::XXX, MVT::XXX, 
Custom) in construction function Cpu0TargetLowering(), and llvm will call 
Cpu0TargetLowering::LowerOperation() for each ISD IR DAG node of Custom type 
translation. The global address access can be identified by check the DAG node of 
opcode is ISD::GlobalAddress. 
For static mode, LowerGlobalAddress() will check the translation is for 
IsGlobalInSmallSection() or not. 
When IsLinuxOpt is true and static mode, IsGlobalInSmallSection() always 
return false. 
LowerGlobalAddress() will translate global variable by create 2 DAG IR nodes 
ABS_HI and ABS_LO for high part and low part of address and one extra node ADD. 
List it again as follows.

.. code-block:: c++

    //  Cpu0ISelLowering.cpp
    ...
        // %hi/%lo relocation
        SDValue GAHi = DAG.getTargetGlobalAddress(GV, dl, MVT::i32, 0,
                                                  Cpu0II::MO_ABS_HI);
        SDValue GALo = DAG.getTargetGlobalAddress(GV, dl, MVT::i32, 0,
                                                  Cpu0II::MO_ABS_LO);
        SDValue HiPart = DAG.getNode(Cpu0ISD::Hi, dl, VTs, &GAHi, 1);
        SDValue Lo = DAG.getNode(Cpu0ISD::Lo, dl, MVT::i32, GALo);
        return DAG.getNode(ISD::ADD, dl, MVT::i32, HiPart, Lo);
    
The DAG list form for these three DAG nodes as above code created can be 
represented as (ADD (Hi(h1, h2), Lo (l1, l2)). 
Since some DAG nodes are not with two arguments, we will define the list as 
(ADD (Hi (...), Lo (...)) or (ADD (Hi, Lo)) sometimes in this book. 
The corresponding machine instructions of these three IR nodes are defined in 
Cpu0InstrInfo.td as follows,

.. code-block:: c++

  //  Cpu0InstrInfo.td
  ...
  // Hi and Lo nodes are used to handle global addresses. Used on
  // Cpu0ISelLowering to lower stuff like GlobalAddress, ExternalSymbol
  // static model. (nothing to do with Cpu0 Registers Hi and Lo)
  def Cpu0Hi    : SDNode<"Cpu0ISD::Hi", SDTIntUnaryOp>;
  def Cpu0Lo    : SDNode<"Cpu0ISD::Lo", SDTIntUnaryOp>;
  def Cpu0GPRel : SDNode<"Cpu0ISD::GPRel", SDTIntUnaryOp>;
  ...
  // hi/lo relocs
  def : Pat<(Cpu0Hi tglobaladdr:$in), (SHL (ADDiu ZERO, tglobaladdr:$in), 16)>;
  // Expect cpu0 add LUi support, like Mips
  //def : Pat<(Cpu0Hi tglobaladdr:$in), (LUi tglobaladdr:$in)>;
  def : Pat<(Cpu0Lo tglobaladdr:$in), (ADDiu ZERO, tglobaladdr:$in)>;
  
  def : Pat<(add CPURegs:$hi, (Cpu0Lo tglobaladdr:$lo)),
        (ADDiu CPURegs:$hi, tglobaladdr:$lo)>;
  
  // gp_rel relocs
  def : Pat<(add CPURegs:$gp, (Cpu0GPRel tglobaladdr:$in)),
        (ADDiu CPURegs:$gp, tglobaladdr:$in)>;

Above code meaning translate ABS_HI into ADDiu and SHL two instructions. 
Remember the DAG and Instruction Selection introduced in chapter "Back end 
structure", DAG list 
(SHL (ADDiu ...), 16) meaning DAG node ADDiu and it's parent DAG node SHL two 
instructions nodes is for list IR DAG ABS_HI. 
The Pat<> has two list DAG representation. 
The left is IR DAG and the right is machine instruction DAG. 
So after Instruction Selection and Register Allocation, it translate ABS_HI to,

.. code-block:: c++

  addiu $2, %hi(gI) 
  shl $2, $2, 16 

According above code, we know llvm allocate register $2 for the output operand 
of ADDiu instruction and $2 for SHL instruction in this example. 
Since (SHL (ADDiu), 16), the ADDiu output result will be the SHL first register. 
The result is **“shl $2, 16”**. 
Above Pat<> also define DAG list (add $hi, (ABS_LO)) will be translated into 
(ADD $hi, (ADDiu ZERO, ...)) where ADD is machine instruction **add** and ADDiu 
is machine instruction **ldi** which defined in Cpu0InstrInfo.td too. 
Remember (add $hi, (ABS_LO)) meaning add DAG has two operands, the first is $hi 
and the second is the register which the ABS_LO output result register save to. 
So, the IR DAG pattern and it's corresponding machine instruction node as 
follows,

.. code-block:: c++

  addiu $3, %lo(gI)  // def : Pat<(Cpu0Lo tglobaladdr:$in), (ADDiu ZERO, 
                     // tglobaladdr:$in)>;
    
  // def : Pat<(add CPURegs:$hi, (Cpu0Lo tglobaladdr:$lo)), (ADD CPURegs:$hi, 
  //  (LDI ZERO, tglobaladdr:$lo))>;
  // So, the second register for add is the output register of ABS_LO IR DAG 
  //  translation result saved to;
  // Since LowerGlobalAddress() create list (ADD (Hi, Lo)) with 3 DAG nodes, 
  //  the Hi output register $2 will be the first input register for add.
     add $2, $2, $3   
    
After translated as above, the register $2 is the global variable address, so 
get the global variable by IR DAG load will translate into machine instruction 
as follows,

.. code-block:: c++

  %2 = load i32* @gI, align 4 
  =>  ld  $2, 0($2) 

When IsLinuxOpt is false and static mode, LowerGlobalAddress() will run the 
following code to create a DAG list (ADD GOT, GPRel).

.. code-block:: c++

  // %gp_rel relocation
  if (TLOF.IsGlobalInSmallSection(GV, getTargetMachine())) {
    SDValue GA = DAG.getTargetGlobalAddress(GV, dl, MVT::i32, 0,
                                              Cpu0II::MO_GPREL);
    SDValue GPRelNode = DAG.getNode(Cpu0ISD::GPRel, dl, VTs, &GA, 1);
    SDValue GOT = DAG.getGLOBAL_OFFSET_TABLE(MVT::i32);
    return DAG.getNode(ISD::ADD, dl, MVT::i32, GOT, GPRelNode);
  }


As mentioned just before, all global variables allocated in sdata or sbss 
sections which is addressable by 16 bits + $gp in compile/link time (address 
binding in compile time). 
It's equal to offset+GOT where GOT is the base address for global variable and 
offset is 16 bits. 
Now, according the following Cpu0InstrInfo.td definition,

.. code-block:: c++

  //  Cpu0InstrInfo.td
  def Cpu0GPRel : SDNode<"Cpu0ISD::GPRel", SDTIntUnaryOp>;
  ...
  // gp_rel relocs
  def : Pat<(add CPURegs:$gp, (Cpu0GPRel tglobaladdr:$in)),
            (ADD CPURegs:$gp, (ADDiu ZERO, tglobaladdr:$in))>;

It translate global variable address of list (ADD GOT, GPRel) into machine 
instructions as follows,

.. code-block:: c++

  addiu $2, $gp, %gp_rel(gI)


PIC mode
~~~~~~~~~

When PIC mode, LowerGlobalAddress() will create the DAG list (load 
DAG.getEntryNode(), (Wrapper GetGlobalReg(), GA)) by the following code and 
the code in Cpu0ISeleDAGToDAG.cpp as follows,

.. code-block:: c++

    ...
    bool HasGotOfst = (GV->hasInternalLinkage() || 
                       (GV->hasLocalLinkage() && !isa<Function>(GV))); 
    unsigned GotFlag = (HasGotOfst ? Cpu0II::MO_GOT : Cpu0II::MO_GOT16); 
    SDValue GA = DAG.getTargetGlobalAddress(GV, dl, ValTy, 0, GotFlag); 
    GA = DAG.getNode(Cpu0ISD::Wrapper, dl, ValTy, GetGlobalReg(DAG, ValTy), GA); 
    SDValue ResNode = DAG.getLoad(ValTy, dl, DAG.getEntryNode(), GA, 
                                  MachinePointerInfo(), false, false, false, 0); 
    // On functions and global targets not internal linked only 
    // a load from got/GP is necessary for PIC to work. 
    if (!HasGotOfst) 
      return ResNode;
    ...
    
  // Cpu0ISelDAGToDAG.cpp
  /// ComplexPattern used on Cpu0InstrInfo
  /// Used on Cpu0 Load/Store instructions
  bool Cpu0DAGToDAGISel::
  SelectAddr(SDNode *Parent, SDValue Addr, SDValue &Base, SDValue &Offset) {
    ...
    // on PIC code Load GA
    if (Addr.getOpcode() == Cpu0ISD::Wrapper) {
      Base   = Addr.getOperand(0);
      Offset = Addr.getOperand(1);
      return true;
    }
    ...
  }

Then it translate into the following code,

.. code-block:: c++

  ld  $2, %got(gI)($gp) 

Where DAG.getEntryNode() is the register $2 which decided by Register Allocator
; DAG.getNode(Cpu0ISD::Wrapper, dl, ValTy, GetGlobalReg(DAG, ValTy), GA) is 
translated into Base=$gp as well as the 16 bits Offset for $gp.

Apart from above code, add the following code to Cpu0AsmPrinter.cpp and it will 
emit .cpload asm pseudo instruction,

.. code-block:: c++

  // Cpu0AsmPrinter.cpp
  /// EmitFunctionBodyStart - Targets can override this to emit stuff before
  /// the first basic block in the function.
  void Cpu0AsmPrinter::EmitFunctionBodyStart() {
  ...
      // Emit .cpload directive if needed.
      if (EmitCPLoad)
      //- .cpload $t9
        OutStreamer.EmitRawText(StringRef("\t.cpload\t$t9"));
  ...
  }
    
  // ch6_1.cpu0.s
      .cpload $t9 
      .set    nomacro 
  # BB#0: 
      ldi $sp, -8

According Mips Application Binary Interface (ABI), $t9 ($25) is the register 
used in jalr $25 for long distance function pointer (far subroutine call). 
The jal %subroutine has 24 bits range of address offset relative to Program 
Counter (PC) while jalr has 32 bits address range in register size is 32 bits. 
One example of PIC mode is used in share library. 
Share library is re-entry code which can be loaded in different memory address 
decided on run time. 
The static mode (absolute address mode) is usually designed to load in specific 
memory address decided on compile time. Since share library can be loaded in 
different memory address, the global variable address cannot be decided in 
compile time. 
As above, the global variable address is translated into the relative address 
of $gp. 
In example code ch6_1.ll, .cpload is a asm pseudo instruction just before the 
first instruction of main(), ldi. 
When the share library main() function be loaded, the loader will assign the 
$t9 value to $gp when it meet “.cpload $t9”. 
After that, the $gp value is $9 which point to main(), and the global variable 
address is the relative address to main().


Global variable print support
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Above code is for global address DAG translation. 
Next, add the following code to Cpu0MCInstLower.cpp, Cpu0InstPrinter.cpp and 
Cpu0ISelLowering.cpp for global variable printing operand function.

.. code-block:: c++

  // Cpu0MCInstLower.cpp
  MCOperand Cpu0MCInstLower::LowerSymbolOperand(const MachineOperand &MO,
                                                MachineOperandType MOTy,
                                                unsigned Offset) const {
    MCSymbolRefExpr::VariantKind Kind;
    const MCSymbol *Symbol;
    
    switch(MO.getTargetFlags()) {
    default:                   llvm_unreachable("Invalid target flag!"); 
  // Cpu0_GPREL is for llc -march=cpu0 -relocation-model=static 
  //  -cpu0-islinux-format=false (global var in .sdata) 
    case Cpu0II::MO_GPREL:     Kind = MCSymbolRefExpr::VK_Cpu0_GPREL; break; 
    
    case Cpu0II::MO_GOT16:     Kind = MCSymbolRefExpr::VK_Cpu0_GOT16; break; 
    case Cpu0II::MO_GOT:       Kind = MCSymbolRefExpr::VK_Cpu0_GOT; break; 
  // ABS_HI and ABS_LO is for llc -march=cpu0 -relocation-model=static 
  //  (global var in .data) 
    case Cpu0II::MO_ABS_HI:    Kind = MCSymbolRefExpr::VK_Cpu0_ABS_HI; break; 
    case Cpu0II::MO_ABS_LO:    Kind = MCSymbolRefExpr::VK_Cpu0_ABS_LO; break;
    }
    
    switch (MOTy) {
    case MachineOperand::MO_GlobalAddress:
      Symbol = Mang->getSymbol(MO.getGlobal());
      break;
    
    default:
      llvm_unreachable("<unknown operand type>");
    }
    ...
  }
    
  MCOperand Cpu0MCInstLower::LowerOperand(const MachineOperand& MO,
                                            unsigned offset) const {
    MachineOperandType MOTy = MO.getType();
    
    switch (MOTy) {
    ...
    case MachineOperand::MO_GlobalAddress:
      return LowerSymbolOperand(MO, MOTy, offset);
    ...
   }
    
  // Cpu0InstPrinter.cpp
  ...
  static void printExpr(const MCExpr *Expr, raw_ostream &OS) {
    ...
    switch (Kind) {
    default:                                 llvm_unreachable("Invalid kind!");
    case MCSymbolRefExpr::VK_None:           break;
  // Cpu0_GPREL is for llc -march=cpu0 -relocation-model=static
    case MCSymbolRefExpr::VK_Cpu0_GPREL:     OS << "%gp_rel("; break;
    case MCSymbolRefExpr::VK_Cpu0_GOT16:     OS << "%got(";    break;
    case MCSymbolRefExpr::VK_Cpu0_GOT:       OS << "%got(";    break;
    case MCSymbolRefExpr::VK_Cpu0_ABS_HI:    OS << "%hi(";     break;
    case MCSymbolRefExpr::VK_Cpu0_ABS_LO:    OS << "%lo(";     break;
    }
    ...
  }

  Cpu0ISelLowering.cpp
  ...
  // The following function is for llc -debug DAG node name printing.
  const char *Cpu0TargetLowering::getTargetNodeName(unsigned Opcode) const {
    switch (Opcode) {
    case Cpu0ISD::JmpLink:           return "Cpu0ISD::JmpLink";
    case Cpu0ISD::Hi:                return "Cpu0ISD::Hi";
    case Cpu0ISD::Lo:                return "Cpu0ISD::Lo";
    case Cpu0ISD::GPRel:             return "Cpu0ISD::GPRel";
    case Cpu0ISD::Ret:               return "Cpu0ISD::Ret";
    case Cpu0ISD::DivRem:            return "MipsISD::DivRem";
    case Cpu0ISD::DivRemU:           return "MipsISD::DivRemU";
    case Cpu0ISD::Wrapper:           return "Cpu0ISD::Wrapper";
    default:                         return NULL;
    }
  }



OS is the output stream which output to the assembly file.


Summary
~~~~~~~~

The global variable Instruction Selection for DAG translation is not like the 
ordinary IR node translation, it has static (absolute address) and PIC mode. 
Backend deal this translation by create DAG nodes in function 
LowerGlobalAddress() which called by LowerOperation(). 
Function LowerOperation() take care all Custom type of operation. 
Backend set global address as Custom operation by 
**”setOperationAction(ISD::GlobalAddress, MVT::i32, Custom);”** in 
Cpu0TargetLowering() constructor. 
Different address mode has it's corresponding DAG list be created. 
By set the pattern Pat<> in Cpu0InstrInfo.td, the llvm can apply the compiler 
mechanism, pattern match, in the Instruction Selection stage.

There are three type for setXXXAction(), Promote, Expand and Custom. 
Except Custom, the other two usually no need to coding. 
The section "Instruction Selector" of [#]_ is the references.

Array and struct support
-------------------------

LLVM use getelementptr to represent the array and struct type in C. 
Please reference section getelementptr of [#]_. 
For ch6_2.cpp, the llvm IR as follows,

.. code-block:: c++

  // ch6_2.cpp
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

  // ch6_2.ll
  ; ModuleID = 'ch6_2.bc'
  target datalayout = "e-p:32:32:32-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:32:64-
  f32:32:32-f64:32:64-v64:64:64-v128:128:128-a0:0:64-f80:128:128-n8:16:32-S128"
  target triple = "i386-apple-macosx10.8.0"
    
  %struct.Date = type { i32, i32, i32 }
    
  @date = global %struct.Date { i32 2012, i32 10, i32 12 }, align 4
  @a = global [3 x i32] [i32 2012, i32 10, i32 12], align 4
    
  define i32 @main() nounwind ssp {
  entry:
    %retval = alloca i32, align 4
    %day = alloca i32, align 4
    %i = alloca i32, align 4
    store i32 0, i32* %retval
    %0 = load i32* getelementptr inbounds (%struct.Date* @date, i32 0, i32 2), 
    align 4
    store i32 %0, i32* %day, align 4
    %1 = load i32* getelementptr inbounds ([3 x i32]* @a, i32 0, i32 1), align 4
    store i32 %1, i32* %i, align 4
    ret i32 0
  }
    
Run 6/1/Cpu0 with ch6_2.bc on static mode will get the incorrect asm file as 
follows,

.. code-block:: bash

  118-165-66-82:InputFiles Jonathan$ /Users/Jonathan/llvm/test/cmake_
  debug_build/bin/Debug/llc -march=cpu0 -relocation-model=static -filetype=asm 
  ch6_2.bc -o ch6_2.cpu0.static.s
  118-165-66-82:InputFiles Jonathan$ cat ch6_2.cpu0.static.s 
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
    ld  $2, 0($2)   // the correct one is   ld  $2, 8($2)
    st  $2, 8($sp)
    addiu $2, $zero, %hi(a)
    shl $2, $2, 16
    addiu $2, $2, %lo(a)
    ld  $2, 0($2)
    st  $2, 4($sp)
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


For **“day = date.day”**, the correct one is **“ld $2, 8($2)”**, not 
**“ld $2, 0($2)”**, since date.day is offset 8(date). 
Type int is 4 bytes in cpu0, and the date.day has fields year and month before 
it. 
Let use debug option in llc to see what's wrong,

.. code-block:: bash

  jonathantekiimac:InputFiles Jonathan$ /Users/Jonathan/llvm/test/
  cmake_debug_build/bin/Debug/llc -march=cpu0 -debug -relocation-model=static 
  -filetype=asm ch6_2.bc -o ch6_2.cpu0.static.s
  ...
  === main
  Initial selection DAG: BB#0 'main:entry'
  SelectionDAG has 20 nodes:
    0x7f7f5b02d210: i32 = undef [ORD=1]
    
        0x7f7f5ac10590: ch = EntryToken [ORD=1]
    
        0x7f7f5b02d010: i32 = Constant<0> [ORD=1]
    
        0x7f7f5b02d110: i32 = FrameIndex<0> [ORD=1]
    
        0x7f7f5b02d210: <multiple use>
      0x7f7f5b02d310: ch = store 0x7f7f5ac10590, 0x7f7f5b02d010, 0x7f7f5b02d110, 
      0x7f7f5b02d210<ST4[%retval]> [ORD=1]
    
        0x7f7f5b02d410: i32 = GlobalAddress<%struct.Date* @date> 0 [ORD=2]
    
        0x7f7f5b02d510: i32 = Constant<8> [ORD=2]
    
      0x7f7f5b02d610: i32 = add 0x7f7f5b02d410, 0x7f7f5b02d510 [ORD=2]
    
      0x7f7f5b02d210: <multiple use>
    0x7f7f5b02d710: i32,ch = load 0x7f7f5b02d310, 0x7f7f5b02d610, 0x7f7f5b02d210
    <LD4[getelementptr inbounds (%struct.Date* @date, i32 0, i32 2)]> [ORD=3]
    
    0x7f7f5b02db10: i64 = Constant<4>
    
        0x7f7f5b02d710: <multiple use>
        0x7f7f5b02d710: <multiple use>
        0x7f7f5b02d810: i32 = FrameIndex<1> [ORD=4]
  
        0x7f7f5b02d210: <multiple use>
      0x7f7f5b02d910: ch = store 0x7f7f5b02d710:1, 0x7f7f5b02d710, 0x7f7f5b02d810,
       0x7f7f5b02d210<ST4[%day]> [ORD=4]
  
        0x7f7f5b02da10: i32 = GlobalAddress<[3 x i32]* @a> 0 [ORD=5]
    
        0x7f7f5b02dc10: i32 = Constant<4> [ORD=5]
    
      0x7f7f5b02dd10: i32 = add 0x7f7f5b02da10, 0x7f7f5b02dc10 [ORD=5]
    
      0x7f7f5b02d210: <multiple use>
    0x7f7f5b02de10: i32,ch = load 0x7f7f5b02d910, 0x7f7f5b02dd10, 0x7f7f5b02d210
    <LD4[getelementptr inbounds ([3 x i32]* @a, i32 0, i32 1)]> [ORD=6]
    
  ...
    
    
  Replacing.3 0x7f7f5b02dd10: i32 = add 0x7f7f5b02da10, 0x7f7f5b02dc10 [ORD=5]
    
  With: 0x7f7f5b030010: i32 = GlobalAddress<[3 x i32]* @a> + 4
    
    
  Replacing.3 0x7f7f5b02d610: i32 = add 0x7f7f5b02d410, 0x7f7f5b02d510 [ORD=2]
    
  With: 0x7f7f5b02db10: i32 = GlobalAddress<%struct.Date* @date> + 8
    
  Optimized lowered selection DAG: BB#0 'main:entry'
  SelectionDAG has 15 nodes:
    0x7f7f5b02d210: i32 = undef [ORD=1]
    
        0x7f7f5ac10590: ch = EntryToken [ORD=1]
    
        0x7f7f5b02d010: i32 = Constant<0> [ORD=1]
    
        0x7f7f5b02d110: i32 = FrameIndex<0> [ORD=1]
    
        0x7f7f5b02d210: <multiple use>
      0x7f7f5b02d310: ch = store 0x7f7f5ac10590, 0x7f7f5b02d010, 0x7f7f5b02d110, 
      0x7f7f5b02d210<ST4[%retval]> [ORD=1]
    
      0x7f7f5b02db10: i32 = GlobalAddress<%struct.Date* @date> + 8
    
      0x7f7f5b02d210: <multiple use>
    0x7f7f5b02d710: i32,ch = load 0x7f7f5b02d310, 0x7f7f5b02db10, 0x7f7f5b02d210
    <LD4[getelementptr inbounds (%struct.Date* @date, i32 0, i32 2)]> [ORD=3]
    
        0x7f7f5b02d710: <multiple use>
        0x7f7f5b02d710: <multiple use>
        0x7f7f5b02d810: i32 = FrameIndex<1> [ORD=4]
    
        0x7f7f5b02d210: <multiple use>
      0x7f7f5b02d910: ch = store 0x7f7f5b02d710:1, 0x7f7f5b02d710, 0x7f7f5b02d810,
       0x7f7f5b02d210<ST4[%day]> [ORD=4]
    
      0x7f7f5b030010: i32 = GlobalAddress<[3 x i32]* @a> + 4
    
      0x7f7f5b02d210: <multiple use>
    0x7f7f5b02de10: i32,ch = load 0x7f7f5b02d910, 0x7f7f5b030010, 0x7f7f5b02d210
    <LD4[getelementptr inbounds ([3 x i32]* @a, i32 0, i32 1)]> [ORD=6]
    
  ...


By ``llc -debug``, you can see the DAG translation process. 
As above, the DAG list 
for date.day (add GlobalAddress<[3 x i32]* @a> 0, Constant<8>) with 3 nodes is 
replaced by 1 node GlobalAddress<%struct.Date* @date> + 8. 
The DAG list for a[1] is same. 
The replacement occurs since TargetLowering.cpp::isOffsetFoldingLegal(...) 
return true in ``llc -static`` static addressing mode as below. 
In Cpu0 the **ld** instruction format is **“ld $r1, offset($r2)”** which 
meaning load $r2 address+offset to $r1. 
So, we just replace the isOffsetFoldingLegal(...) function by override 
mechanism as below.

.. code-block:: c++

  // TargetLowering.cpp
  bool
  TargetLowering::isOffsetFoldingLegal(const GlobalAddressSDNode *GA) const {
    // Assume that everything is safe in static mode.
    if (getTargetMachine().getRelocationModel() == Reloc::Static)
      return true;
    
    // In dynamic-no-pic mode, assume that known defined values are safe.
    if (getTargetMachine().getRelocationModel() == Reloc::DynamicNoPIC &&
       GA &&
       !GA->getGlobal()->isDeclaration() &&
       !GA->getGlobal()->isWeakForLinker())
    return true;
    
    // Otherwise assume nothing is safe.
    return false;
  }
    
  // Cpu0TargetLowering.cpp
  bool
  Cpu0TargetLowering::isOffsetFoldingLegal(const GlobalAddressSDNode *GA) const {
    // The Cpu0 target isn't yet aware of offsets.
    return false;
  }

Beyond that, we need to add the following code fragment to Cpu0ISelDAGToDAG.cpp,

.. code-block:: c++

  //  Cpu0ISelDAGToDAG.cpp
  /// ComplexPattern used on Cpu0InstrInfo
  /// Used on Cpu0 Load/Store instructions
  bool Cpu0DAGToDAGISel::
  SelectAddr(SDNode *Parent, SDValue Addr, SDValue &Base, SDValue &Offset) {
  ...
    // Addresses of the form FI+const or FI|const
    if (CurDAG->isBaseWithConstantOffset(Addr)) {
      ConstantSDNode *CN = dyn_cast<ConstantSDNode>(Addr.getOperand(1));
      if (isInt<16>(CN->getSExtValue())) {
    
        // If the first operand is a FI, get the TargetFI Node
        if (FrameIndexSDNode *FIN = dyn_cast<FrameIndexSDNode>
                                            (Addr.getOperand(0)))
          Base = CurDAG->getTargetFrameIndex(FIN->getIndex(), ValTy);
        else
          Base = Addr.getOperand(0);
    
        Offset = CurDAG->getTargetConstant(CN->getZExtValue(), ValTy);
        return true;
      }
    }
  }

Recall we have translated DAG list for date.day 
(add GlobalAddress<[3 x i32]* @a> 0, Constant<8>) into 
(add (add Cpu0ISD::Hi (Cpu0II::MO_ABS_HI), Cpu0ISD::Lo(Cpu0II::MO_ABS_LO)), 
Constant<8>) by the following code in Cpu0ISelLowering.cpp.

.. code-block:: c++

  // Cpu0ISelLowering.cpp
  SDValue Cpu0TargetLowering::LowerGlobalAddress(SDValue Op,
                                      SelectionDAG &DAG) const {
    ...
      // %hi/%lo relocation
      SDValue GAHi = DAG.getTargetGlobalAddress(GV, dl, MVT::i32, 0,
                                                Cpu0II::MO_ABS_HI);
      SDValue GALo = DAG.getTargetGlobalAddress(GV, dl, MVT::i32, 0,
                                                Cpu0II::MO_ABS_LO);
      SDValue HiPart = DAG.getNode(Cpu0ISD::Hi, dl, VTs, &GAHi, 1);
      SDValue Lo = DAG.getNode(Cpu0ISD::Lo, dl, MVT::i32, GALo);
      return DAG.getNode(ISD::ADD, dl, MVT::i32, HiPart, Lo);
    ...
  }

So, when the SelectAddr(...) of Cpu0ISelDAGToDAG.cpp is called. 
The Addr SDValue in SelectAddr(..., Addr, ...) is DAG list for date.day 
(add (add Cpu0ISD::Hi (Cpu0II::MO_ABS_HI), Cpu0ISD::Lo(Cpu0II::MO_ABS_LO)), 
Constant<8>). 
Since Addr.getOpcode() = ISD:ADD, Addr.getOperand(0) = 
(add Cpu0ISD::Hi (Cpu0II::MO_ABS_HI), Cpu0ISD::Lo(Cpu0II::MO_ABS_LO)) and 
Addr.getOperand(1).getOpcode() = ISD::Constant, the Base = SDValue 
(add Cpu0ISD::Hi (Cpu0II::MO_ABS_HI), Cpu0ISD::Lo(Cpu0II::MO_ABS_LO)) and 
Offset = Constant<8>. 
After set Base and Offset, the load DAG will translate the global address 
date.day into machine instruction **“ld $r1, 8($r2)”** in Instruction Selection 
stage.

6/2/Cpu0 include these changes as above, you can run it with ch6_2.cpp to get 
the correct generated instruction **“ld $r1, 8($r2)”** for date.day access, as 
follows.


.. code-block:: bash

  ...
  ld  $2, 8($2)
  st  $2, 8($sp)
  addiu $2, $zero, %hi(a)
  shl $2, $2, 16
  addiu $2, $2, %lo(a)
  ld  $2, 4($2)



.. _section Global variable:
    http://jonathan2251.github.com/lbd/globalvar.html#global-variable

.. _section Array and struct support:
    http://jonathan2251.github.com/lbd/globalvar.html#array-and-struct-support

.. [#] http://llvm.org/docs/CommandLine.html

.. [#] http://llvm.org/docs/WritingAnLLVMBackend.html

.. [#] http://llvm.org/docs/LangRef.html
