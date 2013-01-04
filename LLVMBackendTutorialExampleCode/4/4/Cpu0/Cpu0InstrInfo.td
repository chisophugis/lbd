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

// Return
def Cpu0Ret : SDNode<"Cpu0ISD::Ret", SDT_Cpu0Ret, [SDNPHasChain,
                     SDNPOptInGlue]>;

//===----------------------------------------------------------------------===//
// Cpu0 Operand, Complex Patterns and Transformations Definitions.
//===----------------------------------------------------------------------===//

// Signed Operand
def simm16      : Operand<i32> {
  let DecoderMethod= "DecodeSimm16";
}

def shamt       : Operand<i32>;

// Address operand
def mem : Operand<i32> {
  let PrintMethod = "printMemOperand";
  let MIOperandInfo = (ops CPURegs, simm16);
  let EncoderMethod = "getMemEncoding";
}

// Node immediate fits as 16-bit sign extended on target immediate.
// e.g. addi, andi
def immSExt16  : PatLeaf<(imm), [{ return isInt<16>(N->getSExtValue()); }]>;

// shamt field must fit in 5 bits.
def immZExt5 : ImmLeaf<i32, [{return Imm == (Imm & 0x1f);}]>;

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
  let shamt = 0;
  let isCommutable = isComm;	// e.g. add rb rc =  add rc rb
  let isReMaterializable = 1;
}

class CmpInstr<bits<8> op, string instr_asm,
                    InstrItinClass itin, RegisterClass RC, bit isComm = 0>:
  FA<op, (outs RC:$SW), (ins RC:$ra, RC:$rb),
     !strconcat(instr_asm, "\t$ra, $rb"), [], itin> {
  let rc = 0;
  let shamt = 0;
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

// Move immediate imm16 to register ra.
class MoveImm<bits<8> op, string instr_asm, SDNode OpNode,
                  Operand Od, PatLeaf imm_type, RegisterClass RC> :
  FL<op, (outs RC:$ra), (ins RC:$rb, Od:$imm16),
     !strconcat(instr_asm, "\t$ra, $imm16"),
     [(set RC:$ra, (OpNode RC:$rb, imm_type:$imm16))], IIAlu> {
  let rb = 0;
  let isReMaterializable = 1;
}

// Shifts
class shift_rotate_imm<bits<8> op, bits<4> isRotate, string instr_asm,
                       SDNode OpNode, PatFrag PF, Operand ImmOpnd,
                       RegisterClass RC>:
  FA<op, (outs RC:$ra), (ins RC:$rb, ImmOpnd:$shamt),
     !strconcat(instr_asm, "\t$ra, $rb, $shamt"),
     [(set RC:$ra, (OpNode RC:$rb, PF:$shamt))], IIAlu> {
  let rc = isRotate;
  let shamt = shamt;
}

// 32-bit shift instructions.
class shift_rotate_imm32<bits<8> func, bits<4> isRotate, string instr_asm,
                         SDNode OpNode>:
  shift_rotate_imm<func, isRotate, instr_asm, OpNode, immZExt5, shamt, CPURegs>;

// Load Upper Imediate
class LoadUpper<bits<8> op, string instr_asm, RegisterClass RC, Operand Imm>:
  FL<op, (outs RC:$ra), (ins Imm:$imm16),
     !strconcat(instr_asm, "\t$ra, $imm16"), [], IIAlu> {
  let rb = 0;
  let neverHasSideEffects = 1;
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

//===----------------------------------------------------------------------===//
// Instruction definition
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Cpu0I Instructions
//===----------------------------------------------------------------------===//

/// Load and Store Instructions
///  aligned
defm LD     : LoadM32<0x00,  "ld",  load_a>;
defm ST     : StoreM32<0x01, "st",  store_a>;

/// Arithmetic Instructions (ALU Immediate)
//def LDI     : MoveImm<0x08, "ldi", add, simm16, immSExt16, CPURegs>;
// add defined in include/llvm/Target/TargetSelectionDAG.td, line 315 (def add).
def ADDiu   : ArithLogicI<0x09, "addiu", add, simm16, immSExt16, CPURegs>;

/// Arithmetic Instructions (3-Operand, R-Type)
def CMP		: CmpInstr<0x10, "cmp", IIAlu, CPURegs, 1>;
def ADD     : ArithLogicR<0x13, "add", add, IIAlu, CPURegs, 1>;
def SUB     : ArithLogicR<0x14, "sub", sub, IIAlu, CPURegs, 1>;
def MUL     : ArithLogicR<0x15, "mul", mul, IIImul, CPURegs, 1>;
def DIV     : ArithLogicR<0x16, "div", sdiv, IIIdiv, CPURegs, 1>;
def UDIV    : ArithLogicR<0x17, "udiv", udiv, IIIdiv, CPURegs, 1>;
def AND     : ArithLogicR<0x18, "and", and, IIAlu, CPURegs, 1>;
def OR      : ArithLogicR<0x19, "or", or, IIAlu, CPURegs, 1>;
def XOR     : ArithLogicR<0x1A, "xor", xor, IIAlu, CPURegs, 1>;

/// Shift Instructions
def SRA     : shift_rotate_imm32<0x1B, 0x00, "sra", sra>; // work, it's for ashr llvm IR instruction
def ROL     : shift_rotate_imm32<0x1C, 0x01, "rol", rotl>;
def ROR     : shift_rotate_imm32<0x1D, 0x01, "ror", rotr>;
def SHL     : shift_rotate_imm32<0x1E, 0x00, "shl", shl>;
def SHR     : shift_rotate_imm32<0x1F, 0x00, "shr", srl>; // work, it's for lshr llvm IR instruction

let isReturn=1, isTerminator=1, hasDelaySlot=1, isCodeGenOnly=1,
    isBarrier=1, hasCtrlDep=1 in
  def RET : FJ <0x2C, (outs), (ins CPURegs:$target),
                "ret\t$target", [(Cpu0Ret CPURegs:$target)], IIBranch>;

//===----------------------------------------------------------------------===//
//  Arbitrary patterns that map to one or more instructions
//===----------------------------------------------------------------------===//

// Small immediates

def : Pat<(i32 immSExt16:$in),
          (ADDiu ZERO, imm:$in)>;

def : Pat<(not CPURegs:$in),
          (XOR CPURegs:$in, ZERO)>;

// setcc patterns
multiclass SeteqPats<RegisterClass RC, Instruction XOROp> {
  def : Pat<(seteq RC:$lhs, RC:$rhs),
            (XOROp (XOROp RC:$lhs, RC:$rhs), (ADDiu ZERO, 1))>;
}

defm : SeteqPats<CPURegs, XOR>;

