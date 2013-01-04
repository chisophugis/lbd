//===-- Cpu0MCInstLower.cpp - Convert Cpu0 MachineInstr to MCInst ---------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains code to lower Cpu0 MachineInstrs to their corresponding
// MCInst records.
//
//===----------------------------------------------------------------------===//

#include "Cpu0MCInstLower.h"
#include "Cpu0AsmPrinter.h"
#include "Cpu0InstrInfo.h"
#include "MCTargetDesc/Cpu0BaseInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/CodeGen/MachineOperand.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCInst.h"
#include "llvm/Target/Mangler.h"

using namespace llvm;

Cpu0MCInstLower::Cpu0MCInstLower(Cpu0AsmPrinter &asmprinter)
  : AsmPrinter(asmprinter) {}

void Cpu0MCInstLower::Initialize(Mangler *M, MCContext* C) {
  Mang = M;
  Ctx = C;
}

MCOperand Cpu0MCInstLower::LowerSymbolOperand(const MachineOperand &MO,
                                              MachineOperandType MOTy,
                                              unsigned Offset) const {
  MCSymbolRefExpr::VariantKind Kind;
  const MCSymbol *Symbol;

  switch(MO.getTargetFlags()) {
  default:                   llvm_unreachable("Invalid target flag!");
  case Cpu0II::MO_NO_FLAG:   Kind = MCSymbolRefExpr::VK_None; break;
// Cpu0_GPREL is for llc -march=cpu0 -relocation-model=static -cpu0-islinux-format=false (global var in .sdata)
  case Cpu0II::MO_GPREL:     Kind = MCSymbolRefExpr::VK_Cpu0_GPREL; break;

  case Cpu0II::MO_GOT_CALL:  Kind = MCSymbolRefExpr::VK_Cpu0_GOT_CALL; break;
  case Cpu0II::MO_GOT16:     Kind = MCSymbolRefExpr::VK_Cpu0_GOT16; break;
  case Cpu0II::MO_GOT:       Kind = MCSymbolRefExpr::VK_Cpu0_GOT; break;
// ABS_HI and ABS_LO is for llc -march=cpu0 -relocation-model=static (global var in .data)
  case Cpu0II::MO_ABS_HI:    Kind = MCSymbolRefExpr::VK_Cpu0_ABS_HI; break;
  case Cpu0II::MO_ABS_LO:    Kind = MCSymbolRefExpr::VK_Cpu0_ABS_LO; break;
  }

  switch (MOTy) {
  case MachineOperand::MO_MachineBasicBlock:
    Symbol = MO.getMBB()->getSymbol();
    break;

  case MachineOperand::MO_GlobalAddress:
    Symbol = Mang->getSymbol(MO.getGlobal());
    break;

  default:
    llvm_unreachable("<unknown operand type>");
  }

  const MCSymbolRefExpr *MCSym = MCSymbolRefExpr::Create(Symbol, Kind, *Ctx);

  if (!Offset)
    return MCOperand::CreateExpr(MCSym);

  // Assume offset is never negative.
  assert(Offset > 0);

  const MCConstantExpr *OffsetExpr =  MCConstantExpr::Create(Offset, *Ctx);
  const MCBinaryExpr *AddExpr = MCBinaryExpr::CreateAdd(MCSym, OffsetExpr, *Ctx);
  return MCOperand::CreateExpr(AddExpr);
}

MCOperand Cpu0MCInstLower::LowerOperand(const MachineOperand& MO,
                                        unsigned offset) const {
  MachineOperandType MOTy = MO.getType();

  switch (MOTy) {
  default: llvm_unreachable("unknown operand type");
  case MachineOperand::MO_Register:
    // Ignore all implicit register operands.
    if (MO.isImplicit()) break;
    return MCOperand::CreateReg(MO.getReg());
  case MachineOperand::MO_Immediate:
    return MCOperand::CreateImm(MO.getImm() + offset);
  case MachineOperand::MO_MachineBasicBlock:
  case MachineOperand::MO_GlobalAddress:
  case MachineOperand::MO_BlockAddress:
    return LowerSymbolOperand(MO, MOTy, offset);
  case MachineOperand::MO_RegisterMask:
    break;
 }

  return MCOperand();
}

void Cpu0MCInstLower::Lower(const MachineInstr *MI, MCInst &OutMI) const {
  OutMI.setOpcode(MI->getOpcode());

  for (unsigned i = 0, e = MI->getNumOperands(); i != e; ++i) {
    const MachineOperand &MO = MI->getOperand(i);
    MCOperand MCOp = LowerOperand(MO);

    if (MCOp.isValid())
      OutMI.addOperand(MCOp);
  }
}

