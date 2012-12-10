//===-- Cpu0MachineFunctionInfo.cpp - Private data used for Cpu0 ----------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "Cpu0MachineFunction.h"
#include "Cpu0InstrInfo.h"
#include "Cpu0Subtarget.h"
#include "MCTargetDesc/Cpu0BaseInfo.h"
#include "llvm/Function.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/Support/CommandLine.h"

using namespace llvm;

static cl::opt<bool>
FixGlobalBaseReg("cpu0-fix-global-base-reg", cl::Hidden, cl::init(true),
                 cl::desc("Always use $gp as the global base register."));

bool Cpu0FunctionInfo::globalBaseRegFixed() const {
  return FixGlobalBaseReg;
}

bool Cpu0FunctionInfo::globalBaseRegSet() const {
  return GlobalBaseReg;
}

unsigned Cpu0FunctionInfo::getGlobalBaseReg() {
  // Return if it has already been initialized.
  if (GlobalBaseReg)
    return GlobalBaseReg;

  if (FixGlobalBaseReg) // $gp is the global base register.
    return GlobalBaseReg = Cpu0::GP;

  const TargetRegisterClass *RC;
  RC = Cpu0::CPURegsRegisterClass;

  return GlobalBaseReg = MF.getRegInfo().createVirtualRegister(RC);
}

void Cpu0FunctionInfo::anchor() { }
