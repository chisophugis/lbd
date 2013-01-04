//===-- Cpu0MCTargetDesc.h - Cpu0 Target Descriptions -----------*- C++ -*-===//
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

#ifndef CPU0MCTARGETDESC_H
#define CPU0MCTARGETDESC_H

#include "llvm/Support/DataTypes.h"

namespace llvm {
class MCAsmBackend;
class MCCodeEmitter;
class MCContext;
class MCInstrInfo;
class MCObjectWriter;
class MCSubtargetInfo;
class StringRef;
class Target;
class raw_ostream;

extern Target TheCpu0Target;
extern Target TheCpu0elTarget;

MCAsmBackend *createCpu0AsmBackendEB32(const Target &T, StringRef TT);
MCAsmBackend *createCpu0AsmBackendEL32(const Target &T, StringRef TT);
} // End llvm namespace

// Defines symbolic names for Cpu0 registers.  This defines a mapping from
// register name to register number.
#define GET_REGINFO_ENUM
#include "Cpu0GenRegisterInfo.inc"

// Defines symbolic names for the Cpu0 instructions.
#define GET_INSTRINFO_ENUM
#include "Cpu0GenInstrInfo.inc"

#define GET_SUBTARGETINFO_ENUM
#include "Cpu0GenSubtargetInfo.inc"
#endif


