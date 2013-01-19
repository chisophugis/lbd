.. _sec-appendix-old-llvm-ver:

Appendix B: LLVM changes
========================

This chapter show you the old version of LLVM API and structure 
those affect Cpu0 back end. 
Mips changes also mentioned in this chapter. 
If you work on the latest LLVM version only, please skip this chapter. 
LLVM version 3.2 released in 20 December, 2012. 
Version 3.1 released in 22 May, 2012. 
This book started from September, 2012. 
This chapter discuss the old version start from 3.1. 


Difference between 3.2 and 3.1
------------------------------

API difference
~~~~~~~~~~~~~~~

Difference in API as follows,

1. In llvm 3.1, the parameters of call back function for Target Registration 
is different from 3.2. 
LLVM 3.2 add parameter "MCRegisterInfo" in the callback function for 
RegisterMCCodeEmitter() and "StringRef" in the callback function for  
RegisterMCAsmBackend. 
In other word, you can get more information of registers and CPU 
(type of StringRef) for your backend after this registration.
Of course, these information came from TabGen which source is the Target 
Description .td you write.

.. code-block:: c++

  extern "C" void LLVMInitializeCpu0TargetMC() {
    ...
    // Register the MC Code Emitter
    TargetRegistry::RegisterMCCodeEmitter(TheCpu0Target,
                      createCpu0MCCodeEmitterEB);
    TargetRegistry::RegisterMCCodeEmitter(TheCpu0elTarget,
                      createCpu0MCCodeEmitterEL);
    ...
  
    // Register the asm backend.
    TargetRegistry::RegisterMCAsmBackend(TheCpu0Target,
                       createCpu0AsmBackendEB32);
    TargetRegistry::RegisterMCAsmBackend(TheCpu0elTarget,
                       createCpu0AsmBackendEL32);
    ...
  }


Version 3.1 as follows,

.. code-block:: c++

  MCCodeEmitter *createCpu0MCCodeEmitterEB(const MCInstrInfo &MCII,
                       const MCSubtargetInfo &STI,
                       MCContext &Ctx);
  MCCodeEmitter *createCpu0MCCodeEmitterEL(const MCInstrInfo &MCII,
                       const MCSubtargetInfo &STI,
                       MCContext &Ctx);
  
  MCAsmBackend *createCpu0AsmBackendEB32(const Target &T, StringRef TT);
  MCAsmBackend *createCpu0AsmBackendEL32(const Target &T, StringRef TT);

Version 3.2 as follows,

.. code-block:: c++

  MCCodeEmitter *createCpu0MCCodeEmitterEB(const MCInstrInfo &MCII,
                       const MCRegisterInfo &MRI,
                       const MCSubtargetInfo &STI,
                       MCContext &Ctx);
  MCCodeEmitter *createCpu0MCCodeEmitterEL(const MCInstrInfo &MCII,
                       const MCRegisterInfo &MRI,
                       const MCSubtargetInfo &STI,
                       MCContext &Ctx);
  
  MCAsmBackend *createCpu0AsmBackendEB32(const Target &T, StringRef TT,
                       StringRef CPU);
  MCAsmBackend *createCpu0AsmBackendEL32(const Target &T, StringRef TT,
                       StringRef CPU);

2. Change LowerCall() parameters as follows,

Version 3.1 as follows,

.. code-block:: c++

  SDValue
      LowerCall(SDValue Chain, SDValue Callee,
          CallingConv::ID CallConv, bool isVarArg,
          bool doesNotRet, bool &isTailCall,
          const SmallVectorImpl<ISD::OutputArg> &Outs,
          const SmallVectorImpl<SDValue> &OutVals,
          const SmallVectorImpl<ISD::InputArg> &Ins,
          DebugLoc dl, SelectionDAG &DAG,
          SmallVectorImpl<SDValue> &InVals) const;

Version 3.2 as follows,

.. code-block:: c++

  LowerCall(TargetLowering::CallLoweringInfo &CLI,
          SmallVectorImpl<SDValue> &InVals) const;

The TargetLowering::CallLoweringInfo is type of structure/class which contains 
the old version 3.1 parameters. 
You can get the 3.1 same information by,

.. code-block:: c++

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
    ...
  }

As chapter "function call", the role of LowerCall() is handling the outgoing 
arguments passing in function call. 

3. The TargetData structure of LLVMTargetMachine has been renamed to DataLayout 
and the corresponding function name change as follows,

.. code-block:: c++

  // 3.1
  class Cpu0TargetMachine : public LLVMTargetMachine {
    ...
    virtual const TargetData      *getTargetData()    const
    { return &DataLayout;}
    ...
  }

.. code-block:: c++

  // 3.2
  class Cpu0TargetMachine : public LLVMTargetMachine {
    ...
    virtual const DataLayout *getDataLayout()    const
    { return &DL;}
    ...
  }

4. The "add a pass" API change as follows,

.. code-block:: c++

  // 3.1
  TargetPassConfig *Cpu0TargetMachine::createPassConfig(PassManagerBase &PM) {
    return new Cpu0PassConfig(this, PM);
  }
  
  // Install an instruction selector pass using
  // the ISelDag to gen Cpu0 code.
  bool Cpu0PassConfig::addInstSelector() {
    PM->add(createCpu0ISelDag(getCpu0TargetMachine()));
    return false;
  }
  
  // 3.2
  // Install an instruction selector pass using
  // the ISelDag to gen Cpu0 code.
  bool Cpu0PassConfig::addInstSelector() {
    addPass(createCpu0ISelDag(getCpu0TargetMachine()));
    return false;
  }

5. Above changes is mandatory. 
There are some changes are adviced to follow. Like the below. 
We comment the "Change Reason" in the following code. You can get the 
"Change Reason" by internet searching.

.. code-block:: c++

    MCObjectWriter *createObjectWriter(raw_ostream &OS) const {
    // Change Reason:
    // Reduce the exposure of Triple::OSType in the ELF object writer. This will
    //  avoid including ADT/Triple.h in many places when the target specific bits 
    //  are moved.
    return createCpu0ELFObjectWriter(OS,
      MCELFObjectTargetWriter::getOSABI(OSType), IsLittle);
  // Even though, the old function still work on LLVM version 3.2
  //    return createCpu0ELFObjectWriter(OS, OSType, IsLittle);
    }
  
  class Cpu0MCCodeEmitter : public MCCodeEmitter {
    // #define LLVM_DELETED_FUNCTION
    //  LLVM_DELETED_FUNCTION - Expands to = delete if the compiler supports it. 
    //  Use to mark functions as uncallable. Member functions with this should be 
    //  declared private so that some behavior is kept in C++03 mode.
    //  class DontCopy { private: DontCopy(const DontCopy&) LLVM_DELETED_FUNCTION;
    //  DontCopy &operator =(const DontCopy&) LLVM_DELETED_FUNCTION; public: ... };
    //  Definition at line 79 of file Compiler.h.
  
    Cpu0MCCodeEmitter(const Cpu0MCCodeEmitter &) LLVM_DELETED_FUNCTION;
    void operator=(const Cpu0MCCodeEmitter &) LLVM_DELETED_FUNCTION;
  // Even though, the old function still work on LLVM version 3.2
  //  Cpu0MCCodeEmitter(const Cpu0MCCodeEmitter &); // DO NOT IMPLEMENT
  //  void operator=(const Cpu0MCCodeEmitter &); // DO NOT IMPLEMENT
  ...


Structure difference
~~~~~~~~~~~~~~~~~~~~

1. Change the name from CPURegsRegisterClass (3.1) to CPURegsRegClass (3.2). 
The source of register class information came from your backend <register>.td. 
The new name CPURegsRegClass is **"call by reference"** type in C++ while the 
old CPURegsRegisterClass is **"pointer"** type. The "reference" type use 
**"."** while pointer type use **"->"** as follows,

.. code-block:: c++

  // 3.2
  unsigned CPURegSize = Cpu0::CPURegsRegClass.getSize();
  // 3.1
  unsigned CPURegSize = Cpu0::CPURegsRegisterClass->getSize();


2. The TargetData structure has been renamed to DataLayout and moved to VMCore 
to remove a dependency on Target [#]_. 

.. code-block:: c++

  // 3.1
  #include "llvm/Target/TargetData.h"
  class Cpu0TargetMachine : public LLVMTargetMachine {
    ...
    const TargetData    DataLayout; // Calculates type size & alignment
    ...
  }

  // 3.2
  #include "llvm/DataLayout.h"
  class Cpu0TargetMachine : public LLVMTargetMachine {
    ...
    const DataLayout    DL; // Calculates type size & alignment
    ...
  }

3. DebugInfo.h is moved.

.. code-block:: c++

  // 3.1
  #include "llvm/Analysis/DebugInfo.h
  
  // 3.2
  #include "llvm/DebugInfo.h



Verify the Cpu0 for difference 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

3.1_src_files_modify include the LLVM 3.1 those files 
modified for Cpu0 backend support. 
Please copy 
3.1_src_files_modify/src_files_modify/src to your LLVM 3.1 source directory. 
The llvm3.1/Cpu0 is the code for LLVM version 3.1. 
File ch_all.cpp include the all C/C++ operators, global variable, struct, 
array, control statement and function call test. 
Run llvm3.1/Cpu0 with ch_all.cpp will get the assembly code as below. 
By compare it with the output of 3.2 result, you can verify the correction 
as below. The difference came from 3.2 correcting the label number in 
order. 

.. code-block:: c++

  //#include <stdio.h>
  #include <stdarg.h>
  #include <stdlib.h>
  
  int test_operators()
  {
    int a = 5;
    int b = 2;
    int c = 0;
    int d = 0;
    int e, f, g, h, i, j, k, l = 0;
    unsigned int a1 = -5, k1 = 0, f1 = 0;
  
    c = a + b;
    d = a - b;
    e = a * b;
    f = a / b;
    f1 = a1 / b;
    g = (a & b);
    h = (a | b);
    i = (a ^ b);
    j = (a << 2);
    int j1 = (a1 << 2);
    k = (a >> 2);
    k1 = (a1 >> 2);
  
    b = !a;
    int* p = &b;
    b = (b+1)%a;
    c = rand();
    b = (b+1)%c;
    
    return c;
  }
  
  int gI = 100;
  
  int test_globalvar()
  {
    int c = 0;
  
    c = gI;
    
    return c;
  }
  
  struct Date
  {
    int year;
    int month;
    int day;
  };
  
  Date date = {2012, 10, 12};
  int a[3] = {2012, 10, 12};
  
  int test_struct()
  {
    int day = date.day;
    int i = a[1];
  
    return 0;
  }
  
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
    test_operators();
    int a = sum<int>(6, 1, 2, 3, 4, 5, 6);
  //  printf("a = %d\n", a);
    
    return a;
  }


.. code-block:: bash

  118-165-78-60:InputFiles Jonathan$ diff ch_all.3.1.cpu0.s ch_all.3.2.cpu0.s 
  262c262
  <   jge $BB4_7
  ---
  >   jge $BB4_6
  285d284
  < # BB#6:                                 #   in Loop: Header=BB4_1 Depth=1
  290c289
  < $BB4_7:
  ---
  > $BB4_6:
  295,297c294,296
  <   jne $BB4_9
  <   jmp $BB4_8
  < $BB4_8:                                 # %SP_return
  ---
  >   jne $BB4_8
  >   jmp $BB4_7
  > $BB4_7:                                 # %SP_return
  301c300
  < $BB4_9:                                 # %CallStackCheckFailBlk
  ---
  > $BB4_8:                                 # %CallStackCheckFailBlk

.. code-block:: bash

  // ch_all.3.2.cpu0.s
  ...
  $BB4_5:                                 #   in Loop: Header=BB4_1 Depth=1
    ld  $3, 0($3)
    st  $3, 36($sp)
    ld  $4, 32($sp)
    add $3, $4, $3
    st  $3, 32($sp)
    ld  $3, 40($sp)
    addiu $3, $3, 1
    st  $3, 40($sp)
    jmp $BB4_1
  $BB4_6:
    ld  $2, %got(__stack_chk_guard)($gp)
    ld  $2, 0($2)
    ld  $3, 48($sp)
    cmp $2, $3
    jne $BB4_8
    jmp $BB4_7
  $BB4_7:                                 # %SP_return
  ...
  
  
  // ch_all.3.1.cpu0.s
  ...
  $BB4_5:                                 #   in Loop: Header=BB4_1 Depth=1
    ld  $3, 0($3)
    st  $3, 36($sp)
    ld  $4, 32($sp)
    add $3, $4, $3
    st  $3, 32($sp)
  # BB#6:                                 #   in Loop: Header=BB4_1 Depth=1
    ld  $3, 40($sp)
    addiu $3, $3, 1
    st  $3, 40($sp)
    jmp $BB4_1
  $BB4_7:
    ld  $2, %got(__stack_chk_guard)($gp)
    ld  $2, 0($2)
    ld  $3, 48($sp)
    cmp $2, $3
    jne $BB4_9
    jmp $BB4_8
  $BB4_8:                                 # %SP_return
  ...


Difference in Mips backend
--------------------------

In 3.1, Mips use **".cpload"** and **".cprestore"** pseudo assembly code. 
It removes these pseudo assembly code in 3.2.
This change is good for spim (mips assembly code simulator) which run for 
Mips assembly code. According the theory of "System Software", some pseudo 
assembly code (especially for those not in standard) cannot be translated by  
assembler. It will break down in assembly code simulator. 
Run ch_mips_llvm3.2_globalvar_changes.cpp with llvm 3.1 and 3.2 for mips, you 
will find the **".cprestore"** is removed directly since 3.2 use other register 
instead of $gp in the callee function (as example, it use $1 in f() and remove 
**.gprestore** in sum_i()).
**".cpload"** is replaced with instructions as follows,

.. code-block:: bash

  // llvm 3.1 mips
    .cpload $25
  
  // llvm 3.2 mips
    lui $2, %hi(_gp_disp)
    addiu $2, $2, %lo(_gp_disp)
    ...
    addu  $gp, $2, $25

Reference [#]_ for **".cpload"**, **".cprestore"** and **"_gp_disp"**.


.. [#] http://llvm.org/releases/3.2/docs/ReleaseNotes.html

.. [#] http://jonathan2251.github.com/lbd/funccall.html#handle-gp-register-in-pic-addressing-mode

