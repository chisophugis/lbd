//===-- SIInstrInfo.h - SI Instruction Info Interface ---------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
/// \file
/// \brief Interface definition for SIInstrInfo.
//
//===----------------------------------------------------------------------===//


#ifndef SIINSTRINFO_H
#define SIINSTRINFO_H

#include "AMDGPUInstrInfo.h"
#include "SIRegisterInfo.h"

namespace llvm {

class SIInstrInfo : public AMDGPUInstrInfo {
private:
  const SIRegisterInfo RI;

public:
  explicit SIInstrInfo(AMDGPUTargetMachine &tm);

  const SIRegisterInfo &getRegisterInfo() const;

  virtual void copyPhysReg(MachineBasicBlock &MBB,
                           MachineBasicBlock::iterator MI, DebugLoc DL,
                           unsigned DestReg, unsigned SrcReg,
                           bool KillSrc) const;

  virtual MachineInstr * getMovImmInstr(MachineFunction *MF, unsigned DstReg,
                                        int64_t Imm) const;

  virtual unsigned getIEQOpcode() const { assert(!"Implement"); return 0;}
  virtual bool isMov(unsigned Opcode) const;

  virtual bool isSafeToMoveRegClassDefs(const TargetRegisterClass *RC) const;

  virtual int getIndirectIndexBegin(const MachineFunction &MF) const;

  virtual int getIndirectIndexEnd(const MachineFunction &MF) const;

  virtual unsigned calculateIndirectAddress(unsigned RegIndex,
                                            unsigned Channel) const;

  virtual const TargetRegisterClass *getIndirectAddrStoreRegClass(
                                                      unsigned SourceReg) const;

  virtual const TargetRegisterClass *getIndirectAddrLoadRegClass() const;

  virtual MachineInstrBuilder buildIndirectWrite(MachineBasicBlock *MBB,
                                                 MachineBasicBlock::iterator I,
                                                 unsigned ValueReg,
                                                 unsigned Address,
                                                 unsigned OffsetReg) const;

  virtual MachineInstrBuilder buildIndirectRead(MachineBasicBlock *MBB,
                                                MachineBasicBlock::iterator I,
                                                unsigned ValueReg,
                                                unsigned Address,
                                                unsigned OffsetReg) const;

  virtual const TargetRegisterClass *getSuperIndirectRegClass() const;
  };

} // End namespace llvm

namespace SIInstrFlags {
  enum Flags {
    // First 4 bits are the instruction encoding
    VM_CNT = 1 << 0,
    EXP_CNT = 1 << 1,
    LGKM_CNT = 1 << 2
  };
}

#endif //SIINSTRINFO_H
