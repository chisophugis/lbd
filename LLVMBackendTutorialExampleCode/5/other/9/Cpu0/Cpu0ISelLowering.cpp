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
//#include "llvm/CodeGen/TargetLoweringObjectFileImpl.h"
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
#if 0
  case Cpu0ISD::Hi:                return "Cpu0ISD::Hi";
  case Cpu0ISD::Lo:                return "Cpu0ISD::Lo";
#endif
  case Cpu0ISD::GPRel:             return "Cpu0ISD::GPRel";
#if 0
  case Cpu0ISD::ThreadPointer:     return "Cpu0ISD::ThreadPointer";
#endif
  case Cpu0ISD::Ret:               return "Cpu0ISD::Ret";
#if 0
  case Cpu0ISD::FPBrcond:          return "Cpu0ISD::FPBrcond";
  case Cpu0ISD::FPCmp:             return "Cpu0ISD::FPCmp";
  case Cpu0ISD::CMovFP_T:          return "Cpu0ISD::CMovFP_T";
  case Cpu0ISD::CMovFP_F:          return "Cpu0ISD::CMovFP_F";
  case Cpu0ISD::FPRound:           return "Cpu0ISD::FPRound";
  case Cpu0ISD::MAdd:              return "Cpu0ISD::MAdd";
  case Cpu0ISD::MAddu:             return "Cpu0ISD::MAddu";
  case Cpu0ISD::MSub:              return "Cpu0ISD::MSub";
  case Cpu0ISD::MSubu:             return "Cpu0ISD::MSubu";
  case Cpu0ISD::DivRem:            return "Cpu0ISD::DivRem";
  case Cpu0ISD::DivRemU:           return "Cpu0ISD::DivRemU";
  case Cpu0ISD::BuildPairF64:      return "Cpu0ISD::BuildPairF64";
  case Cpu0ISD::ExtractElementF64: return "Cpu0ISD::ExtractElementF64";
  case Cpu0ISD::Wrapper:           return "Cpu0ISD::Wrapper";
  case Cpu0ISD::DynAlloc:          return "Cpu0ISD::DynAlloc";
  case Cpu0ISD::Sync:              return "Cpu0ISD::Sync";
  case Cpu0ISD::Ext:               return "Cpu0ISD::Ext";
  case Cpu0ISD::Ins:               return "Cpu0ISD::Ins";
#endif
  default:                         return NULL;
  }
}


Cpu0TargetLowering::
Cpu0TargetLowering(Cpu0TargetMachine &TM)
  : TargetLowering(TM, new Cpu0TargetObjectFile()),
    Subtarget(&TM.getSubtarget<Cpu0Subtarget>()) {

  // Set up the register classes
  addRegisterClass(MVT::i32, Cpu0::CPURegsRegisterClass);

  // Load extented operations for i1 types must be promoted
  setLoadExtAction(ISD::EXTLOAD,  MVT::i1,  Promote);
  setLoadExtAction(ISD::ZEXTLOAD, MVT::i1,  Promote);
  setLoadExtAction(ISD::SEXTLOAD, MVT::i1,  Promote);

  // Used by legalize types to correctly generate the setcc result.
  // Without this, every float setcc comes with a AND/OR with the result,
  // we don't want this, since the fpcmp result goes to a flag register,
  // which is used implicitly by brcond and select operations.
  AddPromotedToType(ISD::SETCC, MVT::i1, MVT::i32);

  // Cpu0 Custom Operations
  setOperationAction(ISD::GlobalAddress,      MVT::i32,   Custom);

  setOperationAction(ISD::BlockAddress,       MVT::i32,   Custom);
  setOperationAction(ISD::GlobalTLSAddress,   MVT::i32,   Custom);
  setOperationAction(ISD::JumpTable,          MVT::i32,   Custom);
  setOperationAction(ISD::ConstantPool,       MVT::i32,   Custom);
  setOperationAction(ISD::SELECT,             MVT::i32,   Custom);
  setOperationAction(ISD::BRCOND,             MVT::Other, Custom);

  // Operations not directly supported by Cpu0.
  setOperationAction(ISD::BR_JT,             MVT::Other, Expand);
  setOperationAction(ISD::BR_CC,             MVT::Other, Expand);
  setOperationAction(ISD::SELECT_CC,         MVT::Other, Expand);

//- Set .align 2
// It will emit .align 2 later
  setMinFunctionAlignment(2);

// must, computeRegisterProperties - Once all of the register classes are added, this allows us to compute derived properties we expose
  computeRegisterProperties();
}

bool Cpu0TargetLowering::allowsUnalignedMemoryAccesses(EVT VT) const {
  MVT::SimpleValueType SVT = VT.getSimpleVT().SimpleTy;

  switch (SVT) {
  case MVT::i64:
  case MVT::i32:
  case MVT::i16:
    return true;
  default:
    return false;
  }
}

EVT Cpu0TargetLowering::getSetCCResultType(EVT VT) const {
  return MVT::i32;
}

SDValue  Cpu0TargetLowering::PerformDAGCombine(SDNode *N, DAGCombinerInfo &DCI)
  const {
  SelectionDAG &DAG = DCI.DAG;
  unsigned opc = N->getOpcode();

  switch (opc) {
  default: break;
  }

  return SDValue();
}

SDValue Cpu0TargetLowering::
LowerOperation(SDValue Op, SelectionDAG &DAG) const
{
  switch (Op.getOpcode())
  {
#if 1
    case ISD::BRCOND:             return LowerBRCOND(Op, DAG);
#endif
    case ISD::ConstantPool:       return LowerConstantPool(Op, DAG);
    case ISD::DYNAMIC_STACKALLOC: return LowerDYNAMIC_STACKALLOC(Op, DAG);
    case ISD::GlobalAddress:      return LowerGlobalAddress(Op, DAG);
    case ISD::BlockAddress:       return LowerBlockAddress(Op, DAG);
    case ISD::GlobalTLSAddress:   return LowerGlobalTLSAddress(Op, DAG);
    case ISD::JumpTable:          return LowerJumpTable(Op, DAG);
    case ISD::SELECT:             return LowerSELECT(Op, DAG);
    case ISD::VASTART:            return LowerVASTART(Op, DAG);
    case ISD::FRAMEADDR:          return LowerFRAMEADDR(Op, DAG);
    case ISD::MEMBARRIER:         return LowerMEMBARRIER(Op, DAG);
  }
  return SDValue();
}

//===----------------------------------------------------------------------===//
//  Lower helper functions
//===----------------------------------------------------------------------===//

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

//===----------------------------------------------------------------------===//
//  Misc Lower Operation implementation
//===----------------------------------------------------------------------===//
SDValue Cpu0TargetLowering::
LowerDYNAMIC_STACKALLOC(SDValue Op, SelectionDAG &DAG) const
{
  MachineFunction &MF = DAG.getMachineFunction();
  Cpu0FunctionInfo *Cpu0FI = MF.getInfo<Cpu0FunctionInfo>();
  unsigned SP = Cpu0::SP;

  assert(getTargetMachine().getFrameLowering()->getStackAlignment() >=
         cast<ConstantSDNode>(Op.getOperand(2).getNode())->getZExtValue() &&
         "Cannot lower if the alignment of the allocated space is larger than \
          that of the stack.");

  SDValue Chain = Op.getOperand(0);
  SDValue Size = Op.getOperand(1);
  DebugLoc dl = Op.getDebugLoc();

  // Get a reference from Cpu0 stack pointer
  SDValue StackPointer = DAG.getCopyFromReg(Chain, dl, SP, getPointerTy());

  // Subtract the dynamic size from the actual stack size to
  // obtain the new stack size.
  SDValue Sub = DAG.getNode(ISD::SUB, dl, getPointerTy(), StackPointer, Size);

  // The Sub result contains the new stack start address, so it
  // must be placed in the stack pointer register.
  Chain = DAG.getCopyToReg(StackPointer.getValue(1), dl, SP, Sub, SDValue());

  // This node always has two return values: a new stack pointer
  // value and a chain
  SDVTList VTLs = DAG.getVTList(getPointerTy(), MVT::Other);
  SDValue Ptr = DAG.getFrameIndex(Cpu0FI->getDynAllocFI(), getPointerTy());
  SDValue Ops[] = { Chain, Ptr, Chain.getValue(1) };

  return DAG.getNode(Cpu0ISD::DynAlloc, dl, VTLs, Ops, 3);
}
#if 1
SDValue Cpu0TargetLowering::
LowerBRCOND(SDValue Op, SelectionDAG &DAG) const
{
  return Op;
}
#endif

SDValue Cpu0TargetLowering::
LowerSELECT(SDValue Op, SelectionDAG &DAG) const
{
  return Op;
}

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
    SDValue GAHi = DAG.getTargetGlobalAddress(GV, dl, MVT::i32, 0,
                                              Cpu0II::MO_ABS);
	return GAHi;
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
                                                        Cpu0II::MO_ABS);
  SDValue Lo = DAG.getNode(Cpu0ISD::Lo, dl, ValTy, GALo);
  return DAG.getNode(ISD::ADD, dl, ValTy, ResNode, Lo);
}

SDValue Cpu0TargetLowering::LowerBlockAddress(SDValue Op,
                                              SelectionDAG &DAG) const {
  const BlockAddress *BA = cast<BlockAddressSDNode>(Op)->getBlockAddress();
  // FIXME there isn't actually debug info here
  DebugLoc dl = Op.getDebugLoc();

  if (getTargetMachine().getRelocationModel() != Reloc::PIC_) {
    return DAG.getBlockAddress(BA, MVT::i32, true, Cpu0II::MO_ABS);
  }

  EVT ValTy = Op.getValueType();
  unsigned GOTFlag = Cpu0II::MO_GOT;
  unsigned OFSTFlag = Cpu0II::MO_ABS;
  SDValue BAGOTOffset = DAG.getBlockAddress(BA, ValTy, true, GOTFlag);
  BAGOTOffset = DAG.getNode(Cpu0ISD::Wrapper, dl, ValTy,
                            GetGlobalReg(DAG, ValTy), BAGOTOffset);
  SDValue BALOOffset = DAG.getBlockAddress(BA, ValTy, true, OFSTFlag);
  SDValue Load = DAG.getLoad(ValTy, dl, DAG.getEntryNode(), BAGOTOffset,
                             MachinePointerInfo(), false, false, false, 0);
  SDValue Lo = DAG.getNode(Cpu0ISD::Lo, dl, ValTy, BALOOffset);
  return DAG.getNode(ISD::ADD, dl, ValTy, Load, Lo);
}

SDValue Cpu0TargetLowering::
LowerGlobalTLSAddress(SDValue Op, SelectionDAG &DAG) const
{
  // If the relocation model is PIC, use the General Dynamic TLS Model or
  // Local Dynamic TLS model, otherwise use the Initial Exec or
  // Local Exec TLS Model.

  GlobalAddressSDNode *GA = cast<GlobalAddressSDNode>(Op);
  DebugLoc dl = GA->getDebugLoc();
  const GlobalValue *GV = GA->getGlobal();
  EVT PtrVT = getPointerTy();

  if (getTargetMachine().getRelocationModel() == Reloc::PIC_) {
    // General Dynamic TLS Model
    bool LocalDynamic = GV->hasInternalLinkage();
    unsigned Flag = LocalDynamic ? Cpu0II::MO_TLSLDM :Cpu0II::MO_TLSGD;
    SDValue TGA = DAG.getTargetGlobalAddress(GV, dl, PtrVT, 0, Flag);
    SDValue Argument = DAG.getNode(Cpu0ISD::Wrapper, dl, PtrVT,
                                   GetGlobalReg(DAG, PtrVT), TGA);
    unsigned PtrSize = PtrVT.getSizeInBits();
    IntegerType *PtrTy = Type::getIntNTy(*DAG.getContext(), PtrSize);

    SDValue TlsGetAddr = DAG.getExternalSymbol("__tls_get_addr", PtrVT);

    ArgListTy Args;
    ArgListEntry Entry;
    Entry.Node = Argument;
    Entry.Ty = PtrTy;
    Args.push_back(Entry);

    std::pair<SDValue, SDValue> CallResult =
      LowerCallTo(DAG.getEntryNode(), PtrTy,
                  false, false, false, false, 0, CallingConv::C,
                  /*isTailCall=*/false, /*doesNotRet=*/false,
                  /*isReturnValueUsed=*/true,
                  TlsGetAddr, Args, DAG, dl);

    SDValue Ret = CallResult.first;

    if (!LocalDynamic)
      return Ret;

    SDValue TGAHi = DAG.getTargetGlobalAddress(GV, dl, PtrVT, 0,
                                               Cpu0II::MO_DTPREL_HI);
    SDValue Hi = DAG.getNode(Cpu0ISD::Hi, dl, PtrVT, TGAHi);
    SDValue TGALo = DAG.getTargetGlobalAddress(GV, dl, PtrVT, 0,
                                               Cpu0II::MO_DTPREL_LO);
    SDValue Lo = DAG.getNode(Cpu0ISD::Lo, dl, PtrVT, TGALo);
    SDValue Add = DAG.getNode(ISD::ADD, dl, PtrVT, Hi, Ret);
    return DAG.getNode(ISD::ADD, dl, PtrVT, Add, Lo);
  }

  SDValue Offset;
  if (GV->isDeclaration()) {
    // Initial Exec TLS Model
    SDValue TGA = DAG.getTargetGlobalAddress(GV, dl, PtrVT, 0,
                                             Cpu0II::MO_GOTTPREL);
    TGA = DAG.getNode(Cpu0ISD::Wrapper, dl, PtrVT, GetGlobalReg(DAG, PtrVT),
                      TGA);
    Offset = DAG.getLoad(PtrVT, dl,
                         DAG.getEntryNode(), TGA, MachinePointerInfo(),
                         false, false, false, 0);
  } else {
    // Local Exec TLS Model
    SDValue TGAHi = DAG.getTargetGlobalAddress(GV, dl, PtrVT, 0,
                                               Cpu0II::MO_TPREL_HI);
    SDValue TGALo = DAG.getTargetGlobalAddress(GV, dl, PtrVT, 0,
                                               Cpu0II::MO_TPREL_LO);
    SDValue Hi = DAG.getNode(Cpu0ISD::Hi, dl, PtrVT, TGAHi);
    SDValue Lo = DAG.getNode(Cpu0ISD::Lo, dl, PtrVT, TGALo);
    Offset = DAG.getNode(ISD::ADD, dl, PtrVT, Hi, Lo);
  }

  SDValue ThreadPointer = DAG.getNode(Cpu0ISD::ThreadPointer, dl, PtrVT);
  return DAG.getNode(ISD::ADD, dl, PtrVT, ThreadPointer, Offset);
}

SDValue Cpu0TargetLowering::
LowerJumpTable(SDValue Op, SelectionDAG &DAG) const
{
  SDValue HiPart, JTI, JTILo;
  // FIXME there isn't actually debug info here
  DebugLoc dl = Op.getDebugLoc();
  bool IsPIC = getTargetMachine().getRelocationModel() == Reloc::PIC_;
  EVT PtrVT = Op.getValueType();
  JumpTableSDNode *JT = cast<JumpTableSDNode>(Op);

  if (!IsPIC) {
    JTI = DAG.getTargetJumpTable(JT->getIndex(), PtrVT, Cpu0II::MO_ABS);
    HiPart = DAG.getNode(Cpu0ISD::Hi, dl, PtrVT, JTI);
    JTILo = DAG.getTargetJumpTable(JT->getIndex(), PtrVT, Cpu0II::MO_ABS);
  } else {// Emit Load from Global Pointer
    unsigned GOTFlag = Cpu0II::MO_GOT;
    unsigned OfstFlag = Cpu0II::MO_ABS;
    JTI = DAG.getTargetJumpTable(JT->getIndex(), PtrVT, GOTFlag);
    JTI = DAG.getNode(Cpu0ISD::Wrapper, dl, PtrVT, GetGlobalReg(DAG, PtrVT),
                      JTI);
    HiPart = DAG.getLoad(PtrVT, dl, DAG.getEntryNode(), JTI,
                         MachinePointerInfo(), false, false, false, 0);
    JTILo = DAG.getTargetJumpTable(JT->getIndex(), PtrVT, OfstFlag);
  }

  SDValue Lo = DAG.getNode(Cpu0ISD::Lo, dl, PtrVT, JTILo);
  return DAG.getNode(ISD::ADD, dl, PtrVT, HiPart, Lo);
}

SDValue Cpu0TargetLowering::
LowerConstantPool(SDValue Op, SelectionDAG &DAG) const
{
  SDValue ResNode;
  ConstantPoolSDNode *N = cast<ConstantPoolSDNode>(Op);
  const Constant *C = N->getConstVal();
  // FIXME there isn't actually debug info here
  DebugLoc dl = Op.getDebugLoc();

  // gp_rel relocation
  // FIXME: we should reference the constant pool using small data sections,
  // but the asm printer currently doesn't support this feature without
  // hacking it. This feature should come soon so we can uncomment the
  // stuff below.
  //if (IsInSmallSection(C->getType())) {
  //  SDValue GPRelNode = DAG.getNode(Cpu0ISD::GPRel, MVT::i32, CP);
  //  SDValue GOT = DAG.getGLOBAL_OFFSET_TABLE(MVT::i32);
  //  ResNode = DAG.getNode(ISD::ADD, MVT::i32, GOT, GPRelNode);

  if (getTargetMachine().getRelocationModel() != Reloc::PIC_) {
    SDValue CPHi = DAG.getTargetConstantPool(C, MVT::i32, N->getAlignment(),
                                             N->getOffset(), Cpu0II::MO_ABS);
    SDValue ResNode = DAG.getNode(Cpu0ISD::Hi, dl, MVT::i32, CPHi);
  } else {
    EVT ValTy = Op.getValueType();
    unsigned GOTFlag = Cpu0II::MO_GOT;
    unsigned OFSTFlag = Cpu0II::MO_ABS;
    SDValue CP = DAG.getTargetConstantPool(C, ValTy, N->getAlignment(),
                                           N->getOffset(), GOTFlag);
    CP = DAG.getNode(Cpu0ISD::Wrapper, dl, ValTy, GetGlobalReg(DAG, ValTy), CP);
    SDValue Load = DAG.getLoad(ValTy, dl, DAG.getEntryNode(), CP,
                               MachinePointerInfo::getConstantPool(), false,
                               false, false, 0);
    SDValue CPLo = DAG.getTargetConstantPool(C, ValTy, N->getAlignment(),
                                             N->getOffset(), OFSTFlag);
    SDValue Lo = DAG.getNode(Cpu0ISD::Lo, dl, ValTy, CPLo);
    ResNode = DAG.getNode(ISD::ADD, dl, ValTy, Load, Lo);
  }

  return ResNode;
}

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

SDValue Cpu0TargetLowering::
LowerFRAMEADDR(SDValue Op, SelectionDAG &DAG) const {
  // check the depth
  assert((cast<ConstantSDNode>(Op.getOperand(0))->getZExtValue() == 0) &&
         "Frame address can only be determined for current frame.");

  MachineFrameInfo *MFI = DAG.getMachineFunction().getFrameInfo();
  MFI->setFrameAddressIsTaken(true);
  EVT VT = Op.getValueType();
  DebugLoc dl = Op.getDebugLoc();
  SDValue FrameAddr = DAG.getCopyFromReg(DAG.getEntryNode(), dl,
                                         Cpu0::FP, VT);
  return FrameAddr;
}

// TODO: set SType according to the desired memory barrier behavior.
SDValue
Cpu0TargetLowering::LowerMEMBARRIER(SDValue Op, SelectionDAG& DAG) const {
  unsigned SType = 0;
  DebugLoc dl = Op.getDebugLoc();
  return DAG.getNode(Cpu0ISD::Sync, dl, MVT::Other, Op.getOperand(0),
                     DAG.getConstant(SType, MVT::i32));
}

#include "Cpu0GenCallingConv.inc"

/// LowerCall - functions arguments are copied from virtual regs to
/// (physical regs)/(stack frame), CALLSEQ_START and CALLSEQ_END are emitted.
/// TODO: isTailCall.
SDValue
Cpu0TargetLowering::LowerCall(SDValue InChain, SDValue Callee,
                              CallingConv::ID CallConv, bool isVarArg,
                              bool doesNotRet, bool &isTailCall,
                              const SmallVectorImpl<ISD::OutputArg> &Outs,
                              const SmallVectorImpl<SDValue> &OutVals,
                              const SmallVectorImpl<ISD::InputArg> &Ins,
                              DebugLoc dl, SelectionDAG &DAG,
                              SmallVectorImpl<SDValue> &InVals) const {
  // MIPs target does not yet support tail call optimization.
  isTailCall = false;

  MachineFunction &MF = DAG.getMachineFunction();
  MachineFrameInfo *MFI = MF.getFrameInfo();
  const TargetFrameLowering *TFL = MF.getTarget().getFrameLowering();
  bool IsPIC = getTargetMachine().getRelocationModel() == Reloc::PIC_;
  Cpu0FunctionInfo *Cpu0FI = MF.getInfo<Cpu0FunctionInfo>();

  // Analyze operands of the call, assigning locations to each operand.
  SmallVector<CCValAssign, 16> ArgLocs;
  CCState CCInfo(CallConv, isVarArg, DAG.getMachineFunction(),
                 getTargetMachine(), ArgLocs, *DAG.getContext());

#if 0
  if (IsO32)
    CCInfo.AnalyzeCallOperands(Outs, CC_Cpu0O32);
#if 0
  else if (HasCpu064)
    AnalyzeCpu064CallOperands(CCInfo, Outs);
#endif
  else
#endif
    CCInfo.AnalyzeCallOperands(Outs, CC_Cpu0);

  // Get a count of how many bytes are to be pushed on the stack.
  unsigned NextStackOffset = CCInfo.getNextStackOffset();

  // Chain is the output chain of the last Load/Store or CopyToReg node.
  // ByValChain is the output chain of the last Memcpy node created for copying
  // byval arguments to the stack.
  SDValue Chain, CallSeqStart, ByValChain;
  SDValue NextStackOffsetVal = DAG.getIntPtrConstant(NextStackOffset, true);
  Chain = CallSeqStart = DAG.getCALLSEQ_START(InChain, NextStackOffsetVal);
  ByValChain = InChain;
#if 0
  // If this is the first call, create a stack frame object that points to
  // a location to which .cprestore saves $gp.
  if (IsO32 && IsPIC && Cpu0FI->globalBaseRegFixed() && !Cpu0FI->getGPFI())
    Cpu0FI->setGPFI(MFI->CreateFixedObject(4, 0, true));
#endif
  // Get the frame index of the stack frame object that points to the location
  // of dynamically allocated area on the stack.
  int DynAllocFI = Cpu0FI->getDynAllocFI();
#if 0
  // Update size of the maximum argument space.
  // For O32, a minimum of four words (16 bytes) of argument space is
  // allocated.
  if (IsO32)
    NextStackOffset = std::max(NextStackOffset, (unsigned)16);
#endif
  unsigned MaxCallFrameSize = Cpu0FI->getMaxCallFrameSize();

  if (MaxCallFrameSize < NextStackOffset) {
    Cpu0FI->setMaxCallFrameSize(NextStackOffset);

    // Set the offsets relative to $sp of the $gp restore slot and dynamically
    // allocated stack space. These offsets must be aligned to a boundary
    // determined by the stack alignment of the ABI.
    unsigned StackAlignment = TFL->getStackAlignment();
    NextStackOffset = (NextStackOffset + StackAlignment - 1) /
                      StackAlignment * StackAlignment;

    if (Cpu0FI->needGPSaveRestore())
      MFI->setObjectOffset(Cpu0FI->getGPFI(), NextStackOffset);

    MFI->setObjectOffset(DynAllocFI, NextStackOffset);
  }

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
      assert(Flags.getByValSize() &&
             "ByVal args of size 0 should have been ignored by front-end.");
#if 0
      if (IsO32)
        WriteByValArg(ByValChain, Chain, dl, RegsToPass, MemOpChains, LastFI,
                      MFI, DAG, Arg, VA, Flags, getPointerTy(),
                      Subtarget->isLittle());
#endif
#if 0
      else
        PassByValArg64(ByValChain, Chain, dl, RegsToPass, MemOpChains, LastFI,
                       MFI, DAG, Arg, VA, Flags, getPointerTy(),
                       Subtarget->isLittle());
#endif
      continue;
    }

    // Promote the value if needed.
    switch (VA.getLocInfo()) {
    default: llvm_unreachable("Unknown loc info!");
    case CCValAssign::Full:
      if (VA.isRegLoc()) {
        if ((ValVT == MVT::f32 && LocVT == MVT::i32) ||
            (ValVT == MVT::f64 && LocVT == MVT::i64))
          Arg = DAG.getNode(ISD::BITCAST, dl, LocVT, Arg);
        else if (ValVT == MVT::f64 && LocVT == MVT::i32) {
          SDValue Lo = DAG.getNode(Cpu0ISD::ExtractElementF64, dl, MVT::i32,
                                   Arg, DAG.getConstant(0, MVT::i32));
          SDValue Hi = DAG.getNode(Cpu0ISD::ExtractElementF64, dl, MVT::i32,
                                   Arg, DAG.getConstant(1, MVT::i32));
          if (!Subtarget->isLittle())
            std::swap(Lo, Hi);
          unsigned LocRegLo = VA.getLocReg();
          unsigned LocRegHigh = getNextIntArgReg(LocRegLo);
          RegsToPass.push_back(std::make_pair(LocRegLo, Lo));
          RegsToPass.push_back(std::make_pair(LocRegHigh, Hi));
          continue;
        }
      }
      break;
    case CCValAssign::SExt:
      Arg = DAG.getNode(ISD::SIGN_EXTEND, dl, LocVT, Arg);
      break;
    case CCValAssign::ZExt:
      Arg = DAG.getNode(ISD::ZERO_EXTEND, dl, LocVT, Arg);
      break;
    case CCValAssign::AExt:
      Arg = DAG.getNode(ISD::ANY_EXTEND, dl, LocVT, Arg);
      break;
    }

    // Arguments that can be passed on register must be kept at
    // RegsToPass vector
    if (VA.isRegLoc()) {
      RegsToPass.push_back(std::make_pair(VA.getLocReg(), Arg));
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
#if 0 // cpu0 int 32 only
  bool IsPICCall = (IsN64 || IsPIC); // true if calls are translated to jalr $25
#else
  bool IsPICCall = IsPIC; // true if calls are translated to jalr $25
#endif
  bool GlobalOrExternal = false;
  SDValue CalleeLo;

  if (GlobalAddressSDNode *G = dyn_cast<GlobalAddressSDNode>(Callee)) {
    if (IsPICCall && G->getGlobal()->hasInternalLinkage()) {
      OpFlag = IsO32 ? Cpu0II::MO_GOT : Cpu0II::MO_GOT_PAGE;
      unsigned char LoFlag = IsO32 ? Cpu0II::MO_ABS_LO : Cpu0II::MO_GOT_OFST;
      Callee = DAG.getTargetGlobalAddress(G->getGlobal(), dl, getPointerTy(), 0,
                                          OpFlag);
      CalleeLo = DAG.getTargetGlobalAddress(G->getGlobal(), dl, getPointerTy(),
                                            0, LoFlag);
    } else {
      OpFlag = IsPICCall ? Cpu0II::MO_GOT_CALL : Cpu0II::MO_NO_FLAG;
      Callee = DAG.getTargetGlobalAddress(G->getGlobal(), dl,
                                          getPointerTy(), 0, OpFlag);
    }

    GlobalOrExternal = true;
  }
  else if (ExternalSymbolSDNode *S = dyn_cast<ExternalSymbolSDNode>(Callee)) {
#if 0 // cpu0 int 32 only
    if (IsN64 || (!IsO32 && IsPIC))
      OpFlag = Cpu0II::MO_GOT_DISP;
    else if (!IsPIC) // !N64 && static
      OpFlag = Cpu0II::MO_NO_FLAG;
    else // O32 & PIC
      OpFlag = Cpu0II::MO_GOT_CALL;
#else
    if (!IsPIC) // static
      OpFlag = Cpu0II::MO_NO_FLAG;
    else // O32 & PIC
      OpFlag = Cpu0II::MO_GOT_CALL;
#endif
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
#if 0 // cpu0 int 32 only
    unsigned T9Reg = IsN64 ? Cpu0::T9_64 : Cpu0::T9;
#else
    unsigned T9Reg = Cpu0::T9;
#endif
    Chain = DAG.getCopyToReg(Chain, dl, T9Reg, Callee, SDValue(0, 0));
    InFlag = Chain.getValue(1);
    Callee = DAG.getRegister(T9Reg, getPointerTy());
  }

  // Build a sequence of copy-to-reg nodes chained together with token
  // chain and flag operands which copy the outgoing args into registers.
  // The InFlag in necessary since all emitted instructions must be
  // stuck together.
  for (unsigned i = 0, e = RegsToPass.size(); i != e; ++i) {
    Chain = DAG.getCopyToReg(Chain, dl, RegsToPass[i].first,
                             RegsToPass[i].second, InFlag);
    InFlag = Chain.getValue(1);
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
  return Chain;
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

    return DAG.getNode(Cpu0ISD::Ret, dl, MVT::Other,
                       Chain, DAG.getRegister(Cpu0::LR, MVT::i32));
}

