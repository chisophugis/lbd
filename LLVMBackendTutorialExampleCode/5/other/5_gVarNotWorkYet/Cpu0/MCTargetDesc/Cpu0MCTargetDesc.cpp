//===-- Cpu0MCTargetDesc.cpp - Cpu0 Target Descriptions -------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file provides Cpu0 specific target descriptions.
//
//===----------------------------------------------------------------------===//

#include "Cpu0MCAsmInfo.h"
#include "Cpu0MCTargetDesc.h"
#include "InstPrinter/Cpu0InstPrinter.h"
#include "llvm/MC/MachineLocation.h"
#include "llvm/MC/MCCodeGenInfo.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/TargetRegistry.h"

#define GET_INSTRINFO_MC_DESC
#include "Cpu0GenInstrInfo.inc"

#define GET_SUBTARGETINFO_MC_DESC
#include "Cpu0GenSubtargetInfo.inc"

#define GET_REGINFO_MC_DESC
#include "Cpu0GenRegisterInfo.inc"

using namespace llvm;

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
