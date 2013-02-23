//===-- Cpu0Subtarget.h - Define Subtarget for the Cpu0 ---------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file declares the Cpu0 specific subclass of TargetSubtargetInfo.
//
//===----------------------------------------------------------------------===//

#ifndef CPU0SUBTARGET_H
#define CPU0SUBTARGET_H

#include "llvm/Target/TargetSubtargetInfo.h"
#include "llvm/MC/MCInstrItineraries.h"
#include <string>

namespace llvm {
class StringRef;

//class Cpu0Subtarget : public Cpu0GenSubtargetInfo {
class Cpu0Subtarget {
  virtual void anchor();

public:
  // NOTE: O64 will not be supported.
  enum Cpu0ABIEnum {
    UnknownABI, O32
  };

protected:
  enum Cpu0ArchEnum {
    Cpu032
  };

  // Cpu0 architecture version
  Cpu0ArchEnum Cpu0ArchVersion;

  // Cpu0 supported ABIs
  Cpu0ABIEnum Cpu0ABI;

  // IsLittle - The target is Little Endian
  bool IsLittle;

  InstrItineraryData InstrItins;

public:
  unsigned getTargetABI() const { return Cpu0ABI; }

  /// This constructor initializes the data members to match that
  /// of the specified triple.
  Cpu0Subtarget(const std::string &TT, const std::string &CPU,
                const std::string &FS, bool little);

  bool isLittle() const { return IsLittle; }
};
} // End llvm namespace

#endif
