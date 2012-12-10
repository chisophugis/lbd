//===-- Cpu0ISelLowering.cpp - Cpu0 DAG Lowering Implementation -----------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines the interfaces that Cpu0 uses to lower LLVM code into a
// selection DAG.
//
//===----------------------------------------------------------------------===//

#define DEBUG_TYPE "cpu0-lower"
#include "Cpu0ISelLowering.h"
#include "Cpu0MachineFunction.h"
#include "Cpu0TargetMachine.h"
#include "Cpu0TargetObjectFile.h"
#include "Cpu0Subtarget.h"
#include "MCTargetDesc/Cpu0BaseInfo.h"
#include "llvm/DerivedTypes.h"
#include "llvm/Function.h"
#include "llvm/GlobalVariable.h"
#include "llvm/Intrinsics.h"
#include "llvm/CallingConv.h"
#include "llvm/CodeGen/CallingConvLower.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/SelectionDAGISel.h"
#include "llvm/CodeGen/ValueTypes.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

static SDValue GetGlobalReg(SelectionDAG &DAG, EVT Ty) {
  Cpu0FunctionInfo *FI = DAG.getMachineFunction().getInfo<Cpu0FunctionInfo>();
  return DAG.getRegister(FI->getGlobalBaseReg(), Ty);
}

const char *Cpu0TargetLowering::getTargetNodeName(unsigned Opcode) const {
  switch (Opcode) {
  case Cpu0ISD::JmpLink:           return "Cpu0ISD::JmpLink";
  case Cpu0ISD::Hi:                return "Cpu0ISD::Hi";
  case Cpu0ISD::Lo:                return "Cpu0ISD::Lo";
  case Cpu0ISD::GPRel:             return "Cpu0ISD::GPRel";
  case Cpu0ISD::Ret:               return "Cpu0ISD::Ret";
  case Cpu0ISD::Wrapper:           return "Cpu0ISD::Wrapper";
  default:                         return NULL;
  }
}

Cpu0TargetLowering::
Cpu0TargetLowering(Cpu0TargetMachine &TM)
  : TargetLowering(TM, new Cpu0TargetObjectFile()),
    Subtarget(&TM.getSubtarget<Cpu0Subtarget>()) {

  // Set up the register classes
  addRegisterClass(MVT::i32, Cpu0::CPURegsRegisterClass);

  // Used by legalize types to correctly generate the setcc result.
  // Without this, every float setcc comes with a AND/OR with the result,
  // we don't want this, since the fpcmp result goes to a flag register,
  // which is used implicitly by brcond and select operations.
  AddPromotedToType(ISD::SETCC, MVT::i1, MVT::i32);

  // Cpu0 Custom Operations
  setOperationAction(ISD::GlobalAddress,      MVT::i32,   Custom);
  setOperationAction(ISD::BRCOND,             MVT::Other, Custom);
  
  // Operations not directly supported by Cpu0.
//  setOperationAction(ISD::BR_JT,             MVT::Other, Expand);
  setOperationAction(ISD::BR_CC,             MVT::Other, Expand);
//  setOperationAction(ISD::SELECT_CC,         MVT::Other, Expand);

//- Set .align 2
// It will emit .align 2 later
  setMinFunctionAlignment(2);

// must, computeRegisterProperties - Once all of the register classes are added, this allows us to compute derived properties we expose
  computeRegisterProperties();
}

SDValue Cpu0TargetLowering::
LowerOperation(SDValue Op, SelectionDAG &DAG) const
{
  switch (Op.getOpcode())
  {
    case ISD::BRCOND:             return LowerBRCOND(Op, DAG);
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
#if 1
SDValue Cpu0TargetLowering::
LowerBRCOND(SDValue Op, SelectionDAG &DAG) const
{
#if 0	// Without FP support
  // The first operand is the chain, the second is the condition, the third is
  // the block to branch to if the condition is true.
  SDValue Chain = Op.getOperand(0);
  SDValue Dest = Op.getOperand(2);
  DebugLoc dl = Op.getDebugLoc();

  SDValue CondRes = CreateFPCmp(DAG, Op.getOperand(1));

  // Return if flag is not set by a floating point comparison.
  if (CondRes.getOpcode() != Cpu0ISD::FPCmp)
    return Op;

  SDValue CCNode  = CondRes.getOperand(2);
  Cpu0::CondCode CC =
    (Cpu0::CondCode)cast<ConstantSDNode>(CCNode)->getZExtValue();
  SDValue BrCode = DAG.getConstant(GetFPBranchCodeFromCond(CC), MVT::i32);

  return DAG.getNode(Cpu0ISD::FPBrcond, dl, Op.getValueType(), Chain, BrCode,
                     Dest, CondRes);
#else
  return Op;
#endif
}
#endif

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

#include "Cpu0GenCallingConv.inc"

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
#if 0                                          
  return Chain;
#else

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
/*
  if (IsO32)
    CCInfo.AnalyzeFormalArguments(Ins, CC_MipsO32);
  else*/
    CCInfo.AnalyzeFormalArguments(Ins, CC_Cpu0);

  Function::const_arg_iterator FuncArg =
    DAG.getMachineFunction().getFunction()->arg_begin();
  int LastFI = 0;// MipsFI->LastInArgFI is 0 at the entry of this function.
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

/*
    // Arguments stored on registers
    if (IsRegLoc) {
      EVT RegVT = VA.getLocVT();
      unsigned ArgReg = VA.getLocReg();
      const TargetRegisterClass *RC;

      if (RegVT == MVT::i32)
        RC = Mips::CPURegsRegisterClass;
      else if (RegVT == MVT::i64)
        RC = Mips::CPU64RegsRegisterClass;
      else if (RegVT == MVT::f32)
        RC = Mips::FGR32RegisterClass;
      else if (RegVT == MVT::f64)
        RC = HasMips64 ? Mips::FGR64RegisterClass : Mips::AFGR64RegisterClass;
      else
        llvm_unreachable("RegVT not supported by FormalArguments Lowering");

      // Transform the arguments stored on
      // physical registers into virtual ones
      unsigned Reg = AddLiveIn(DAG.getMachineFunction(), ArgReg, RC);
      SDValue ArgValue = DAG.getCopyFromReg(Chain, dl, Reg, RegVT);

      // If this is an 8 or 16-bit value, it has been passed promoted
      // to 32 bits.  Insert an assert[sz]ext to capture this, then
      // truncate to the right size.
      if (VA.getLocInfo() != CCValAssign::Full) {
        unsigned Opcode = 0;
        if (VA.getLocInfo() == CCValAssign::SExt)
          Opcode = ISD::AssertSext;
        else if (VA.getLocInfo() == CCValAssign::ZExt)
          Opcode = ISD::AssertZext;
        if (Opcode)
          ArgValue = DAG.getNode(Opcode, dl, RegVT, ArgValue,
                                 DAG.getValueType(ValVT));
        ArgValue = DAG.getNode(ISD::TRUNCATE, dl, ValVT, ArgValue);
      }

      // Handle floating point arguments passed in integer registers.
      if ((RegVT == MVT::i32 && ValVT == MVT::f32) ||
          (RegVT == MVT::i64 && ValVT == MVT::f64))
        ArgValue = DAG.getNode(ISD::BITCAST, dl, ValVT, ArgValue);
      else if (IsO32 && RegVT == MVT::i32 && ValVT == MVT::f64) {
        unsigned Reg2 = AddLiveIn(DAG.getMachineFunction(),
                                  getNextIntArgReg(ArgReg), RC);
        SDValue ArgValue2 = DAG.getCopyFromReg(Chain, dl, Reg2, RegVT);
        if (!Subtarget->isLittle())
          std::swap(ArgValue, ArgValue2);
        ArgValue = DAG.getNode(MipsISD::BuildPairF64, dl, MVT::f64,
                               ArgValue, ArgValue2);
      }

      InVals.push_back(ArgValue);
    } else */{ // VA.isRegLoc()

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
  }
/*  // The mips ABIs for returning structs by value requires that we copy
  // the sret argument into $v0 for the return. Save the argument into
  // a virtual register so that we can access it from the return points.
  if (DAG.getMachineFunction().getFunction()->hasStructRetAttr()) {
    unsigned Reg = MipsFI->getSRetReturnReg();
    if (!Reg) {
      Reg = MF.getRegInfo().createVirtualRegister(getRegClassFor(MVT::i32));
      MipsFI->setSRetReturnReg(Reg);
    }
    SDValue Copy = DAG.getCopyToReg(DAG.getEntryNode(), dl, Reg, InVals[0]);
    Chain = DAG.getNode(ISD::TokenFactor, dl, MVT::Other, Copy, Chain);
  }

  if (isVarArg) {
    unsigned NumOfRegs = IsO32 ? 4 : 8;
    const uint16_t *ArgRegs = IsO32 ? O32IntRegs : Mips64IntRegs;
    unsigned Idx = CCInfo.getFirstUnallocated(ArgRegs, NumOfRegs);
    int FirstRegSlotOffset = IsO32 ? 0 : -64 ; // offset of $a0's slot.
    const TargetRegisterClass *RC
      = IsO32 ? Mips::CPURegsRegisterClass : Mips::CPU64RegsRegisterClass;
    unsigned RegSize = RC->getSize();
    int RegSlotOffset = FirstRegSlotOffset + Idx * RegSize;

    // Offset of the first variable argument from stack pointer.
    int FirstVaArgOffset;

    if (IsO32 || (Idx == NumOfRegs)) {
      FirstVaArgOffset =
        (CCInfo.getNextStackOffset() + RegSize - 1) / RegSize * RegSize;
    } else
      FirstVaArgOffset = RegSlotOffset;

    // Record the frame index of the first variable argument
    // which is a value necessary to VASTART.
    LastFI = MFI->CreateFixedObject(RegSize, FirstVaArgOffset, true);
    MipsFI->setVarArgsFrameIndex(LastFI);

    // Copy the integer registers that have not been used for argument passing
    // to the argument register save area. For O32, the save area is allocated
    // in the caller's stack frame, while for N32/64, it is allocated in the
    // callee's stack frame.
    for (int StackOffset = RegSlotOffset;
         Idx < NumOfRegs; ++Idx, StackOffset += RegSize) {
      unsigned Reg = AddLiveIn(DAG.getMachineFunction(), ArgRegs[Idx], RC);
      SDValue ArgValue = DAG.getCopyFromReg(Chain, dl, Reg,
                                            MVT::getIntegerVT(RegSize * 8));
      LastFI = MFI->CreateFixedObject(RegSize, StackOffset, true);
      SDValue PtrOff = DAG.getFrameIndex(LastFI, getPointerTy());
      OutChains.push_back(DAG.getStore(Chain, dl, ArgValue, PtrOff,
                                       MachinePointerInfo(), false, false, 0));
    }
  }
*/
  Cpu0FI->setLastInArgFI(LastFI);

  // All stores are grouped in one node to allow the matching between
  // the size of Ins and InVals. This only happens when on varg functions
  if (!OutChains.empty()) {
    OutChains.push_back(Chain);
    Chain = DAG.getNode(ISD::TokenFactor, dl, MVT::Other,
                        &OutChains[0], OutChains.size());
  }

  return Chain;
#endif
}

//===----------------------------------------------------------------------===//
//               Return Value Calling Convention Implementation
//===----------------------------------------------------------------------===//

SDValue
Cpu0TargetLowering::LowerReturn(SDValue Chain,
                                CallingConv::ID CallConv, bool isVarArg,
                                const SmallVectorImpl<ISD::OutputArg> &Outs,
                                const SmallVectorImpl<SDValue> &OutVals,
                                DebugLoc dl, SelectionDAG &DAG) const {

#if 0
    return DAG.getNode(Cpu0ISD::Ret, dl, MVT::Other,
                       Chain, DAG.getRegister(Cpu0::LR, MVT::i32));
#else

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

  // The Cpu0 ABIs for returning structs by value requires that we copy
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

  // Return on Cpu0 is always a "jr $lr"
  if (Flag.getNode())
    return DAG.getNode(Cpu0ISD::Ret, dl, MVT::Other,
                       Chain, DAG.getRegister(Cpu0::LR, MVT::i32), Flag);
  else // Return Void
    return DAG.getNode(Cpu0ISD::Ret, dl, MVT::Other,
                       Chain, DAG.getRegister(Cpu0::LR, MVT::i32));
#endif                       
}

bool
Cpu0TargetLowering::isOffsetFoldingLegal(const GlobalAddressSDNode *GA) const {
  // The Mips target isn't yet aware of offsets.
  return false;
}

