//===- Cpu0Disassembler.cpp - Disassembler for Cpu0 -------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file is part of the Cpu0 Disassembler.
//
//===----------------------------------------------------------------------===//
#if 1
#include "Cpu0.h"
#include "Cpu0Subtarget.h"
#include "llvm/MC/EDInstInfo.h"
#include "llvm/MC/MCDisassembler.h"
#include "llvm/Support/MemoryObject.h"
#include "llvm/Support/TargetRegistry.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/Support/MathExtras.h"


#include "Cpu0GenEDInfo.inc"

using namespace llvm;

typedef MCDisassembler::DecodeStatus DecodeStatus;

/// Cpu0Disassembler - a disasembler class for Cpu032.
class Cpu0Disassembler : public MCDisassembler {
public:
  /// Constructor     - Initializes the disassembler.
  ///
  Cpu0Disassembler(const MCSubtargetInfo &STI, bool bigEndian) :
    MCDisassembler(STI), isBigEndian(bigEndian) {
  }

  ~Cpu0Disassembler() {
  }

  /// getInstruction - See MCDisassembler.
  DecodeStatus getInstruction(MCInst &instr,
                              uint64_t &size,
                              const MemoryObject &region,
                              uint64_t address,
                              raw_ostream &vStream,
                              raw_ostream &cStream) const;

  /// getEDInfo - See MCDisassembler.
  const EDInstInfo *getEDInfo() const;

private:
  bool isBigEndian;
};

#if 0
/// Cpu064Disassembler - a disasembler class for Cpu064.
class Cpu064Disassembler : public MCDisassembler {
public:
  /// Constructor     - Initializes the disassembler.
  ///
  Cpu064Disassembler(const MCSubtargetInfo &STI, bool bigEndian) :
    MCDisassembler(STI), isBigEndian(bigEndian) {
  }

  ~Cpu064Disassembler() {
  }

  /// getInstruction - See MCDisassembler.
  DecodeStatus getInstruction(MCInst &instr,
                              uint64_t &size,
                              const MemoryObject &region,
                              uint64_t address,
                              raw_ostream &vStream,
                              raw_ostream &cStream) const;

  /// getEDInfo - See MCDisassembler.
  const EDInstInfo *getEDInfo() const;

private:
  bool isBigEndian;
};
#endif
const EDInstInfo *Cpu0Disassembler::getEDInfo() const {
  return instInfoCpu0;
}
#if 0
const EDInstInfo *Cpu064Disassembler::getEDInfo() const {
  return instInfoCpu0;
}
#endif

// Decoder tables for Cpu0 register
static const unsigned CPURegsTable[] = {
  Cpu0::ZERO, Cpu0::AT, Cpu0::V0, Cpu0::V1,
  Cpu0::A0, Cpu0::A1, Cpu0::T9, Cpu0::S0,
  Cpu0::S1, Cpu0::S2, Cpu0::GP, Cpu0::FP,
  Cpu0::SW, Cpu0::SP, Cpu0::LR, Cpu0::PC
};
#if 0
static const unsigned CPURegsTable[] = {
  Cpu0::ZERO, Cpu0::AT, Cpu0::V0, Cpu0::V1,
  Cpu0::A0, Cpu0::A1, Cpu0::A2, Cpu0::A3,
  Cpu0::T0, Cpu0::T1, Cpu0::T2, Cpu0::T3,
  Cpu0::T4, Cpu0::T5, Cpu0::T6, Cpu0::T7,
  Cpu0::S0, Cpu0::S1, Cpu0::S2, Cpu0::S3,
  Cpu0::S4, Cpu0::S5, Cpu0::S6, Cpu0::S7,
  Cpu0::T8, Cpu0::T9, Cpu0::K0, Cpu0::K1,
  Cpu0::GP, Cpu0::SP, Cpu0::FP, Cpu0::RA
};
#endif
#if 0 // Integer reg only
static const unsigned FGR32RegsTable[] = {
  Cpu0::F0, Cpu0::F1, Cpu0::F2, Cpu0::F3,
  Cpu0::F4, Cpu0::F5, Cpu0::F6, Cpu0::F7,
  Cpu0::F8, Cpu0::F9, Cpu0::F10, Cpu0::F11,
  Cpu0::F12, Cpu0::F13, Cpu0::F14, Cpu0::F15,
  Cpu0::F16, Cpu0::F17, Cpu0::F18, Cpu0::F18,
  Cpu0::F20, Cpu0::F21, Cpu0::F22, Cpu0::F23,
  Cpu0::F24, Cpu0::F25, Cpu0::F26, Cpu0::F27,
  Cpu0::F28, Cpu0::F29, Cpu0::F30, Cpu0::F31
};
#endif
#if 0 // Cpu0InstrFPU.td: FGR64
static const unsigned CPU64RegsTable[] = {
  Cpu0::ZERO_64, Cpu0::AT_64, Cpu0::V0_64, Cpu0::V1_64,
  Cpu0::A0_64, Cpu0::A1_64, Cpu0::A2_64, Cpu0::A3_64,
  Cpu0::T0_64, Cpu0::T1_64, Cpu0::T2_64, Cpu0::T3_64,
  Cpu0::T4_64, Cpu0::T5_64, Cpu0::T6_64, Cpu0::T7_64,
  Cpu0::S0_64, Cpu0::S1_64, Cpu0::S2_64, Cpu0::S3_64,
  Cpu0::S4_64, Cpu0::S5_64, Cpu0::S6_64, Cpu0::S7_64,
  Cpu0::T8_64, Cpu0::T9_64, Cpu0::K0_64, Cpu0::K1_64,
  Cpu0::GP_64, Cpu0::SP_64, Cpu0::FP_64, Cpu0::RA_64
};

static const unsigned FGR64RegsTable[] = {
  Cpu0::D0_64,  Cpu0::D1_64,  Cpu0::D2_64,  Cpu0::D3_64,
  Cpu0::D4_64,  Cpu0::D5_64,  Cpu0::D6_64,  Cpu0::D7_64,
  Cpu0::D8_64,  Cpu0::D9_64,  Cpu0::D10_64, Cpu0::D11_64,
  Cpu0::D12_64, Cpu0::D13_64, Cpu0::D14_64, Cpu0::D15_64,
  Cpu0::D16_64, Cpu0::D17_64, Cpu0::D18_64, Cpu0::D19_64,
  Cpu0::D20_64, Cpu0::D21_64, Cpu0::D22_64, Cpu0::D23_64,
  Cpu0::D24_64, Cpu0::D25_64, Cpu0::D26_64, Cpu0::D27_64,
  Cpu0::D28_64, Cpu0::D29_64, Cpu0::D30_64, Cpu0::D31_64
};

static const unsigned AFGR64RegsTable[] = {
  Cpu0::D0,  Cpu0::D1,  Cpu0::D2,  Cpu0::D3,
  Cpu0::D4,  Cpu0::D5,  Cpu0::D6,  Cpu0::D7,
  Cpu0::D8,  Cpu0::D9,  Cpu0::D10, Cpu0::D11,
  Cpu0::D12, Cpu0::D13, Cpu0::D14, Cpu0::D15
};
#endif
#if 0
// Forward declare these because the autogenerated code will reference them.
// Definitions are further down.
static DecodeStatus DecodeCPU64RegsRegisterClass(MCInst &Inst,
                                                 unsigned RegNo,
                                                 uint64_t Address,
                                                 const void *Decoder);
#endif
static DecodeStatus DecodeCPURegsRegisterClass(MCInst &Inst,
                                               unsigned RegNo,
                                               uint64_t Address,
                                               const void *Decoder);
#if 0 // Cpu0InstrFPU.td: FGR64
static DecodeStatus DecodeFGR64RegisterClass(MCInst &Inst,
                                             unsigned RegNo,
                                             uint64_t Address,
                                             const void *Decoder);
#endif
#if 0 // Integer reg only
static DecodeStatus DecodeFGR32RegisterClass(MCInst &Inst,
                                             unsigned RegNo,
                                             uint64_t Address,
                                             const void *Decoder);
#endif
#if 0	// Cpu0InstrFPU.td: CCR
static DecodeStatus DecodeCCRRegisterClass(MCInst &Inst,
                                           unsigned RegNo,
                                           uint64_t Address,
                                           const void *Decoder);
#endif
#if 0
static DecodeStatus DecodeHWRegsRegisterClass(MCInst &Inst,
                                              unsigned Insn,
                                              uint64_t Address,
                                              const void *Decoder);
#endif
#if 0 // Cpu0InstrFPU.td: FGR64
static DecodeStatus DecodeAFGR64RegisterClass(MCInst &Inst,
                                              unsigned RegNo,
                                              uint64_t Address,
                                              const void *Decoder);
#endif
#if 0
static DecodeStatus DecodeHWRegs64RegisterClass(MCInst &Inst,
                                                unsigned Insn,
                                                uint64_t Address,
                                                const void *Decoder);
#endif
static DecodeStatus DecodeBranchTarget(MCInst &Inst,
                                       unsigned Offset,
                                       uint64_t Address,
                                       const void *Decoder);
#if 0
static DecodeStatus DecodeBC1(MCInst &Inst,
                              unsigned Insn,
                              uint64_t Address,
                              const void *Decoder);
#endif

static DecodeStatus DecodeJumpTarget(MCInst &Inst,
                                     unsigned Insn,
                                     uint64_t Address,
                                     const void *Decoder);

static DecodeStatus DecodeMem(MCInst &Inst,
                              unsigned Insn,
                              uint64_t Address,
                              const void *Decoder);
#if 0  // Cpu0InstrFPU.td: "DecodeFMem"
static DecodeStatus DecodeFMem(MCInst &Inst, unsigned Insn,
                               uint64_t Address,
                               const void *Decoder);
#endif
static DecodeStatus DecodeSimm16(MCInst &Inst,
                                 unsigned Insn,
                                 uint64_t Address,
                                 const void *Decoder);
#if 0
static DecodeStatus DecodeCondCode(MCInst &Inst,
                                   unsigned Insn,
                                   uint64_t Address,
                                   const void *Decoder);

static DecodeStatus DecodeInsSize(MCInst &Inst,
                                  unsigned Insn,
                                  uint64_t Address,
                                  const void *Decoder);

static DecodeStatus DecodeExtSize(MCInst &Inst,
                                  unsigned Insn,
                                  uint64_t Address,
                                  const void *Decoder);
#endif
namespace llvm {
extern Target TheCpu0elTarget, TheCpu0Target, TheCpu064Target,
              TheCpu064elTarget;
}

static MCDisassembler *createCpu0Disassembler(
                       const Target &T,
                       const MCSubtargetInfo &STI) {
  return new Cpu0Disassembler(STI,true);
}

static MCDisassembler *createCpu0elDisassembler(
                       const Target &T,
                       const MCSubtargetInfo &STI) {
  return new Cpu0Disassembler(STI,false);
}
#if 0
static MCDisassembler *createCpu064Disassembler(
                       const Target &T,
                       const MCSubtargetInfo &STI) {
  return new Cpu064Disassembler(STI,true);
}

static MCDisassembler *createCpu064elDisassembler(
                       const Target &T,
                       const MCSubtargetInfo &STI) {
  return new Cpu064Disassembler(STI, false);
}
#endif
extern "C" void LLVMInitializeCpu0Disassembler() {
  // Register the disassembler.
  TargetRegistry::RegisterMCDisassembler(TheCpu0Target,
                                         createCpu0Disassembler);
  TargetRegistry::RegisterMCDisassembler(TheCpu0elTarget,
                                         createCpu0elDisassembler);
#if 0
  TargetRegistry::RegisterMCDisassembler(TheCpu064Target,
                                         createCpu064Disassembler);
  TargetRegistry::RegisterMCDisassembler(TheCpu064elTarget,
                                         createCpu064elDisassembler);
#endif
}


#include "Cpu0GenDisassemblerTables.inc"

  /// readInstruction - read four bytes from the MemoryObject
  /// and return 32 bit word sorted according to the given endianess
static DecodeStatus readInstruction32(const MemoryObject &region,
                                      uint64_t address,
                                      uint64_t &size,
                                      uint32_t &insn,
                                      bool isBigEndian) {
  uint8_t Bytes[4];

  // We want to read exactly 4 Bytes of data.
  if (region.readBytes(address, 4, (uint8_t*)Bytes, NULL) == -1) {
    size = 0;
    return MCDisassembler::Fail;
  }

  if (isBigEndian) {
    // Encoded as a big-endian 32-bit word in the stream.
    insn = (Bytes[3] <<  0) |
           (Bytes[2] <<  8) |
           (Bytes[1] << 16) |
           (Bytes[0] << 24);
  }
  else {
    // Encoded as a small-endian 32-bit word in the stream.
    insn = (Bytes[0] <<  0) |
           (Bytes[1] <<  8) |
           (Bytes[2] << 16) |
           (Bytes[3] << 24);
  }

  return MCDisassembler::Success;
}

DecodeStatus
Cpu0Disassembler::getInstruction(MCInst &instr,
                                 uint64_t &Size,
                                 const MemoryObject &Region,
                                 uint64_t Address,
                                 raw_ostream &vStream,
                                 raw_ostream &cStream) const {
  uint32_t Insn;

  DecodeStatus Result = readInstruction32(Region, Address, Size,
                                          Insn, isBigEndian);
  if (Result == MCDisassembler::Fail)
    return MCDisassembler::Fail;

  // Calling the auto-generated decoder function.
  Result = decodeCpu0Instruction32(instr, Insn, Address, this, STI);
  if (Result != MCDisassembler::Fail) {
    Size = 4;
    return Result;
  }

  return MCDisassembler::Fail;
}
#if 0
DecodeStatus
Cpu064Disassembler::getInstruction(MCInst &instr,
                                   uint64_t &Size,
                                   const MemoryObject &Region,
                                   uint64_t Address,
                                   raw_ostream &vStream,
                                   raw_ostream &cStream) const {
  uint32_t Insn;

  DecodeStatus Result = readInstruction32(Region, Address, Size,
                                          Insn, isBigEndian);
  if (Result == MCDisassembler::Fail)
    return MCDisassembler::Fail;

  // Calling the auto-generated decoder function.
  Result = decodeCpu064Instruction32(instr, Insn, Address, this, STI);
  if (Result != MCDisassembler::Fail) {
    Size = 4;
    return Result;
  }
  // If we fail to decode in Cpu064 decoder space we can try in Cpu032
  Result = decodeCpu0Instruction32(instr, Insn, Address, this, STI);
  if (Result != MCDisassembler::Fail) {
    Size = 4;
    return Result;
  }

  return MCDisassembler::Fail;
}
#endif
#if 0	// support double type
static DecodeStatus DecodeCPU64RegsRegisterClass(MCInst &Inst,
                                                 unsigned RegNo,
                                                 uint64_t Address,
                                                 const void *Decoder) {

  if (RegNo > 31)
    return MCDisassembler::Fail;

  Inst.addOperand(MCOperand::CreateReg(CPU64RegsTable[RegNo]));
  return MCDisassembler::Success;
}
#endif
static DecodeStatus DecodeCPURegsRegisterClass(MCInst &Inst,
                                               unsigned RegNo,
                                               uint64_t Address,
                                               const void *Decoder) {
  if (RegNo > 31)
    return MCDisassembler::Fail;

  Inst.addOperand(MCOperand::CreateReg(CPURegsTable[RegNo]));
  return MCDisassembler::Success;
}
#if 0 // Cpu0InstrFPU.td: FGR64
static DecodeStatus DecodeFGR64RegisterClass(MCInst &Inst,
                                             unsigned RegNo,
                                             uint64_t Address,
                                             const void *Decoder) {
  if (RegNo > 31)
    return MCDisassembler::Fail;

  Inst.addOperand(MCOperand::CreateReg(FGR64RegsTable[RegNo]));
  return MCDisassembler::Success;
}
#endif
#if 0 // Integer reg only
static DecodeStatus DecodeFGR32RegisterClass(MCInst &Inst,
                                             unsigned RegNo,
                                             uint64_t Address,
                                             const void *Decoder) {
  if (RegNo > 31)
    return MCDisassembler::Fail;

  Inst.addOperand(MCOperand::CreateReg(FGR32RegsTable[RegNo]));
  return MCDisassembler::Success;
}
#endif
#if 0
static DecodeStatus DecodeCCRRegisterClass(MCInst &Inst,
                                           unsigned RegNo,
                                           uint64_t Address,
                                           const void *Decoder) {
  Inst.addOperand(MCOperand::CreateReg(RegNo));
  return MCDisassembler::Success;
}
#endif
static DecodeStatus DecodeMem(MCInst &Inst,
                              unsigned Insn,
                              uint64_t Address,
                              const void *Decoder) {
  int Offset = SignExtend32<16>(Insn & 0xffff);
  int Reg = (int)fieldFromInstruction32(Insn, 16, 5);
  int Base = (int)fieldFromInstruction32(Insn, 21, 5);

#if 0	// without SC command support
  if(Inst.getOpcode() == Cpu0::SC){
    Inst.addOperand(MCOperand::CreateReg(CPURegsTable[Reg]));
  }
#endif
  Inst.addOperand(MCOperand::CreateReg(CPURegsTable[Reg]));
  Inst.addOperand(MCOperand::CreateReg(CPURegsTable[Base]));
  Inst.addOperand(MCOperand::CreateImm(Offset));

  return MCDisassembler::Success;
}

#if 0   // Cpu0InstrFPU.td: "DecodeFMem"
static DecodeStatus DecodeFMem(MCInst &Inst,
                               unsigned Insn,
                               uint64_t Address,
                               const void *Decoder) {
  int Offset = SignExtend32<16>(Insn & 0xffff);
  int Reg = (int)fieldFromInstruction32(Insn, 16, 5);
  int Base = (int)fieldFromInstruction32(Insn, 21, 5);
  Inst.addOperand(MCOperand::CreateReg(FGR64RegsTable[Reg]));
  Inst.addOperand(MCOperand::CreateReg(CPURegsTable[Base]));
  Inst.addOperand(MCOperand::CreateImm(Offset));

  return MCDisassembler::Success;
}
#endif

#if 0
static DecodeStatus DecodeHWRegsRegisterClass(MCInst &Inst,
                                              unsigned RegNo,
                                              uint64_t Address,
                                              const void *Decoder) {
  // Currently only hardware register 29 is supported.
  if (RegNo != 29)
    return  MCDisassembler::Fail;
  Inst.addOperand(MCOperand::CreateReg(Cpu0::HWR29));
  return MCDisassembler::Success;
}

static DecodeStatus DecodeCondCode(MCInst &Inst,
                                   unsigned Insn,
                                   uint64_t Address,
                                   const void *Decoder) {
  int CondCode = Insn & 0xf;
  Inst.addOperand(MCOperand::CreateImm(CondCode));
  return MCDisassembler::Success;
}
#endif
#if 0 // Cpu0InstrFPU.td: FGR64
static DecodeStatus DecodeAFGR64RegisterClass(MCInst &Inst,
                                              unsigned RegNo,
                                              uint64_t Address,
                                              const void *Decoder) {
  if (RegNo > 31)
    return MCDisassembler::Fail;

  Inst.addOperand(MCOperand::CreateReg(AFGR64RegsTable[RegNo]));
  return MCDisassembler::Success;
}
#endif
#if 0
static DecodeStatus DecodeHWRegs64RegisterClass(MCInst &Inst,
                                                unsigned RegNo,
                                                uint64_t Address,
                                                const void *Decoder) {
  //Currently only hardware register 29 is supported
  if (RegNo != 29)
    return  MCDisassembler::Fail;
  Inst.addOperand(MCOperand::CreateReg(Cpu0::HWR29));
  return MCDisassembler::Success;
}
#endif
static DecodeStatus DecodeBranchTarget(MCInst &Inst,
                                       unsigned Offset,
                                       uint64_t Address,
                                       const void *Decoder) {
  unsigned BranchOffset = Offset & 0xffff;
  BranchOffset = SignExtend32<18>(BranchOffset << 2) + 4;
  Inst.addOperand(MCOperand::CreateImm(BranchOffset));
  return MCDisassembler::Success;
}
#if 0
static DecodeStatus DecodeBC1(MCInst &Inst,
                              unsigned Insn,
                              uint64_t Address,
                              const void *Decoder) {
  unsigned BranchOffset = Insn & 0xffff;
  BranchOffset = SignExtend32<18>(BranchOffset << 2) + 4;
  Inst.addOperand(MCOperand::CreateImm(BranchOffset));
  return MCDisassembler::Success;
}
#endif
static DecodeStatus DecodeJumpTarget(MCInst &Inst,
                                     unsigned Insn,
                                     uint64_t Address,
                                     const void *Decoder) {

  unsigned JumpOffset = fieldFromInstruction32(Insn, 0, 26) << 2;
  Inst.addOperand(MCOperand::CreateImm(JumpOffset));
  return MCDisassembler::Success;
}


static DecodeStatus DecodeSimm16(MCInst &Inst,
                                 unsigned Insn,
                                 uint64_t Address,
                                 const void *Decoder) {
  Inst.addOperand(MCOperand::CreateImm(SignExtend32<16>(Insn)));
  return MCDisassembler::Success;
}

#if 0
static DecodeStatus DecodeInsSize(MCInst &Inst,
                                  unsigned Insn,
                                  uint64_t Address,
                                  const void *Decoder) {
  // First we need to grab the pos(lsb) from MCInst.
  int Pos = Inst.getOperand(2).getImm();
  int Size = (int) Insn - Pos + 1;
  Inst.addOperand(MCOperand::CreateImm(SignExtend32<16>(Size)));
  return MCDisassembler::Success;
}

static DecodeStatus DecodeExtSize(MCInst &Inst,
                                  unsigned Insn,
                                  uint64_t Address,
                                  const void *Decoder) {
  int Size = (int) Insn  + 1;
  Inst.addOperand(MCOperand::CreateImm(SignExtend32<16>(Size)));
  return MCDisassembler::Success;
}
#endif
#endif
