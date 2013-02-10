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
this main()+bootcode() elf can translated back to hex file format which include 
the disassemble code as comment. 
Further, we can design the Cpu0 with Verilog language tool and run the Cpu0 
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


Above 3 Pseudo Instruction definitions in cpu0InstrInfo.td such as 
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


