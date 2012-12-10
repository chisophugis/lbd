//===- Cpu0InstrInfo.td - Target Description for Cpu0 Target -*- tablegen -*-=//
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

//===----------------------------------------------------------------------===//
// Instruction format superclass
//===----------------------------------------------------------------------===//

include "Cpu0InstrFormats.td"

//===----------------------------------------------------------------------===//
// Cpu0 profiles and nodes
//===----------------------------------------------------------------------===//

def SDT_Cpu0Ret          : SDTypeProfile<0, 1, [SDTCisInt<0>]>;
def SDT_Cpu0JmpLink      : SDTypeProfile<0, 1, [SDTCisVT<0, iPTR>]>;

// Call
def Cpu0JmpLink : SDNode<"Cpu0ISD::JmpLink",SDT_Cpu0JmpLink,
                         [SDNPHasChain, SDNPOutGlue, SDNPOptInGlue,
                          SDNPVariadic]>;

// Return
def Cpu0Ret : SDNode<"Cpu0ISD::Ret", SDT_Cpu0Ret, [SDNPHasChain,
                     SDNPOptInGlue]>;

def RelocPIC    :     Predicate<"TM.getRelocationModel() == Reloc::PIC_">,
                      AssemblerPredicate<"FeatureCpu032">;

//===----------------------------------------------------------------------===//
// Cpu0 Operand, Complex Patterns and Transformations Definitions.
//===----------------------------------------------------------------------===//

// Instruction operand types
def brtarget    : Operand<OtherVT> {
  let EncoderMethod = "getBranchTargetOpValue";
  let OperandType = "OPERAND_PCREL";
  let DecoderMethod = "DecodeBranchTarget";
}

def calltarget  : Operand<iPTR> {
  let EncoderMethod = "getJumpTargetOpValue";
}

def simm16      : Operand<i32> {
  let DecoderMethod= "DecodeSimm16";
}

// Address operand
def mem : Operand<i32> {
  let PrintMethod = "printMemOperand";
  let MIOperandInfo = (ops CPURegs, simm16);
  let EncoderMethod = "getMemEncoding";
}

// Node immediate fits as 16-bit sign extended on target immediate.
// e.g. addi, andi
def immSExt16  : PatLeaf<(imm), [{ return isInt<16>(N->getSExtValue()); }]>;

// Cpu0 Address Mode! SDNode frameindex could possibily be a match
// since load and store instructions from stack used it.
def addr : ComplexPattern<iPTR, 2, "SelectAddr", [frameindex], [SDNPWantParent]>;

//===----------------------------------------------------------------------===//
// Pattern fragment for load/store
//===----------------------------------------------------------------------===//


class AlignedLoad<PatFrag Node> :
  PatFrag<(ops node:$ptr), (Node node:$ptr), [{
  LoadSDNode *LD = cast<LoadSDNode>(N);
  return LD->getMemoryVT().getSizeInBits()/8 <= LD->getAlignment();
}]>;

class AlignedStore<PatFrag Node> :
  PatFrag<(ops node:$val, node:$ptr), (Node node:$val, node:$ptr), [{
  StoreSDNode *SD = cast<StoreSDNode>(N);
  return SD->getMemoryVT().getSizeInBits()/8 <= SD->getAlignment();
}]>;

// Load/Store PatFrags.
def load_a          : AlignedLoad<load>;
def store_a         : AlignedStore<store>;

//===----------------------------------------------------------------------===//
// Instructions specific format
//===----------------------------------------------------------------------===//

// Arithmetic and logical instructions with 3 register operands.
class ArithLogicR<bits<8> op, string instr_asm, SDNode OpNode,
                  InstrItinClass itin, RegisterClass RC, bit isComm = 0>:
  FA<op, (outs RC:$ra), (ins RC:$rb, RC:$rc),
     !strconcat(instr_asm, "\t$ra, $rb, $rc"),
     [(set RC:$ra, (OpNode RC:$rb, RC:$rc))], itin> {
  let isCommutable = isComm;	// e.g. add rb rc =  add rc rb
  let isReMaterializable = 1;
}

class CmpInstr<bits<8> op, string instr_asm,
                    InstrItinClass itin, RegisterClass RC, bit isComm = 0>:
  FA<op, (outs RC:$SW), (ins RC:$ra, RC:$rb),
     !strconcat(instr_asm, "\t$ra, $rb"), [], itin> {
  let isCommutable = isComm;
}

// Arithmetic and logical instructions with 2 register operands.
class ArithLogicI<bits<8> op, string instr_asm, SDNode OpNode,
                  Operand Od, PatLeaf imm_type, RegisterClass RC> :
  FL<op, (outs RC:$ra), (ins RC:$rb, Od:$imm16),
     !strconcat(instr_asm, "\t$ra, $rb, $imm16"),
     [(set RC:$ra, (OpNode RC:$rb, imm_type:$imm16))], IIAlu> {
  let isReMaterializable = 1;
}

class FMem<bits<8> op, dag outs, dag ins, string asmstr, list<dag> pattern,
          InstrItinClass itin>: FL<op, outs, ins, asmstr, pattern, itin> {
  bits<20> addr;
  let Inst{19-16} = addr{19-16};
  let Inst{15-0}  = addr{15-0};
  let DecoderMethod = "DecodeMem";
}

// Memory Load/Store
let canFoldAsLoad = 1 in
class LoadM<bits<8> op, string instr_asm, PatFrag OpNode, RegisterClass RC,
            Operand MemOpnd, bit Pseudo>:
  FMem<op, (outs RC:$ra), (ins MemOpnd:$addr),
     !strconcat(instr_asm, "\t$ra, $addr"),
     [(set RC:$ra, (OpNode addr:$addr))], IILoad> {
  let isPseudo = Pseudo;
}

class StoreM<bits<8> op, string instr_asm, PatFrag OpNode, RegisterClass RC,
             Operand MemOpnd, bit Pseudo>:
  FMem<op, (outs), (ins RC:$ra, MemOpnd:$addr),
     !strconcat(instr_asm, "\t$ra, $addr"),
     [(OpNode RC:$ra, addr:$addr)], IIStore> {
  let isPseudo = Pseudo;
}


// 32-bit load.
multiclass LoadM32<bits<8> op, string instr_asm, PatFrag OpNode,
                   bit Pseudo = 0> {
  def #NAME# : LoadM<op, instr_asm, OpNode, CPURegs, mem, Pseudo>;
}

// 32-bit store.
multiclass StoreM32<bits<8> op, string instr_asm, PatFrag OpNode,
                    bit Pseudo = 0> {
  def #NAME# : StoreM<op, instr_asm, OpNode, CPURegs, mem, Pseudo>;
}

// Conditional Branch
class CBranch<bits<8> op, string instr_asm, PatFrag cond_op, RegisterClass RC>:
  BranchBase<op, (outs), (ins RC:$rb, RC:$rc, brtarget:$imm24),
             !strconcat(instr_asm, "\t$imm24"),
             [(brcond (i32 (cond_op RC:$rb, RC:$rc)), bb:$imm24)], IIBranch> {
  let isBranch = 1;
  let isTerminator = 1;
  let hasDelaySlot = 0;
}

// Unconditional branch
class UncondBranch<bits<8> op, string instr_asm>:
//  BranchBase<op, (outs), (ins brtarget:$imm24),
//             !strconcat(instr_asm, "\t$imm24"), [(br bb:$imm24)], IIBranch> {
  BranchBase<op, (outs), (ins brtarget:$target),
             !strconcat(instr_asm, "\t$target"), [(br bb:$target)], IIBranch> {
//  let rs = 0;
//  let rt = 0;
  let isBranch = 1;
  let isTerminator = 1;
  let isBarrier = 1;
  let hasDelaySlot = 1;
  let Predicates = [RelocPIC];
}

// Jump and Link (Call)
let isCall=1, hasDelaySlot=0 in {
  class JumpLink<bits<8> op, string instr_asm>:
    FJ<op, (outs), (ins calltarget:$target, variable_ops),
       !strconcat(instr_asm, "\t$target"), [(Cpu0JmpLink imm:$target)],
       IIBranch> {
       let DecoderMethod = "DecodeJumpTarget";
       }
}

// When handling PIC code the assembler needs .cpload and .cprestore
// directives. If the real instructions corresponding these directives
// are used, we have the same behavior, but get also a bunch of warnings
// from the assembler.
let neverHasSideEffects = 1 in
def CPRESTORE : Cpu0Pseudo<(outs), (ins i32imm:$loc, CPURegs:$gp),
                           ".cprestore\t$loc", []>;

// For O32 ABI & PIC & non-fixed global base register, the following instruction
// seqeunce is emitted to set the global base register:
//
//  0. lui   $2, %hi(_gp_disp)
//  1. addiu $2, $2, %lo(_gp_disp)
//  2. addu  $globalbasereg, $2, $t9
//
// SETGP01 is emitted during Prologue/Epilogue insertion and then converted to
// instructions 0 and 1 in the sequence above during MC lowering.
// SETGP2 is emitted just before register allocation and converted to
// instruction 2 just prior to post-RA scheduling.
//
// These pseudo instructions are needed to ensure no instructions are inserted
// before or between instructions 0 and 1, which is a limitation imposed by
// GNU linker.

let isTerminator = 1, isBarrier = 1 in
def SETGP01 : Cpu0Pseudo<(outs CPURegs:$dst), (ins), "", []>;

let neverHasSideEffects = 1 in
def SETGP2 : Cpu0Pseudo<(outs CPURegs:$globalreg), (ins CPURegs:$picreg), "",
                        []>;

//===----------------------------------------------------------------------===//
// Instruction definition
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Cpu0I Instructions
//===----------------------------------------------------------------------===//

/// Load and Store Instructions
///  aligned
defm LW      : LoadM32<0x00,  "lw",  load_a>;
defm ST      : StoreM32<0x01, "st",  store_a>;

/// Arithmetic Instructions (ALU Immediate)
def LDI   : ArithLogicI<0x08, "ldi", add, simm16, immSExt16, CPURegs>;
// add defined in include/llvm/Target/TargetSelectionDAG.td, line 315 (def add).

/// Arithmetic Instructions (3-Operand, R-Type)
def CMP		: CmpInstr<0x10, "cmp", IIAlu, CPURegs, 1>;
def ADD     : ArithLogicR<0x13, "add", add, IIAlu, CPURegs, 1>;
def SUB     : ArithLogicR<0x14, "sub", sub, IIAlu, CPURegs, 1>;
def MUL     : ArithLogicR<0x15, "mul", mul, IIImul, CPURegs, 1>;
def DIV     : ArithLogicR<0x16, "div", sdiv, IIIdiv, CPURegs, 1>;
def AND     : ArithLogicR<0x18, "and", and, IIAlu, CPURegs, 1>;
def OR      : ArithLogicR<0x19, "or", or, IIAlu, CPURegs, 1>;
def XOR     : ArithLogicR<0x1A, "xor", xor, IIAlu, CPURegs, 1>;

/// Shift Instructions
def ROL     : ArithLogicR<0x1C, "rol", rotl, IIAlu, CPURegs, 1>;
def ROR     : ArithLogicR<0x1D, "ror", rotr, IIAlu, CPURegs, 1>;
def SHL     : ArithLogicR<0x1E, "shl", shl, IIAlu, CPURegs, 1>;
def SHR     : ArithLogicR<0x1F, "shr", sra, IIAlu, CPURegs, 1>;

/// Jump and Branch Instructions
def JEQ     : CBranch<0x20, "jeq", seteq, CPURegs>;
def JNE     : CBranch<0x21, "jne", setne, CPURegs>;
def JLT     : CBranch<0x22, "jle", setle, CPURegs>;
def JGT     : CBranch<0x23, "jgt", setgt, CPURegs>;
def JLE     : CBranch<0x24, "jle", setle, CPURegs>;
def JGE     : CBranch<0x25, "jge", setge, CPURegs>;
def JMP     : UncondBranch<0x26, "jmp">;

def SWI  : JumpLink<0x2A, "swi">;
def JSUB  : JumpLink<0x2B, "jsub">;

let isReturn=1, isTerminator=1, hasDelaySlot=1, isCodeGenOnly=1,
    isBarrier=1, hasCtrlDep=1 in
  def RET : FJ <0x2C, (outs), (ins CPURegs:$target),
                "ret\t$target", [(Cpu0Ret CPURegs:$target)], IIBranch>;

/// No operation
let addr=0 in
  def NOP   : FJ<0, (outs), (ins), "nop", [], IIAlu>;

//===----------------------------------------------------------------------===//
//  Arbitrary patterns that map to one or more instructions
//===----------------------------------------------------------------------===//

// Small immediates

def : Pat<(i32 immSExt16:$in),
          (LDI ZERO, imm:$in)>;

def : Pat<(not CPURegs:$in),
          (XOR CPURegs:$in, ZERO)>;

