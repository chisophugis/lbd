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

def SDT_Cpu0CMov         : SDTypeProfile<1, 4, [SDTCisSameAs<0, 1>,
                                                SDTCisSameAs<1, 2>,
                                                SDTCisSameAs<3, 4>,
                                                SDTCisInt<4>]>;
def SDT_Cpu0CallSeqStart : SDCallSeqStart<[SDTCisVT<0, i32>]>;
def SDT_Cpu0CallSeqEnd   : SDCallSeqEnd<[SDTCisVT<0, i32>, SDTCisVT<1, i32>]>;
def SDT_Cpu0MAddMSub     : SDTypeProfile<0, 4,
                                         [SDTCisVT<0, i32>, SDTCisSameAs<0, 1>,
                                          SDTCisSameAs<1, 2>,
                                          SDTCisSameAs<2, 3>]>;
def SDT_Cpu0DivRem       : SDTypeProfile<0, 2,
                                         [SDTCisInt<0>,
                                          SDTCisSameAs<0, 1>]>;

def SDT_Cpu0ThreadPointer : SDTypeProfile<1, 0, [SDTCisPtrTy<0>]>;

def SDT_Cpu0DynAlloc    : SDTypeProfile<1, 1, [SDTCisVT<0, iPTR>,
                                               SDTCisSameAs<0, 1>]>;
def SDT_Sync             : SDTypeProfile<0, 1, [SDTCisVT<0, i32>]>;

def SDT_Ext : SDTypeProfile<1, 3, [SDTCisInt<0>, SDTCisSameAs<0, 1>,
                                   SDTCisVT<2, i32>, SDTCisSameAs<2, 3>]>;
def SDT_Ins : SDTypeProfile<1, 4, [SDTCisInt<0>, SDTCisSameAs<0, 1>,
                                   SDTCisVT<2, i32>, SDTCisSameAs<2, 3>,
                                   SDTCisSameAs<0, 4>]>;

// Call
def Cpu0JmpLink : SDNode<"Cpu0ISD::JmpLink",SDT_Cpu0JmpLink,
                         [SDNPHasChain, SDNPOutGlue, SDNPOptInGlue,
                          SDNPVariadic]>;

// Hi and Lo nodes are used to handle global addresses. Used on
// Cpu0ISelLowering to lower stuff like GlobalAddress, ExternalSymbol
// static model. (nothing to do with Cpu0 Registers Hi and Lo)
def Cpu0Hi    : SDNode<"Cpu0ISD::Hi", SDTIntUnaryOp>;
def Cpu0Lo    : SDNode<"Cpu0ISD::Lo", SDTIntUnaryOp>;

def Cpu0GPRel : SDNode<"Cpu0ISD::GPRel", SDTIntUnaryOp>;
// Return
def Cpu0Ret : SDNode<"Cpu0ISD::Ret", SDT_Cpu0Ret, [SDNPHasChain,
                     SDNPOptInGlue]>;

// These are target-independent nodes, but have target-specific formats.
def callseq_start : SDNode<"ISD::CALLSEQ_START", SDT_Cpu0CallSeqStart,
                           [SDNPHasChain, SDNPOutGlue]>;
def callseq_end   : SDNode<"ISD::CALLSEQ_END", SDT_Cpu0CallSeqEnd,
                           [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue]>;

// Pointer to dynamically allocated stack area.
def Cpu0DynAlloc  : SDNode<"Cpu0ISD::DynAlloc", SDT_Cpu0DynAlloc,
                           [SDNPHasChain, SDNPInGlue]>;

def Cpu0Sync : SDNode<"Cpu0ISD::Sync", SDT_Sync, [SDNPHasChain]>;

def Cpu0Ext :  SDNode<"Cpu0ISD::Ext", SDT_Ext>;
def Cpu0Ins :  SDNode<"Cpu0ISD::Ins", SDT_Ins>;

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

def simm12      : Operand<i32> {
  let DecoderMethod= "DecodeSimm12";
}

// Unsigned Operand
def uimm12      : Operand<i32> {
  let PrintMethod = "printUnsignedImm";
}

def simm16      : Operand<i32> {
  let DecoderMethod= "DecodeSimm16";
}

// Unsigned Operand
def uimm16      : Operand<i32> {
  let PrintMethod = "printUnsignedImm";
}

// Address operand
def mem : Operand<i32> {
  let PrintMethod = "printMemOperand";
  let MIOperandInfo = (ops CPURegs, simm16);
  let EncoderMethod = "getMemEncoding";
}
def mem_ea : Operand<i32> {
  let PrintMethod = "printMemOperandEA";
  let MIOperandInfo = (ops CPURegs, simm16);
  let EncoderMethod = "getMemEncoding";
}

// Transformation Function - get the lower 12 bits.
def LO12 : SDNodeXForm<imm, [{
  return getImm(N, N->getZExtValue() & 0x0FFF);
}]>;

// Transformation Function - get the higher 12 bits.
def HI12 : SDNodeXForm<imm, [{
  return getImm(N, (N->getZExtValue() >> 20) & 0x0FFF);
}]>;

// Transformation Function - get the lower 16 bits.
def LO16 : SDNodeXForm<imm, [{
  return getImm(N, N->getZExtValue() & 0xFFFF);
}]>;

// Transformation Function - get the higher 16 bits.
def HI16 : SDNodeXForm<imm, [{
  return getImm(N, (N->getZExtValue() >> 16) & 0xFFFF);
}]>;

// Transformation Function - get the lower 24 bits.
def LO24 : SDNodeXForm<imm, [{
  return getImm(N, N->getZExtValue() & 0xFFFFFF);
}]>;

// Transformation Function - get the higher 24 bits.
def HI24 : SDNodeXForm<imm, [{
  return getImm(N, (N->getZExtValue() >> 8) & 0xFFFFFF);
}]>;

// Node immediate fits as 12-bit sign extended on target immediate.
// e.g. rol, shr
def immSExt12  : PatLeaf<(imm), [{ return isInt<12>(N->getSExtValue()); }]>;

// Node immediate fits as 12-bit zero extended on target immediate.
// The LO12 param means that only the lower 12 bits of the node
// immediate are caught.
// e.g. addiu, sltiu
def immZExt12  : PatLeaf<(imm), [{
  if (N->getValueType(0) == MVT::i32)
    return (uint32_t)N->getZExtValue() == (unsigned short)N->getZExtValue();
//  else
//    return (uint64_t)N->getZExtValue() == (unsigned short)N->getZExtValue();
}], LO12>;

// Node immediate fits as 16-bit sign extended on target immediate.
// e.g. addi, andi
def immSExt16  : PatLeaf<(imm), [{ return isInt<16>(N->getSExtValue()); }]>;

// Node immediate fits as 16-bit zero extended on target immediate.
// The LO16 param means that only the lower 16 bits of the node
// immediate are caught.
// e.g. addiu, sltiu
def immZExt16  : PatLeaf<(imm), [{
  if (N->getValueType(0) == MVT::i32)
    return (uint32_t)N->getZExtValue() == (unsigned short)N->getZExtValue();
  else
    return (uint64_t)N->getZExtValue() == (unsigned short)N->getZExtValue();
}], LO16>;

// Immediate can be loaded with LUi (32-bit int with lower 16-bit cleared).
def immLow16Zero : PatLeaf<(imm), [{
  int64_t Val = N->getSExtValue();
  return isInt<32>(Val) && !(Val & 0xffff);
}]>;

// shamt field must fit in 5 bits.
def immZExt24 : ImmLeaf<i32, [{return Imm == (Imm & 0xffffff);}]>;

// shamt field must fit in 5 bits.
def immZExt32 : ImmLeaf<i32, [{return Imm == (Imm & 0xffffffff);}]>;

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
def sextloadi16_a   : AlignedLoad<sextloadi16>;
def zextloadi16_a   : AlignedLoad<zextloadi16>;
def extloadi16_a    : AlignedLoad<extloadi16>;

def load_a          : AlignedLoad<load>;

def sextloadi32_a   : AlignedLoad<sextloadi32>;
def zextloadi32_a   : AlignedLoad<zextloadi32>;
def extloadi32_a    : AlignedLoad<extloadi32>;
def truncstorei16_a : AlignedStore<truncstorei16>;

def store_a         : AlignedStore<store>;
def truncstorei32_a : AlignedStore<truncstorei32>;

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

class ArithOverflowR<bits<8> op, string instr_asm,
                    InstrItinClass itin, RegisterClass RC, bit isComm = 0>:
  FA<op, (outs RC:$ra), (ins RC:$rb, RC:$rc),
     !strconcat(instr_asm, "\t$ra, $rb, $rc"), [], itin> {
  let isCommutable = isComm;
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

  class JumpLinkReg<bits<8> op, string instr_asm,
                    RegisterClass RC>:
    FA<op, (outs), (ins RC:$rb, variable_ops),
       !strconcat(instr_asm, "\t$rb"), [(Cpu0JmpLink RC:$rb)], IIBranch> {
    let rc = 0;
    let ra = 14;
    let imm12 = 0;
  }
}

class EffectiveAddress<string instr_asm, RegisterClass RC, Operand Mem> :
  FMem<0x08, (outs RC:$ra), (ins Mem:$addr),
     instr_asm, [(set RC:$ra, addr:$addr)], IIAlu>;
//===----------------------------------------------------------------------===//
// Pseudo instructions
//===----------------------------------------------------------------------===//

// As stack alignment is always done with addiu, we need a 16-bit immediate
let Defs = [SP], Uses = [SP] in {
def ADJCALLSTACKDOWN : Cpu0Pseudo<(outs), (ins uimm16:$amt),
                                  "!ADJCALLSTACKDOWN $amt",
                                  [(callseq_start timm:$amt)]>;
def ADJCALLSTACKUP   : Cpu0Pseudo<(outs), (ins uimm16:$amt1, uimm16:$amt2),
                                  "!ADJCALLSTACKUP $amt1",
                                  [(callseq_end timm:$amt1, timm:$amt2)]>;
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

defm LDB     : LoadM32<0x02,  "ldb", zextloadi8>;
defm STB     : StoreM32<0x03, "stb", truncstorei8>;

/// Arithmetic Instructions (ALU Immediate)
def LDI   : ArithLogicI<0x08, "ldi", add, simm16, immSExt16, CPURegs>;
// add defined in include/llvm/Target/TargetSelectionDAG.td, line 315 (def add).

/// Arithmetic Instructions (3-Operand, R-Type)
def CMP		: CmpInstr<0x10, "cmp", IIAlu, CPURegs, 1>;
def MOV		: ArithOverflowR<0x12, "mov", IIAlu, CPURegs, 1>;
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
//def J       : JumpFJ<0x02, "j">;
//def JR      : JumpFR<0x00, 0x08, "jr", CPURegs>;
def JEQ     : CBranch<0x20, "jeq", seteq, CPURegs>;
def JNE     : CBranch<0x21, "jne", setne, CPURegs>;
def JLT     : CBranch<0x22, "jle", setle, CPURegs>;
def JGT     : CBranch<0x23, "jgt", setgt, CPURegs>;
def JLE     : CBranch<0x24, "jle", setle, CPURegs>;
def JGE     : CBranch<0x25, "jge", setge, CPURegs>;
def JMP     : UncondBranch<0x26, "jmp">;
//def JMP       : JumpFJStatic<0x026, "jmp">;	// work in -relocation-model=static
//def JMP       : JumpFJPic<0x026, "jmp">;
//def JMP       : JumpLink<0x026, "jmp">;
//def JSUBR : JumpLinkReg<0x27, "jsubr", CPURegs>;

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

// FrameIndexes are legalized when they are operands from load/store
// instructions. The same not happens for stack address copies, so an
// add op with mem ComplexPattern is used and the stack address copy
// can be matched. It's similar to Sparc LEA_ADDRi

//def LEA_ADDiu : EffectiveAddress<"addiu\t$rt, $addr", CPURegs, mem_ea> {
def LEA_LDI : EffectiveAddress<"ldi\t$ra, $addr", CPURegs, mem_ea> {
  let isCodeGenOnly = 1;
}

// DynAlloc node points to dynamically allocated stack space.
// $sp is added to the list of implicitly used registers to prevent dead code
// elimination from removing instructions that modify $sp.
let Uses = [SP] in
//def DynAlloc : EffectiveAddress<"addiu\t$rt, $addr", CPURegs, mem_ea> {
def DynAlloc : EffectiveAddress<"ldi\t$ra, $addr", CPURegs, mem_ea> {
  let isCodeGenOnly = 1;
}


// Small immediates
def : Pat<(i32 immSExt16:$in),
          (LDI ZERO, imm:$in)>;

// gp_rel relocs
def : Pat<(add CPURegs:$gp, (Cpu0GPRel tglobaladdr:$in)),
          (ADD CPURegs:$gp, tglobaladdr:$in)>;
def : Pat<(add CPURegs:$gp, (Cpu0GPRel tconstpool:$in)),
          (ADD CPURegs:$gp, tconstpool:$in)>;

// Cpu0 does not have "not", so we expand our way
def : Pat<(not CPURegs:$in),
          (XOR CPURegs:$in, ZERO)>;

