.. _sec-backendstructure:

Backend structure
==================

This chapter introduce the back end class inherit tree and class members first. 
Next, following the back end structure, adding individual class implementation 
in each section. 
There are compiler knowledge like DAG (Directed-Acyclic-Graph) and instruction 
selection needed in this chapter. 
This chapter explains these knowledge just when needed. 
At the end of this chapter, we will have a back end to compile llvm 
intermediate code into cpu0 assembly code.

Many code are added in this chapter. They almost are common in every back end 
except the back end name (cpu0 or mips ...). Actually, we copy almost all the 
code from mips and replace the name with cpu0. Please focus on the classes 
relationship in this backend structure. Once knowing the structure, you can 
create your backend structure as quickly as we did, even though there are 3000 
lines of code in this chapter.

TargetMachine structure
-----------------------

Your back end should define a TargetMachine class, for example, we define the 
Cpu0TargetMachine class. 
Cpu0TargetMachine class contains it's own instruction class, frame/stack class, 
DAG (Directed-Acyclic-Graph) class, and register class. 
The Cpu0TargetMachine contents as follows,

.. code-block:: c++

  //- TargetMachine.h 
  class TargetMachine { 
    TargetMachine(const TargetMachine &) LLVM_DELETED_FUNCTION;
    void operator=(const TargetMachine &) LLVM_DELETED_FUNCTION;
  
  public: 
    // Interfaces to the major aspects of target machine information: 
    // -- Instruction opcode and operand information 
    // -- Pipelines and scheduling information 
    // -- Stack frame information 
    // -- Selection DAG lowering information 
    // 
    virtual const TargetInstrInfo         *getInstrInfo() const { return 0; } 
    virtual const TargetFrameLowering *getFrameLowering() const { return 0; } 
    virtual const TargetLowering    *getTargetLowering() const { return 0; } 
    virtual const TargetSelectionDAGInfo *getSelectionDAGInfo() const{ return 0; } 
    virtual const DataLayout             *getDataLayout() const { return 0; } 
    ... 
    /// getSubtarget - This method returns a pointer to the specified type of 
    /// TargetSubtargetInfo.  In debug builds, it verifies that the object being 
    /// returned is of the correct type. 
    template<typename STC> const STC &getSubtarget() const { 
    return *static_cast<const STC*>(getSubtargetImpl()); 
    } 
  
  } 
  
  //- TargetMachine.h 
  class LLVMTargetMachine : public TargetMachine { 
  protected: // Can only create subclasses. 
    LLVMTargetMachine(const Target &T, StringRef TargetTriple, 
            StringRef CPU, StringRef FS, TargetOptions Options, 
            Reloc::Model RM, CodeModel::Model CM, 
            CodeGenOpt::Level OL); 
    ... 
  }; 
  
  class Cpu0TargetMachine : public LLVMTargetMachine { 
    Cpu0Subtarget       Subtarget; 
    const DataLayout    DL; // Calculates type size & alignment 
    Cpu0InstrInfo       InstrInfo;  //- Instructions 
    Cpu0FrameLowering   FrameLowering;  //- Stack(Frame) and Stack direction 
    Cpu0TargetLowering  TLInfo; //- Stack(Frame) and Stack direction 
    Cpu0SelectionDAGInfo TSInfo;  //- Map .bc DAG to backend DAG 
  public: 
    virtual const Cpu0InstrInfo   *getInstrInfo()     const 
    { return &InstrInfo; } 
    virtual const TargetFrameLowering *getFrameLowering()     const 
    { return &FrameLowering; } 
    virtual const Cpu0Subtarget   *getSubtargetImpl() const 
    { return &Subtarget; } 
    virtual const DataLayout *getDataLayout()    const
    { return &DL;}
     virtual const Cpu0TargetLowering *getTargetLowering() const { 
    return &TLInfo; 
    } 
  
    virtual const Cpu0SelectionDAGInfo* getSelectionDAGInfo() const { 
    return &TSInfo; 
    } 
  }; 
  
  //- TargetInstInfo.h 
  class TargetInstrInfo : public MCInstrInfo { 
    TargetInstrInfo(const TargetInstrInfo &) LLVM_DELETED_FUNCTION;
    void operator=(const TargetInstrInfo &) LLVM_DELETED_FUNCTION;
  public: 
    ... 
  } 
  
  //- TargetInstInfo.h 
  class TargetInstrInfoImpl : public TargetInstrInfo { 
  protected: 
    TargetInstrInfoImpl(int CallFrameSetupOpcode = -1, 
              int CallFrameDestroyOpcode = -1) 
    : TargetInstrInfo(CallFrameSetupOpcode, CallFrameDestroyOpcode) {} 
  public: 
    ... 
  } 
  
  //- Cpu0GenInstInfo.inc which generate from Cpu0InstrInfo.td 
  #ifdef GET_INSTRINFO_HEADER 
  #undef GET_INSTRINFO_HEADER 
  namespace llvm { 
  struct Cpu0GenInstrInfo : public TargetInstrInfoImpl { 
    explicit Cpu0GenInstrInfo(int SO = -1, int DO = -1); 
  }; 
  } // End llvm namespace 
  #endif // GET_INSTRINFO_HEADER 
  
  #define GET_INSTRINFO_HEADER 
  #include "Cpu0GenInstrInfo.inc" 
  //- Cpu0InstInfo.h 
  class Cpu0InstrInfo : public Cpu0GenInstrInfo { 
    Cpu0TargetMachine &TM; 
  public: 
    explicit Cpu0InstrInfo(Cpu0TargetMachine &TM); 
  };

.. _backendstructure_f1: 
.. figure:: ../Fig/backendstructure/1.png
	:align: center

	TargetMachine class diagram 1

The Cpu0TargetMachine inherit tree is TargetMachine <- LLVMTargetMachine <- 
Cpu0TargetMachine. 
Cpu0TargetMachine has class Cpu0Subtarget, Cpu0InstrInfo, Cpu0FrameLowering, 
Cpu0TargetLowering and Cpu0SelectionDAGInfo. 
Class Cpu0Subtarget, Cpu0InstrInfo, Cpu0FrameLowering, Cpu0TargetLowering and 
Cpu0SelectionDAGInfo are inherited from parent class TargetSubtargetInfo, 
TargetInstrInfo, TargetFrameLowering, TargetLowering and TargetSelectionDAGInfo.

:ref:`backendstructure_f1` shows Cpu0TargetMachine inherit tree and it's 
Cpu0InstrInfo class inherit tree. 
Cpu0TargetMachine contains Cpu0InstrInfo and ... other class. 
Cpu0InstrInfo contains Cpu0RegisterInfo class, RI. Cpu0InstrInfo.td and 
Cpu0RegisterInfo.td will generate Cpu0GenInstrInfo.inc and 
Cpu0GenRegisterInfo.inc which contain some member functions implementation for 
class Cpu0InstrInfo and Cpu0RegisterInfo.

:ref:`backendstructure_f2` as below shows Cpu0TargetMachine contains class 
TSInfo: Cpu0SelectionDAGInfo, FrameLowering: Cpu0FrameLowering, Subtarget: 
Cpu0Subtarget and TLInfo: Cpu0TargetLowering.

.. _backendstructure_f2:  
.. figure:: ../Fig/backendstructure/2.png
	:align: center

	TargetMachine class diagram 2

.. _backendstructure_f3: 
.. figure:: ../Fig/backendstructure/3.png
	:align: center

	TargetMachine members and operators

:ref:`backendstructure_f3` shows some members and operators (member function) 
of the parent class TargetMachine's. 
:ref:`backendstructure_f4` as below shows some members of class InstrInfo, 
RegisterInfo and TargetLowering. 
Class DAGInfo is skipped here.

.. _backendstructure_f4: 
.. figure:: ../Fig/backendstructure/4.png
	:align: center

	Other class members and operators

Benefit from the inherit tree structure, we just need to implement few code in 
instruction, frame/stack, select DAG class. 
Many code implemented by their parent class. 
The llvm-tblgen generate Cpu0GenInstrInfo.inc from Cpu0InstrInfo.td. 
Cpu0InstrInfo.h extract those code it need from Cpu0GenInstrInfo.inc by define 
“#define GET_INSTRINFO_HEADER”. 
Following is the code fragment from Cpu0GenInstrInfo.inc. 
Code between “#if def  GET_INSTRINFO_HEADER” and “#endif // GET_INSTRINFO_HEADER” 
will be extracted by Cpu0InstrInfo.h.

.. code-block:: c++

  //- Cpu0GenInstInfo.inc which generate from Cpu0InstrInfo.td 
  #ifdef GET_INSTRINFO_HEADER 
  #undef GET_INSTRINFO_HEADER 
  namespace llvm { 
  struct Cpu0GenInstrInfo : public TargetInstrInfoImpl { 
    explicit Cpu0GenInstrInfo(int SO = -1, int DO = -1); 
  }; 
  } // End llvm namespace 
  #endif // GET_INSTRINFO_HEADER 

Reference Write An LLVM Backend web site [#]_.

Now, the code in 3/1/Cpu0 add class Cpu0TargetMachine(Cpu0TargetMachine.h and 
cpp), Cpu0Subtarget (Cpu0Subtarget.h and .cpp), Cpu0InstrInfo (Cpu0InstrInfo.h 
and .cpp), Cpu0FrameLowering (Cpu0FrameLowering.h and .cpp), Cpu0TargetLowering 
(Cpu0ISelLowering.h and .cpp) and Cpu0SelectionDAGInfo ( Cpu0SelectionDAGInfo.h 
and .cpp). 
CMakeLists.txt  modified with those new added \*.cpp as follows,

.. code-block:: c++

  # CMakeLists.txt 
  ...
  add_llvm_target(Cpu0CodeGen 
    Cpu0ISelLowering.cpp 
    Cpu0InstrInfo.cpp 
    Cpu0FrameLowering.cpp 
    Cpu0Subtarget.cpp 
    Cpu0TargetMachine.cpp 
    Cpu0SelectionDAGInfo.cpp 
    )

Please take a look for 3/1 code. 
After that, building 3/1 by make as chapter 2 (of course, you should remove old 
lib/Target/Cpu0 and replace with 3/1/Cpu0). 
You can remove lib/Target/Cpu0/\*.inc before do “make” to ensure your code 
rebuild completely. 
By remove \*.inc, all files those have included .inc will be rebuild, then your 
Target library will regenerate. 
Command as follows,

.. code-block:: bash

  118-165-78-230:cmake_debug_build Jonathan$ rm -rf lib/Target/Cpu0/*

Add RegisterInfo
----------------

As depicted in :ref:`backendstructure_f1`, the Cpu0InstrInfo class should 
contains Cpu0RegisterInfo. 
So 3/2/Cpu0 add Cpu0RegisterInfo class (Cpu0RegisterInfo.h, 
Cpu0RegisterInfo.cpp), and Cpu0RegisterInfo class in files Cpu0InstrInfo.h, 
Cpu0InstrInfo.cpp, Cpu0TargetMachine.h, and modify CMakeLists.txt as follows,

.. code-block:: c++

  // Cpu0InstrInfo.h
  class Cpu0InstrInfo : public Cpu0GenInstrInfo { 
    Cpu0TargetMachine &TM; 
    const Cpu0RegisterInfo RI; 
  public: 
    explicit Cpu0InstrInfo(Cpu0TargetMachine &TM); 
  
    /// getRegisterInfo - TargetInstrInfo is a superset of MRegister info.  As 
    /// such, whenever a client has an instance of instruction info, it should 
    /// always be able to get register info as well (through this method). 
    /// 
    virtual const Cpu0RegisterInfo &getRegisterInfo() const; 
  
  public: 
  };
  
  // Cpu0InstrInfo.cpp
  Cpu0InstrInfo::Cpu0InstrInfo(Cpu0TargetMachine &tm) 
    : 
    TM(tm), 
    RI(*TM.getSubtargetImpl(), *this) {} 
  
  const Cpu0RegisterInfo &Cpu0InstrInfo::getRegisterInfo() const { 
    return RI; 
  } 
  
  //  Cpu0TargetMachine.h
    virtual const Cpu0RegisterInfo *getRegisterInfo()  const {
      return &InstrInfo.getRegisterInfo();
    }
  
  # CMakeLists.txt 
  ...
  add_llvm_target(Cpu0CodeGen 
    ...
    Cpu0RegisterInfo.cpp 
    ...
    )

Now, let's replace 3/1/Cpu0 with 3/2/Cpu0 of adding register class definition 
and rebuild. 
After that, let's try to run the ``llc`` compile command to see what happen,

.. code-block:: bash

  118-165-78-230:InputFiles Jonathan$ /Users/Jonathan/llvm/test/cmake_debug_build/
  bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=asm ch3.bc -o 
  ch3.cpu0.s
  Assertion failed: (AsmInfo && "MCAsmInfo not initialized." "Make sure you includ
  ...


The errors say that we have not Target AsmPrinter. 
Let's add it in next section.


Add AsmPrinter
--------------

3/3/cpu0 contains the Cpu0AsmPrinter definition. First, we add definitions in 
Cpu0.td to support AssemblyWriter. 
Cpu0.td is added with the following fragment,

.. code-block:: c++

  // Cpu0.td
  //...
  //===----------------------------------------------------------------------===//
  // Cpu0 processors supported. 
  //===----------------------------------------------------------------------===//
  
  class Proc<string Name, list<SubtargetFeature> Features> 
   : Processor<Name, Cpu0GenericItineraries, Features>; 
  
  def : Proc<"cpu032", [FeatureCpu032]>; 
  
  def Cpu0AsmWriter : AsmWriter { 
    string AsmWriterClassName  = "InstPrinter"; 
    bit isMCAsmWriter = 1; 
  } 
  
  // Will generate Cpu0GenAsmWrite.inc included by Cpu0InstPrinter.cpp, contents
  //  as follows, 
  // void Cpu0InstPrinter::printInstruction(const MCInst *MI, raw_ostream &O) 
  //  {...}
  // const char *Cpu0InstPrinter::getRegisterName(unsigned RegNo) {...} 
  def Cpu0 : Target { 
  // def Cpu0InstrInfo : InstrInfo as before. 
    let InstructionSet = Cpu0InstrInfo; 
    let AssemblyWriters = [Cpu0AsmWriter]; 
  }

As comments indicate, it will generate Cpu0GenAsmWrite.inc which is included 
by Cpu0InstPrinter.cpp. 
Cpu0GenAsmWrite.inc has the implementation of 
Cpu0InstPrinter::printInstruction() and Cpu0InstPrinter::getRegisterName(). 
Both of these functions can be auto-generated from the information we defined 
in Cpu0InstrInfo.td and Cpu0RegisterInfo.td. 
To let these two functions work in our code, the only thing need to do is add a 
class Cpu0InstPrinter and include them.

File 3/3/Cpu0/InstPrinter/Cpu0InstPrinter.cpp include Cpu0GenAsmWrite.inc and 
call the auto-generated functions as follows,

.. code-block:: c++

  //  Cpu0InstPrinter.cpp
  #include "Cpu0GenAsmWriter.inc" 
  
  void Cpu0InstPrinter::printRegName(raw_ostream &OS, unsigned RegNo) const { 
  //- getRegisterName(RegNo) defined in Cpu0GenAsmWriter.inc which came from
  //-  Cpu0.td indicate. 
    OS << '$' << StringRef(getRegisterName(RegNo)).lower(); 
  } 
  
  void Cpu0InstPrinter::printInst(const MCInst *MI, raw_ostream &O, 
                  StringRef Annot) { 
  //- printInstruction(MI, O) defined in Cpu0GenAsmWriter.inc which came from
  //-  Cpu0.td indicate. 
    printInstruction(MI, O); 
    printAnnotation(O, Annot); 
  } 

Next, add Cpu0AsmPrinter (Cpu0AsmPrinter.h, Cpu0AsmPrinter.cpp), 
Cpu0MCInstLower (Cpu0MCInstLower.h, Cpu0MCInstLower.cpp), Cpu0BaseInfo.h, 
Cpu0FixupKinds.h and Cpu0MCAsmInfo (Cpu0MCAsmInfo.h, Cpu0MCAsmInfo.cpp) in 
sub-directory MCTargetDesc.

Finally, add code in Cpu0MCTargetDesc.cpp to register Cpu0InstPrinter as 
follows,

.. code-block:: c++

  //  Cpu0MCTargetDesc.cpp
  static MCAsmInfo *createCpu0MCAsmInfo(const Target &T, StringRef TT) {
    MCAsmInfo *MAI = new Cpu0MCAsmInfo(T, TT);
  
    MachineLocation Dst(MachineLocation::VirtualFP);
    MachineLocation Src(Cpu0::SP, 0);
    MAI->addInitialFrameState(0, Dst, Src);
  
    return MAI;
  }
  
  static MCInstPrinter *createCpu0MCInstPrinter(const Target &T,
                          unsigned SyntaxVariant,
                          const MCAsmInfo &MAI,
                          const MCInstrInfo &MII,
                          const MCRegisterInfo &MRI,
                          const MCSubtargetInfo &STI) {
    return new Cpu0InstPrinter(MAI, MII, MRI);
  }
  
  extern "C" void LLVMInitializeCpu0TargetMC() {
    // Register the MC asm info.
    RegisterMCAsmInfoFn X(TheCpu0Target, createCpu0MCAsmInfo);
    RegisterMCAsmInfoFn Y(TheCpu0elTarget, createCpu0MCAsmInfo);
  
    // Register the MCInstPrinter.
    TargetRegistry::RegisterMCInstPrinter(TheCpu0Target,
                      createCpu0MCInstPrinter);
    TargetRegistry::RegisterMCInstPrinter(TheCpu0elTarget,
                      createCpu0MCInstPrinter);
  }

Now, it's time to work with AsmPrinter. According section 
"section Target Registration" [#]_, we can register our AsmPrinter when we need it 
as follows,

.. code-block:: c++

  // Cpu0AsmPrinter.cpp
  // Force static initialization.
  extern "C" void LLVMInitializeCpu0AsmPrinter() {
    RegisterAsmPrinter<Cpu0AsmPrinter> X(TheCpu0Target);
    RegisterAsmPrinter<Cpu0AsmPrinter> Y(TheCpu0elTarget);
  }

The dynamic register mechanism is a good idea, right.

Except add the new .cpp files to CMakeLists.txt, please remember to add 
subdirectory InstPrinter, enable asmprinter, add libraries AsmPrinter and 
Cpu0AsmPrinter to LLVMBuild.txt as follows,

.. code-block:: c++

  //  LLVMBuild.txt
  [common] 
  subdirectories = InstPrinter MCTargetDesc TargetInfo 
  
  [component_0] 
  ...
  # Please enable asmprinter
  has_asmprinter = 1 
  ...
  
  [component_1] 
  # Add AsmPrinter Cpu0AsmPrinter
  required_libraries = AsmPrinter CodeGen Core MC Cpu0AsmPrinter Cpu0Desc  
                       Cpu0Info SelectionDAG Support Target

Now, run 3/3/Cpu0 for AsmPrinter support, will get error message as follows,

.. code-block:: bash

  118-165-78-230:InputFiles Jonathan$ /Users/Jonathan/llvm/test/cmake_debug_build/
  bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=asm ch3.bc -o 
  ch3.cpu0.s
  /Users/Jonathan/llvm/test/cmake_debug_build/bin/Debug/llc: target does not 
  support generation of this file type!

The ``llc`` fails to compile IR code into machine code since we didn't implement 
class Cpu0DAGToDAGISel. Before the implementation, we will introduce the LLVM 
Code Generation Sequence, DAG, and LLVM instruction selection in next 3 
sections.

LLVM Code Generation Sequence
-----------------------------

Following diagram came from tricore_llvm.pdf.

.. _backendstructure_f5: 
.. figure:: ../Fig/backendstructure/5.png
	:align: center

	tricore_llvm.pdf: Code generation sequence. On the path from LLVM code to assembly code, numerous passes are run through and several data structures are used to represent the intermediate results.

LLVM is a Static Single Assignment (SSA) based representation. 
LLVM provides an infinite virtual registers which can hold values of primitive 
type (integral, floating point, or pointer values). 
So, every operand can save in different virtual register in llvm SSA 
representation. 
Comment is “;” in llvm representation. 
Following is the llvm SSA instructions.

.. code-block:: c++

  store i32 0, i32* %a  ; store i32 type of 0 to virtual register %a, %a is
              ;  pointer type which point to i32 value
  store i32 %b, i32* %c ; store %b contents to %c point to, %b isi32 type virtual
              ;  register, %c is pointer type which point to i32 value.
  %a1 = load i32* %a    ; load the memory value where %a point to and assign the
              ;  memory value to %a1
  %a3 = add i32 %a2, 1  ; add %a2 and 1 and save to %a3

We explain the code generation process as below. 
If you don't feel comfortable, please check tricore_llvm.pdf section 4.2 first. 
You can  read “The LLVM Target-Independent Code Generator” from [#]_ 
and “LLVM Language Reference Manual” from [#]_ 
before go ahead, but we think read section 
4.2 of tricore_llvm.pdf is enough. 
We suggest you read the web site documents as above only when you are still not 
quite understand, even though you have read this section and next 2 sections 
article for DAG and Instruction Selection.

1. Instruction Selection

.. code-block:: c++

  // In this stage, transfer the llvm opcode into machine opcode, but the operand
  //  still is llvm virtual operand.
      store i16 0, i16* %a // store 0 of i16 type to where virtual register %a
                 //  point to
  =>  addiu i16 0, i32* %a

2. Scheduling and Formation

.. code-block:: c++

  // In this stage, reorder the instructions sequence for optimization in
  //  instructions cycle or in register pressure.
      st i32 %a, i16* %b,  i16 5 // st %a to *(%b+5)
      st %b, i32* %c, i16 0
      %d = ld i32* %c
  
  // Transfer above instructions order as follows. In RISC like Mips the ld %c use
  //  the previous instruction st %c, must wait more than 1
  // cycles. Meaning the ld cannot follow st immediately.
  =>  st %b, i32* %c, i16 0
      st i32 %a, i16* %b,  i16 5
      %d = ld i32* %c, i16 0
  // If without reorder instructions, a instruction nop which do nothing must be
  //  filled, contribute one instruction cycle more than optimization. (Actually,
  //  Mips is scheduled with hardware dynamically and will insert nop between st
  //  and ld instructions if compiler didn't insert nop.)
      st i32 %a, i16* %b,  i16 5
      st %b, i32* %c, i16 0
      nop
      %d = ld i32* %c, i16 0
  
  // Minimum register pressure
  //  Suppose %c is alive after the instructions basic block (meaning %c will be
  //  used after the basic block), %a and %b are not alive after that.
  // The following no reorder version need 3 registers at least
      %a = add i32 1, i32 0
      %b = add i32 2, i32 0
      st %a,  i32* %c, 1
      st %b,  i32* %c, 2
  
  // The reorder version need 2 registers only (by allocate %a and %b in the same
  //  register)
  => %a = add i32 1, i32 0
      st %a,  i32* %c, 1
      %b = add i32 2, i32 0
      st %b,  i32* %c, 2

3. SSA-based Machine Code Optimization

    For example, common expression remove, shown in next section DAG.
	
4. Register Allocation

    Allocate real register for virtual register.
	
5. Prologue/Epilogue Code Insertion

    Explain in section Add Prologue/Epilogue functions
	
6. Late Machine Code Optimizations

    Any “last-minute” peephole optimizations of the final machine code can be applied during this phase. For example, replace x = x * 2 by x = x < 1 for integer operand.
	
7. Code Emission
	Finally, the completed machine code is emitted. For static compilation, the end result is an assembly code file; for JIT compilation, the opcodes of the machine instructions are written into memory. 

DAG (Directed Acyclic Graph)
----------------------------

Many important techniques for local optimization begin by transforming a basic 
block into DAG. For example, the basic block code and it's corresponding DAG as 
:ref:`backendstructure_f6`.

.. _backendstructure_f6: 
.. figure:: ../Fig/backendstructure/6.png
	:align: center

	DAG example

If b is not live on exit from the block, then we can do common expression 
remove to get the following code.

.. code-block:: c++

  a = b + c
  d = a – d
  c = d + c

As you can imagine, the common expression remove can apply in IR or machine 
code.

DAG like a tree which opcode is the node and operand (register and 
const/immediate/offset) is leaf. 
It can also be represented by list as prefix order in tree. 
For example, (+ b, c), (+ b, 1) is IR DAG representation.


Instruction Selection
---------------------

In back end, we need to translate IR code into machine code at Instruction 
Selection Process as :ref:`backendstructure_f7`.

.. _backendstructure_f7: 
.. figure:: ../Fig/backendstructure/7.png
	:align: center

	IR and it's corresponding machine instruction

For machine instruction selection, the better solution is represent IR and 
machine instruction by DAG. 
In :ref:`backendstructure_f7`, we skip the register leaf. 
The rj + rk is IR DAG representation (for symbol notation, not llvm SSA form). 
ADD is machine instruction.

.. _backendstructure_f8: 
.. figure:: ../Fig/backendstructure/8.png
	:align: center

	Instruction DAG representation

The IR DAG and machine instruction DAG can also represented as list. 
For example, (+ ri, rj), (- ri, 1) are lists for IR DAG; (ADD ri, rj), 
(SUBI ri, 1) are lists for machine instruction DAG.

Now, let's recall the ADDiu instruction defined on Cpu0InstrInfo.td in the 
previous chapter. 
And It will expand to the following Pattern as mentioned in section Write td 
(Target Description) of the previous chapter as follows,

.. code-block:: c++

  def ADDiu   : ArithLogicI<0x09, "addiu", add, simm16, immSExt16, CPURegs>;
  
  Pattern = [(set CPURegs:$ra, (add RC:$rb, immSExt16:$imm16))]

This pattern meaning the IR DAG node **add** can translate into machine 
instruction DAG node ADDiu by pattern match mechanism. 
Similarly, the machine instruction DAG node LD and ST can be got from IR DAG 
node **load** and **store**.

Some cpu/fpu (floating point processor) has multiply-and-add floating point 
instruction, fmadd. 
It can be represented by DAG list (fadd (fmul ra, rc), rb). 
For this implementation, we can assign fmadd DAG pattern to instruction td as 
follows,

.. code-block:: c++

  def FMADDS : AForm_1<59, 29,
            (ops F4RC:$FRT, F4RC:$FRA, F4RC:$FRC, F4RC:$FRB),
            "fmadds $FRT, $FRA, $FRC, $FRB",
            [(set F4RC:$FRT, (fadd (fmul F4RC:$FRA, F4RC:$FRC),
                         F4RC:$FRB))]>;

Similar with ADDiu, [(set F4RC:$FRT, (fadd (fmul F4RC:$FRA, F4RC:$FRC), 
F4RC:$FRB))] is the pattern which include node **fmul** and node **fadd**.

Now, for the following basic block notation IR and llvm SSA IR code,

.. code-block:: c++

  d = a * c
  e = d + b
  ...
  
  %d = fmul %a, %c
  %e = fadd %d, %b
  ...

The llvm SelectionDAG Optimization Phase (is part of Instruction Selection 
Process) prefered to translate this 2 IR DAG node (fmul %a, %b) (fadd %d, %c) 
into one machine instruction DAG node (**fmadd** %a, %c, %b), than translate 
them into 2 machine instruction nodes **fmul** and **fadd**.

.. code-block:: c++

  %e = fmadd %a, %c, %b
  ...

As you can see, the IR notation representation is easier to read then llvm SSA 
IR form. 
So, we  use the notation form in this book sometimes.

For the following basic block code,

.. code-block:: c++

  a = b + c   // in notation IR form
  d = a – d
  %e = fmadd %a, %c, %b // in llvm SSA IR form

We can apply :ref:`backendstructure_f7` Instruction tree pattern to get the 
following machine code,

.. code-block:: c++

  load  rb, M(sp+8); // assume b allocate in sp+8, sp is stack point register
  load  rc, M(sp+16);
  add ra, rb, rc;
  load  rd, M(sp+24);
  sub rd, ra, rd;
  fmadd re, ra, rc, rb;


Add Cpu0DAGToDAGISel class
--------------------------

The IR DAG to machine instruction DAG transformation is introduced in the 
previous section. 
Now, let's check what IR DAG node the file ch3.bc has. List ch3.ll as follows,

.. code-block:: c++

  // ch3.ll
  define i32 @main() nounwind uwtable { 
  %1 = alloca i32, align 4 
  store i32 0, i32* %1 
  ret i32 0 
  } 

As above, ch3.ll use the IR DAG node **store**, **ret**. Actually, it also use 
**add** for sp (stack point) register adjust. 
So, the definitions in Cpu0InstInfo.td as follows is enough. 
IR DAG is defined in file  include/llvm/Target/TargetSelectionDAG.td.

.. code-block:: c++

  /// Load and Store Instructions 
  ///  aligned 
  defm LD      : LoadM32<0x00,  "ld",  load_a>; 
  defm ST      : StoreM32<0x01, "st",  store_a>; 
  
  /// Arithmetic Instructions (ALU Immediate)
  //def LDI     : MoveImm<0x08, "ldi", add, simm16, immSExt16, CPURegs>;
  // add defined in include/llvm/Target/TargetSelectionDAG.td, line 315 (def add).
  def ADDiu   : ArithLogicI<0x09, "addiu", add, simm16, immSExt16, CPURegs>;
  
  let isReturn=1, isTerminator=1, hasDelaySlot=1, isCodeGenOnly=1, 
    isBarrier=1, hasCtrlDep=1 in 
    def RET : FJ <0x2C, (outs), (ins CPURegs:$target), 
          "ret\t$target", [(Cpu0Ret CPURegs:$target)], IIBranch>;

Add class Cpu0DAGToDAGISel (Cpu0ISelDAGToDAG.cpp) to CMakeLists.txt, and add 
following fragment to Cpu0TargetMachine.cpp,

.. code-block:: c++

  //  Cpu0TargetMachine.cpp
  ...
  // Install an instruction selector pass using
  // the ISelDag to gen Cpu0 code.
  bool Cpu0PassConfig::addInstSelector() {
    addPass(createCpu0ISelDag(getCpu0TargetMachine()));
    return false;
  }
  
  //  Cpu0ISelDAGToDAG.cpp
  /// createCpu0ISelDag - This pass converts a legalized DAG into a 
  /// CPU0-specific DAG, ready for instruction scheduling. 
  FunctionPass *llvm::createCpu0ISelDag(Cpu0TargetMachine &TM) { 
    return new Cpu0DAGToDAGISel(TM); 
  }

This version adding the following code in Cpu0InstInfo.cpp to enable debug 
information which called by llvm at proper time.

.. code-block:: c++

  // Cpu0InstInfo.cpp
  ...
  MachineInstr*
  Cpu0InstrInfo::emitFrameIndexDebugValue(MachineFunction &MF, int FrameIx,
                      uint64_t Offset, const MDNode *MDPtr,
                      DebugLoc DL) const {
    MachineInstrBuilder MIB = BuildMI(MF, DL, get(Cpu0::DBG_VALUE))
    .addFrameIndex(FrameIx).addImm(0).addImm(Offset).addMetadata(MDPtr);
    return &*MIB;
  }

Build 3/4, run it, we find the error message in 3/3 is gone. The new error 
message for 3/4 as follows,

.. code-block:: bash

  118-165-78-230:InputFiles Jonathan$ /Users/Jonathan/llvm/test/cmake_debug_build/
  bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=asm ch3.bc -o 
  ch3.cpu0.s
  ...
  Target didn't implement TargetInstrInfo::storeRegToStackSlot!
  1.  Running pass 'Function Pass Manager' on module 'ch3.bc'.
  2.  Running pass 'Prologue/Epilogue Insertion & Frame Finalization' on function 
  '@main'
  ...


Add Prologue/Epilogue functions
-------------------------------

Following came from tricore_llvm.pdf section “4.4.2 Non-static Register 
Information ”.

For some target architectures, some aspects of the target architecture’s 
register set are dependent upon variable factors and have to be determined at 
runtime. 
As a consequence, they cannot be generated statically from a TableGen 
description – although that would be possible for the bulk of them in the case 
of the TriCore backend. 
Among them are the following points:

• Callee-saved registers. Normally, the ABI specifies a set of registers that a function must save on entry and restore on return if their contents are possibly modified during execution.

• Reserved registers. Although the set of unavailable registers is already defined in the TableGen file, TriCoreRegisterInfo contains a method that marks all non-allocatable register numbers in a bit vector. 

The following methods are implemented:

• emitPrologue() inserts prologue code at the beginning of a function. Thanks to TriCore’s context model, this is a trivial task as it is not required to save any registers manually. The only thing that has to be done is reserving space for the function’s stack frame by decrementing the stack pointer. In addition, if the function needs a frame pointer, the frame register %a14 is set to the old value of the stack pointer beforehand.

• emitEpilogue() is intended to emit instructions to destroy the stack frame and restore all previously saved registers before returning from a function. However, as %a10 (stack pointer), %a11 (return address), and %a14 (frame pointer, if any) are all part of the upper context, no epilogue code is needed at all. All cleanup operations are performed implicitly by the ret instruction. 

• eliminateFrameIndex() is called for each instruction that references a word of data in a stack slot. All previous passes of the code generator have been addressing stack slots through an abstract frame index and an immediate offset. The purpose of this function is to translate such a reference into a register–offset pair. Depending on whether the machine function that contains the instruction has a fixed or a variable stack frame, either the stack pointer %a10 or the frame pointer %a14 is used as the base register. The offset is computed accordingly. Figure 3.9 demonstrates for both cases how a stack slot is addressed. 

If the addressing mode of the affected instruction cannot handle the address because the offset is too large (the offset field has 10 bits for the BO addressing mode and 16 bits for the BOL mode), a sequence of instructions is emitted that explicitly computes the effective address. Interim results are put into an unused address register. If none is available, an already occupied address register is scavenged. For this purpose, LLVM’s framework offers a class named RegScavenger that takes care of all the details.

.. _backendstructure_f9: 
.. figure:: ../Fig/backendstructure/9.png
	:align: center

	Addressing of a variable a located on the stack. If the stack frame has a variable size, slot must be addressed relative to the frame pointer

We will explain the Prologue and Epilogue further by example code. 
So for the following llvm IR code, Cpu0 back end will emit the corresponding 
machine instructions as follows,

.. code-block:: bash

  define i32 @main() nounwind uwtable { 
    %1 = alloca i32, align 4 
    store i32 0, i32* %1 
    ret i32 0 
  }
  
    .section .mdebug.abi32
    .previous
    .file "ch3.bc"
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
    .set  nomacro
  # BB#0:
    addiu $sp, $sp, -8
  $tmp1:
    .cfi_def_cfa_offset 8
    addiu $2, $zero, 0
    st  $2, 4($sp)
    addiu $sp, $sp, 8
    ret $lr
    .set  macro
    .set  reorder
    .end  main
  $tmp2:
    .size main, ($tmp2)-main
    .cfi_endproc

LLVM get the stack size by parsing IR and counting how many virtual registers 
is assigned to local variables. After that, it call emitPrologue(). 
This function will emit machine instructions to adjust sp (stack pointer 
register) for local variables since we don't use fp (frame pointer register). 
For our example, it will emit the instructions,

.. code-block:: c++

  addiu $sp, $sp, -8

The  emitEpilogue will emit “addiu  $sp, $sp, 8”, 8 is the stack size.

Since Instruction Selection and Register Allocation occurs before 
Prologue/Epilogue Code Insertion, eliminateFrameIndex() is called after machine 
instruction and real register allocated. 
It translate the frame index of local variable (%1 and %2 in the following 
example) into stack offset according the frame index order upward (stack grow 
up downward from high address to low address, 0($sp) is the top, 52($sp) is the 
bottom) as follows,

.. code-block:: bash

  define i32 @main() nounwind uwtable { 
       %1 = alloca i32, align 4 
       %2 = alloca i32, align 4 
      ...
      store i32 0, i32* %1
      store i32 5, i32* %2, align 4 
      ...
      ret i32 0 
  
  => # BB#0: 
    addiu $sp, $sp, -56 
  $tmp1: 
    addiu $3, $zero, 0 
    st  $3, 52($sp)   // %1 is the first frame index local variable, so allocate
                      // in 52($sp)
    addiu $2, $zero, 5 
    st  $2, 48($sp)   // %2 is the second frame index local variable, so 
                      // allocate in 48($sp)
    ...
    ret $lr

After add these Prologue and Epilogue functions, and build with 3/5/Cpu0. 
Now we are ready to compile our example code ch3.bc into cpu0 assembly code. 
Following is the command and output file ch3.cpu0.s,

.. code-block:: bash

  118-165-78-230:InputFiles Jonathan$ cat ch3.cpu0.s 
    .section .mdebug.abi32
    .previous
    .file "ch3.bc"
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
    .set  nomacro
  # BB#0:
    addiu $sp, $sp, -8
  $tmp1:
    .cfi_def_cfa_offset 8
    addiu $2, $zero, 0
    st  $2, 4($sp)
    addiu $sp, $sp, 8
    ret $lr
    .set  macro
    .set  reorder
    .end  main
  $tmp2:
    .size main, ($tmp2)-main
    .cfi_endproc


Summary of this Chapter
-----------------------

We have finished a simple assembler for cpu0 which only support **addiu**, 
**st** and **ret** 3 instructions.

We are satisfied with this result. 
But you may think “After so many codes we program, and just get the 3 
instructions”. 
The point is we have created a frame work for cpu0 target machine (please 
look back the llvm back end structure class inherit tree early in this 
chapter). 
Until now, we have around 3050 lines of source code with comments which include 
files \*.cpp, \*.h, \*.td, CMakeLists.txt and LLVMBuild.txt. 
It can be counted by command ``wc `find dir -name *.cpp``` for files \*.cpp, 
\*.h, \*.td, \*.txt. 
LLVM front end tutorial have 700 lines of source code without comments totally. 
Don't feel down with this result. 
In reality, write a back end is warm up slowly but run fast. 
Clang has over 500,000 lines of source code with comments in clang/lib 
directory which include C++ and Obj C support. 
Mips back end has only 15,000 lines with comments. 
Even the complicate X86 CPU which CISC outside and RISC inside (micro 
instruction), has only 45,000 lines with comments. 
In next chapter, we will show you that add a new instruction support is as easy 
as 123.



.. [#] http://llvm.org/docs/WritingAnLLVMBackend.html#TargetMachine

.. [#] http://jonathan2251.github.com/lbd/llvmstructure.html#target-registration

.. [#] http://llvm.org/docs/CodeGenerator.html

.. [#] http://llvm.org/docs/LangRef.html