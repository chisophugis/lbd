//===-- Cpu0InstrInfo.h - Cpu0 Instruction Information ----------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains the Cpu0 implementation of the TargetInstrInfo class.
//
//===----------------------------------------------------------------------===//

#ifndef CPU0INSTRUCTIONINFO_H
#define CPU0INSTRUCTIONINFO_H

#include "Cpu0.h"
#include "Cpu0RegisterInfo.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Target/TargetInstrInfo.h"

#define GET_INSTRINFO_HEADER
#include "Cpu0GenInstrInfo.inc"

namespace llvm {

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

  virtual void copyPhysReg(MachineBasicBlock &MBB,
                           MachineBasicBlock::iterator MI, DebugLoc DL,
                           unsigned DestReg, unsigned SrcReg,
                           bool KillSrc) const;

public:
  virtual MachineInstr* emitFrameIndexDebugValue(MachineFunction &MF,
                                                 int FrameIx, uint64_t Offset,
                                                 const MDNode *MDPtr,
                                                 DebugLoc DL) const;
};
}

#endif
