ELF
====

Cpu0 backend generated the ELF format of obj. 
The ELF (Executable and Linkable Format) is a common standard file format for 
executables, object code, shared libraries and core dumps. 
First published in the System V Application Binary Interface specification, 
and later in the Tool Interface Standard, it was quickly accepted among 
different vendors of Unixsystems. 
In 1999 it was chosen as the standard binary file format for Unix and 
Unix-like systems on x86 by the x86open project. 
Please reference [#]_.

The binary encode of cpu0 instruction set in obj has been checked in the 
previous chapters. 
But we didn't dig into the ELF file format like elf header and relocation 
record at that time. 
This chapter will use the binutils which has been installed in 
"sub-section Install other tools on iMac" of Appendix A: “Installing LLVM” 
[#]_ to analysis cpu0 ELF file. 
You will learn the objdump, readelf, …, tools and understand the ELF file 
format itself through using these tools to analyze the cpu0 generated obj in 
this chapter. 
LLVM has the llvm-objdump tool which like objdump but it's only support the 
native CPU. 
The binutils support other CPU ELF dump as a cross compiler tool chains. 
Linux platform has binutils already and no need to install it further.
We use Linux binutils in this chapter just because iMac will display Chinese 
text. 
The iMac corresponding binutils have no problem except it use add g in 
command, for example, use gobjdump instead of objdump, and display your area 
language instead of pure English.

The binutils tool we use is not a part of llvm tools, but it's a powerful tool 
in ELF analysis. 
This chapter introduce the tool to readers since we think it is a valuable 
knowledge in this popular ELF format and the ELF binutils analysis tool. 
An LLVM compiler engineer has the responsibility to analyze the ELF since 
the obj is need to be handled by linker or loader later. 
With this tool, you can verify your generated ELF format.
 
The cpu0 author has published a “System Software” book which introduce the 
topics 
of assembler, linker, loader, compiler and OS in concept, and at same time 
demonstrate how to use binutils and gcc to analysis ELF through the example 
code in his book. 
It's a Chinese book of “System Program” in concept and practice. 
This book does the real analysis through binutils. 
The “System Program” written by Beck is a famous book in concept of telling 
readers what is the compiler output, what is the linker output, what is the 
loader output, and how they work together. 
But it covers the concept only. 
You can reference it to understand how the **“Relocation Record”** works if you 
need to refresh or learning this knowledge for this chapter.

[#]_, [#]_, [#]_ are the Chinese documents available from the cpu0 author on web site.


ELF format
-----------

ELF is a format used both in obj and executable file. 
So, there are two views in it as :ref:`elf_f1`.

.. _elf_f1:
.. figure:: ../Fig/elf/1.png
    :height: 320 px
    :width: 213 px
    :scale: 100 %
    :align: center

    ELF file format overview

As :ref:`elf_f1`, the “Section header table” include sections .text, .rodata, 
…, .data which are sections layout for code, read only data, …, and read/write 
data. 
“Program header table” include segments include run time code and data. 
The definition of segments is run time layout for code and data, and sections 
is link time layout for code and data.

ELF header and Section header table
------------------------------------

Let's run 7/7/Cpu0 with ch6_1.cpp, and dump ELF header information by 
``readelf -h`` to see what information the ELF header contains.

.. code-block:: bash

  [Gamma@localhost InputFiles]$ /usr/local/llvm/3.1.test/cpu0/1/cmake_debug_build/
  bin/llc -march=cpu0 -relocation-model=pic -filetype=obj ch6_1.bc -o ch6_1.cpu0.o
  
  [Gamma@localhost InputFiles]$ readelf -h ch6_1.cpu0.o 
  ELF Header:
    Magic:   7f 45 4c 46 01 02 01 08 00 00 00 00 00 00 00 00 
    Class:                             ELF32
    Data:                              2's complement, big endian
    Version:                           1 (current)
    OS/ABI:                            UNIX - IRIX
    ABI Version:                       0
    Type:                              REL (Relocatable file)
    Machine:                           <unknown>: 0xc9
    Version:                           0x1
    Entry point address:               0x0
    Start of program headers:          0 (bytes into file)
    Start of section headers:          212 (bytes into file)
    Flags:                             0x70000001
    Size of this header:               52 (bytes)
    Size of program headers:           0 (bytes)
    Number of program headers:         0
    Size of section headers:           40 (bytes)
    Number of section headers:         10
    Section header string table index: 7
  [Gamma@localhost InputFiles]$ 

  [Gamma@localhost InputFiles]$ /usr/local/llvm/3.1.test/cpu0/1/cmake_debug_build/
  bin/llc -march=mips -relocation-model=pic -filetype=obj ch6_1.bc -o ch6_1.mips.o
  
  [Gamma@localhost InputFiles]$ readelf -h ch6_1.mips.o 
  ELF Header:
    Magic:   7f 45 4c 46 01 02 01 08 00 00 00 00 00 00 00 00 
    Class:                             ELF32
    Data:                              2's complement, big endian
    Version:                           1 (current)
    OS/ABI:                            UNIX - IRIX
    ABI Version:                       0
    Type:                              REL (Relocatable file)
    Machine:                           MIPS R3000
    Version:                           0x1
    Entry point address:               0x0
    Start of program headers:          0 (bytes into file)
    Start of section headers:          212 (bytes into file)
    Flags:                             0x70000001
    Size of this header:               52 (bytes)
    Size of program headers:           0 (bytes)
    Number of program headers:         0
    Size of section headers:           40 (bytes)
    Number of section headers:         11
    Section header string table index: 8
  [Gamma@localhost InputFiles]$ 


As above ELF header display, it contains information of magic number, version, 
ABI, …, . The Machine field of cpu0 is unknown while mips is MIPSR3000. 
It is because cpu0 is not a popular CPU recognized by utility readelf. 
Let's check ELF segments information as follows,

.. code-block:: bash

  [Gamma@localhost InputFiles]$ readelf -l ch6_1.cpu0.o 
  
  There are no program headers in this file.
  [Gamma@localhost InputFiles]$ 


The result is in expectation because cpu0 obj is for link only, not for 
execution. 
So, the segments is empty. 
Check ELF sections information as follows. 
It contains offset and size information for every section.

.. code-block:: bash

  [Gamma@localhost InputFiles]$ readelf -S ch6_1.cpu0.o 
  There are 10 section headers, starting at offset 0xd4:
  
  Section Headers:
    [Nr] Name              Type            Addr     Off    Size   ES Flg Lk Inf Al
    [ 0]                   NULL            00000000 000000 000000 00      0   0  0
    [ 1] .text             PROGBITS        00000000 000034 000034 00  AX  0   0  4
    [ 2] .rel.text         REL             00000000 000310 000018 08      8   1  4
    [ 3] .data             PROGBITS        00000000 000068 000004 00  WA  0   0  4
    [ 4] .bss              NOBITS          00000000 00006c 000000 00  WA  0   0  4
    [ 5] .eh_frame         PROGBITS        00000000 00006c 000028 00   A  0   0  4
    [ 6] .rel.eh_frame     REL             00000000 000328 000008 08      8   5  4
    [ 7] .shstrtab         STRTAB          00000000 000094 00003e 00      0   0  1
    [ 8] .symtab           SYMTAB          00000000 000264 000090 10      9   6  4
    [ 9] .strtab           STRTAB          00000000 0002f4 00001b 00      0   0  1
  Key to Flags:
    W (write), A (alloc), X (execute), M (merge), S (strings)
    I (info), L (link order), G (group), T (TLS), E (exclude), x (unknown)
    O (extra OS processing required) o (OS specific), p (processor specific)
  [Gamma@localhost InputFiles]$ 



Relocation Record
------------------

The cpu0 backend translate global variable as follows,

.. code-block:: bash

  [Gamma@localhost InputFiles]$ clang -c ch6_1.cpp -emit-llvm -o ch6_1.bc
  [Gamma@localhost InputFiles]$ /usr/local/llvm/3.1.test/cpu0/1/cmake_debug_build/
  bin/llc -march=cpu0 -relocation-model=pic -filetype=asm ch6_1.bc -o ch6_1.cpu0.s
  [Gamma@localhost InputFiles]$ cat ch6_1.cpu0.s 
    .section .mdebug.abi32
    .previous
    .file "ch6_1.bc"
    .text
    .globl  main
    .align  2
    .type main,@function
    .ent  main                    # @main
  main:
    .cfi_startproc
    .frame  $sp,8,$lr
    .mask   0x00000000,0
    .set  noreorder
    .cpload $t9
  ...
    ld  $2, %got(gI)($gp)
  ...
    .type gI,@object              # @gI
    .data
    .globl  gI
    .align  2
  gI:
    .4byte  100                     # 0x64
    .size gI, 4
  
  
  [Gamma@localhost InputFiles]$ /usr/local/llvm/3.1.test/cpu0/1/cmake_debug_build/
  bin/llc -march=cpu0 -relocation-model=pic -filetype=obj ch6_1.bc -o ch6_1.cpu0.o
  [Gamma@localhost InputFiles]$ objdump -s ch6_1.cpu0.o
  
  ch6_1.cpu0.o:     file format elf32-big
  
  Contents of section .text:
  // .cpload machine instruction
   0000 09a00000 1eaa0010 09aa0000 13aa6000  ..............`.
   ...
   0020 002a0000 00220000 012d0000 09dd0008  .*..."...-......
   ...
  [Gamma@localhost InputFiles]$ Jonathan$ 
  
  [Gamma@localhost InputFiles]$ readelf -tr ch6_1.cpu0.o 
  There are 10 section headers, starting at offset 0xd4:
  
  Section Headers:
    [Nr] Name
       Type            Addr     Off    Size   ES   Lk Inf Al
       Flags
    [ 0] 
       NULL            00000000 000000 000000 00   0   0  0
       [00000000]: 
    [ 1] .text
       PROGBITS        00000000 000034 000034 00   0   0  4
       [00000006]: ALLOC, EXEC
    [ 2] .rel.text
       REL             00000000 000310 000018 08   8   1  4
       [00000000]: 
    [ 3] .data
       PROGBITS        00000000 000068 000004 00   0   0  4
       [00000003]: WRITE, ALLOC
    [ 4] .bss
       NOBITS          00000000 00006c 000000 00   0   0  4
       [00000003]: WRITE, ALLOC
    [ 5] .eh_frame
       PROGBITS        00000000 00006c 000028 00   0   0  4
       [00000002]: ALLOC
    [ 6] .rel.eh_frame
       REL             00000000 000328 000008 08   8   5  4
       [00000000]: 
    [ 7] .shstrtab
       STRTAB          00000000 000094 00003e 00   0   0  1
       [00000000]: 
    [ 8] .symtab
       SYMTAB          00000000 000264 000090 10   9   6  4
       [00000000]: 
    [ 9] .strtab
       STRTAB          00000000 0002f4 00001b 00   0   0  1
       [00000000]: 
  
  Relocation section '.rel.text' at offset 0x310 contains 3 entries:
   Offset     Info    Type            Sym.Value  Sym. Name
  00000000  00000805 unrecognized: 5       00000000   _gp_disp
  00000008  00000806 unrecognized: 6       00000000   _gp_disp
  00000020  00000609 unrecognized: 9       00000000   gI
  
  Relocation section '.rel.eh_frame' at offset 0x328 contains 1 entries:
   Offset     Info    Type            Sym.Value  Sym. Name
  0000001c  00000202 unrecognized: 2       00000000   .text
  [Gamma@localhost InputFiles]$ readelf -tr ch6_1.mips.o 
  There are 10 section headers, starting at offset 0xd0:
  
  Section Headers:
    [Nr] Name
       Type            Addr     Off    Size   ES   Lk Inf Al
       Flags
    [ 0] 
       NULL            00000000 000000 000000 00   0   0  0
       [00000000]: 
    [ 1] .text
       PROGBITS        00000000 000034 000030 00   0   0  4
       [00000006]: ALLOC, EXEC
    [ 2] .rel.text
       REL             00000000 00030c 000018 08   8   1  4
       [00000000]: 
    [ 3] .data
       PROGBITS        00000000 000064 000004 00   0   0  4
       [00000003]: WRITE, ALLOC
    [ 4] .bss
       NOBITS          00000000 000068 000000 00   0   0  4
       [00000003]: WRITE, ALLOC
    [ 5] .eh_frame
       PROGBITS        00000000 000068 000028 00   0   0  4
       [00000002]: ALLOC
    [ 6] .rel.eh_frame
       REL             00000000 000324 000008 08   8   5  4
       [00000000]: 
    [ 7] .shstrtab
       STRTAB          00000000 000090 00003e 00   0   0  1
       [00000000]: 
    [ 8] .symtab
       SYMTAB          00000000 000260 000090 10   9   6  4
       [00000000]: 
    [ 9] .strtab
       STRTAB          00000000 0002f0 00001b 00   0   0  1
       [00000000]: 
  
  Relocation section '.rel.text' at offset 0x30c contains 3 entries:
   Offset     Info    Type            Sym.Value  Sym. Name
  00000000  00000805 R_MIPS_HI16       00000000   _gp_disp
  00000004  00000806 R_MIPS_LO16       00000000   _gp_disp
  00000018  00000609 R_MIPS_GOT16      00000000   gI
  
  Relocation section '.rel.eh_frame' at offset 0x324 contains 1 entries:
   Offset     Info    Type            Sym.Value  Sym. Name
  0000001c  00000202 R_MIPS_32         00000000   .text


As depicted in `section Handle $gp register in PIC addressing mode`_, it 
translate **“.cpload %reg”** into the following.

.. code-block:: c++

  // Lower ".cpload $reg" to
  //  "addiu $gp, $zero, %hi(_gp_disp)"
  //  "shl   $gp, $gp, 16"
  //  "addiu $gp, $gp, %lo(_gp_disp)"
  //  "addu  $gp, $gp, $t9"

The _gp_disp value is determined by loader. So, it's undefined in obj. 
You can find the Relocation Records for offset 0 and 8 of .text section 
referred to _gp_disp value. 
The offset 0 and 8 of .text section are instructions "addiu $gp, $zero, 
%hi(_gp_disp)" and "addiu $gp, $gp, %lo(_gp_disp)" and their corresponding obj 
encode are  09a00000 and  09aa0000. 
The obj translate the %hi(_gp_disp) and %lo(_gp_disp) into 0 since when loader 
load this obj into memory, loader will know the _gp_disp value at run time and 
will update these two offset relocation records into the correct offset value. 
You can check the cpu0 of %hi(_gp_disp) and %lo(_gp_disp) are correct by above 
mips Relocation Records of R_MIPS_HI(_gp_disp) and  R_MIPS_LO(_gp_disp) even 
though the cpu0 is not a CPU recognized by greadelf utilitly. 
The instruction **“ld $2, %got(gI)($gp)”** is same since we don't know what the 
address of .data section variable will load to. 
So, translate the address to 0 and made a relocation record on 0x00000020 of 
.text section. Loader will change this address too.
	
Run with ch8_3_3.cpp will get the unknown result in _Z5sum_iiz and other symbol 
reference as below. 
Loader or linker will take care them according the relocation records compiler 
generated.

.. code-block:: bash

  [Gamma@localhost InputFiles]$ /usr/local/llvm/3.1.test/cpu0/1/cmake_debug_build/
  bin/llc -march=cpu0 -relocation-model=pic -filetype=obj ch8_3_3.bc -o ch8_3__3.
  cpu0.o
  [Gamma@localhost InputFiles]$ readelf -tr ch8_3_3.cpu0.o 
  There are 11 section headers, starting at offset 0x248:
  
  Section Headers:
    [Nr] Name
       Type            Addr     Off    Size   ES   Lk Inf Al
       Flags
    [ 0] 
       NULL            00000000 000000 000000 00   0   0  0
       [00000000]: 
    [ 1] .text
       PROGBITS        00000000 000034 000178 00   0   0  4
       [00000006]: ALLOC, EXEC
    [ 2] .rel.text
       REL             00000000 000538 000058 08   9   1  4
       [00000000]: 
    [ 3] .data
       PROGBITS        00000000 0001ac 000000 00   0   0  4
       [00000003]: WRITE, ALLOC
    [ 4] .bss
       NOBITS          00000000 0001ac 000000 00   0   0  4
       [00000003]: WRITE, ALLOC
    [ 5] .rodata.str1.1
       PROGBITS        00000000 0001ac 000008 01   0   0  1
       [00000032]: ALLOC, MERGE, STRINGS
    [ 6] .eh_frame
       PROGBITS        00000000 0001b4 000044 00   0   0  4
       [00000002]: ALLOC
    [ 7] .rel.eh_frame
       REL             00000000 000590 000010 08   9   6  4
       [00000000]: 
    [ 8] .shstrtab
       STRTAB          00000000 0001f8 00004d 00   0   0  1
       [00000000]: 
    [ 9] .symtab
       SYMTAB          00000000 000400 0000e0 10  10   8  4
       [00000000]: 
    [10] .strtab
       STRTAB          00000000 0004e0 000055 00   0   0  1
       [00000000]: 
  
  Relocation section '.rel.text' at offset 0x538 contains 11 entries:
   Offset     Info    Type            Sym.Value  Sym. Name
  00000000  00000c05 unrecognized: 5       00000000   _gp_disp
  00000008  00000c06 unrecognized: 6       00000000   _gp_disp
  0000001c  00000b09 unrecognized: 9       00000000   __stack_chk_guard
  000000b8  00000b09 unrecognized: 9       00000000   __stack_chk_guard
  000000dc  00000a0b unrecognized: b       00000000   __stack_chk_fail
  000000e8  00000c05 unrecognized: 5       00000000   _gp_disp
  000000f0  00000c06 unrecognized: 6       00000000   _gp_disp
  00000140  0000080b unrecognized: b       00000000   _Z5sum_iiz
  00000154  00000209 unrecognized: 9       00000000   $.str
  00000158  00000206 unrecognized: 6       00000000   $.str
  00000160  00000d0b unrecognized: b       00000000   printf
  
  Relocation section '.rel.eh_frame' at offset 0x590 contains 2 entries:
   Offset     Info    Type            Sym.Value  Sym. Name
  0000001c  00000302 unrecognized: 2       00000000   .text
  00000034  00000302 unrecognized: 2       00000000   .text
  [Gamma@localhost InputFiles]$ /usr/local/llvm/3.1.test/cpu0/1/cmake_debug_build/
  bin/llc -march=mips -relocation-model=pic -filetype=obj ch8_3_3.bc -o ch8_3__3.
  mips.o
  [Gamma@localhost InputFiles]$ readelf -tr ch8_3_3.mips.o 
  There are 11 section headers, starting at offset 0x254:
  
  Section Headers:
    [Nr] Name
       Type            Addr     Off    Size   ES   Lk Inf Al
       Flags
    [ 0] 
       NULL            00000000 000000 000000 00   0   0  0
       [00000000]: 
    [ 1] .text
       PROGBITS        00000000 000034 000184 00   0   0  4
       [00000006]: ALLOC, EXEC
    [ 2] .rel.text
       REL             00000000 000544 000058 08   9   1  4
       [00000000]: 
    [ 3] .data
       PROGBITS        00000000 0001b8 000000 00   0   0  4
       [00000003]: WRITE, ALLOC
    [ 4] .bss
       NOBITS          00000000 0001b8 000000 00   0   0  4
       [00000003]: WRITE, ALLOC
    [ 5] .rodata.str1.1
       PROGBITS        00000000 0001b8 000008 01   0   0  1
       [00000032]: ALLOC, MERGE, STRINGS
    [ 6] .eh_frame
       PROGBITS        00000000 0001c0 000044 00   0   0  4
       [00000002]: ALLOC
    [ 7] .rel.eh_frame
       REL             00000000 00059c 000010 08   9   6  4
       [00000000]: 
    [ 8] .shstrtab
       STRTAB          00000000 000204 00004d 00   0   0  1
       [00000000]: 
    [ 9] .symtab
       SYMTAB          00000000 00040c 0000e0 10  10   8  4
       [00000000]: 
    [10] .strtab
       STRTAB          00000000 0004ec 000055 00   0   0  1
       [00000000]: 
  
  Relocation section '.rel.text' at offset 0x544 contains 11 entries:
   Offset     Info    Type            Sym.Value  Sym. Name
  00000000  00000c05 R_MIPS_HI16       00000000   _gp_disp
  00000004  00000c06 R_MIPS_LO16       00000000   _gp_disp
  00000024  00000b09 R_MIPS_GOT16      00000000   __stack_chk_guard
  000000c8  00000b09 R_MIPS_GOT16      00000000   __stack_chk_guard
  000000f0  00000a0b R_MIPS_CALL16     00000000   __stack_chk_fail
  00000100  00000c05 R_MIPS_HI16       00000000   _gp_disp
  00000104  00000c06 R_MIPS_LO16       00000000   _gp_disp
  00000134  0000080b R_MIPS_CALL16     00000000   _Z5sum_iiz
  00000154  00000209 R_MIPS_GOT16      00000000   $.str
  00000158  00000206 R_MIPS_LO16       00000000   $.str
  0000015c  00000d0b R_MIPS_CALL16     00000000   printf
  
  Relocation section '.rel.eh_frame' at offset 0x59c contains 2 entries:
   Offset     Info    Type            Sym.Value  Sym. Name
  0000001c  00000302 R_MIPS_32         00000000   .text
  00000034  00000302 R_MIPS_32         00000000   .text
  [Gamma@localhost InputFiles]$ 


Cpu0 ELF related files
-----------------------

Files Cpu0ELFObjectWrite.cpp and Cpu0MC*.cpp are the files take care the obj 
format. 
Most obj code translation are defined by Cpu0InstrInfo.td and 
Cpu0RegisterInfo.td. 
With these td description, LLVM translate the instruction into obj format 
automatically.


lld
----

The lld is a project of LLVM linker. 
It's under development and we cannot finish the installation by following the 
web site direction. 
Even with this, it's really make sense to develop a new linker according it's web 
site information.
Please visit the web site [#]_.


.. _section Handle $gp register in PIC addressing mode:
	http://jonathan2251.github.com/lbd/funccall.html#handle-gp-register-in-pic-addressing-mode


.. [#] http://en.wikipedia.org/wiki/Executable_and_Linkable_Format

.. [#] http://jonathan2251.github.com/lbd/install.html#install-other-tools-on-imac

.. [#] http://ccckmit.wikidot.com/lk:aout

.. [#] http://ccckmit.wikidot.com/lk:objfile

.. [#] http://ccckmit.wikidot.com/lk:elf

.. [#] http://lld.llvm.org/

