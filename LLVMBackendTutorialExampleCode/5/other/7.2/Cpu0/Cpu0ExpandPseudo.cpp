//===--  Cpu0ExpandPseudo.cpp - Expand Pseudo Instructions ----------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This pass expands pseudo instructions into target instructions after register
// allocation but before post-RA scheduling.
//
//===----------------------------------------------------------------------===//

#define DEBUG_TYPE "cpu0-expand-pseudo"

#include "Cpu0.h"
#include "Cpu0TargetMachine.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/Target/TargetInstrInfo.h"
#include "llvm/ADT/Statistic.h"

using namespace llvm;

namespace {
  struct Cpu0ExpandPseudo : public MachineFunctionPass {

    TargetMachine &TM;
    const TargetInstrInfo *TII;

    static char ID;
    Cpu0ExpandPseudo(TargetMachine &tm)
      : MachineFunctionPass(ID), TM(tm), TII(tm.getInstrInfo()) { }

    virtual const char *getPassName() const {
      return "Cpu0 PseudoInstrs Expansion";
    }

    bool runOnMachineFunction(MachineFunction &F);
    bool runOnMachineBasicBlock(MachineBasicBlock &MBB);

  private:
    void ExpandBuildPairF64(MachineBasicBlock&, MachineBasicBlock::iterator);
    void ExpandExtractElementF64(MachineBasicBlock&,
                                 MachineBasicBlock::iterator);
  };
  char Cpu0ExpandPseudo::ID = 0;
} // end of anonymous namespace

bool Cpu0ExpandPseudo::runOnMachineFunction(MachineFunction& F) {
  bool Changed = false;

  for (MachineFunction::iterator I = F.begin(); I != F.end(); ++I)
    Changed |= runOnMachineBasicBlock(*I);

  return Changed;
}

bool Cpu0ExpandPseudo::runOnMachineBasicBlock(MachineBasicBlock& MBB) {

  bool Changed = false;
  for (MachineBasicBlock::iterator I = MBB.begin(); I != MBB.end();) {
    const MCInstrDesc& MCid = I->getDesc();

    switch(MCid.getOpcode()) {
    default:
      ++I;
      continue;
    case Cpu0::SETGP2:
      // Convert "setgp2 $globalreg, $t9" to "addu $globalreg, $v0, $t9"
      BuildMI(MBB, I, I->getDebugLoc(), TII->get(Cpu0::ADD),
              I->getOperand(0).getReg())
        .addReg(Cpu0::V0).addReg(I->getOperand(1).getReg());
      break;
    }

    // delete original instr
    MBB.erase(I++);
    Changed = true;
  }

  return Changed;
}

/// createCpu0Cpu0ExpandPseudoPass - Returns a pass that expands pseudo
/// instrs into real instrs
FunctionPass *llvm::createCpu0ExpandPseudoPass(Cpu0TargetMachine &tm) {
  return new Cpu0ExpandPseudo(tm);
}
