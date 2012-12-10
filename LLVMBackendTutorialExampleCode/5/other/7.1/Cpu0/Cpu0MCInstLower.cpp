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
  case Cpu0II::MO_GPREL:     Kind = MCSymbolRefExpr::VK_Cpu0_GPREL; break;
  case Cpu0II::MO_GOT_CALL:  Kind = MCSymbolRefExpr::VK_Cpu0_GOT_CALL; break;

  case Cpu0II::MO_GOT16:     Kind = MCSymbolRefExpr::VK_Cpu0_GOT16; break;
  case Cpu0II::MO_GOT:       Kind = MCSymbolRefExpr::VK_Cpu0_GOT; break;
  case Cpu0II::MO_ABS:       Kind = MCSymbolRefExpr::VK_Cpu0_ABS; break;

  case Cpu0II::MO_TLSGD:     Kind = MCSymbolRefExpr::VK_Cpu0_TLSGD; break;
  case Cpu0II::MO_TLSLDM:    Kind = MCSymbolRefExpr::VK_Cpu0_TLSLDM; break;
  case Cpu0II::MO_DTPREL_HI: Kind = MCSymbolRefExpr::VK_Cpu0_DTPREL_HI; break;
  case Cpu0II::MO_DTPREL_LO: Kind = MCSymbolRefExpr::VK_Cpu0_DTPREL_LO; break;
  case Cpu0II::MO_GOTTPREL:  Kind = MCSymbolRefExpr::VK_Cpu0_GOTTPREL; break;
  case Cpu0II::MO_TPREL_HI:  Kind = MCSymbolRefExpr::VK_Cpu0_TPREL_HI; break;
  case Cpu0II::MO_TPREL_LO:  Kind = MCSymbolRefExpr::VK_Cpu0_TPREL_LO; break;
  case Cpu0II::MO_GPOFF_HI:  Kind = MCSymbolRefExpr::VK_Cpu0_GPOFF_HI; break;
  case Cpu0II::MO_GPOFF_LO:  Kind = MCSymbolRefExpr::VK_Cpu0_GPOFF_LO; break;
  case Cpu0II::MO_GOT_DISP:  Kind = MCSymbolRefExpr::VK_Cpu0_GOT_DISP; break;
  case Cpu0II::MO_GOT_PAGE:  Kind = MCSymbolRefExpr::VK_Cpu0_GOT_PAGE; break;
  case Cpu0II::MO_GOT_OFST:  Kind = MCSymbolRefExpr::VK_Cpu0_GOT_OFST; break;
  }

  switch (MOTy) {
  case MachineOperand::MO_MachineBasicBlock:
    Symbol = MO.getMBB()->getSymbol();
    break;

  case MachineOperand::MO_GlobalAddress:
    Symbol = Mang->getSymbol(MO.getGlobal());
    break;

  case MachineOperand::MO_BlockAddress:
    Symbol = AsmPrinter.GetBlockAddressSymbol(MO.getBlockAddress());
    break;

  case MachineOperand::MO_ExternalSymbol:
    Symbol = AsmPrinter.GetExternalSymbolSymbol(MO.getSymbolName());
    break;

  case MachineOperand::MO_JumpTableIndex:
    Symbol = AsmPrinter.GetJTISymbol(MO.getIndex());
    break;

  case MachineOperand::MO_ConstantPoolIndex:
    Symbol = AsmPrinter.GetCPISymbol(MO.getIndex());
    if (MO.getOffset())
      Offset += MO.getOffset();
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
  case MachineOperand::MO_GlobalAddress:
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

