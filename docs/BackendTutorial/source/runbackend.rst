.. _sec-runbackend:

Run backend
===========

This chapter will add LLVM AsmParser support first. 
With AsmParser support, we can hand code the assembly language in C/C++ file 
and translate it into obj (elf format). 
We can write a C++ main 
function as well as the boot code by assembly hand code, and translate this 
main()+bootcode() into obj file.
Combined with llvm-objdump support in last chapter, 
this main()+bootcode() elf can be translated into hex file format which 
include the disassemble code as comment. 
Furthermore, we can design the Cpu0 with Verilog language tool and run the Cpu0 
backend on PC by feed the hex file and see the Cpu0 instructions execution 
result.


AsmParser support
------------------

Run 9/1/Cpu0 with ch10_1.cpp will get the following error message.

.. code-block:: c++

  // ch10_1.cpp
  asm("ld $2, 8($sp)");
  asm("st $0, 4($sp)");
  asm("addiu $3,  $ZERO, 0");
  asm("add $3, $1, $2");
  asm("sub $3, $2, $3");
  asm("mul $2, $1, $3");
  asm("div $3, $2");
  asm("divu $2, $3");
  asm("and $2, $1, $3");
  asm("or $3, $1, $2");
  asm("xor $1, $2, $3");
  asm("mult $4, $3");
  asm("multu $3, $2");
  asm("mfhi $3");
  asm("mflo $2");
  asm("mthi $2");
  asm("mtlo $2");
  asm("sra $2, $2, 2");
  asm("rol $2, $1, 3");
  asm("ror $3, $3, 4");
  asm("shl $2, $2, 2");
  asm("shr $2, $3, 5");
  asm("cmp $sw, $2, $3");
  asm("jeq $sw, 20");
  asm("jne $sw, 16");
  asm("jlt $sw, -20");
  asm("jle $sw, -16");
  asm("jgt $sw, -4");
  asm("jge $sw, -12");
  asm("swi 0x00000400");
  asm("jsub 0x000010000");
  asm("ret $lr");
  asm("jalr $t9");
  asm("li $3, 0x00700000");
  asm("la $3, 0x00800000($6)");
  asm("la $3, 0x00900000");

.. code-block:: bash

  JonathantekiiMac:InputFiles Jonathan$ clang -c ch10_1.cpp -emit-llvm -o 
  ch10_1.bc
  JonathantekiiMac:InputFiles Jonathan$ /Users/Jonathan/llvm/test/cmake_debug_
  build/bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=obj ch10_1.bc 
  -o ch10_1.cpu0.o
  LLVM ERROR: Inline asm not supported by this streamer because we don't have 
  an asm parser for this target
  
Since we didn't implement cpu0 assembly, it has the error message as above. 
The cpu0 can translate LLVM IR into assembly and obj directly, but it cannot 
translate hand code assembly into obj. 
Directory AsmParser handle the assembly to obj translation.
The 10/1/Cpu0 include AsmParser implementation as follows,

.. code-block:: c++
  
  // AsmParser/Cpu0AsmParser.cpp
  //===-- Cpu0AsmParser.cpp - Parse Cpu0 assembly to MCInst instructions ----===//
  //
  //                     The LLVM Compiler Infrastructure
  //
  // This file is distributed under the University of Illinois Open Source
  // License. See LICENSE.TXT for details.
  //
  //===----------------------------------------------------------------------===//
  
  #include "MCTargetDesc/Cpu0MCTargetDesc.h"
  #include "Cpu0RegisterInfo.h"
  #include "llvm/ADT/StringSwitch.h"
  #include "llvm/MC/MCContext.h"
  #include "llvm/MC/MCExpr.h"
  #include "llvm/MC/MCInst.h"
  #include "llvm/MC/MCStreamer.h"
  #include "llvm/MC/MCSubtargetInfo.h"
  #include "llvm/MC/MCSymbol.h"
  #include "llvm/MC/MCParser/MCAsmLexer.h"
  #include "llvm/MC/MCParser/MCParsedAsmOperand.h"
  #include "llvm/MC/MCTargetAsmParser.h"
  #include "llvm/Support/TargetRegistry.h"
  
  using namespace llvm;
  
  namespace {
  class Cpu0AssemblerOptions {
  public:
    Cpu0AssemblerOptions():
      aTReg(1), reorder(true), macro(true) {
    }
  
    bool isReorder() {return reorder;}
    void setReorder() {reorder = true;}
    void setNoreorder() {reorder = false;}
  
    bool isMacro() {return macro;}
    void setMacro() {macro = true;}
    void setNomacro() {macro = false;}
  
  private:
    unsigned aTReg;
    bool reorder;
    bool macro;
  };
  }
  
  namespace {
  class Cpu0AsmParser : public MCTargetAsmParser {
    MCSubtargetInfo &STI;
    MCAsmParser &Parser;
    Cpu0AssemblerOptions Options;
  
  
  #define GET_ASSEMBLER_HEADER
  #include "Cpu0GenAsmMatcher.inc"
  
    bool MatchAndEmitInstruction(SMLoc IDLoc, unsigned &Opcode,
                                 SmallVectorImpl<MCParsedAsmOperand*> &Operands,
                                 MCStreamer &Out, unsigned &ErrorInfo,
                                 bool MatchingInlineAsm);
  
    bool ParseRegister(unsigned &RegNo, SMLoc &StartLoc, SMLoc &EndLoc);
  
    bool ParseInstruction(ParseInstructionInfo &Info, StringRef Name,
                          SMLoc NameLoc,
                          SmallVectorImpl<MCParsedAsmOperand*> &Operands);
  
    bool parseMathOperation(StringRef Name, SMLoc NameLoc,
                          SmallVectorImpl<MCParsedAsmOperand*> &Operands);
  
    bool ParseDirective(AsmToken DirectiveID);
  
    Cpu0AsmParser::OperandMatchResultTy
    parseMemOperand(SmallVectorImpl<MCParsedAsmOperand*>&);
  
    bool ParseOperand(SmallVectorImpl<MCParsedAsmOperand*> &,
                      StringRef Mnemonic);
  
    int tryParseRegister(StringRef Mnemonic);
  
    bool tryParseRegisterOperand(SmallVectorImpl<MCParsedAsmOperand*> &Operands,
                                 StringRef Mnemonic);
  
    bool needsExpansion(MCInst &Inst);
  
    void expandInstruction(MCInst &Inst, SMLoc IDLoc,
                           SmallVectorImpl<MCInst> &Instructions);
    void expandLoadImm(MCInst &Inst, SMLoc IDLoc,
                       SmallVectorImpl<MCInst> &Instructions);
    void expandLoadAddressImm(MCInst &Inst, SMLoc IDLoc,
                              SmallVectorImpl<MCInst> &Instructions);
    void expandLoadAddressReg(MCInst &Inst, SMLoc IDLoc,
                              SmallVectorImpl<MCInst> &Instructions);
    bool reportParseError(StringRef ErrorMsg);
  
    bool parseMemOffset(const MCExpr *&Res);
    bool parseRelocOperand(const MCExpr *&Res);
  
    bool parseDirectiveSet();
  
    bool parseSetAtDirective();
    bool parseSetNoAtDirective();
    bool parseSetMacroDirective();
    bool parseSetNoMacroDirective();
    bool parseSetReorderDirective();
    bool parseSetNoReorderDirective();
  
    MCSymbolRefExpr::VariantKind getVariantKind(StringRef Symbol);
  
    int matchRegisterName(StringRef Symbol);
  
    int matchRegisterByNumber(unsigned RegNum, StringRef Mnemonic);
  
    unsigned getReg(int RC,int RegNo);
  
  public:
    Cpu0AsmParser(MCSubtargetInfo &sti, MCAsmParser &parser)
      : MCTargetAsmParser(), STI(sti), Parser(parser) {
      // Initialize the set of available features.
      setAvailableFeatures(ComputeAvailableFeatures(STI.getFeatureBits()));
    }
  
    MCAsmParser &getParser() const { return Parser; }
    MCAsmLexer &getLexer() const { return Parser.getLexer(); }
  
  };
  }
  
  namespace {
  
  /// Cpu0Operand - Instances of this class represent a parsed Cpu0 machine
  /// instruction.
  class Cpu0Operand : public MCParsedAsmOperand {
  
    enum KindTy {
      k_CondCode,
      k_CoprocNum,
      k_Immediate,
      k_Memory,
      k_PostIndexRegister,
      k_Register,
      k_Token
    } Kind;
  
    Cpu0Operand(KindTy K) : MCParsedAsmOperand(), Kind(K) {}
  
    union {
      struct {
        const char *Data;
        unsigned Length;
      } Tok;
  
      struct {
        unsigned RegNum;
      } Reg;
  
      struct {
        const MCExpr *Val;
      } Imm;
  
      struct {
        unsigned Base;
        const MCExpr *Off;
      } Mem;
    };
  
    SMLoc StartLoc, EndLoc;
  
  public:
    void addRegOperands(MCInst &Inst, unsigned N) const {
      assert(N == 1 && "Invalid number of operands!");
      Inst.addOperand(MCOperand::CreateReg(getReg()));
    }
  
    void addExpr(MCInst &Inst, const MCExpr *Expr) const{
      // Add as immediate when possible.  Null MCExpr = 0.
      if (Expr == 0)
        Inst.addOperand(MCOperand::CreateImm(0));
      else if (const MCConstantExpr *CE = dyn_cast<MCConstantExpr>(Expr))
        Inst.addOperand(MCOperand::CreateImm(CE->getValue()));
      else
        Inst.addOperand(MCOperand::CreateExpr(Expr));
    }
  
    void addImmOperands(MCInst &Inst, unsigned N) const {
      assert(N == 1 && "Invalid number of operands!");
      const MCExpr *Expr = getImm();
      addExpr(Inst,Expr);
    }
  
    void addMemOperands(MCInst &Inst, unsigned N) const {
      assert(N == 2 && "Invalid number of operands!");
  
      Inst.addOperand(MCOperand::CreateReg(getMemBase()));
  
      const MCExpr *Expr = getMemOff();
      addExpr(Inst,Expr);
    }
  
    bool isReg() const { return Kind == k_Register; }
    bool isImm() const { return Kind == k_Immediate; }
    bool isToken() const { return Kind == k_Token; }
    bool isMem() const { return Kind == k_Memory; }
  
    StringRef getToken() const {
      assert(Kind == k_Token && "Invalid access!");
      return StringRef(Tok.Data, Tok.Length);
    }
  
    unsigned getReg() const {
      assert((Kind == k_Register) && "Invalid access!");
      return Reg.RegNum;
    }
  
    const MCExpr *getImm() const {
      assert((Kind == k_Immediate) && "Invalid access!");
      return Imm.Val;
    }
  
    unsigned getMemBase() const {
      assert((Kind == k_Memory) && "Invalid access!");
      return Mem.Base;
    }
  
    const MCExpr *getMemOff() const {
      assert((Kind == k_Memory) && "Invalid access!");
      return Mem.Off;
    }
  
    static Cpu0Operand *CreateToken(StringRef Str, SMLoc S) {
      Cpu0Operand *Op = new Cpu0Operand(k_Token);
      Op->Tok.Data = Str.data();
      Op->Tok.Length = Str.size();
      Op->StartLoc = S;
      Op->EndLoc = S;
      return Op;
    }
  
    static Cpu0Operand *CreateReg(unsigned RegNum, SMLoc S, SMLoc E) {
      Cpu0Operand *Op = new Cpu0Operand(k_Register);
      Op->Reg.RegNum = RegNum;
      Op->StartLoc = S;
      Op->EndLoc = E;
      return Op;
    }
  
    static Cpu0Operand *CreateImm(const MCExpr *Val, SMLoc S, SMLoc E) {
      Cpu0Operand *Op = new Cpu0Operand(k_Immediate);
      Op->Imm.Val = Val;
      Op->StartLoc = S;
      Op->EndLoc = E;
      return Op;
    }
  
    static Cpu0Operand *CreateMem(unsigned Base, const MCExpr *Off,
                                   SMLoc S, SMLoc E) {
      Cpu0Operand *Op = new Cpu0Operand(k_Memory);
      Op->Mem.Base = Base;
      Op->Mem.Off = Off;
      Op->StartLoc = S;
      Op->EndLoc = E;
      return Op;
    }
  
    /// getStartLoc - Get the location of the first token of this operand.
    SMLoc getStartLoc() const { return StartLoc; }
    /// getEndLoc - Get the location of the last token of this operand.
    SMLoc getEndLoc() const { return EndLoc; }
  
    virtual void print(raw_ostream &OS) const {
      llvm_unreachable("unimplemented!");
    }
  };
  }
  
  bool Cpu0AsmParser::needsExpansion(MCInst &Inst) {
  
    switch(Inst.getOpcode()) {
      case Cpu0::LoadImm32Reg:
      case Cpu0::LoadAddr32Imm:
      case Cpu0::LoadAddr32Reg:
        return true;
      default:
        return false;
    }
  }
  
  void Cpu0AsmParser::expandInstruction(MCInst &Inst, SMLoc IDLoc,
                          SmallVectorImpl<MCInst> &Instructions){
    switch(Inst.getOpcode()) {
      case Cpu0::LoadImm32Reg:
        return expandLoadImm(Inst, IDLoc, Instructions);
      case Cpu0::LoadAddr32Imm:
        return expandLoadAddressImm(Inst,IDLoc,Instructions);
      case Cpu0::LoadAddr32Reg:
        return expandLoadAddressReg(Inst,IDLoc,Instructions);
      }
  }
  
  void Cpu0AsmParser::expandLoadImm(MCInst &Inst, SMLoc IDLoc,
                                    SmallVectorImpl<MCInst> &Instructions){
    MCInst tmpInst;
    const MCOperand &ImmOp = Inst.getOperand(1);
    assert(ImmOp.isImm() && "expected immediate operand kind");
    const MCOperand &RegOp = Inst.getOperand(0);
    assert(RegOp.isReg() && "expected register operand kind");
  
    int ImmValue = ImmOp.getImm();
    tmpInst.setLoc(IDLoc);
    if ( -32768 <= ImmValue && ImmValue <= 32767) {
      // for -32768 <= j < 32767.
      // li d,j => addiu d,$zero,j
      tmpInst.setOpcode(Cpu0::ADDiu); //TODO:no ADDiu64 in td files?
      tmpInst.addOperand(MCOperand::CreateReg(RegOp.getReg()));
      tmpInst.addOperand(
                MCOperand::CreateReg(Cpu0::ZERO));
      tmpInst.addOperand(MCOperand::CreateImm(ImmValue));
      Instructions.push_back(tmpInst);
    } else {
      // for any other value of j that is representable as a 32-bit integer.
      // li d,j => addiu d, $0, hi16(j)
      //           shl d, d, 16
      //           addiu at, $0, lo16(j)
      //           or d, d, at
      tmpInst.setOpcode(Cpu0::ADDiu);
      tmpInst.addOperand(MCOperand::CreateReg(RegOp.getReg()));
      tmpInst.addOperand(MCOperand::CreateReg(Cpu0::ZERO));
      tmpInst.addOperand(MCOperand::CreateImm((ImmValue & 0xffff0000) >> 16));
      Instructions.push_back(tmpInst);
      tmpInst.clear();
      tmpInst.setOpcode(Cpu0::SHL);
      tmpInst.addOperand(MCOperand::CreateReg(RegOp.getReg()));
      tmpInst.addOperand(MCOperand::CreateReg(RegOp.getReg()));
      tmpInst.addOperand(MCOperand::CreateImm(16));
      Instructions.push_back(tmpInst);
      tmpInst.clear();
      tmpInst.setOpcode(Cpu0::ADDiu);
      tmpInst.addOperand(MCOperand::CreateReg(Cpu0::AT));
      tmpInst.addOperand(MCOperand::CreateReg(Cpu0::ZERO));
      tmpInst.addOperand(MCOperand::CreateImm(ImmValue & 0x0000ffff));
      Instructions.push_back(tmpInst);
      tmpInst.clear();
      tmpInst.setOpcode(Cpu0::OR);
      tmpInst.addOperand(MCOperand::CreateReg(RegOp.getReg()));
      tmpInst.addOperand(MCOperand::CreateReg(RegOp.getReg()));
      tmpInst.addOperand(MCOperand::CreateReg(Cpu0::AT));
      tmpInst.setLoc(IDLoc);
      Instructions.push_back(tmpInst);
    }
  }
  
  void Cpu0AsmParser::expandLoadAddressReg(MCInst &Inst, SMLoc IDLoc,
                                           SmallVectorImpl<MCInst> &Instructions){
    MCInst tmpInst;
    const MCOperand &ImmOp = Inst.getOperand(2);
    assert(ImmOp.isImm() && "expected immediate operand kind");
    const MCOperand &SrcRegOp = Inst.getOperand(1);
    assert(SrcRegOp.isReg() && "expected register operand kind");
    const MCOperand &DstRegOp = Inst.getOperand(0);
    assert(DstRegOp.isReg() && "expected register operand kind");
    int ImmValue = ImmOp.getImm();
    if ( -32768 <= ImmValue && ImmValue <= 32767) {
      // for -32768 <= j < 32767.
      //la d,j(s) => addiu d,s,j
      tmpInst.setOpcode(Cpu0::ADDiu); //TODO:no ADDiu64 in td files?
      tmpInst.addOperand(MCOperand::CreateReg(DstRegOp.getReg()));
      tmpInst.addOperand(MCOperand::CreateReg(SrcRegOp.getReg()));
      tmpInst.addOperand(MCOperand::CreateImm(ImmValue));
      Instructions.push_back(tmpInst);
    } else {
      // for any other value of j that is representable as a 32-bit integer.
      // li d,j(s) => addiu d, $0, hi16(j)
      //           shl d, d, 16
      //           addiu at, $0, lo16(j)
      //           or d, d, at
      //           add d,d,s
      tmpInst.setOpcode(Cpu0::ADDiu);
      tmpInst.addOperand(MCOperand::CreateReg(DstRegOp.getReg()));
      tmpInst.addOperand(MCOperand::CreateReg(Cpu0::ZERO));
      tmpInst.addOperand(MCOperand::CreateImm((ImmValue & 0xffff0000) >> 16));
      Instructions.push_back(tmpInst);
      tmpInst.clear();
      tmpInst.setOpcode(Cpu0::SHL);
      tmpInst.addOperand(MCOperand::CreateReg(DstRegOp.getReg()));
      tmpInst.addOperand(MCOperand::CreateReg(SrcRegOp.getReg()));
      tmpInst.addOperand(MCOperand::CreateImm(16));
      Instructions.push_back(tmpInst);
      tmpInst.clear();
      tmpInst.setOpcode(Cpu0::ADDiu);
      tmpInst.addOperand(MCOperand::CreateReg(Cpu0::AT));
      tmpInst.addOperand(MCOperand::CreateReg(Cpu0::ZERO));
      tmpInst.addOperand(MCOperand::CreateImm(ImmValue & 0x0000ffff));
      Instructions.push_back(tmpInst);
      tmpInst.clear();
      tmpInst.setOpcode(Cpu0::OR);
      tmpInst.addOperand(MCOperand::CreateReg(DstRegOp.getReg()));
      tmpInst.addOperand(MCOperand::CreateReg(SrcRegOp.getReg()));
      tmpInst.addOperand(MCOperand::CreateReg(Cpu0::AT));
      tmpInst.setLoc(IDLoc);
      Instructions.push_back(tmpInst);
      tmpInst.clear();
      tmpInst.setOpcode(Cpu0::ADD);
      tmpInst.addOperand(MCOperand::CreateReg(DstRegOp.getReg()));
      tmpInst.addOperand(MCOperand::CreateReg(DstRegOp.getReg()));
      tmpInst.addOperand(MCOperand::CreateReg(SrcRegOp.getReg()));
      Instructions.push_back(tmpInst);
    }
  }
  
  void Cpu0AsmParser::expandLoadAddressImm(MCInst &Inst, SMLoc IDLoc,
                                           SmallVectorImpl<MCInst> &Instructions){
    MCInst tmpInst;
    const MCOperand &ImmOp = Inst.getOperand(1);
    assert(ImmOp.isImm() && "expected immediate operand kind");
    const MCOperand &RegOp = Inst.getOperand(0);
    assert(RegOp.isReg() && "expected register operand kind");
    int ImmValue = ImmOp.getImm();
    if ( -32768 <= ImmValue && ImmValue <= 32767) {
      // for -32768 <= j < 32767.
      //la d,j => addiu d,$zero,j
      tmpInst.setOpcode(Cpu0::ADDiu);
      tmpInst.addOperand(MCOperand::CreateReg(RegOp.getReg()));
      tmpInst.addOperand(
                MCOperand::CreateReg(Cpu0::ZERO));
      tmpInst.addOperand(MCOperand::CreateImm(ImmValue));
      Instructions.push_back(tmpInst);
    } else {
      // for any other value of j that is representable as a 32-bit integer.
      // la d,j => addiu d, $0, hi16(j)
      //           shl d, d, 16
      //           addiu at, $0, lo16(j)
      //           or d, d, at
      tmpInst.setOpcode(Cpu0::ADDiu);
      tmpInst.addOperand(MCOperand::CreateReg(RegOp.getReg()));
      tmpInst.addOperand(MCOperand::CreateReg(Cpu0::ZERO));
      tmpInst.addOperand(MCOperand::CreateImm((ImmValue & 0xffff0000) >> 16));
      Instructions.push_back(tmpInst);
      tmpInst.clear();
      tmpInst.setOpcode(Cpu0::SHL);
      tmpInst.addOperand(MCOperand::CreateReg(RegOp.getReg()));
      tmpInst.addOperand(MCOperand::CreateReg(RegOp.getReg()));
      tmpInst.addOperand(MCOperand::CreateImm(16));
      Instructions.push_back(tmpInst);
      tmpInst.clear();
      tmpInst.setOpcode(Cpu0::ADDiu);
      tmpInst.addOperand(MCOperand::CreateReg(Cpu0::AT));
      tmpInst.addOperand(MCOperand::CreateReg(Cpu0::ZERO));
      tmpInst.addOperand(MCOperand::CreateImm(ImmValue & 0x0000ffff));
      Instructions.push_back(tmpInst);
      tmpInst.clear();
      tmpInst.setOpcode(Cpu0::OR);
      tmpInst.addOperand(MCOperand::CreateReg(RegOp.getReg()));
      tmpInst.addOperand(MCOperand::CreateReg(RegOp.getReg()));
      tmpInst.addOperand(MCOperand::CreateReg(Cpu0::AT));
      tmpInst.setLoc(IDLoc);
      Instructions.push_back(tmpInst);
    }
  }
  
  bool Cpu0AsmParser::
  MatchAndEmitInstruction(SMLoc IDLoc, unsigned &Opcode,
                          SmallVectorImpl<MCParsedAsmOperand*> &Operands,
                          MCStreamer &Out, unsigned &ErrorInfo,
                          bool MatchingInlineAsm) {
    MCInst Inst;
    unsigned MatchResult = MatchInstructionImpl(Operands, Inst, ErrorInfo,
                                                MatchingInlineAsm);
  
    switch (MatchResult) {
    default: break;
    case Match_Success: {
      if (needsExpansion(Inst)) {
        SmallVector<MCInst, 4> Instructions;
        expandInstruction(Inst, IDLoc, Instructions);
        for(unsigned i =0; i < Instructions.size(); i++){
          Out.EmitInstruction(Instructions[i]);
        }
      } else {
          Inst.setLoc(IDLoc);
          Out.EmitInstruction(Inst);
        }
      return false;
    }
    case Match_MissingFeature:
      Error(IDLoc, "instruction requires a CPU feature not currently enabled");
      return true;
    case Match_InvalidOperand: {
      SMLoc ErrorLoc = IDLoc;
      if (ErrorInfo != ~0U) {
        if (ErrorInfo >= Operands.size())
          return Error(IDLoc, "too few operands for instruction");
  
        ErrorLoc = ((Cpu0Operand*)Operands[ErrorInfo])->getStartLoc();
        if (ErrorLoc == SMLoc()) ErrorLoc = IDLoc;
      }
  
      return Error(ErrorLoc, "invalid operand for instruction");
    }
    case Match_MnemonicFail:
      return Error(IDLoc, "invalid instruction");
    }
    return true;
  }
  
  int Cpu0AsmParser::matchRegisterName(StringRef Name) {
  
     int CC;
      CC = StringSwitch<unsigned>(Name)
        .Case("zero",  Cpu0::ZERO)
        .Case("at",  Cpu0::AT)
        .Case("v0",  Cpu0::V0)
        .Case("v1",  Cpu0::V1)
        .Case("a0",  Cpu0::A0)
        .Case("a1",  Cpu0::A1)
        .Case("t9",  Cpu0::T9)
        .Case("s0",  Cpu0::S0)
        .Case("s1",  Cpu0::S1)
        .Case("s2",  Cpu0::S2)
        .Case("gp",  Cpu0::GP)
        .Case("fp",  Cpu0::FP)
        .Case("sw",  Cpu0::SW)
        .Case("sp",  Cpu0::SP)
        .Case("lr",  Cpu0::LR)
        .Case("pc",  Cpu0::PC)
        .Default(-1);
  
    if (CC != -1)
      return CC;
  
    return -1;
  }
  
  unsigned Cpu0AsmParser::getReg(int RC,int RegNo) {
    return *(getContext().getRegisterInfo().getRegClass(RC).begin() + RegNo);
  }
  
  int Cpu0AsmParser::matchRegisterByNumber(unsigned RegNum, StringRef Mnemonic) {
    if (RegNum > 15)
      return -1;
  
    return getReg(Cpu0::CPURegsRegClassID, RegNum);
  }
  
  int Cpu0AsmParser::tryParseRegister(StringRef Mnemonic) {
    const AsmToken &Tok = Parser.getTok();
    int RegNum = -1;
  
    if (Tok.is(AsmToken::Identifier)) {
      std::string lowerCase = Tok.getString().lower();
      RegNum = matchRegisterName(lowerCase);
    } else if (Tok.is(AsmToken::Integer))
      RegNum = matchRegisterByNumber(static_cast<unsigned>(Tok.getIntVal()),
                                     Mnemonic.lower());
      else
        return RegNum;  //error
    return RegNum;
  }
  
  bool Cpu0AsmParser::
    tryParseRegisterOperand(SmallVectorImpl<MCParsedAsmOperand*> &Operands,
                            StringRef Mnemonic){
  
    SMLoc S = Parser.getTok().getLoc();
    int RegNo = -1;
  
      RegNo = tryParseRegister(Mnemonic);
    if (RegNo == -1)
      return true;
  
    Operands.push_back(Cpu0Operand::CreateReg(RegNo, S,
        Parser.getTok().getLoc()));
    Parser.Lex(); // Eat register token.
    return false;
  }
  
  bool Cpu0AsmParser::ParseOperand(SmallVectorImpl<MCParsedAsmOperand*>&Operands,
                                   StringRef Mnemonic) {
    // Check if the current operand has a custom associated parser, if so, try to
    // custom parse the operand, or fallback to the general approach.
    OperandMatchResultTy ResTy = MatchOperandParserImpl(Operands, Mnemonic);
    if (ResTy == MatchOperand_Success)
      return false;
    // If there wasn't a custom match, try the generic matcher below. Otherwise,
    // there was a match, but an error occurred, in which case, just return that
    // the operand parsing failed.
    if (ResTy == MatchOperand_ParseFail)
      return true;
  
    switch (getLexer().getKind()) {
    default:
      Error(Parser.getTok().getLoc(), "unexpected token in operand");
      return true;
    case AsmToken::Dollar: {
      // parse register
      SMLoc S = Parser.getTok().getLoc();
      Parser.Lex(); // Eat dollar token.
      // parse register operand
      if (!tryParseRegisterOperand(Operands, Mnemonic)) {
        if (getLexer().is(AsmToken::LParen)) {
          // check if it is indexed addressing operand
          Operands.push_back(Cpu0Operand::CreateToken("(", S));
          Parser.Lex(); // eat parenthesis
          if (getLexer().isNot(AsmToken::Dollar))
            return true;
  
          Parser.Lex(); // eat dollar
          if (tryParseRegisterOperand(Operands, Mnemonic))
            return true;
  
          if (!getLexer().is(AsmToken::RParen))
            return true;
  
          S = Parser.getTok().getLoc();
          Operands.push_back(Cpu0Operand::CreateToken(")", S));
          Parser.Lex();
        }
        return false;
      }
      // maybe it is a symbol reference
      StringRef Identifier;
      if (Parser.ParseIdentifier(Identifier))
        return true;
  
      SMLoc E = SMLoc::getFromPointer(Parser.getTok().getLoc().getPointer() - 1);
  
      MCSymbol *Sym = getContext().GetOrCreateSymbol("$" + Identifier);
  
      // Otherwise create a symbol ref.
      const MCExpr *Res = MCSymbolRefExpr::Create(Sym, MCSymbolRefExpr::VK_None,
                                                  getContext());
  
      Operands.push_back(Cpu0Operand::CreateImm(Res, S, E));
      return false;
    }
    case AsmToken::Identifier:
    case AsmToken::LParen:
    case AsmToken::Minus:
    case AsmToken::Plus:
    case AsmToken::Integer:
    case AsmToken::String: {
       // quoted label names
      const MCExpr *IdVal;
      SMLoc S = Parser.getTok().getLoc();
      if (getParser().ParseExpression(IdVal))
        return true;
      SMLoc E = SMLoc::getFromPointer(Parser.getTok().getLoc().getPointer() - 1);
      Operands.push_back(Cpu0Operand::CreateImm(IdVal, S, E));
      return false;
    }
    case AsmToken::Percent: {
      // it is a symbol reference or constant expression
      const MCExpr *IdVal;
      SMLoc S = Parser.getTok().getLoc(); // start location of the operand
      if (parseRelocOperand(IdVal))
        return true;
  
      SMLoc E = SMLoc::getFromPointer(Parser.getTok().getLoc().getPointer() - 1);
  
      Operands.push_back(Cpu0Operand::CreateImm(IdVal, S, E));
      return false;
    } // case AsmToken::Percent
    } // switch(getLexer().getKind())
    return true;
  }
  
  bool Cpu0AsmParser::parseRelocOperand(const MCExpr *&Res) {
  
    Parser.Lex(); // eat % token
    const AsmToken &Tok = Parser.getTok(); // get next token, operation
    if (Tok.isNot(AsmToken::Identifier))
      return true;
  
    std::string Str = Tok.getIdentifier().str();
  
    Parser.Lex(); // eat identifier
    // now make expression from the rest of the operand
    const MCExpr *IdVal;
    SMLoc EndLoc;
  
    if (getLexer().getKind() == AsmToken::LParen) {
      while (1) {
        Parser.Lex(); // eat '(' token
        if (getLexer().getKind() == AsmToken::Percent) {
          Parser.Lex(); // eat % token
          const AsmToken &nextTok = Parser.getTok();
          if (nextTok.isNot(AsmToken::Identifier))
            return true;
          Str += "(%";
          Str += nextTok.getIdentifier();
          Parser.Lex(); // eat identifier
          if (getLexer().getKind() != AsmToken::LParen)
            return true;
        } else
          break;
      }
      if (getParser().ParseParenExpression(IdVal,EndLoc))
        return true;
  
      while (getLexer().getKind() == AsmToken::RParen)
        Parser.Lex(); // eat ')' token
  
    } else
      return true; // parenthesis must follow reloc operand
  
    // Check the type of the expression
    if (const MCConstantExpr *MCE = dyn_cast<MCConstantExpr>(IdVal)) {
      // it's a constant, evaluate lo or hi value
      int Val = MCE->getValue();
      if (Str == "lo") {
        Val = Val & 0xffff;
      } else if (Str == "hi") {
        Val = (Val & 0xffff0000) >> 16;
      }
      Res = MCConstantExpr::Create(Val, getContext());
      return false;
    }
  
    if (const MCSymbolRefExpr *MSRE = dyn_cast<MCSymbolRefExpr>(IdVal)) {
      // it's a symbol, create symbolic expression from symbol
      StringRef Symbol = MSRE->getSymbol().getName();
      MCSymbolRefExpr::VariantKind VK = getVariantKind(Str);
      Res = MCSymbolRefExpr::Create(Symbol,VK,getContext());
      return false;
    }
    return true;
  }
  
  bool Cpu0AsmParser::ParseRegister(unsigned &RegNo, SMLoc &StartLoc,
                                    SMLoc &EndLoc) {
  
    StartLoc = Parser.getTok().getLoc();
    RegNo = tryParseRegister("");
    EndLoc = Parser.getTok().getLoc();
    return (RegNo == (unsigned)-1);
  }
  
  bool Cpu0AsmParser::parseMemOffset(const MCExpr *&Res) {
  
    SMLoc S;
  
    switch(getLexer().getKind()) {
    default:
      return true;
    case AsmToken::Integer:
    case AsmToken::Minus:
    case AsmToken::Plus:
      return (getParser().ParseExpression(Res));
    case AsmToken::Percent:
      return parseRelocOperand(Res);
    case AsmToken::LParen:
      return false;  // it's probably assuming 0
    }
    return true;
  }
  
  // eg, 12($sp) or 12(la)
  Cpu0AsmParser::OperandMatchResultTy Cpu0AsmParser::parseMemOperand(
                 SmallVectorImpl<MCParsedAsmOperand*>&Operands) {
  
    const MCExpr *IdVal = 0;
    SMLoc S;
    // first operand is the offset
    S = Parser.getTok().getLoc();
  
    if (parseMemOffset(IdVal))
      return MatchOperand_ParseFail;
  
    const AsmToken &Tok = Parser.getTok(); // get next token
    if (Tok.isNot(AsmToken::LParen)) {
      Cpu0Operand *Mnemonic = static_cast<Cpu0Operand*>(Operands[0]);
      if (Mnemonic->getToken() == "la") {
        SMLoc E = SMLoc::getFromPointer(Parser.getTok().getLoc().getPointer()-1);
        Operands.push_back(Cpu0Operand::CreateImm(IdVal, S, E));
        return MatchOperand_Success;
      }
      Error(Parser.getTok().getLoc(), "'(' expected");
      return MatchOperand_ParseFail;
    }
  
    Parser.Lex(); // Eat '(' token.
  
    const AsmToken &Tok1 = Parser.getTok(); // get next token
    if (Tok1.is(AsmToken::Dollar)) {
      Parser.Lex(); // Eat '$' token.
      if (tryParseRegisterOperand(Operands,"")) {
        Error(Parser.getTok().getLoc(), "unexpected token in operand");
        return MatchOperand_ParseFail;
      }
  
    } else {
      Error(Parser.getTok().getLoc(), "unexpected token in operand");
      return MatchOperand_ParseFail;
    }
  
    const AsmToken &Tok2 = Parser.getTok(); // get next token
    if (Tok2.isNot(AsmToken::RParen)) {
      Error(Parser.getTok().getLoc(), "')' expected");
      return MatchOperand_ParseFail;
    }
  
    SMLoc E = SMLoc::getFromPointer(Parser.getTok().getLoc().getPointer() - 1);
  
    Parser.Lex(); // Eat ')' token.
  
    if (IdVal == 0)
      IdVal = MCConstantExpr::Create(0, getContext());
  
    // now replace register operand with the mem operand
    Cpu0Operand* op = static_cast<Cpu0Operand*>(Operands.back());
    int RegNo = op->getReg();
    // remove register from operands
    Operands.pop_back();
    // and add memory operand
    Operands.push_back(Cpu0Operand::CreateMem(RegNo, IdVal, S, E));
    delete op;
    return MatchOperand_Success;
  }
  
  MCSymbolRefExpr::VariantKind Cpu0AsmParser::getVariantKind(StringRef Symbol) {
  
    MCSymbolRefExpr::VariantKind VK
                     = StringSwitch<MCSymbolRefExpr::VariantKind>(Symbol)
      .Case("hi",          MCSymbolRefExpr::VK_Cpu0_ABS_HI)
      .Case("lo",          MCSymbolRefExpr::VK_Cpu0_ABS_LO)
      .Case("gp_rel",      MCSymbolRefExpr::VK_Cpu0_GPREL)
      .Case("call24",      MCSymbolRefExpr::VK_Cpu0_GOT_CALL)
      .Case("got",         MCSymbolRefExpr::VK_Cpu0_GOT)
      .Case("tlsgd",       MCSymbolRefExpr::VK_Cpu0_TLSGD)
      .Case("tlsldm",      MCSymbolRefExpr::VK_Cpu0_TLSLDM)
      .Case("dtprel_hi",   MCSymbolRefExpr::VK_Cpu0_DTPREL_HI)
      .Case("dtprel_lo",   MCSymbolRefExpr::VK_Cpu0_DTPREL_LO)
      .Case("gottprel",    MCSymbolRefExpr::VK_Cpu0_GOTTPREL)
      .Case("tprel_hi",    MCSymbolRefExpr::VK_Cpu0_TPREL_HI)
      .Case("tprel_lo",    MCSymbolRefExpr::VK_Cpu0_TPREL_LO)
      .Case("got_disp",    MCSymbolRefExpr::VK_Cpu0_GOT_DISP)
      .Case("got_page",    MCSymbolRefExpr::VK_Cpu0_GOT_PAGE)
      .Case("got_ofst",    MCSymbolRefExpr::VK_Cpu0_GOT_OFST)
      .Case("hi(%neg(%gp_rel",    MCSymbolRefExpr::VK_Cpu0_GPOFF_HI)
      .Case("lo(%neg(%gp_rel",    MCSymbolRefExpr::VK_Cpu0_GPOFF_LO)
      .Default(MCSymbolRefExpr::VK_None);
  
    return VK;
  }
  
  bool Cpu0AsmParser::
  parseMathOperation(StringRef Name, SMLoc NameLoc,
                     SmallVectorImpl<MCParsedAsmOperand*> &Operands) {
    // split the format
    size_t Start = Name.find('.'), Next = Name.rfind('.');
    StringRef Format1 = Name.slice(Start, Next);
    // and add the first format to the operands
    Operands.push_back(Cpu0Operand::CreateToken(Format1, NameLoc));
    // now for the second format
    StringRef Format2 = Name.slice(Next, StringRef::npos);
    Operands.push_back(Cpu0Operand::CreateToken(Format2, NameLoc));
  
    // set the format for the first register
  //  setFpFormat(Format1);
  
    // Read the remaining operands.
    if (getLexer().isNot(AsmToken::EndOfStatement)) {
      // Read the first operand.
      if (ParseOperand(Operands, Name)) {
        SMLoc Loc = getLexer().getLoc();
        Parser.EatToEndOfStatement();
        return Error(Loc, "unexpected token in argument list");
      }
  
      if (getLexer().isNot(AsmToken::Comma)) {
        SMLoc Loc = getLexer().getLoc();
        Parser.EatToEndOfStatement();
        return Error(Loc, "unexpected token in argument list");
  
      }
      Parser.Lex();  // Eat the comma.
  
      // Parse and remember the operand.
      if (ParseOperand(Operands, Name)) {
        SMLoc Loc = getLexer().getLoc();
        Parser.EatToEndOfStatement();
        return Error(Loc, "unexpected token in argument list");
      }
    }
  
    if (getLexer().isNot(AsmToken::EndOfStatement)) {
      SMLoc Loc = getLexer().getLoc();
      Parser.EatToEndOfStatement();
      return Error(Loc, "unexpected token in argument list");
    }
  
    Parser.Lex(); // Consume the EndOfStatement
    return false;
  }
  
  bool Cpu0AsmParser::
  ParseInstruction(ParseInstructionInfo &Info, StringRef Name, SMLoc NameLoc,
                   SmallVectorImpl<MCParsedAsmOperand*> &Operands) {
  
    // Create the leading tokens for the mnemonic, split by '.' characters.
    size_t Start = 0, Next = Name.find('.');
    StringRef Mnemonic = Name.slice(Start, Next);
  
    Operands.push_back(Cpu0Operand::CreateToken(Mnemonic, NameLoc));
  
    // Read the remaining operands.
    if (getLexer().isNot(AsmToken::EndOfStatement)) {
      // Read the first operand.
      if (ParseOperand(Operands, Name)) {
        SMLoc Loc = getLexer().getLoc();
        Parser.EatToEndOfStatement();
        return Error(Loc, "unexpected token in argument list");
      }
  
      while (getLexer().is(AsmToken::Comma) ) {
        Parser.Lex();  // Eat the comma.
  
        // Parse and remember the operand.
        if (ParseOperand(Operands, Name)) {
          SMLoc Loc = getLexer().getLoc();
          Parser.EatToEndOfStatement();
          return Error(Loc, "unexpected token in argument list");
        }
      }
    }
  
    if (getLexer().isNot(AsmToken::EndOfStatement)) {
      SMLoc Loc = getLexer().getLoc();
      Parser.EatToEndOfStatement();
      return Error(Loc, "unexpected token in argument list");
    }
  
    Parser.Lex(); // Consume the EndOfStatement
    return false;
  }
  
  bool Cpu0AsmParser::reportParseError(StringRef ErrorMsg) {
     SMLoc Loc = getLexer().getLoc();
     Parser.EatToEndOfStatement();
     return Error(Loc, ErrorMsg);
  }
  
  bool Cpu0AsmParser::parseSetReorderDirective() {
    Parser.Lex();
    // if this is not the end of the statement, report error
    if (getLexer().isNot(AsmToken::EndOfStatement)) {
      reportParseError("unexpected token in statement");
      return false;
    }
    Options.setReorder();
    Parser.Lex(); // Consume the EndOfStatement
    return false;
  }
  
  bool Cpu0AsmParser::parseSetNoReorderDirective() {
      Parser.Lex();
      // if this is not the end of the statement, report error
      if (getLexer().isNot(AsmToken::EndOfStatement)) {
        reportParseError("unexpected token in statement");
        return false;
      }
      Options.setNoreorder();
      Parser.Lex(); // Consume the EndOfStatement
      return false;
  }
  
  bool Cpu0AsmParser::parseSetMacroDirective() {
    Parser.Lex();
    // if this is not the end of the statement, report error
    if (getLexer().isNot(AsmToken::EndOfStatement)) {
      reportParseError("unexpected token in statement");
      return false;
    }
    Options.setMacro();
    Parser.Lex(); // Consume the EndOfStatement
    return false;
  }
  
  bool Cpu0AsmParser::parseSetNoMacroDirective() {
    Parser.Lex();
    // if this is not the end of the statement, report error
    if (getLexer().isNot(AsmToken::EndOfStatement)) {
      reportParseError("`noreorder' must be set before `nomacro'");
      return false;
    }
    if (Options.isReorder()) {
      reportParseError("`noreorder' must be set before `nomacro'");
      return false;
    }
    Options.setNomacro();
    Parser.Lex(); // Consume the EndOfStatement
    return false;
  }
  bool Cpu0AsmParser::parseDirectiveSet() {
  
    // get next token
    const AsmToken &Tok = Parser.getTok();
  
    if (Tok.getString() == "reorder") {
      return parseSetReorderDirective();
    } else if (Tok.getString() == "noreorder") {
      return parseSetNoReorderDirective();
    } else if (Tok.getString() == "macro") {
      return parseSetMacroDirective();
    } else if (Tok.getString() == "nomacro") {
      return parseSetNoMacroDirective();
    }
    return true;
  }
  
  bool Cpu0AsmParser::ParseDirective(AsmToken DirectiveID) {
  
    if (DirectiveID.getString() == ".ent") {
      // ignore this directive for now
      Parser.Lex();
      return false;
    }
  
    if (DirectiveID.getString() == ".end") {
      // ignore this directive for now
      Parser.Lex();
      return false;
    }
  
    if (DirectiveID.getString() == ".frame") {
      // ignore this directive for now
      Parser.EatToEndOfStatement();
      return false;
    }
  
    if (DirectiveID.getString() == ".set") {
      return parseDirectiveSet();
    }
  
    if (DirectiveID.getString() == ".fmask") {
      // ignore this directive for now
      Parser.EatToEndOfStatement();
      return false;
    }
  
    if (DirectiveID.getString() == ".mask") {
      // ignore this directive for now
      Parser.EatToEndOfStatement();
      return false;
    }
  
    if (DirectiveID.getString() == ".gpword") {
      // ignore this directive for now
      Parser.EatToEndOfStatement();
      return false;
    }
  
    return true;
  }
  
  extern "C" void LLVMInitializeCpu0AsmParser() {
    RegisterMCAsmParser<Cpu0AsmParser> X(TheCpu0Target);
    RegisterMCAsmParser<Cpu0AsmParser> Y(TheCpu0elTarget);
  }
  
  #define GET_REGISTER_MATCHER
  #define GET_MATCHER_IMPLEMENTATION
  #include "Cpu0GenAsmMatcher.inc"
  

  // AsmParser/CMakeLists.txt
  include_directories( ${CMAKE_CURRENT_BINARY_DIR}/.. ${CMAKE_CURRENT_SOURCE_DIR}/.. )
  add_llvm_library(LLVMCpu0AsmParser
    Cpu0AsmParser.cpp
    )
  
  add_dependencies(LLVMCpu0AsmParser Cpu0CommonTableGen)
  
  // AsmParser/LLVMBuild.txt
  ;===- ./lib/Target/Mips/AsmParser/LLVMBuild.txt ----------------*- Conf -*--===;
  ;
  ;                     The LLVM Compiler Infrastructure
  ;
  ; This file is distributed under the University of Illinois Open Source
  ; License. See LICENSE.TXT for details.
  ;
  ;===------------------------------------------------------------------------===;
  ;
  ; This is an LLVMBuild description file for the components in this subdirectory.
  ;
  ; For more information on the LLVMBuild system, please see:
  ;
  ;   http://llvm.org/docs/LLVMBuild.html
  ;
  ;===------------------------------------------------------------------------===;
  
  [component_0]
  type = Library
  name = Cpu0AsmParser
  parent = Mips
  required_libraries = MC MCParser Support MipsDesc MipsInfo
  add_to_library_groups = Cpu0

The Cpu0AsmParser.cpp contains one thousand of code which do the assembly 
language parsing. You can understand it with a little patient only.
To let directory AsmParser be built, modify CMakeLists.txt and LLVMBuild.txt as 
follows,

.. code-block:: c++

  // CMakeLists.txt
  ...
  tablegen(LLVM Cpu0GenAsmMatcher.inc -gen-asm-matcher)
  ...
  add_subdirectory(AsmParser)
  
  // LLVMBuild.txt
  ...
  subdirectories = AsmParser ...
  ...
  has_asmparser = 1
  
  
The other files change as follows,

.. code-block:: c++

  // MCTargetDesc/Cpu0MCCodeEmitter.cpp
  unsigned Cpu0MCCodeEmitter::
  getBranchTargetOpValue(const MCInst &MI, unsigned OpNo,
               SmallVectorImpl<MCFixup> &Fixups) const {
    ...
    // If the destination is an immediate, we have nothing to do.
    if (MO.isImm()) return MO.getImm();
    ...
  }
  
  /// getJumpAbsoluteTargetOpValue - Return binary encoding of the jump
  /// target operand. Such as SWI.
  unsigned Cpu0MCCodeEmitter::
  getJumpAbsoluteTargetOpValue(const MCInst &MI, unsigned OpNo,
             SmallVectorImpl<MCFixup> &Fixups) const {
    ...
    // If the destination is an immediate, we have nothing to do.
    if (MO.isImm()) return MO.getImm();
    ...
  }
  
  // Cpu0.td
  def Cpu0AsmParser : AsmParser {
    let ShouldEmitMatchRegisterName = 0;
  }
  
  def Cpu0AsmParserVariant : AsmParserVariant {
    int Variant = 0;
  
    // Recognize hard coded registers.
    string RegisterPrefix = "$";
  }
  
  def Cpu0 : Target {
    let AssemblyParsers = [Cpu0AsmParser];
    let AssemblyParserVariants = [Cpu0AsmParserVariant];
  }
  
  // Cpu0InstrFormats.td
  // Pseudo-instructions for alternate assembly syntax (never used by codegen).
  // These are aliases that require C++ handling to convert to the target
  // instruction, while InstAliases can be handled directly by tblgen.
  class Cpu0AsmPseudoInst<dag outs, dag ins, string asmstr>:
    Cpu0Inst<outs, ins, asmstr, [], IIPseudo, Pseudo> {
    let isPseudo = 1;
    let Pattern = [];
  }
  
  // Cpu0InstrInfo.td
  def Cpu0MemAsmOperand : AsmOperandClass {
    let Name = "Mem";
    let ParserMethod = "parseMemOperand";
  }
  
  // Address operand
  def mem : Operand<i32> {
    ...
    let ParserMatchClass = Cpu0MemAsmOperand;
  }
  ...
  class CmpInstr<...
     !strconcat(instr_asm, "\t$rc, $ra, $rb"), [], itin> {
    ...
  }
  ...
  class CBranch<...
         !strconcat(instr_asm, "\t$ra, $addr"), ...> {
    ...
  }
  ...
  //===----------------------------------------------------------------------===//
  // Pseudo Instruction definition
  //===----------------------------------------------------------------------===//
  
  class LoadImm32< string instr_asm, Operand Od, RegisterClass RC> :
    Cpu0AsmPseudoInst<(outs RC:$ra), (ins Od:$imm32),
             !strconcat(instr_asm, "\t$ra, $imm32")> ;
  def LoadImm32Reg : LoadImm32<"li", shamt, CPURegs>;
  
  class LoadAddress<string instr_asm, Operand MemOpnd, RegisterClass RC> :
    Cpu0AsmPseudoInst<(outs RC:$ra), (ins MemOpnd:$addr),
             !strconcat(instr_asm, "\t$ra, $addr")> ;
  def LoadAddr32Reg : LoadAddress<"la", mem, CPURegs>;
  
  class LoadAddressImm<string instr_asm, Operand Od, RegisterClass RC> :
    Cpu0AsmPseudoInst<(outs RC:$ra), (ins Od:$imm32),
             !strconcat(instr_asm, "\t$ra, $imm32")> ;
  def LoadAddr32Imm : LoadAddressImm<"la", shamt, CPURegs>;


We define the **ParserMethod = "parseMemOperand"** and implement the 
parseMemOperand() in Cpu0AsmParser.cpp to handle the **"mem"** operand which 
used in ld and st. For example, ld $2, 4($sp), the **mem** operand is 4($sp). 
Accompany with **"let ParserMatchClass = Cpu0MemAsmOperand;"**, 
LLVM will call parseMemOperand() of Cpu0AsmParser.cpp when it meets the assembly 
**mem** operand 4($sp). With above **"let"** assignment, TableGen will generate 
the following structure and functions in Cpu0GenAsmMatcher.inc.

.. code-block:: c++
  
    enum OperandMatchResultTy {
      MatchOperand_Success,    // operand matched successfully
      MatchOperand_NoMatch,    // operand did not match
      MatchOperand_ParseFail   // operand matched but had errors
    };
    OperandMatchResultTy MatchOperandParserImpl(
      SmallVectorImpl<MCParsedAsmOperand*> &Operands,
      StringRef Mnemonic);
    OperandMatchResultTy tryCustomParseOperand(
      SmallVectorImpl<MCParsedAsmOperand*> &Operands,
      unsigned MCK);
  
  Cpu0AsmParser::OperandMatchResultTy Cpu0AsmParser::
  tryCustomParseOperand(SmallVectorImpl<MCParsedAsmOperand*> &Operands,
              unsigned MCK) {
  
    switch(MCK) {
    case MCK_Mem:
      return parseMemOperand(Operands);
    default:
      return MatchOperand_NoMatch;
    }
    return MatchOperand_NoMatch;
  }
  
  Cpu0AsmParser::OperandMatchResultTy Cpu0AsmParser::
  MatchOperandParserImpl(SmallVectorImpl<MCParsedAsmOperand*> &Operands,
               StringRef Mnemonic) {
    ...
  }
  
  /// MatchClassKind - The kinds of classes which participate in
  /// instruction matching.
  enum MatchClassKind {
    ...
    MCK_Mem, // user defined class 'Cpu0MemAsmOperand'
    ...
  };


Above 3 Pseudo Instruction definitions in Cpu0InstrInfo.td such as 
LoadImm32Reg are handled by Cpu0AsmParser.cpp as follows,

.. code-block:: c++
  
  bool Cpu0AsmParser::needsExpansion(MCInst &Inst) {
  
    switch(Inst.getOpcode()) {
    case Cpu0::LoadImm32Reg:
    case Cpu0::LoadAddr32Imm:
    case Cpu0::LoadAddr32Reg:
      return true;
    default:
      return false;
    }
  }
  
  void Cpu0AsmParser::expandInstruction(MCInst &Inst, SMLoc IDLoc,
              SmallVectorImpl<MCInst> &Instructions){
    switch(Inst.getOpcode()) {
    case Cpu0::LoadImm32Reg:
      return expandLoadImm(Inst, IDLoc, Instructions);
    case Cpu0::LoadAddr32Imm:
      return expandLoadAddressImm(Inst,IDLoc,Instructions);
    case Cpu0::LoadAddr32Reg:
      return expandLoadAddressReg(Inst,IDLoc,Instructions);
    }
  }
  
  bool Cpu0AsmParser::
  MatchAndEmitInstruction(SMLoc IDLoc, unsigned &Opcode,
              SmallVectorImpl<MCParsedAsmOperand*> &Operands,
              MCStreamer &Out, unsigned &ErrorInfo,
              bool MatchingInlineAsm) {
    MCInst Inst;
    unsigned MatchResult = MatchInstructionImpl(Operands, Inst, ErrorInfo,
                          MatchingInlineAsm);
  
    switch (MatchResult) {
    default: break;
    case Match_Success: {
    if (needsExpansion(Inst)) {
      SmallVector<MCInst, 4> Instructions;
      expandInstruction(Inst, IDLoc, Instructions);
    ...
    ...
  }


Finally, we change registers name to lower case as below since the assembly 
output and ``llvm-objdump -d`` using lower case. The CPURegs as below must 
follow the order of register number because AsmParser use this when do register 
number encode.

.. code-block:: c++

  // Cpu0Register.cpp
  // The register string, such as "9" or "gp will show on "llvm-objdump -d"
  let Namespace = "Cpu0" in {
    // General Purpose Registers
    def ZERO : Cpu0GPRReg< 0, "zero">, DwarfRegNum<[0]>;
    def AT   : Cpu0GPRReg< 1, "at">,   DwarfRegNum<[1]>;
    def V0   : Cpu0GPRReg< 2, "2">,    DwarfRegNum<[2]>;
    def V1   : Cpu0GPRReg< 3, "3">,    DwarfRegNum<[3]>;
    def A0   : Cpu0GPRReg< 4, "4">,    DwarfRegNum<[6]>;
    def A1   : Cpu0GPRReg< 5, "5">,    DwarfRegNum<[7]>;
    def T9   : Cpu0GPRReg< 6, "6">,    DwarfRegNum<[6]>;
    def S0   : Cpu0GPRReg< 7, "7">,    DwarfRegNum<[7]>;
    def S1   : Cpu0GPRReg< 8, "8">,    DwarfRegNum<[8]>;
    def S2   : Cpu0GPRReg< 9, "9">,    DwarfRegNum<[9]>;
    def GP   : Cpu0GPRReg< 10, "gp">,  DwarfRegNum<[10]>;
    def FP   : Cpu0GPRReg< 11, "fp">,  DwarfRegNum<[11]>;
    def SW   : Cpu0GPRReg< 12, "sw">,   DwarfRegNum<[12]>;
    def SP   : Cpu0GPRReg< 13, "sp">,   DwarfRegNum<[13]>;
    def LR   : Cpu0GPRReg< 14, "lr">,   DwarfRegNum<[14]>;
    def PC   : Cpu0GPRReg< 15, "pc">,   DwarfRegNum<[15]>;
  //  def MAR  : Register< 16, "mar">,  DwarfRegNum<[16]>;
  //  def MDR  : Register< 17, "mdr">,  DwarfRegNum<[17]>;
  
    // Hi/Lo registers
    def HI   : Register<"hi">, DwarfRegNum<[18]>;
    def LO   : Register<"lo">, DwarfRegNum<[19]>;
  }
  
  //===----------------------------------------------------------------------===//
  // Register Classes
  //===----------------------------------------------------------------------===//
  
  def CPURegs : RegisterClass<"Cpu0", [i32], 32, (add 
    // Reserved
    ZERO, AT, 
    // Return Values and Arguments
    V0, V1, A0, A1, 
    // Not preserved across procedure calls
    T9, 
    // Callee save
    S0, S1, S2, 
    // Reserved
    GP, FP, SW, SP, LR, PC)>;

Run 10/1/Cpu0 with ch10_1.cpp to get the correct result as follows,

.. code-block:: bash

  JonathantekiiMac:InputFiles Jonathan$ /Users/Jonathan/llvm/test/cmake_debug_
  build/bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=obj ch10_1.bc -o 
  ch10_1.cpu0.o
  JonathantekiiMac:InputFiles Jonathan$ /Users/Jonathan/llvm/test/cmake_debug_
  build/bin/Debug/llvm-objdump -d ch10_1.cpu0.o
  
  ch10_1.cpu0.o:  file format ELF32-unknown
  
  Disassembly of section .text:
  .text:
       0: 00 2d 00 08                                   ld  $2, 8($sp)
       4: 01 0d 00 04                                   st  $zero, 4($sp)
       8: 09 30 00 00                                   addiu $3, $zero, 0
       c: 13 31 20 00                                   add $3, $at, $2
      10: 14 32 30 00                                   sub $3, $2, $3
      14: 15 21 30 00                                   mul $2, $at, $3
      18: 16 32 00 00                                   div $3, $2
      1c: 17 23 00 00                                   divu  $2, $3
      20: 18 21 30 00                                   and $2, $at, $3
      24: 19 31 20 00                                   or  $3, $at, $2
      28: 1a 12 30 00                                   xor $at, $2, $3
      2c: 50 43 00 00                                   mult  $4, $3
      30: 51 32 00 00                                   multu $3, $2
      34: 40 30 00 00                                   mfhi  $3
      38: 41 20 00 00                                   mflo  $2
      3c: 42 20 00 00                                   mthi  $2
      40: 43 20 00 00                                   mtlo  $2
      44: 1b 22 00 02                                   sra $2, $2, 2
      48: 1c 21 10 03                                   rol $2, $at, 3
      4c: 1d 33 10 04                                   ror $3, $3, 4
      50: 1e 22 00 02                                   shl $2, $2, 2
      54: 1f 23 00 05                                   shr $2, $3, 5
      58: 10 23 00 00                                   cmp $zero, $2, $3
      5c: 20 00 00 14                                   jeq $zero, 20
      60: 21 00 00 10                                   jne $zero, 16
      64: 22 ff ff ec                                   jlt $zero, -20
      68: 24 ff ff f0                                   jle $zero, -16
      6c: 23 ff ff fc                                   jgt $zero, -4
      70: 25 ff ff f4                                   jge $zero, -12
      74: 2a 00 04 00                                   swi 1024
      78: 2b 01 00 00                                   jsub  65536
      7c: 2c e0 00 00                                   ret $lr
      80: 2d e6 00 00                                   jalr  $6
      84: 09 30 00 70                                   addiu $3, $zero, 112
      88: 1e 33 00 10                                   shl $3, $3, 16
      8c: 09 10 00 00                                   addiu $at, $zero, 0
      90: 19 33 10 00                                   or  $3, $3, $at
      94: 09 30 00 80                                   addiu $3, $zero, 128
      98: 1e 36 00 10                                   shl $3, $6, 16
      9c: 09 10 00 00                                   addiu $at, $zero, 0
      a0: 19 36 10 00                                   or  $3, $6, $at
      a4: 13 33 60 00                                   add $3, $3, $6
      a8: 09 30 00 90                                   addiu $3, $zero, 144
      ac: 1e 33 00 10                                   shl $3, $3, 16
      b0: 09 10 00 00                                   addiu $at, $zero, 0
      b4: 19 33 10 00                                   or  $3, $3, $at


We replace cmp and jeg with explicit $sw in assembly and $zero in disassembly for 
AsmParser support. It's OK with just a little bad in readability and in assembly 
programing than implicit representation.


Verilog of CPU0
------------------

Verilog language is an IEEE standard in IC design. There are a lot of book and 
documents for this language. Web site [#]_ has a pdf [#]_ in this. 
Example code LLVMBackendTutorialExampleCode/cpu0s_verilog/raw/cpu0s.v is the 
cpu0 design in Verilog. In Appendix A, we have downloaded and installed Icarus 
Verilog tool both on iMac and Linux. The cpu0s.v is a simple design with only 
270 lines of code. Alough it has not the pipeline features, we can assume the 
cpu0 backend code run on the pipeline machine because the pipeline version  
use the same machine instructions. Verilog is C like language in syntex and 
this book is a compiler book, so we list the cpu0s.v as well as the building 
command directly as below. We expect 
readers can understand the Verilog code just with a little patient and no need 
further explanation. There are two type of I/O. One is memory mapped I/O, the 
other is instruction I/O. CPU0 use memory mapped I/O, we set the memory address 
0x7000 as the output port. When meet the instruction **"st $ra, cx($rb)"**, where 
cx($rb) is 0x7000 (28672), CPU0 display the content as follows,

.. code-block:: c++

        ST :
          if (R[b]+c16 == 28672)
            $display("%4dns %8x : %8x OUTPUT=%-d", $stime, pc0, ir, R[a]);

          
.. code-block:: c++

  // cpu0s.v
  // Operand width
  `define INT32 2'b11     // 32 bits
  `define INT24 2'b10     // 24 bits
  `define INT16 2'b01     // 16 bits
  `define BYTE  2'b00     // 8  bits
  
  // Reference web: http://ccckmit.wikidot.com/ocs:cpu0
  module cpu0(input clock, reset, output reg [2:0] tick, 
              output reg [31:0] ir, pc, mar, mdr, inout [31:0] dbus, 
              output reg m_en, m_rw, output reg [1:0] m_size);
    reg signed [31:0] R [0:15], HI, LO; // High and Low part of 64 bit result
    reg [7:0] op;
    reg [3:0] a, b, c;
    reg [4:0] c5;
    reg signed [31:0] c12, c16, c24, Ra, Rb, Rc, pc0; // pc0 : instruction pc
  
    // register name
    `define PC   R[15]   // Program Counter
    `define LR   R[14]   // Link Register
    `define SP   R[13]   // Stack Pointer
    `define SW   R[12]   // Status Word
    // SW Flage
    `define N    `SW[31] // Negative flag
    `define Z    `SW[30] // Zero
    `define C    `SW[29] // Carry
    `define V    `SW[28] // Overflow
    `define I    `SW[7]  // Hardware Interrupt Enable
    `define T    `SW[6]  // Software Interrupt Enable
    `define M    `SW[0]  // Mode bit
    // Instruction Opcode 
    parameter [7:0] LD=8'h00,ST=8'h01,LDB=8'h02,STB=8'h03,LDR=8'h04,STR=8'h05,
    LBR=8'h06,SBR=8'h07,LDI=8'h08,ADDiu=8'h09,CMP=8'h10,MOV=8'h12,ADD=8'h13,
    SUB=8'h14,MUL=8'h15,SDIV=8'h16,AND=8'h18,OR=8'h19,XOR=8'h1A,
    SRA=8'h1B,ROL=8'h1C,ROR=8'h1D,SHL=8'h1E,SHR=8'h1F,
    JEQ=8'h20,JNE=8'h21,JLT=8'h22,JGT=8'h23,JLE=8'h24,JGE=8'h25,JMP=8'h26,
    SWI=8'h2A,JSUB=8'h2B,RET=8'h2C,IRET=8'h2D,JALR=8'h2E,
    PUSH=8'h30,POP=8'h31,PUSHB=8'h32,POPB=8'h33,
    MFHI=8'h40,MFLO=8'h41,MTHI=8'h42,MTLO=8'h43,MULT=8'h50;
    
    reg [2:0] state, next_state;
    parameter Reset=3'h0, Fetch=3'h1, Decode=3'h2, Execute=3'h3, WriteBack=3'h4;
  
    task memReadStart(input [31:0] addr, input [1:0] size); begin // Read Memory Word
      mar = addr;     // read(m[addr])
      m_rw = 1;     // Access Mode: read 
      m_en = 1;     // Enable read
      m_size = size;
    end endtask
  
    task memReadEnd(output [31:0] data); begin // Read Memory Finish, get data
      mdr = dbus; // get momory, dbus = m[addr]
      data = mdr; // return to data
      m_en = 0; // read complete
    end endtask
  
    // Write memory -- addr: address to write, data: date to write
    task memWriteStart(input [31:0] addr, input [31:0] data, input [1:0] size); begin 
      mar = addr;    // write(m[addr], data)
      mdr = data;
      m_rw = 0;    // access mode: write
      m_en = 1;     // Enable write
      m_size  = size;
    end endtask
  
    task memWriteEnd; begin // Write Memory Finish
      m_en = 0; // write complete
    end endtask
  
    task regSet(input [3:0] i, input [31:0] data); begin
      if (i!=0) R[i] = data;
    end endtask
  
    task regHILOSet(input [31:0] data1, input [31:0] data2); begin
      HI = data1;
      LO = data2;
    end endtask
  
    always @(posedge clock or posedge reset) begin
      if (reset) state <= Reset; 
      else state <= next_state;
    end
    
    always @(state or reset) begin
      m_en = 0;
      case (state)    
      Reset: begin 
        `PC = 0; tick = 0; R[0] = 0; `SW = 0; `LR = -1; 
        next_state = reset?Reset:Fetch;
      end
      Fetch: begin  // Tick 1 : instruction fetch, throw PC to address bus, 
                    // memory.read(m[PC])
        memReadStart(`PC, `INT32);
        pc0  = `PC;
        `PC = `PC+4;
        next_state = Decode;
      end
      Decode: begin  // Tick 2 : instruction decode, ir = m[PC]
        memReadEnd(ir); // IR = dbus = m[PC]
        {op,a,b,c} = ir[31:12];
        c24 = $signed(ir[23:0]);
        c16 = $signed(ir[15:0]);
        c12 = $signed(ir[11:0]);
        c5  = ir[4:0];
        Ra = R[a];
        Rb = R[b];
        Rc = R[c];
        next_state = Execute;
      end
      Execute: begin // Tick 3 : instruction execution
        case (op)
        // load and store instructions
        LD:  memReadStart(Rb+c16, `INT32);      // LD Ra,[Rb+Cx]; Ra<=[Rb+Cx]
        ST:  memWriteStart(Rb+c16, Ra, `INT32); // ST Ra,[Rb+Cx]; Ra=>[Rb+Cx]
        LDB: memReadStart(Rb+c16, `BYTE);     // LDB Ra,[Rb+Cx]; Ra<=(byte)[Rb+Cx]
        STB: memWriteStart(Rb+c16, Ra, `BYTE);// STB Ra,[Rb+Cx]; Ra=>(byte)[Rb+Cx]
        LDR: memReadStart(Rb+Rc, `INT32);       // LDR Ra, [Rb+Rc]; Ra<=[Rb+ Rc]
        STR: memWriteStart(Rb+Rc, Ra, `INT32);  // STR Ra, [Rb+Rc]; Ra=>[Rb+ Rc]
        LBR: memReadStart(Rb+Rc, `BYTE);      // LBR Ra,[Rb+Rc]; Ra<=(byte)[Rb+Rc]
        SBR: memWriteStart(Rb+Rc, Ra, `BYTE); // SBR Ra,[Rb+Rc]; Ra=>(byte)[Rb+Rc]
        LDI: R[a] = c16;                   // LDI Ra,Cx; Ra<=Cx
        // Mathematic 
        ADDiu: R[a] = Rb+c16;                   // ADDiu Ra, Rb+Cx; Ra<=Rb+Cx
        CMP: begin `N=(Ra-Rb<0);`Z=(Ra-Rb==0); end // CMP Ra, Rb; SW=(Ra >=< Rb)
        MOV: regSet(a, Rb);                  // MOV Ra,Rb; Ra<=Rb 
        ADD: regSet(a, Rb+Rc);               // ADD Ra,Rb,Rc; Ra<=Rb+Rc
        SUB: regSet(a, Rb-Rc);               // SUB Ra,Rb,Rc; Ra<=Rb-Rc
        MUL: regSet(a, Rb*Rc);               // MUL Ra,Rb,Rc;     Ra<=Rb*Rc
        SDIV: regHILOSet(Ra%Rb, Ra/Rb);          // SDIV Ra,Rb; HI<=Ra%Rb; LO<=Ra/Rb
                                             // with exception overflow
        AND: regSet(a, Rb&Rc);               // AND Ra,Rb,Rc; Ra<=(Rb and Rc)
        OR:  regSet(a, Rb|Rc);               // OR Ra,Rb,Rc; Ra<=(Rb or Rc)
        XOR: regSet(a, Rb^Rc);               // XOR Ra,Rb,Rc; Ra<=(Rb xor Rc)
        SHL: regSet(a, Rb<<c5);     // Shift Left; SHL Ra,Rb,Cx; Ra<=(Rb << Cx)
        SRA: regSet(a, (Rb&'h80000000)|(Rb>>c5)); 
                                    // Shift Right with signed bit fill;
                                    // SHR Ra,Rb,Cx; Ra<=(Rb&0x80000000)|(Rb>>Cx)
        SHR: regSet(a, Rb>>c5);     // Shift Right with 0 fill; 
                                    // SHR Ra,Rb,Cx; Ra<=(Rb >> Cx)
        // Jump Instructions
        JEQ: if (`Z) `PC=`PC+c24;            // JEQ Cx; if SW(=) PC  PC+Cx
        JNE: if (!`Z) `PC=`PC+c24;           // JNE Cx; if SW(!=) PC PC+Cx
        JLT: if (`N)`PC=`PC+c24;             // JLT Cx; if SW(<) PC  PC+Cx
        JGT: if (!`N&&!`Z) `PC=`PC+c24;      // JGT Cx; if SW(>) PC  PC+Cx
        JLE: if (`N || `Z) `PC=`PC+c24;      // JLE Cx; if SW(<=) PC PC+Cx    
        JGE: if (!`N || `Z) `PC=`PC+c24;     // JGE Cx; if SW(>=) PC PC+Cx
        JMP: `PC = `PC+c24;                  // JMP Cx; PC <= PC+Cx
        SWI: begin 
          `LR=`PC;`PC= c24; `I = 1'b1; 
        end // Software Interrupt; SWI Cx; LR <= PC; PC <= Cx; INT<=1
        JSUB:begin `LR=`PC;`PC=`PC + c24; end // JSUB Cx; LR<=PC; PC<=PC+Cx
        JALR:begin `LR=`PC;`PC=Ra; end // JALR Ra,Rb; Ra<=PC; PC<=Rb
        RET: begin `PC=`LR; end               // RET; PC <= LR
        IRET:begin 
          `PC=`LR;`I = 1'b0; 
        end // Interrupt Return; IRET; PC <= LR; INT<=0
        // 
        PUSH:begin 
          `SP = `SP-4; memWriteStart(`SP, Ra, `INT32); 
        end // PUSH Ra; SP-=4; [SP]<=Ra;
        POP: begin 
          memReadStart(`SP, `INT32); `SP = `SP + 4; 
        end // POP Ra; Ra=[SP]; SP+=4;
        PUSHB:begin 
          `SP = `SP-1; memWriteStart(`SP, Ra, `BYTE); 
        end // Push byte; PUSHB Ra; SP--; [SP]<=Ra;(byte)
        POPB:begin 
          memReadStart(`SP, `BYTE); `SP = `SP+1; 
        end // Pop byte; POPB Ra; Ra<=[SP]; SP++;(byte)
        MULT: {HI, LO}=Ra*Rb; // MULT Ra,Rb; HI<=((Ra*Rb)>>32); 
                              // LO<=((Ra*Rb) and 0x00000000ffffffff);
                              // with exception overflow
        MFLO: regSet(a, LO);            // MFLO Ra; Ra<=LO
        MFHI: regSet(a, HI);            // MFHI Ra; Ra<=HI
        MTLO: LO = Ra;             // MTLO Ra; LO<=Ra
        MTHI: HI = Ra;             // MTHI Ra; HI<=Ra
        endcase
        next_state = WriteBack;
      end
      WriteBack: begin // Read/Write finish, close memory
        case (op)
          LD, LDB, LDR, LBR, POP, POPB  : memReadEnd(R[a]); 
                                            //read memory complete
          ST, STB, STR, SBR, PUSH, PUSHB: memWriteEnd(); 
                                            // write memory complete
        endcase
        case (op)
        MULT, SDIV, MTHI, MTLO :
          $display("%4dns %8x : %8x HI=%8x LO=%8x SW=%8x", $stime, pc0, ir, HI, 
          LO, `SW);
        ST :
          if (R[b]+c16 == 28672)
            $display("%4dns %8x : %8x OUTPUT=%-d", $stime, pc0, ir, R[a]);
       /* ST :
          $display("%4dns %8x : %8x m[%-04d+%-04d]=%-d SW=%8x", $stime, pc0, ir, 
          R[b], c16, R[a], `SW);*/
        default : 
          $display("%4dns %8x : %8x R[%02d]=%-8x=%-d SW=%8x", $stime, pc0, ir, a, 
          R[a], R[a], `SW);
        endcase
        if (op==RET && `PC < 0) begin
          $display("RET to PC < 0, finished!");
          $finish;
        end
        next_state = Fetch;
      end                
      endcase
      pc = `PC;
    end
  
  endmodule
  
  module memory0(input clock, reset, en, rw, input [1:0] m_size, 
                  input [31:0] abus, dbus_in, output [31:0] dbus_out);
    reg [7:0] m [0:1024];
    reg [31:0] data;
  
    integer i;
    initial begin
      $readmemh("cpu0s.hex", m);
      for (i=0; i < 1024; i=i+4) begin
         $display("%8x: %8x", i, {m[i], m[i+1], m[i+2], m[i+3]});
      end
    end
  
    always @(clock or abus or en or rw or dbus_in) 
    begin
      if (abus >=0 && abus <= 1023) begin
        if (en == 1 && rw == 0) begin // r_w==0:write
          data = dbus_in;
          case (m_size)
          `BYTE:  {m[abus]} = dbus_in[7:0];
          `INT16: {m[abus], m[abus+1] } = dbus_in[15:0];
          `INT24: {m[abus], m[abus+1], m[abus+2]} = dbus_in[24:0];
          `INT32: {m[abus], m[abus+1], m[abus+2], m[abus+3]} = dbus_in;
          endcase
        end else if (en == 1 && rw == 1) begin// r_w==1:read
          case (m_size)
          `BYTE:  data = {8'h00  , 8'h00,   8'h00,   m[abus]      };
          `INT16: data = {8'h00  , 8'h00,   m[abus], m[abus+1]    };
          `INT24: data = {8'h00  , m[abus], m[abus+1], m[abus+2]  };
          `INT32: data = {m[abus], m[abus+1], m[abus+2], m[abus+3]};
          endcase
        end else
          data = 32'hZZZZZZZZ;
      end else
        data = 32'hZZZZZZZZ;
    end
    assign dbus_out = data;
  endmodule
  
  module main;
    reg clock, reset;
    wire [2:0] tick;
    wire [31:0] pc, ir, mar, mdr, dbus;
    wire m_en, m_rw;
    wire [1:0] m_size;
  
    cpu0 cpu(.clock(clock), .reset(reset), .pc(pc), .tick(tick), .ir(ir),
    .mar(mar), .mdr(mdr), .dbus(dbus), .m_en(m_en), .m_rw(m_rw), .m_size(m_size));
  
    memory0 mem(.clock(clock), .reset(reset), .en(m_en), .rw(m_rw), .m_size(m_size), 
    .abus(mar), .dbus_in(mdr), .dbus_out(dbus));
  
    initial
    begin
      clock = 0;
      reset = 1;
      #20 reset = 0;
      #30000 $finish;
    end
  
    always #10 clock=clock+1;
  endmodule

.. code-block:: bash

  JonathantekiiMac:raw Jonathan$ pwd
  /Users/Jonathan/test/2/lbd/LLVMBackendTutorialExampleCode/cpu0_verilog/raw
  JonathantekiiMac:raw Jonathan$ iverilog -o cpu0s cpu0s.v 


Run program on CPU0 machine
---------------------------

Now let's compile ch10_2.cpp as below. Since code size grows up from low to high 
address and stack grows up from high to low address. We set $sp at 1020 because 
cpu0s.v use 1024 bytes of memory.

.. code-block:: c++

  // InitRegs.h
  asm("addiu $1,  $ZERO, 0");
  asm("addiu $2,  $ZERO, 0");
  asm("addiu $3,  $ZERO, 0");
  asm("addiu $4,  $ZERO, 0");
  asm("addiu $5,  $ZERO, 0");
  asm("addiu $6,  $ZERO, 0");
  asm("addiu $7,  $ZERO, 0");
  asm("addiu $8,  $ZERO, 0");
  asm("addiu $9,  $ZERO, 0");
  asm("addiu $10, $ZERO, 0");
  asm("addiu $11, $ZERO, 0");
  asm("addiu $12, $ZERO, 0");
  asm("addiu $14, $ZERO, -1");
  
  // ch10_2.cpp
  #include "InitRegs.h"
  
  #define OUT_MEM 0x7000 // 28672
  
  asm("addiu $sp, $zero, 1020");
  
  void print_integer(int x);
  int test_operators();
  int test_control();
  
  int main()
  {
    int a = 0;
    a = test_operators(); // a = 13
    print_integer(a);
    a += test_control();  // a = 31
    print_integer(a);
  
    return a;
  }
  
  // For memory IO
  void print_integer(int x)
  {
    int *p = (int*)OUT_MEM;
    *p = x;
   return;
  }
  
  void print1_integer(int x)
  {
    asm("ld $at, 8($sp)");
    asm("st $at, 28672($0)");
   return;
  }
  
  #if 0
  // For instruction IO
  void print2_integer(int x)
  {
    asm("ld $at, 8($sp)");
    asm("outw $tat");
    return;
  }
  #endif
  
  int test_operators()
  {
    int a = 11;
    int b = 2;
    int c = 0;
    int d = 0;
    int e, f, g, h, i, j, k, l = 0;
    unsigned int a1 = -5, k1 = 0;
  
    c = a + b;
    d = a - b;
    e = a * b;
    f = a / b;
    b = (a+1)%12;
    g = (a & b);
    h = (a | b);
    i = (a ^ b);
    j = (a << 2);
    k = (a >> 2);
    print_integer(k);
    k1 = (a1 >> 2);
    print_integer((int)k1);
  
    b = !a;
    int* p = &b;
    
    return c; // 13
  }
  
  int test_control()
  {
    int b = 1;
    int c = 2;
    int d = 3;
    int e = 4;
    int f = 5;
    
    if (b != 0) {
      b++;
    }
    if (c > 0) {
      c++;
    }
    if (d >= 0) {
      d++;
    }
    if (e < 0) {
      e++;
    }
    if (f <= 0) {
      f++;
    }
    
    return (b+c+d+e+f); // (2+3+4+4+5)=18
  }

.. code-block:: bash

  JonathantekiiMac:InputFiles Jonathan$ pwd
  /Users/Jonathan/test/2/lbd/LLVMBackendTutorialExampleCode/InputFiles
  JonathantekiiMac:InputFiles Jonathan$ clang -c ch10_2.cpp -emit-llvm -o 
  ch10_2.bc
  JonathantekiiMac:InputFiles Jonathan$ /Users/Jonathan/llvm/test/cmake_debug_
  build/bin/Debug/llc -march=cpu0 -relocation-model=static -filetype=obj 
  ch10_2.bc -o ch10_2.cpu0.o
  JonathantekiiMac:InputFiles Jonathan$ /Users/Jonathan/llvm/test/cmake_debug_
  build/bin/Debug/llvm-objdump -d ch10_2.cpu0.o | tail -n +6| awk '{print "/* " 
  $1 " */\t" $2 " " $3 " " $4 " " $5 "\t/* " $6"\t" $7" " $8" " $9" " $10 "\t*/"}'
   > ../cpu0_verilog/raw/cpu0s.hex
  
  118-165-81-39:raw Jonathan$ cat cpu0s.hex 
  ...
  /* 4c: */ 2b 00 00 20 /* jsub 0    */
  /* 50: */ 01 2d 00 04 /* st $2, 4($sp)    */
  /* 54: */ 2b 00 01 44 /* jsub 0    */
  
  
As above code the subroutine address for **"jsub #offset"** are 0. 
This is correct since C language support separate compile and the subroutine 
address is decided at link time for static address mode or at 
load time for PIC address mode.
Since our backend didn't implement the linker and loader, we change the  
**"jsub #offset"** encode in 10/2/Cpu0 as follow,

.. code-block:: c++

  // Cpu0MCCodeEmitter.cpp
  unsigned Cpu0MCCodeEmitter::
  getJumpTargetOpValue(const MCInst &MI, unsigned OpNo,
             SmallVectorImpl<MCFixup> &Fixups) const {
  
    unsigned Opcode = MI.getOpcode();
    ...
    if (Opcode == Cpu0::JSUB)
      Fixups.push_back(MCFixup::Create(0, Expr,
                       MCFixupKind(Cpu0::fixup_Cpu0_PC24)));
    else if (Opcode == Cpu0::JSUB)
      Fixups.push_back(MCFixup::Create(0, Expr,
                       MCFixupKind(Cpu0::fixup_Cpu0_24)));
    else
      llvm_unreachable("unexpect opcode in getJumpAbsoluteTargetOpValue()");
    
    return 0;
  }

We change JSUB from Relocation Records fixup_Cpu0_24 to Non-Relocaton Records 
fixup_Cpu0_PC24 as the definition below. This change is fine since if call a 
outside defined subroutine, it will add a Relocation Record for this 
**"jsub #offset"**. At this point, we set it to Non-Relocaton Records for 
run on CPU0 Verilog machine. If one day, the CPU0 linker is appeared and the 
linker do the sections arrangement, we should adjust it back to Relocation 
Records. A good linker will reorder the sections for optimization in 
data/function access. In other word, 
keep the global variable access as close as possible to reduce cache miss 
possibility.

.. code-block:: c++

  // Cpu0AsmBackend.cpp
    const MCFixupKindInfo &getFixupKindInfo(MCFixupKind Kind) const {
      const static MCFixupKindInfo Infos[Cpu0::NumTargetFixupKinds] = {
        // This table *must* be in same the order of fixup_* kinds in
        // Cpu0FixupKinds.h.
        //
        // name                    offset  bits  flags
        ...
        { "fixup_Cpu0_24",           0,     24,   0 },
        ...
        { "fixup_Cpu0_PC24",         0,     24,  MCFixupKindInfo::FKF_IsPCRel },
        ...
      }
      ...
    }

Let's run the 10/2/Cpu0 with ``llvm-objdump -d`` again, wiil get the hex file 
as follows,

.. code-block:: bash

  JonathantekiiMac:InputFiles Jonathan$ pwd
  /Users/Jonathan/test/2/lbd/LLVMBackendTutorialExampleCode/InputFiles
  JonathantekiiMac:InputFiles Jonathan$ clang -c ch10_2.cpp -emit-llvm -o 
  ch10_2.bc
  JonathantekiiMac:InputFiles Jonathan$ /Users/Jonathan/llvm/test/cmake_debug_
  build/bin/Debug/llc -march=cpu0 -relocation-model=static -filetype=obj 
  ch10_2.bc -o ch10_2.cpu0.o
  JonathantekiiMac:InputFiles Jonathan$ /Users/Jonathan/llvm/test/cmake_debug_
  build/bin/Debug/llvm-objdump -d ch10_2.cpu0.o | tail -n +6| awk '{print "/* " 
  $1 " */\t" $2 " " $3 " " $4 " " $5 "\t/* " $6"\t" $7" " $8" " $9" " $10 "\t*/"}'
   > ../cpu0_verilog/raw/cpu0s.hex

.. code-block:: c++
  
  118-165-64-234:raw Jonathan$ cat cpu0s.hex
  /* 0: */  09 10 00 00 /* addiu  $at, $zero, 0   */
  /* 4: */  09 20 00 00 /* addiu  $2, $zero, 0  */
  /* 8: */  09 30 00 00 /* addiu  $3, $zero, 0  */
  /* c: */  09 40 00 00 /* addiu  $4, $zero, 0  */
  /* 10: */ 09 50 00 00 /* addiu  $5, $zero, 0  */
  /* 14: */ 09 60 00 00 /* addiu  $6, $zero, 0  */
  /* 18: */ 09 70 00 00 /* addiu  $7, $zero, 0  */
  /* 1c: */ 09 80 00 00 /* addiu  $8, $zero, 0  */
  /* 20: */ 09 90 00 00 /* addiu  $9, $zero, 0  */
  /* 24: */ 09 a0 00 00 /* addiu  $gp, $zero, 0   */
  /* 28: */ 09 b0 00 00 /* addiu  $fp, $zero, 0   */
  /* 2c: */ 09 c0 00 00 /* addiu  $sw, $zero, 0   */
  /* 30: */ 09 e0 ff ff /* addiu  $lr, $zero, -1  */
  /* 34: */ 09 d0 03 fc /* addiu  $sp, $zero, 1020  */
  /* 38: */ 09 dd ff e0 /* addiu  $sp, $sp, -32   */
  /* 3c: */ 01 ed 00 1c /* st $lr, 28($sp)    */
  /* 40: */ 09 20 00 00 /* addiu  $2, $zero, 0  */
  /* 44: */ 01 2d 00 18 /* st $2, 24($sp)   */
  /* 48: */ 01 2d 00 14 /* st $2, 20($sp)   */
  /* 4c: */ 2b 00 00 34 /* jsub 52    */
  /* 50: */ 01 2d 00 14 /* st $2, 20($sp)   */
  /* 54: */ 01 2d 00 00 /* st $2, 0($sp)    */
  /* 58: */ 2b 00 01 74 /* jsub 372     */
  /* 5c: */ 2b 00 01 94 /* jsub 404     */
  /* 60: */ 00 3d 00 14 /* ld $3, 20($sp)   */
  /* 64: */ 13 23 20 00 /* add  $2, $3, $2  */
  /* 68: */ 01 2d 00 14 /* st $2, 20($sp)   */
  /* 6c: */ 01 2d 00 00 /* st $2, 0($sp)    */
  /* 70: */ 2b 00 01 5c /* jsub 348     */
  /* 74: */ 00 2d 00 14 /* ld $2, 20($sp)   */
  /* 78: */ 00 ed 00 1c /* ld $lr, 28($sp)    */
  /* 7c: */ 09 dd 00 20 /* addiu  $sp, $sp, 32  */
  /* 80: */ 2c 00 00 00 /* ret  $zero     */
  /* 84: */ 09 dd ff a8 /* addiu  $sp, $sp, -88   */
  /* 88: */ 01 ed 00 54 /* st $lr, 84($sp)    */
  /* 8c: */ 01 7d 00 50 /* st $7, 80($sp)   */
  /* 90: */ 09 20 00 0b /* addiu  $2, $zero, 11   */
  /* 94: */ 01 2d 00 4c /* st $2, 76($sp)   */
  /* 98: */ 09 20 00 02 /* addiu  $2, $zero, 2  */
  /* 9c: */ 01 2d 00 48 /* st $2, 72($sp)   */
  /* a0: */ 09 70 00 00 /* addiu  $7, $zero, 0  */
  /* a4: */ 01 7d 00 44 /* st $7, 68($sp)   */
  /* a8: */ 01 7d 00 40 /* st $7, 64($sp)   */
  /* ac: */ 01 7d 00 20 /* st $7, 32($sp)   */
  /* b0: */ 09 20 ff fb /* addiu  $2, $zero, -5   */
  /* b4: */ 01 2d 00 1c /* st $2, 28($sp)   */
  /* b8: */ 01 7d 00 18 /* st $7, 24($sp)   */
  /* bc: */ 00 2d 00 48 /* ld $2, 72($sp)   */
  /* c0: */ 00 3d 00 4c /* ld $3, 76($sp)   */
  /* c4: */ 13 23 20 00 /* add  $2, $3, $2  */
  /* c8: */ 01 2d 00 44 /* st $2, 68($sp)   */
  /* cc: */ 00 2d 00 48 /* ld $2, 72($sp)   */
  /* d0: */ 00 3d 00 4c /* ld $3, 76($sp)   */
  /* d4: */ 14 23 20 00 /* sub  $2, $3, $2  */
  /* d8: */ 01 2d 00 40 /* st $2, 64($sp)   */
  /* dc: */ 00 2d 00 48 /* ld $2, 72($sp)   */
  /* e0: */ 00 3d 00 4c /* ld $3, 76($sp)   */
  /* e4: */ 15 23 20 00 /* mul  $2, $3, $2  */
  /* e8: */ 01 2d 00 3c /* st $2, 60($sp)   */
  /* ec: */ 00 2d 00 48 /* ld $2, 72($sp)   */
  /* f0: */ 00 3d 00 4c /* ld $3, 76($sp)   */
  /* f4: */ 16 32 00 00 /* div  $3, $2    */
  /* f8: */ 41 20 00 00 /* mflo $2    */
  /* fc: */ 09 30 2a aa /* addiu  $3, $zero, 10922  */
  /* 100: */  1e 33 00 10 /* shl  $3, $3, 16  */
  /* 104: */  09 40 aa ab /* addiu  $4, $zero, -21845   */
  /* 108: */  19 33 40 00 /* or $3, $3, $4  */
  /* 10c: */  01 2d 00 38 /* st $2, 56($sp)   */
  /* 110: */  00 2d 00 4c /* ld $2, 76($sp)   */
  /* 114: */  09 22 00 01 /* addiu  $2, $2, 1   */
  /* 118: */  50 23 00 00 /* mult $2, $3    */
  /* 11c: */  40 30 00 00 /* mfhi $3    */
  /* 120: */  1f 43 00 1f /* shr  $4, $3, 31  */
  /* 124: */  1b 33 00 01 /* sra  $3, $3, 1   */
  /* 128: */  13 33 40 00 /* add  $3, $3, $4  */
  /* 12c: */  09 40 00 0c /* addiu  $4, $zero, 12   */
  /* 130: */  15 33 40 00 /* mul  $3, $3, $4  */
  /* 134: */  14 22 30 00 /* sub  $2, $2, $3  */
  /* 138: */  01 2d 00 48 /* st $2, 72($sp)   */
  /* 13c: */  00 3d 00 4c /* ld $3, 76($sp)   */
  /* 140: */  18 23 20 00 /* and  $2, $3, $2  */
  /* 144: */  01 2d 00 34 /* st $2, 52($sp)   */
  /* 148: */  00 2d 00 48 /* ld $2, 72($sp)   */
  /* 14c: */  00 3d 00 4c /* ld $3, 76($sp)   */
  /* 150: */  19 23 20 00 /* or $2, $3, $2  */
  /* 154: */  01 2d 00 30 /* st $2, 48($sp)   */
  /* 158: */  00 2d 00 48 /* ld $2, 72($sp)   */
  /* 15c: */  00 3d 00 4c /* ld $3, 76($sp)   */
  /* 160: */  1a 23 20 00 /* xor  $2, $3, $2  */
  /* 164: */  01 2d 00 2c /* st $2, 44($sp)   */
  /* 168: */  00 2d 00 4c /* ld $2, 76($sp)   */
  /* 16c: */  1e 22 00 02 /* shl  $2, $2, 2   */
  /* 170: */  01 2d 00 28 /* st $2, 40($sp)   */
  /* 174: */  00 2d 00 4c /* ld $2, 76($sp)   */
  /* 178: */  1b 22 00 02 /* sra  $2, $2, 2   */
  /* 17c: */  01 2d 00 24 /* st $2, 36($sp)   */
  /* 180: */  01 2d 00 00 /* st $2, 0($sp)    */
  /* 184: */  2b 00 00 48 /* jsub 72    */
  /* 188: */  00 2d 00 1c /* ld $2, 28($sp)   */
  /* 18c: */  1f 22 00 02 /* shr  $2, $2, 2   */
  /* 190: */  01 2d 00 18 /* st $2, 24($sp)   */
  /* 194: */  01 2d 00 00 /* st $2, 0($sp)    */
  /* 198: */  2b 00 00 34 /* jsub 52    */
  /* 19c: */  00 2d 00 4c /* ld $2, 76($sp)   */
  /* 1a0: */  1a 22 70 00 /* xor  $2, $2, $7  */
  /* 1a4: */  09 30 00 01 /* addiu  $3, $zero, 1  */
  /* 1a8: */  1a 22 30 00 /* xor  $2, $2, $3  */
  /* 1ac: */  18 22 30 00 /* and  $2, $2, $3  */
  /* 1b0: */  01 2d 00 48 /* st $2, 72($sp)   */
  /* 1b4: */  09 2d 00 48 /* addiu  $2, $sp, 72   */
  /* 1b8: */  01 2d 00 10 /* st $2, 16($sp)   */
  /* 1bc: */  00 2d 00 44 /* ld $2, 68($sp)   */
  /* 1c0: */  00 7d 00 50 /* ld $7, 80($sp)   */
  /* 1c4: */  00 ed 00 54 /* ld $lr, 84($sp)    */
  /* 1c8: */  09 dd 00 58 /* addiu  $sp, $sp, 88  */
  /* 1cc: */  2c 00 00 00 /* ret  $zero     */
  /* 1d0: */  09 dd ff f8 /* addiu  $sp, $sp, -8  */
  /* 1d4: */  00 2d 00 08 /* ld $2, 8($sp)    */
  /* 1d8: */  01 2d 00 04 /* st $2, 4($sp)    */
  /* 1dc: */  09 20 70 00 /* addiu  $2, $zero, 28672  */
  /* 1e0: */  01 2d 00 00 /* st $2, 0($sp)    */
  /* 1e4: */  00 3d 00 04 /* ld $3, 4($sp)    */
  /* 1e8: */  01 32 00 00 /* st $3, 0($2)   */
  /* 1ec: */  09 dd 00 08 /* addiu  $sp, $sp, 8   */
  /* 1f0: */  2c 00 00 00 /* ret  $zero     */
  /* 1f4: */  09 dd ff e8 /* addiu  $sp, $sp, -24   */
  /* 1f8: */  09 30 00 01 /* addiu  $3, $zero, 1  */
  /* 1fc: */  01 3d 00 14 /* st $3, 20($sp)   */
  /* 200: */  09 20 00 02 /* addiu  $2, $zero, 2  */
  /* 204: */  01 2d 00 10 /* st $2, 16($sp)   */
  /* 208: */  09 20 00 03 /* addiu  $2, $zero, 3  */
  /* 20c: */  01 2d 00 0c /* st $2, 12($sp)   */
  /* 210: */  09 20 00 04 /* addiu  $2, $zero, 4  */
  /* 214: */  01 2d 00 08 /* st $2, 8($sp)    */
  /* 218: */  09 20 00 05 /* addiu  $2, $zero, 5  */
  /* 21c: */  01 2d 00 04 /* st $2, 4($sp)    */
  /* 220: */  09 20 00 00 /* addiu  $2, $zero, 0  */
  /* 224: */  00 4d 00 14 /* ld $4, 20($sp)   */
  /* 228: */  10 42 00 00 /* cmp  $zero, $4, $2   */
  /* 22c: */  20 00 00 10 /* jeq  $zero, 16   */
  /* 230: */  26 00 00 00 /* jmp  0     */
  /* 234: */  00 4d 00 14 /* ld $4, 20($sp)   */
  /* 238: */  09 44 00 01 /* addiu  $4, $4, 1   */
  /* 23c: */  01 4d 00 14 /* st $4, 20($sp)   */
  /* 240: */  00 4d 00 10 /* ld $4, 16($sp)   */
  /* 244: */  10 43 00 00 /* cmp  $zero, $4, $3   */
  /* 248: */  22 00 00 10 /* jlt  $zero, 16   */
  /* 24c: */  26 00 00 00 /* jmp  0     */
  /* 250: */  00 3d 00 10 /* ld $3, 16($sp)   */
  /* 254: */  09 33 00 01 /* addiu  $3, $3, 1   */
  /* 258: */  01 3d 00 10 /* st $3, 16($sp)   */
  /* 25c: */  00 3d 00 0c /* ld $3, 12($sp)   */
  /* 260: */  10 32 00 00 /* cmp  $zero, $3, $2   */
  /* 264: */  22 00 00 10 /* jlt  $zero, 16   */
  /* 268: */  26 00 00 00 /* jmp  0     */
  /* 26c: */  00 3d 00 0c /* ld $3, 12($sp)   */
  /* 270: */  09 33 00 01 /* addiu  $3, $3, 1   */
  /* 274: */  01 3d 00 0c /* st $3, 12($sp)   */
  /* 278: */  09 30 ff ff /* addiu  $3, $zero, -1   */
  /* 27c: */  00 4d 00 08 /* ld $4, 8($sp)    */
  /* 280: */  10 43 00 00 /* cmp  $zero, $4, $3   */
  /* 284: */  23 00 00 10 /* jgt  $zero, 16   */
  /* 288: */  26 00 00 00 /* jmp  0     */
  /* 28c: */  00 3d 00 08 /* ld $3, 8($sp)    */
  /* 290: */  09 33 00 01 /* addiu  $3, $3, 1   */
  /* 294: */  01 3d 00 08 /* st $3, 8($sp)    */
  /* 298: */  00 3d 00 04 /* ld $3, 4($sp)    */
  /* 29c: */  10 32 00 00 /* cmp  $zero, $3, $2   */
  /* 2a0: */  23 00 00 10 /* jgt  $zero, 16   */
  /* 2a4: */  26 00 00 00 /* jmp  0     */
  /* 2a8: */  00 2d 00 04 /* ld $2, 4($sp)    */
  /* 2ac: */  09 22 00 01 /* addiu  $2, $2, 1   */
  /* 2b0: */  01 2d 00 04 /* st $2, 4($sp)    */
  /* 2b4: */  00 2d 00 10 /* ld $2, 16($sp)   */
  /* 2b8: */  00 3d 00 14 /* ld $3, 20($sp)   */
  /* 2bc: */  13 23 20 00 /* add  $2, $3, $2  */
  /* 2c0: */  00 3d 00 0c /* ld $3, 12($sp)   */
  /* 2c4: */  13 22 30 00 /* add  $2, $2, $3  */
  /* 2c8: */  00 3d 00 08 /* ld $3, 8($sp)    */
  /* 2cc: */  13 22 30 00 /* add  $2, $2, $3  */
  /* 2d0: */  00 3d 00 04 /* ld $3, 4($sp)    */
  /* 2d4: */  13 22 30 00 /* add  $2, $2, $3  */
  /* 2d8: */  09 dd 00 18 /* addiu  $sp, $sp, 24  */
  /* 2dc: */  2c 00 00 00 /* ret  $zero     */
  /* 2e0: */  09 dd ff f8 /* addiu  $sp, $sp, -8  */
  /* 2e4: */  00 2d 00 08 /* ld $2, 8($sp)    */
  /* 2e8: */  01 2d 00 04 /* st $2, 4($sp)    */
  /* 2ec: */  00 1d 00 08 /* ld $at, 8($sp)   */
  /* 2f0: */  01 10 70 00 /* st $at, 28672($zero)   */
  /* 2f4: */  09 dd 00 08 /* addiu  $sp, $sp, 8   */
  /* 2f8: */  2c 00 00 00 /* ret  $zero     */

From above result, you can find the print_integer() which implemented by C 
language has 8 instructions while the print1_integer() which implemented by 
assembly has 6 instructions. But the C version is better in portability since 
the assembly is binding with machine assembly language and make the 
assumption that the stack size of print1_integer() is 8.
Now, run the cpu0 backend to get the result as follows,

.. code-block:: bash

  118-165-64-234:raw Jonathan$ ./cpu0s
  WARNING: cpu0s.v:219: $readmemh(cpu0s.hex): Not enough words in the file for 
  the requested range [0:1024].
  00000000: 09100000
  00000004: 09200000
  00000008: 09300000
  0000000c: 09400000
  00000010: 09500000
  00000014: 09600000
  00000018: 09700000
  0000001c: 09800000
  00000020: 09900000
  00000024: 09a00000
  00000028: 09b00000
  0000002c: 09c00000
  00000030: 09e0ffff
  00000034: 09d003fc
  00000038: 09ddffe0
  0000003c: 01ed001c
  00000040: 09200000
  00000044: 012d0018
  00000048: 012d0014
  0000004c: 2b000034
  00000050: 012d0014
  00000054: 012d0000
  00000058: 2b000174
  0000005c: 2b000194
  00000060: 003d0014
  00000064: 13232000
  00000068: 012d0014
  0000006c: 012d0000
  00000070: 2b00015c
  00000074: 002d0014
  00000078: 00ed001c
  0000007c: 09dd0020
  00000080: 2c000000
  00000084: 09ddffa8
  00000088: 01ed0054
  0000008c: 017d0050
  00000090: 0920000b
  00000094: 012d004c
  00000098: 09200002
  0000009c: 012d0048
  000000a0: 09700000
  000000a4: 017d0044
  000000a8: 017d0040
  000000ac: 017d0020
  000000b0: 0920fffb
  000000b4: 012d001c
  000000b8: 017d0018
  000000bc: 002d0048
  000000c0: 003d004c
  000000c4: 13232000
  000000c8: 012d0044
  000000cc: 002d0048
  000000d0: 003d004c
  000000d4: 14232000
  000000d8: 012d0040
  000000dc: 002d0048
  000000e0: 003d004c
  000000e4: 15232000
  000000e8: 012d003c
  000000ec: 002d0048
  000000f0: 003d004c
  000000f4: 16320000
  000000f8: 41200000
  000000fc: 09302aaa
  00000100: 1e330010
  00000104: 0940aaab
  00000108: 19334000
  0000010c: 012d0038
  00000110: 002d004c
  00000114: 09220001
  00000118: 50230000
  0000011c: 40300000
  00000120: 1f43001f
  00000124: 1b330001
  00000128: 13334000
  0000012c: 0940000c
  00000130: 15334000
  00000134: 14223000
  00000138: 012d0048
  0000013c: 003d004c
  00000140: 18232000
  00000144: 012d0034
  00000148: 002d0048
  0000014c: 003d004c
  00000150: 19232000
  00000154: 012d0030
  00000158: 002d0048
  0000015c: 003d004c
  00000160: 1a232000
  00000164: 012d002c
  00000168: 002d004c
  0000016c: 1e220002
  00000170: 012d0028
  00000174: 002d004c
  00000178: 1b220002
  0000017c: 012d0024
  00000180: 012d0000
  00000184: 2b000048
  00000188: 002d001c
  0000018c: 1f220002
  00000190: 012d0018
  00000194: 012d0000
  00000198: 2b000034
  0000019c: 002d004c
  000001a0: 1a227000
  000001a4: 09300001
  000001a8: 1a223000
  000001ac: 18223000
  000001b0: 012d0048
  000001b4: 092d0048
  000001b8: 012d0010
  000001bc: 002d0044
  000001c0: 007d0050
  000001c4: 00ed0054
  000001c8: 09dd0058
  000001cc: 2c000000
  000001d0: 09ddfff8
  000001d4: 002d0008
  000001d8: 012d0004
  000001dc: 09207000
  000001e0: 012d0000
  000001e4: 003d0004
  000001e8: 01320000
  000001ec: 09dd0008
  000001f0: 2c000000
  000001f4: 09ddffe8
  000001f8: 09300001
  000001fc: 013d0014
  00000200: 09200002
  00000204: 012d0010
  00000208: 09200003
  0000020c: 012d000c
  00000210: 09200004
  00000214: 012d0008
  00000218: 09200005
  0000021c: 012d0004
  00000220: 09200000
  00000224: 004d0014
  00000228: 10420000
  0000022c: 20000010
  00000230: 26000000
  00000234: 004d0014
  00000238: 09440001
  0000023c: 014d0014
  00000240: 004d0010
  00000244: 10430000
  00000248: 22000010
  0000024c: 26000000
  00000250: 003d0010
  00000254: 09330001
  00000258: 013d0010
  0000025c: 003d000c
  00000260: 10320000
  00000264: 22000010
  00000268: 26000000
  0000026c: 003d000c
  00000270: 09330001
  00000274: 013d000c
  00000278: 0930ffff
  0000027c: 004d0008
  00000280: 10430000
  00000284: 23000010
  00000288: 26000000
  0000028c: 003d0008
  00000290: 09330001
  00000294: 013d0008
  00000298: 003d0004
  0000029c: 10320000
  000002a0: 23000010
  000002a4: 26000000
  000002a8: 002d0004
  000002ac: 09220001
  000002b0: 012d0004
  000002b4: 002d0010
  000002b8: 003d0014
  000002bc: 13232000
  000002c0: 003d000c
  000002c4: 13223000
  000002c8: 003d0008
  000002cc: 13223000
  000002d0: 003d0004
  000002d4: 13223000
  000002d8: 09dd0018
  000002dc: 2c000000
  000002e0: 09ddfff8
  000002e4: 002d0008
  000002e8: 012d0004
  000002ec: 001d0008
  000002f0: 01107000
  000002f4: 09dd0008
  000002f8: 2c000000
  000002fc: xxxxxxxx
  00000300: xxxxxxxx
  00000304: xxxxxxxx
  00000308: xxxxxxxx
  0000030c: xxxxxxxx
  00000310: xxxxxxxx
  00000314: xxxxxxxx
  00000318: xxxxxxxx
  0000031c: xxxxxxxx
  00000320: xxxxxxxx
  00000324: xxxxxxxx
  00000328: xxxxxxxx
  0000032c: xxxxxxxx
  00000330: xxxxxxxx
  00000334: xxxxxxxx
  00000338: xxxxxxxx
  0000033c: xxxxxxxx
  00000340: xxxxxxxx
  00000344: xxxxxxxx
  00000348: xxxxxxxx
  0000034c: xxxxxxxx
  00000350: xxxxxxxx
  00000354: xxxxxxxx
  00000358: xxxxxxxx
  0000035c: xxxxxxxx
  00000360: xxxxxxxx
  00000364: xxxxxxxx
  00000368: xxxxxxxx
  0000036c: xxxxxxxx
  00000370: xxxxxxxx
  00000374: xxxxxxxx
  00000378: xxxxxxxx
  0000037c: xxxxxxxx
  00000380: xxxxxxxx
  00000384: xxxxxxxx
  00000388: xxxxxxxx
  0000038c: xxxxxxxx
  00000390: xxxxxxxx
  00000394: xxxxxxxx
  00000398: xxxxxxxx
  0000039c: xxxxxxxx
  000003a0: xxxxxxxx
  000003a4: xxxxxxxx
  000003a8: xxxxxxxx
  000003ac: xxxxxxxx
  000003b0: xxxxxxxx
  000003b4: xxxxxxxx
  000003b8: xxxxxxxx
  000003bc: xxxxxxxx
  000003c0: xxxxxxxx
  000003c4: xxxxxxxx
  000003c8: xxxxxxxx
  000003cc: xxxxxxxx
  000003d0: xxxxxxxx
  000003d4: xxxxxxxx
  000003d8: xxxxxxxx
  000003dc: xxxxxxxx
  000003e0: xxxxxxxx
  000003e4: xxxxxxxx
  000003e8: xxxxxxxx
  000003ec: xxxxxxxx
  000003f0: xxxxxxxx
  000003f4: xxxxxxxx
  000003f8: xxxxxxxx
  000003fc: xxxxxxxx
    90ns 00000000 : 09100000 R[01]=00000000=0          SW=00000000
   170ns 00000004 : 09200000 R[02]=00000000=0          SW=00000000
   250ns 00000008 : 09300000 R[03]=00000000=0          SW=00000000
   330ns 0000000c : 09400000 R[04]=00000000=0          SW=00000000
   410ns 00000010 : 09500000 R[05]=00000000=0          SW=00000000
   490ns 00000014 : 09600000 R[06]=00000000=0          SW=00000000
   570ns 00000018 : 09700000 R[07]=00000000=0          SW=00000000
   650ns 0000001c : 09800000 R[08]=00000000=0          SW=00000000
   730ns 00000020 : 09900000 R[09]=00000000=0          SW=00000000
   810ns 00000024 : 09a00000 R[10]=00000000=0          SW=00000000
   890ns 00000028 : 09b00000 R[11]=00000000=0          SW=00000000
   970ns 0000002c : 09c00000 R[12]=00000000=0          SW=00000000
  1050ns 00000030 : 09e0ffff R[14]=ffffffff=-1         SW=00000000
  1130ns 00000034 : 09d003fc R[13]=000003fc=1020       SW=00000000
  1210ns 00000038 : 09ddffe0 R[13]=000003dc=988        SW=00000000
  1370ns 00000040 : 09200000 R[02]=00000000=0          SW=00000000
  1610ns 0000004c : 2b000034 R[00]=00000000=0          SW=00000000
  1690ns 00000084 : 09ddffa8 R[13]=00000384=900        SW=00000000
  1930ns 00000090 : 0920000b R[02]=0000000b=11         SW=00000000
  2090ns 00000098 : 09200002 R[02]=00000002=2          SW=00000000
  2250ns 000000a0 : 09700000 R[07]=00000000=0          SW=00000000
  2570ns 000000b0 : 0920fffb R[02]=fffffffb=-5         SW=00000000
  2810ns 000000bc : 002d0048 R[02]=00000002=2          SW=00000000
  2890ns 000000c0 : 003d004c R[03]=0000000b=11         SW=00000000
  2970ns 000000c4 : 13232000 R[02]=0000000d=13         SW=00000000
  3130ns 000000cc : 002d0048 R[02]=00000002=2          SW=00000000
  3210ns 000000d0 : 003d004c R[03]=0000000b=11         SW=00000000
  3290ns 000000d4 : 14232000 R[02]=00000009=9          SW=00000000
  3450ns 000000dc : 002d0048 R[02]=00000002=2          SW=00000000
  3530ns 000000e0 : 003d004c R[03]=0000000b=11         SW=00000000
  3610ns 000000e4 : 15232000 R[02]=00000016=22         SW=00000000
  3770ns 000000ec : 002d0048 R[02]=00000002=2          SW=00000000
  3850ns 000000f0 : 003d004c R[03]=0000000b=11         SW=00000000
  3930ns 000000f4 : 16320000 HI=00000001 LO=00000005 SW=00000000
  4010ns 000000f8 : 41200000 R[02]=00000005=5          SW=00000000
  4090ns 000000fc : 09302aaa R[03]=00002aaa=10922      SW=00000000
  4170ns 00000100 : 1e330010 R[03]=2aaa0000=715784192  SW=00000000
  4250ns 00000104 : 0940aaab R[04]=ffffaaab=-21845     SW=00000000
  4330ns 00000108 : 19334000 R[03]=ffffaaab=-21845     SW=00000000
  4490ns 00000110 : 002d004c R[02]=0000000b=11         SW=00000000
  4570ns 00000114 : 09220001 R[02]=0000000c=12         SW=00000000
  4650ns 00000118 : 50230000 HI=ffffffff LO=fffc0004 SW=00000000
  4730ns 0000011c : 40300000 R[03]=ffffffff=-1         SW=00000000
  4810ns 00000120 : 1f43001f R[04]=00000001=1          SW=00000000
  4890ns 00000124 : 1b330001 R[03]=ffffffff=-1         SW=00000000
  4970ns 00000128 : 13334000 R[03]=00000000=0          SW=00000000
  5050ns 0000012c : 0940000c R[04]=0000000c=12         SW=00000000
  5130ns 00000130 : 15334000 R[03]=00000000=0          SW=00000000
  5210ns 00000134 : 14223000 R[02]=0000000c=12         SW=00000000
  5370ns 0000013c : 003d004c R[03]=0000000b=11         SW=00000000
  5450ns 00000140 : 18232000 R[02]=00000008=8          SW=00000000
  5610ns 00000148 : 002d0048 R[02]=0000000c=12         SW=00000000
  5690ns 0000014c : 003d004c R[03]=0000000b=11         SW=00000000
  5770ns 00000150 : 19232000 R[02]=0000000f=15         SW=00000000
  5930ns 00000158 : 002d0048 R[02]=0000000c=12         SW=00000000
  6010ns 0000015c : 003d004c R[03]=0000000b=11         SW=00000000
  6090ns 00000160 : 1a232000 R[02]=00000007=7          SW=00000000
  6250ns 00000168 : 002d004c R[02]=0000000b=11         SW=00000000
  6330ns 0000016c : 1e220002 R[02]=0000002c=44         SW=00000000
  6490ns 00000174 : 002d004c R[02]=0000000b=11         SW=00000000
  6570ns 00000178 : 1b220002 R[02]=00000002=2          SW=00000000
  6810ns 00000184 : 2b000048 R[00]=00000000=0          SW=00000000
  6890ns 000001d0 : 09ddfff8 R[13]=0000037c=892        SW=00000000
  6970ns 000001d4 : 002d0008 R[02]=00000002=2          SW=00000000
  7130ns 000001dc : 09207000 R[02]=00007000=28672      SW=00000000
  7290ns 000001e4 : 003d0004 R[03]=00000002=2          SW=00000000
  7370ns 000001e8 : 01320000 OUTPUT=2         
  7450ns 000001ec : 09dd0008 R[13]=00000384=900        SW=00000000
  7530ns 000001f0 : 2c000000 R[00]=00000000=0          SW=00000000
  7610ns 00000188 : 002d001c R[02]=fffffffb=-5         SW=00000000
  7690ns 0000018c : 1f220002 R[02]=3ffffffe=1073741822 SW=00000000
  7930ns 00000198 : 2b000034 R[00]=00000000=0          SW=00000000
  8010ns 000001d0 : 09ddfff8 R[13]=0000037c=892        SW=00000000
  8090ns 000001d4 : 002d0008 R[02]=3ffffffe=1073741822 SW=00000000
  8250ns 000001dc : 09207000 R[02]=00007000=28672      SW=00000000
  8410ns 000001e4 : 003d0004 R[03]=3ffffffe=1073741822 SW=00000000
  8490ns 000001e8 : 01320000 OUTPUT=1073741822
  8570ns 000001ec : 09dd0008 R[13]=00000384=900        SW=00000000
  8650ns 000001f0 : 2c000000 R[00]=00000000=0          SW=00000000
  8730ns 0000019c : 002d004c R[02]=0000000b=11         SW=00000000
  8810ns 000001a0 : 1a227000 R[02]=0000000b=11         SW=00000000
  8890ns 000001a4 : 09300001 R[03]=00000001=1          SW=00000000
  8970ns 000001a8 : 1a223000 R[02]=0000000a=10         SW=00000000
  9050ns 000001ac : 18223000 R[02]=00000000=0          SW=00000000
  9210ns 000001b4 : 092d0048 R[02]=000003cc=972        SW=00000000
  9370ns 000001bc : 002d0044 R[02]=0000000d=13         SW=00000000
  9450ns 000001c0 : 007d0050 R[07]=00000000=0          SW=00000000
  9530ns 000001c4 : 00ed0054 R[14]=00000050=80         SW=00000000
  9610ns 000001c8 : 09dd0058 R[13]=000003dc=988        SW=00000000
  9690ns 000001cc : 2c000000 R[00]=00000000=0          SW=00000000
  9930ns 00000058 : 2b000174 R[00]=00000000=0          SW=00000000
  10010ns 000001d0 : 09ddfff8 R[13]=000003d4=980        SW=00000000
  10090ns 000001d4 : 002d0008 R[02]=0000000d=13         SW=00000000
  10250ns 000001dc : 09207000 R[02]=00007000=28672      SW=00000000
  10410ns 000001e4 : 003d0004 R[03]=0000000d=13         SW=00000000
  10490ns 000001e8 : 01320000 OUTPUT=13        
  10570ns 000001ec : 09dd0008 R[13]=000003dc=988        SW=00000000
  10650ns 000001f0 : 2c000000 R[00]=00000000=0          SW=00000000
  10730ns 0000005c : 2b000194 R[00]=00000000=0          SW=00000000
  10810ns 000001f4 : 09ddffe8 R[13]=000003c4=964        SW=00000000
  10890ns 000001f8 : 09300001 R[03]=00000001=1          SW=00000000
  11050ns 00000200 : 09200002 R[02]=00000002=2          SW=00000000
  11210ns 00000208 : 09200003 R[02]=00000003=3          SW=00000000
  11370ns 00000210 : 09200004 R[02]=00000004=4          SW=00000000
  11530ns 00000218 : 09200005 R[02]=00000005=5          SW=00000000
  11690ns 00000220 : 09200000 R[02]=00000000=0          SW=00000000
  11770ns 00000224 : 004d0014 R[04]=00000001=1          SW=00000000
  11850ns 00000228 : 10420000 R[04]=00000001=1          SW=00000000
  11930ns 0000022c : 20000010 R[00]=00000000=0          SW=00000000
  12010ns 00000230 : 26000000 R[00]=00000000=0          SW=00000000
  12090ns 00000234 : 004d0014 R[04]=00000001=1          SW=00000000
  12170ns 00000238 : 09440001 R[04]=00000002=2          SW=00000000
  12330ns 00000240 : 004d0010 R[04]=00000002=2          SW=00000000
  12410ns 00000244 : 10430000 R[04]=00000002=2          SW=00000000
  12490ns 00000248 : 22000010 R[00]=00000000=0          SW=00000000
  12570ns 0000024c : 26000000 R[00]=00000000=0          SW=00000000
  12650ns 00000250 : 003d0010 R[03]=00000002=2          SW=00000000
  12730ns 00000254 : 09330001 R[03]=00000003=3          SW=00000000
  12890ns 0000025c : 003d000c R[03]=00000003=3          SW=00000000
  12970ns 00000260 : 10320000 R[03]=00000003=3          SW=00000000
  13050ns 00000264 : 22000010 R[00]=00000000=0          SW=00000000
  13130ns 00000268 : 26000000 R[00]=00000000=0          SW=00000000
  13210ns 0000026c : 003d000c R[03]=00000003=3          SW=00000000
  13290ns 00000270 : 09330001 R[03]=00000004=4          SW=00000000
  13450ns 00000278 : 0930ffff R[03]=ffffffff=-1         SW=00000000
  13530ns 0000027c : 004d0008 R[04]=00000004=4          SW=00000000
  13610ns 00000280 : 10430000 R[04]=00000004=4          SW=00000000
  13690ns 00000284 : 23000010 R[00]=00000000=0          SW=00000000
  13770ns 00000298 : 003d0004 R[03]=00000005=5          SW=00000000
  13850ns 0000029c : 10320000 R[03]=00000005=5          SW=00000000
  13930ns 000002a0 : 23000010 R[00]=00000000=0          SW=00000000
  14010ns 000002b4 : 002d0010 R[02]=00000003=3          SW=00000000
  14090ns 000002b8 : 003d0014 R[03]=00000002=2          SW=00000000
  14170ns 000002bc : 13232000 R[02]=00000005=5          SW=00000000
  14250ns 000002c0 : 003d000c R[03]=00000004=4          SW=00000000
  14330ns 000002c4 : 13223000 R[02]=00000009=9          SW=00000000
  14410ns 000002c8 : 003d0008 R[03]=00000004=4          SW=00000000
  14490ns 000002cc : 13223000 R[02]=0000000d=13         SW=00000000
  14570ns 000002d0 : 003d0004 R[03]=00000005=5          SW=00000000
  14650ns 000002d4 : 13223000 R[02]=00000012=18         SW=00000000
  14730ns 000002d8 : 09dd0018 R[13]=000003dc=988        SW=00000000
  14810ns 000002dc : 2c000000 R[00]=00000000=0          SW=00000000
  14890ns 00000060 : 003d0014 R[03]=0000000d=13         SW=00000000
  14970ns 00000064 : 13232000 R[02]=0000001f=31         SW=00000000
  15210ns 00000070 : 2b00015c R[00]=00000000=0          SW=00000000
  15290ns 000001d0 : 09ddfff8 R[13]=000003d4=980        SW=00000000
  15370ns 000001d4 : 002d0008 R[02]=0000001f=31         SW=00000000
  15530ns 000001dc : 09207000 R[02]=00007000=28672      SW=00000000
  15690ns 000001e4 : 003d0004 R[03]=0000001f=31         SW=00000000
  15770ns 000001e8 : 01320000 OUTPUT=31        
  15850ns 000001ec : 09dd0008 R[13]=000003dc=988        SW=00000000
  15930ns 000001f0 : 2c000000 R[00]=00000000=0          SW=00000000
  16010ns 00000074 : 002d0014 R[02]=0000001f=31         SW=00000000
  16090ns 00000078 : 00ed001c R[14]=ffffffff=-1         SW=00000000
  16170ns 0000007c : 09dd0020 R[13]=000003fc=1020       SW=00000000
  16250ns 00000080 : 2c000000 R[00]=00000000=0          SW=00000000
  RET to PC < 0, finished!

As above result, cpu0s.v dump the memory first after read input cpu0s.hex. 
Next, it run instructions from address 0 and print each destination 
register value in the fourth column. 
The first column is the nano seconds of timing. The second 
is instruction address. The third is instruction content. 
We have checked the **">>"** is correct on both signed and unsigned int type 
, and tracking the variable **a** value by print_integer(). You can verify it 
with the **OUTPUT=xxx** in Verilog output.

Now, let's run ch_10_3.cpp to verify the result as follows,

.. code-block:: c++

  // ch10_3.cpp
  #include <stdarg.h>
  
  #include "InitRegs.h"
  
  #define OUT_MEM 0x7000 // 28672
  
  asm("addiu $sp, $zero, 1020");
  
  void print_integer(int x);
  int sum_i(int amount, ...);
  
  int main()
  {
    int a = sum_i(6, 0, 1, 2, 3, 4, 5);
    print_integer(a);
    
    return a;
  }
  
  // For memory IO
  void print_integer(int x)
  {
    int *p = (int*)OUT_MEM;
    *p = x;
   return;
  }
  
  int sum_i(int amount, ...)
  {
    int i = 0;
    int val = 0;
    int sum = 0;
    
    va_list vl;
    va_start(vl, amount);
    for (i = 0; i < amount; i++)
    {
      val = va_arg(vl, int);
      sum += val;
    }
    va_end(vl);
    
    return sum; 
  }

.. code-block:: bash

  118-165-75-175:InputFiles Jonathan$ clang -target `llvm-config --host-target` 
  -c ch10_3.cpp -emit-llvm -o ch10_3.bc
  118-165-75-175:InputFiles Jonathan$ /Users/Jonathan/llvm/test/cmake_debug_build
  /bin/Debug/llc -march=cpu0 -relocation-model=static -filetype=obj ch10_3.bc 
  -o ch10_3.cpu0.o
  118-165-75-175:InputFiles Jonathan$ /Users/Jonathan/llvm/test/cmake_debug_build
  /bin/Debug/llvm-objdump -d ch10_3.cpu0.o | tail -n +6| awk '{print "/* " $1 " 
  */\t" $2 " " $3 " " $4 " " $5 "\t/* " $6"\t" $7" " $8" " $9" " $10 "\t*/"}' 
  > ../cpu0_verilog/raw/cpu0s.hex
  
  118-165-75-175:raw Jonathan$ ./cpu0s
  ...
  12890ns 0000012c : 01320000 OUTPUT=15        
  ...

We show Verilog PC output by display the I/O memory mapped address but we 
didn't implement the output hardware interface or port. The output hardware 
interface/port is dependent on hardware output device, such as RS232, speaker, 
LED, .... You should implement the I/O interface/port when you want to program 
FPGA and wire I/O device to the I/O port.



.. [#] http://www.ece.umd.edu/courses/enee359a/

.. [#] http://www.ece.umd.edu/courses/enee359a/verilog_tutorial.pdf
