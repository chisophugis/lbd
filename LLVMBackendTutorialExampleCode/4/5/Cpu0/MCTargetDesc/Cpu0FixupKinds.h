//===-- Cpu0FixupKinds.h - Cpu0 Specific Fixup Entries ----------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_CPU0_CPU0FIXUPKINDS_H
#define LLVM_CPU0_CPU0FIXUPKINDS_H

#include "llvm/MC/MCFixup.h"

namespace llvm {
namespace Cpu0 {
  // Although most of the current fixup types reflect a unique relocation
  // one can have multiple fixup types for a given relocation and thus need
  // to be uniquely named.
  //
  // This table *must* be in the save order of
  // MCFixupKindInfo Infos[Cpu0::NumTargetFixupKinds]
  // in Cpu0AsmBackend.cpp.
  //
  enum Fixups {
    // Branch fixups resulting in R_CPU0_16.
    fixup_Cpu0_16 = FirstTargetFixupKind,

    // Marker
    LastTargetFixupKind,
    NumTargetFixupKinds = LastTargetFixupKind - FirstTargetFixupKind
  };
} // namespace Cpu0
} // namespace llvm


#endif // LLVM_CPU0_CPU0FIXUPKINDS_H

