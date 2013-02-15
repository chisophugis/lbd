.. _sec-elf:

ELF Support
===========

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
You will learn the objdump, readelf, ..., tools and understand the ELF file 
format itself through using these tools to analyze the cpu0 generated obj in 
this chapter. 
LLVM has the llvm-objdump tool which like objdump. We will make cpu0 support 
llvm-objdump tool in this chapter. 
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
It's a Chinese book of “System Software” in concept and practice. 
This book does the real analysis through binutils. 
The “System Software”[#]_ written by Beck is a famous book in concept of 
telling readers what is the compiler output, what is the linker output, 
what is the loader output, and how they work together. 
But it covers the concept only. 
You can reference it to understand how the **“Relocation Record”** works if you 
need to refresh or learning this knowledge for this chapter.

[#]_, [#]_, [#]_ are the Chinese documents available from the cpu0 author on 
web site.


ELF format
-----------

ELF is a format used both in obj and executable file. 
So, there are two views in it as :num:`Figure #elf-f1`.

.. _elf-f1:
.. figure:: ../Fig/elf/1.png
    :height: 320 px
    :width: 213 px
    :scale: 100 %
    :align: center

    ELF file format overview

As :num:`Figure #elf-f1`, the “Section header table” include sections .text, .rodata, 
..., .data which are sections layout for code, read only data, ..., and 
read/write data. 
“Program header table” include segments include run time code and data. 
The definition of segments is run time layout for code and data, and sections 
is link time layout for code and data.

ELF header and Section header table
------------------------------------

Let's run 7/7/Cpu0 with ch6_1.cpp, and dump ELF header information by 
``readelf -h`` to see what information the ELF header contains.

.. code-block:: bash

  [Gamma@localhost InputFiles]$ /usr/local/llvm/test/cmake_debug_build/
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

  [Gamma@localhost InputFiles]$ /usr/local/llvm/test/cmake_debug_build/
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
ABI, ..., . The Machine field of cpu0 is unknown while mips is MIPSR3000. 
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
  [Gamma@localhost InputFiles]$ /usr/local/llvm/test/cmake_debug_build/
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
  
  
  [Gamma@localhost InputFiles]$ /usr/local/llvm/test/cmake_debug_build/
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

  [Gamma@localhost InputFiles]$ /usr/local/llvm/test/cmake_debug_build/
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
  [Gamma@localhost InputFiles]$ /usr/local/llvm/test/cmake_debug_build/
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


llvm-objdump
-------------

llvm-objdump -t -r
~~~~~~~~~~~~~~~~~~

In linux, ``objdump -tr`` can display the information of relocation records 
like ``readelf -tr``. LLVM tool llvm-objdump is the same tool as objdump. 
Let's run the llvm-objdump command as follows to see the difference. 

.. code-block:: bash

  118-165-83-10:InputFiles Jonathan$ clang -c ch8_3_3.cpp -emit-llvm -I/
  Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/
  SDKs/MacOSX10.8.sdk/usr/include/ -o ch8_3_3.bc
  118-165-83-10:InputFiles Jonathan$ /Users/Jonathan/llvm/test/cmake_debug_build/
  bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=obj ch8_3_3.bc -o 
  ch8_3_3.cpu0.o
  118-165-83-10:InputFiles Jonathan$ /Users/Jonathan/llvm/test/cmake_debug_build/
  bin/Debug/llvm-objdump -t -r ch8_3_3.cpu0.o
  
  118-165-83-10:InputFiles Jonathan$ llvm-objdump -t -r ch8_3_3.cpu0.o
  
  ch8_3_3.cpu0.o: file format ELF32-unknown
  
  RELOCATION RECORDS FOR [.text]:
  0 Unknown Unknown
  8 Unknown Unknown
  28 Unknown Unknown
  188 Unknown Unknown
  224 Unknown Unknown
  236 Unknown Unknown
  244 Unknown Unknown
  324 Unknown Unknown
  344 Unknown Unknown
  348 Unknown Unknown
  356 Unknown Unknown
  
  RELOCATION RECORDS FOR [.eh_frame]:
  28 Unknown Unknown
  52 Unknown Unknown
  
  SYMBOL TABLE:
  00000000 l    df *ABS*  00000000 ch8_3_3.bc
  00000000 l       .rodata.str1.1 00000008 $.str
  00000000 l    d  .text  00000000 .text
  00000000 l    d  .data  00000000 .data
  00000000 l    d  .bss 00000000 .bss
  00000000 l    d  .rodata.str1.1 00000000 .rodata.str1.1
  00000000 l    d  .eh_frame  00000000 .eh_frame
  00000000 g     F .text  000000ec _Z5sum_iiz
  000000ec g     F .text  00000094 main
  00000000         *UND*  00000000 __stack_chk_fail
  00000000         *UND*  00000000 __stack_chk_guard
  00000000         *UND*  00000000 _gp_disp
  00000000         *UND*  00000000 printf
  
  118-165-83-10:InputFiles Jonathan$ /Users/Jonathan/llvm/test/cmake_debug_build/
  bin/Debug/llvm-objdump -t -r ch8_3_3.cpu0.o
  
  ch8_3_3.cpu0.o: file format ELF32-CPU0
  
  RELOCATION RECORDS FOR [.text]:
  0 R_CPU0_HI16 _gp_disp
  8 R_CPU0_LO16 _gp_disp
  28 R_CPU0_GOT16 __stack_chk_guard
  188 R_CPU0_GOT16 __stack_chk_guard
  224 R_CPU0_CALL24 __stack_chk_fail
  236 R_CPU0_HI16 _gp_disp
  244 R_CPU0_LO16 _gp_disp
  324 R_CPU0_CALL24 _Z5sum_iiz
  344 R_CPU0_GOT16 $.str
  348 R_CPU0_LO16 $.str
  356 R_CPU0_CALL24 printf
  
  RELOCATION RECORDS FOR [.eh_frame]:
  28 R_CPU0_32 .text
  52 R_CPU0_32 .text
  
  SYMBOL TABLE:
  00000000 l    df *ABS*  00000000 ch8_3_3.bc
  00000000 l       .rodata.str1.1 00000008 $.str
  00000000 l    d  .text  00000000 .text
  00000000 l    d  .data  00000000 .data
  00000000 l    d  .bss 00000000 .bss
  00000000 l    d  .rodata.str1.1 00000000 .rodata.str1.1
  00000000 l    d  .eh_frame  00000000 .eh_frame
  00000000 g     F .text  000000ec _Z5sum_iiz
  000000ec g     F .text  00000094 main
  00000000         *UND*  00000000 __stack_chk_fail
  00000000         *UND*  00000000 __stack_chk_guard
  00000000         *UND*  00000000 _gp_disp
  00000000         *UND*  00000000 printf

The latter llvm-objdump can display the file format and relocation records 
information since we add the relocation records information in ELF.h as follows, 

.. code-block:: c++

  // include/support/ELF.h
  ...
  // Machine architectures
  enum {
    ...
    EM_CPU0          = 201, // Document Write An LLVM Backend Tutorial For Cpu0
    ...
  }
  
  // include/object/ELF.h
  ...
  template<support::endianness target_endianness, bool is64Bits>
  error_code ELFObjectFile<target_endianness, is64Bits>
              ::getRelocationTypeName(DataRefImpl Rel,
                        SmallVectorImpl<char> &Result) const {
    ...
    switch (Header->e_machine) {
    case ELF::EM_CPU0:  // llvm-objdump -t -r
    switch (type) {
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_NONE);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_16);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_32);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_REL32);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_24);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_HI16);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_LO16);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_GPREL16);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_LITERAL);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_GOT16);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_PC24);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_CALL24);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_GPREL32);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_SHIFT5);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_SHIFT6);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_64);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_GOT_DISP);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_GOT_PAGE);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_GOT_OFST);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_GOT_HI16);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_GOT_LO16);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_SUB);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_INSERT_A);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_INSERT_B);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_DELETE);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_HIGHER);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_HIGHEST);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_CALL_HI16);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_CALL_LO16);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_SCN_DISP);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_REL16);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_ADD_IMMEDIATE);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_PJUMP);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_RELGOT);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_JALR);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_TLS_DTPMOD32);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_TLS_DTPREL32);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_TLS_DTPMOD64);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_TLS_DTPREL64);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_TLS_GD);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_TLS_LDM);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_TLS_DTPREL_HI16);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_TLS_DTPREL_LO16);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_TLS_GOTTPREL);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_TLS_TPREL32);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_TLS_TPREL64);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_TLS_TPREL_HI16);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_TLS_TPREL_LO16);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_GLOB_DAT);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_COPY);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_JUMP_SLOT);
      LLVM_ELF_SWITCH_RELOC_TYPE_NAME(R_CPU0_NUM);
    default:
      res = "Unknown";
    }
    break;
    ...
    }
  
  
  template<support::endianness target_endianness, bool is64Bits>
  error_code ELFObjectFile<target_endianness, is64Bits>
              ::getRelocationValueString(DataRefImpl Rel,
                        SmallVectorImpl<char> &Result) const {
    ...
    case ELF::EM_CPU0:  // llvm-objdump -t -r
    res = symname;
    break;
    ...
  }
  
  template<support::endianness target_endianness, bool is64Bits>
  StringRef ELFObjectFile<target_endianness, is64Bits>
               ::getFileFormatName() const {
    switch(Header->e_ident[ELF::EI_CLASS]) {
    case ELF::ELFCLASS32:
    switch(Header->e_machine) {
    ...
    case ELF::EM_CPU0:  // llvm-objdump -t -r
      return "ELF32-CPU0";
    ...
  }
  
  template<support::endianness target_endianness, bool is64Bits>
  unsigned ELFObjectFile<target_endianness, is64Bits>::getArch() const {
    switch(Header->e_machine) {
    ...
    case ELF::EM_CPU0:  // llvm-objdump -t -r
    return (target_endianness == support::little) ?
         Triple::cpu0el : Triple::cpu0;
    ...
  }


llvm-objdump -d
~~~~~~~~~~~~~~~~

Run 8/9/Cpu0 and command ``llvm-objdump -d`` for dump file from elf to hex as 
follows, 

.. code-block:: bash

  JonathantekiiMac:InputFiles Jonathan$ clang -c ch7_1_1.cpp -emit-llvm -o 
  ch7_1_1.bc
  JonathantekiiMac:InputFiles Jonathan$ /Users/Jonathan/llvm/test/cmake_debug_
  build/bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=obj ch7_1_1.bc 
  -o ch7_1_1.cpu0.o
  JonathantekiiMac:InputFiles Jonathan$ /Users/Jonathan/llvm/test/cmake_debug_
  build/bin/Debug/llvm-objdump -d ch7_1_1.cpu0.o
  
  ch7_1_1.cpu0.o: file format ELF32-unknown
  
  Disassembly of section .text:error: no disassembler for target cpu0-unknown-
  unknown

To support llvm-objdump, the following code added to /9/1/Cpu0.

.. code-block:: c++

  // CMakeLists.txt
  ...
  tablegen(LLVM Cpu0GenDisassemblerTables.inc -gen-disassembler)
  ...
  tablegen(LLVM Cpu0GenEDInfo.inc -gen-enhanced-disassembly-info)
  
  // LLVMBuild.txt
  [common]
  subdirectories = Disassembler ...
  ...
  has_disassembler = 1
  ...
  
  // Cpu0InstrInfo.td
  class CmpInstr<bits<8> op, string instr_asm, 
           InstrItinClass itin, RegisterClass RC, RegisterClass RD, 
           bit isComm = 0>:
    FA<op, (outs RD:$rc), (ins RC:$ra, RC:$rb),
     !strconcat(instr_asm, "\t$ra, $rb"), [], itin> {
    ...
    let DecoderMethod = "DecodeCMPInstruction";
  }
  
  class CBranch<bits<8> op, string instr_asm, RegisterClass RC,
             list<Register> UseRegs>:
    FJ<op, (outs), (ins RC:$ra, brtarget:$addr),
         !strconcat(instr_asm, "\t$addr"),
         [(brcond RC:$ra, bb:$addr)], IIBranch> {
    ...
    let DecoderMethod = "DecodeBranchTarget";
  }
  
  let isBranch=1, isTerminator=1, isBarrier=1, imm16=0, hasDelaySlot = 1,
    isIndirectBranch = 1 in
  class JumpFR<bits<8> op, string instr_asm, RegisterClass RC>:
    FL<op, (outs), (ins RC:$ra),
     !strconcat(instr_asm, "\t$ra"), [(brind RC:$ra)], IIBranch> {
    let rb = 0;
    let imm16 = 0;
  }
  
  let isCall=1, hasDelaySlot=0 in {
    class JumpLink<bits<8> op, string instr_asm>:
    FJ<op, (outs), (ins calltarget:$target, variable_ops),
       !strconcat(instr_asm, "\t$target"), [(Cpu0JmpLink imm:$target)],
       IIBranch> {
       let DecoderMethod = "DecodeJumpAbsoluteTarget";
       }
  
  def JR      : JumpFR<0x2C, "ret", CPURegs>;
  
  
  // Disassembler/CMakeLists.txt
  include_directories( ${CMAKE_CURRENT_BINARY_DIR}/.. ${CMAKE_CURRENT_SOURCE_DIR}/.. )
  
  add_llvm_library(LLVMCpu0Disassembler
    Cpu0Disassembler.cpp
    )
  
  # workaround for hanging compilation on MSVC9 and 10
  if( MSVC_VERSION EQUAL 1400 OR MSVC_VERSION EQUAL 1500 OR MSVC_VERSION EQUAL 1600 )
  set_property(
    SOURCE Cpu0Disassembler.cpp
    PROPERTY COMPILE_FLAGS "/Od"
    )
  endif()
  
  add_dependencies(LLVMCpu0Disassembler Cpu0CommonTableGen)
  
  ;===- ./lib/Target/Cpu0/Disassembler/LLVMBuild.txt --------------*- Conf -*--===;
  ...
  [component_0]
  type = Library
  name = Cpu0Disassembler
  parent = Cpu0
  required_libraries = MC Support Cpu0Info
  add_to_library_groups = Cpu0
  
  // 
  //===- Cpu0Disassembler.cpp - Disassembler for Cpu0 -------------*- C++ -*-===//
  //
  //                     The LLVM Compiler Infrastructure
  //
  // This file is distributed under the University of Illinois Open Source
  // License. See LICENSE.TXT for details.
  //
  //===----------------------------------------------------------------------===//
  //
  // This file is part of the Cpu0 Disassembler.
  //
  //===----------------------------------------------------------------------===//
  
  #include "Cpu0.h"
  #include "Cpu0Subtarget.h"
  #include "Cpu0RegisterInfo.h"
  #include "llvm/MC/EDInstInfo.h"
  #include "llvm/MC/MCDisassembler.h"
  #include "llvm/MC/MCFixedLenDisassembler.h"
  #include "llvm/Support/MemoryObject.h"
  #include "llvm/Support/TargetRegistry.h"
  #include "llvm/MC/MCSubtargetInfo.h"
  #include "llvm/MC/MCInst.h"
  #include "llvm/Support/MathExtras.h"
  
  #include "Cpu0GenEDInfo.inc"
  
  using namespace llvm;
  
  typedef MCDisassembler::DecodeStatus DecodeStatus;
  
  /// Cpu0Disassembler - a disasembler class for Cpu032.
  class Cpu0Disassembler : public MCDisassembler {
  public:
    /// Constructor     - Initializes the disassembler.
    ///
    Cpu0Disassembler(const MCSubtargetInfo &STI, bool bigEndian) :
    MCDisassembler(STI), isBigEndian(bigEndian) {
    }
  
    ~Cpu0Disassembler() {
    }
  
    /// getInstruction - See MCDisassembler.
    DecodeStatus getInstruction(MCInst &instr,
                  uint64_t &size,
                  const MemoryObject &region,
                  uint64_t address,
                  raw_ostream &vStream,
                  raw_ostream &cStream) const;
  
    /// getEDInfo - See MCDisassembler.
    const EDInstInfo *getEDInfo() const;
  
  private:
    bool isBigEndian;
  };
  
  const EDInstInfo *Cpu0Disassembler::getEDInfo() const {
    return instInfoCpu0;
  }
  
  // Decoder tables for Cpu0 register
  static const unsigned CPURegsTable[] = {
    Cpu0::ZERO, Cpu0::AT, Cpu0::V0, Cpu0::V1,
    Cpu0::A0, Cpu0::A1, Cpu0::T9, Cpu0::S0, 
    Cpu0::S1, Cpu0::S2, Cpu0::GP, Cpu0::FP, 
    Cpu0::SW, Cpu0::SP, Cpu0::LR, Cpu0::PC
  };
  
  static DecodeStatus DecodeCPURegsRegisterClass(MCInst &Inst,
                           unsigned RegNo,
                           uint64_t Address,
                           const void *Decoder);
  static DecodeStatus DecodeCMPInstruction(MCInst &Inst,
                       unsigned Insn,
                       uint64_t Address,
                       const void *Decoder);
  static DecodeStatus DecodeBranchTarget(MCInst &Inst,
                       unsigned Insn,
                       uint64_t Address,
                       const void *Decoder);
  static DecodeStatus DecodeJumpRelativeTarget(MCInst &Inst,
                       unsigned Insn,
                       uint64_t Address,
                       const void *Decoder);
  static DecodeStatus DecodeJumpAbsoluteTarget(MCInst &Inst,
                     unsigned Insn,
                     uint64_t Address,
                     const void *Decoder);
  
  static DecodeStatus DecodeMem(MCInst &Inst,
                  unsigned Insn,
                  uint64_t Address,
                  const void *Decoder);
  static DecodeStatus DecodeSimm16(MCInst &Inst,
                   unsigned Insn,
                   uint64_t Address,
                   const void *Decoder);
  
  namespace llvm {
  extern Target TheCpu0elTarget, TheCpu0Target, TheCpu064Target,
          TheCpu064elTarget;
  }
  
  static MCDisassembler *createCpu0Disassembler(
               const Target &T,
               const MCSubtargetInfo &STI) {
    return new Cpu0Disassembler(STI,true);
  }
  
  static MCDisassembler *createCpu0elDisassembler(
               const Target &T,
               const MCSubtargetInfo &STI) {
    return new Cpu0Disassembler(STI,false);
  }
  
  extern "C" void LLVMInitializeCpu0Disassembler() {
    // Register the disassembler.
    TargetRegistry::RegisterMCDisassembler(TheCpu0Target,
                       createCpu0Disassembler);
    TargetRegistry::RegisterMCDisassembler(TheCpu0elTarget,
                       createCpu0elDisassembler);
  }
  
  
  #include "Cpu0GenDisassemblerTables.inc"
  
    /// readInstruction - read four bytes from the MemoryObject
    /// and return 32 bit word sorted according to the given endianess
  static DecodeStatus readInstruction32(const MemoryObject &region,
                      uint64_t address,
                      uint64_t &size,
                      uint32_t &insn,
                      bool isBigEndian) {
    uint8_t Bytes[4];
  
    // We want to read exactly 4 Bytes of data.
    if (region.readBytes(address, 4, (uint8_t*)Bytes, NULL) == -1) {
    size = 0;
    return MCDisassembler::Fail;
    }
  
    if (isBigEndian) {
    // Encoded as a big-endian 32-bit word in the stream.
    insn = (Bytes[3] <<  0) |
         (Bytes[2] <<  8) |
         (Bytes[1] << 16) |
         (Bytes[0] << 24);
    }
    else {
    // Encoded as a small-endian 32-bit word in the stream.
    insn = (Bytes[0] <<  0) |
         (Bytes[1] <<  8) |
         (Bytes[2] << 16) |
         (Bytes[3] << 24);
    }
  
    return MCDisassembler::Success;
  }
  
  DecodeStatus
  Cpu0Disassembler::getInstruction(MCInst &instr,
                   uint64_t &Size,
                   const MemoryObject &Region,
                   uint64_t Address,
                   raw_ostream &vStream,
                   raw_ostream &cStream) const {
    uint32_t Insn;
  
    DecodeStatus Result = readInstruction32(Region, Address, Size,
                        Insn, isBigEndian);
    if (Result == MCDisassembler::Fail)
    return MCDisassembler::Fail;
  
    // Calling the auto-generated decoder function.
    Result = decodeInstruction(DecoderTableCpu032, instr, Insn, Address,
                 this, STI);
    if (Result != MCDisassembler::Fail) {
    Size = 4;
    return Result;
    }
  
    return MCDisassembler::Fail;
  }
  
  static DecodeStatus DecodeCPURegsRegisterClass(MCInst &Inst,
                           unsigned RegNo,
                           uint64_t Address,
                           const void *Decoder) {
    if (RegNo > 16)
    return MCDisassembler::Fail;
  
    Inst.addOperand(MCOperand::CreateReg(CPURegsTable[RegNo]));
    return MCDisassembler::Success;
  }
  
  static DecodeStatus DecodeMem(MCInst &Inst,
                  unsigned Insn,
                  uint64_t Address,
                  const void *Decoder) {
    int Offset = SignExtend32<16>(Insn & 0xffff);
    int Reg = (int)fieldFromInstruction(Insn, 20, 4);
    int Base = (int)fieldFromInstruction(Insn, 16, 4);
  
    Inst.addOperand(MCOperand::CreateReg(CPURegsTable[Reg]));
    Inst.addOperand(MCOperand::CreateReg(CPURegsTable[Base]));
    Inst.addOperand(MCOperand::CreateImm(Offset));
  
    return MCDisassembler::Success;
  }
  
  /* CMP instruction define $rc and then $ra, $rb; The printOperand() print 
  operand 1 and operand 2 (operand 0 is $rc and operand 1 is $ra), so we Create 
  register $rc first and create $ra next, as follows,
  
  // Cpu0InstrInfo.td
  class CmpInstr<bits<8> op, string instr_asm, 
            InstrItinClass itin, RegisterClass RC, RegisterClass RD, bit isComm = 0>:
    FA<op, (outs RD:$rc), (ins RC:$ra, RC:$rb),
     !strconcat(instr_asm, "\t$ra, $rb"), [], itin> {
  
  // Cpu0AsmWriter.inc
  void Cpu0InstPrinter::printInstruction(const MCInst *MI, raw_ostream &O) {
  ...
    case 3:
    // CMP, JEQ, JGE, JGT, JLE, JLT, JNE
    printOperand(MI, 1, O); 
    break;
  ...
    case 1:
    // CMP
    printOperand(MI, 2, O); 
    return;
    break;
  */
  static DecodeStatus DecodeCMPInstruction(MCInst &Inst,
                       unsigned Insn,
                       uint64_t Address,
                       const void *Decoder) {
    int Reg_a = (int)fieldFromInstruction(Insn, 20, 4);
    int Reg_b = (int)fieldFromInstruction(Insn, 16, 4);
    int Reg_c = (int)fieldFromInstruction(Insn, 12, 4);
    int shamt = (int)fieldFromInstruction(Insn, 0, 12);
  
    Inst.addOperand(MCOperand::CreateReg(CPURegsTable[Reg_c]));
    Inst.addOperand(MCOperand::CreateReg(CPURegsTable[Reg_a]));
    Inst.addOperand(MCOperand::CreateReg(CPURegsTable[Reg_b]));
    return MCDisassembler::Success;
  }
  
  /* CBranch instruction define $ra and then imm24; The printOperand() print 
  operand 1 (operand 0 is $ra and operand 1 is imm24), so we Create register 
  operand first and create imm24 next, as follows,
  
  // Cpu0InstrInfo.td
  class CBranch<bits<8> op, string instr_asm, RegisterClass RC,
             list<Register> UseRegs>:
    FJ<op, (outs), (ins RC:$ra, brtarget:$addr),
         !strconcat(instr_asm, "\t$addr"),
         [(brcond RC:$ra, bb:$addr)], IIBranch> {
  
  // Cpu0AsmWriter.inc
  void Cpu0InstPrinter::printInstruction(const MCInst *MI, raw_ostream &O) {
  ...
    case 3:
    // CMP, JEQ, JGE, JGT, JLE, JLT, JNE
    printOperand(MI, 1, O); 
    break;
  */
  static DecodeStatus DecodeBranchTarget(MCInst &Inst,
                       unsigned Insn,
                       uint64_t Address,
                       const void *Decoder) {
    int BranchOffset = fieldFromInstruction(Insn, 0, 24);
    if (BranchOffset > 0x8fffff)
      BranchOffset = -1*(0x1000000 - BranchOffset);
    Inst.addOperand(MCOperand::CreateReg(CPURegsTable[0]));
    Inst.addOperand(MCOperand::CreateImm(BranchOffset));
    return MCDisassembler::Success;
  }
  
  static DecodeStatus DecodeJumpRelativeTarget(MCInst &Inst,
                     unsigned Insn,
                     uint64_t Address,
                     const void *Decoder) {
  
    int JumpOffset = fieldFromInstruction(Insn, 0, 24);
    if (JumpOffset > 0x8fffff)
    JumpOffset = -1*(0x1000000 - JumpOffset);
    Inst.addOperand(MCOperand::CreateImm(JumpOffset));
    return MCDisassembler::Success;
  }
  
  static DecodeStatus DecodeJumpAbsoluteTarget(MCInst &Inst,
                     unsigned Insn,
                     uint64_t Address,
                     const void *Decoder) {
  
    unsigned JumpOffset = fieldFromInstruction(Insn, 0, 24);
    Inst.addOperand(MCOperand::CreateImm(JumpOffset));
    return MCDisassembler::Success;
  }
  
  static DecodeStatus DecodeSimm16(MCInst &Inst,
                   unsigned Insn,
                   uint64_t Address,
                   const void *Decoder) {
    Inst.addOperand(MCOperand::CreateImm(SignExtend32<16>(Insn)));
    return MCDisassembler::Success;
  }
  

As above code, it add directory Disassembler for handling the obj to assembly 
code reverse translation. So, add Disassembler/Cpu0Disassembler.cpp and modify 
the CMakeList.txt and LLVMBuild.txt to build with directory Disassembler and 
enable the disassembler table generated by "has_disassembler = 1". 
Most of code is handled by the table of \*.td files defined. 
Not every instruction in \*.td can be disassembled without trouble even though 
they can be translated into assembly and obj successfully. 
For those cannot be disassembled, LLVM supply the **"let DecoderMethod"** 
keyword to allow programmers implement their decode function. 
In Cpu0 example, we define function DecodeCMPInstruction(), DecodeBranchTarget()
and DecodeJumpAbsoluteTarget() in Cpu0Disassembler.cpp and tell the LLVM table 
driven system by write **"let DecoderMethod = ..."** in the corresponding 
instruction definitions or ISD node of Cpu0InstrInfo.td. 
LLVM will call these DecodeMethod when user use Disassembler job in tools, like 
``llvm-objdump -d``.
You can check the comments above these DecodeMethod functions to see how it 
work.
For the CMP instruction, since there are 3 operand $rc, $ra and $rb occurs in 
CmpInstr<...>, and the assembler print $ra and $rb. 
LLVM table generate system will print operand 1 and 2 
($ra and $rb) in the table generated function printInstruction(). 
The operand 0 ($rc) didn't be printed in printInstruction() since assembly 
print $ra and $rb only. 
In the CMP decode function, we didn't decode shamt field because we 
don't want it to be displayed and it's not in the assembler print pattern of 
Cpu0InstrInfo.td.

The RET (Cpu0ISD::Ret) and JR (ISD::BRIND) are both for "ret" instruction. 
The former is for instruction encode in assembly and obj while the latter is 
for decode in disassembler. 
The IR node Cpu0ISD::Ret is created in LowerReturn() which called at function 
exit point.

Now, run 9/1/Cpu0 with command ``llvm-objdump -d ch7_1_1.cpu0.o`` will get 
the following result.

.. code-block:: bash

  JonathantekiiMac:InputFiles Jonathan$ /Users/Jonathan/llvm/test/cmake_debug_
  build/bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=obj 
  ch7_1_1.bc -o ch7_1_1.cpu0.o
  JonathantekiiMac:InputFiles Jonathan$ /Users/Jonathan/llvm/test/cmake_debug_
  build/bin/Debug/llvm-objdump -d ch7_1_1.cpu0.o
  
  ch7_1_1.cpu0.o: file format ELF32-CPU0
  
  Disassembly of section .text:
  .text:
       0: 09 dd ff d8                                   addiu $sp, $sp, -40
       4: 09 30 00 00                                   addiu $3, $zero, 0
       8: 01 3d 00 24                                   st  $3, 36($sp)
       c: 01 3d 00 20                                   st  $3, 32($sp)
      10: 09 20 00 01                                   addiu $2, $zero, 1
      14: 01 2d 00 1c                                   st  $2, 28($sp)
      18: 09 40 00 02                                   addiu $4, $zero, 2
      1c: 01 4d 00 18                                   st  $4, 24($sp)
      20: 09 40 00 03                                   addiu $4, $zero, 3
      24: 01 4d 00 14                                   st  $4, 20($sp)
      28: 09 40 00 04                                   addiu $4, $zero, 4
      2c: 01 4d 00 10                                   st  $4, 16($sp)
      30: 09 40 00 05                                   addiu $4, $zero, 5
      34: 01 4d 00 0c                                   st  $4, 12($sp)
      38: 09 40 00 06                                   addiu $4, $zero, 6
      3c: 01 4d 00 08                                   st  $4, 8($sp)
      40: 09 40 00 07                                   addiu $4, $zero, 7
      44: 01 4d 00 04                                   st  $4, 4($sp)
      48: 09 40 00 08                                   addiu $4, $zero, 8
      4c: 01 4d 00 00                                   st  $4, 0($sp)
      50: 00 4d 00 20                                   ld  $4, 32($sp)
      54: 10 43 00 00                                   cmp $4, $3
      58: 21 00 00 10                                   jne 16
      5c: 26 00 00 00                                   jmp 0
      60: 00 4d 00 20                                   ld  $4, 32($sp)
      64: 09 44 00 01                                   addiu $4, $4, 1
      68: 01 4d 00 20                                   st  $4, 32($sp)
      6c: 00 4d 00 1c                                   ld  $4, 28($sp)
      70: 10 43 00 00                                   cmp $4, $3
      74: 20 00 00 10                                   jeq 16
      78: 26 00 00 00                                   jmp 0
      7c: 00 4d 00 1c                                   ld  $4, 28($sp)
      80: 09 44 00 01                                   addiu $4, $4, 1
      84: 01 4d 00 1c                                   st  $4, 28($sp)
      88: 00 4d 00 18                                   ld  $4, 24($sp)
      8c: 10 42 00 00                                   cmp $4, $2
      90: 22 00 00 10                                   jlt 16
      94: 26 00 00 00                                   jmp 0
      98: 00 4d 00 18                                   ld  $4, 24($sp)
      9c: 09 44 00 01                                   addiu $4, $4, 1
      a0: 01 4d 00 18                                   st  $4, 24($sp)
      a4: 00 4d 00 14                                   ld  $4, 20($sp)
      a8: 10 43 00 00                                   cmp $4, $3
      ac: 22 00 00 10                                   jlt 16
      b0: 26 00 00 00                                   jmp 0
      b4: 00 4d 00 14                                   ld  $4, 20($sp)
      b8: 09 44 00 01                                   addiu $4, $4, 1
      bc: 01 4d 00 14                                   st  $4, 20($sp)
      c0: 09 40 ff ff                                   addiu $4, $zero, -1
      c4: 00 5d 00 10                                   ld  $5, 16($sp)
      c8: 10 54 00 00                                   cmp $5, $4
      cc: 23 00 00 10                                   jgt 16
      d0: 26 00 00 00                                   jmp 0
      d4: 00 4d 00 10                                   ld  $4, 16($sp)
      d8: 09 44 00 01                                   addiu $4, $4, 1
      dc: 01 4d 00 10                                   st  $4, 16($sp)
      e0: 00 4d 00 0c                                   ld  $4, 12($sp)
      e4: 10 43 00 00                                   cmp $4, $3
      e8: 23 00 00 10                                   jgt 16
      ec: 26 00 00 00                                   jmp 0
      f0: 00 3d 00 0c                                   ld  $3, 12($sp)
      f4: 09 33 00 01                                   addiu $3, $3, 1
      f8: 01 3d 00 0c                                   st  $3, 12($sp)
      fc: 00 3d 00 08                                   ld  $3, 8($sp)
     100: 10 32 00 00                                   cmp $3, $2
     104: 23 00 00 10                                   jgt 16
     108: 26 00 00 00                                   jmp 0
     10c: 00 3d 00 08                                   ld  $3, 8($sp)
     110: 09 33 00 01                                   addiu $3, $3, 1
     114: 01 3d 00 08                                   st  $3, 8($sp)
     118: 00 3d 00 04                                   ld  $3, 4($sp)
     11c: 10 32 00 00                                   cmp $3, $2
     120: 22 00 00 10                                   jlt 16
     124: 26 00 00 00                                   jmp 0
     128: 00 2d 00 04                                   ld  $2, 4($sp)
     12c: 09 22 00 01                                   addiu $2, $2, 1
     130: 01 2d 00 04                                   st  $2, 4($sp)
     134: 00 2d 00 04                                   ld  $2, 4($sp)
     138: 00 3d 00 00                                   ld  $3, 0($sp)
     13c: 10 32 00 00                                   cmp $3, $2
     140: 25 00 00 10                                   jge 16
     144: 26 00 00 00                                   jmp 0
     148: 00 2d 00 00                                   ld  $2, 0($sp)
     14c: 09 22 00 01                                   addiu $2, $2, 1
     150: 01 2d 00 00                                   st  $2, 0($sp)
     154: 00 2d 00 1c                                   ld  $2, 28($sp)
     158: 00 3d 00 20                                   ld  $3, 32($sp)
     15c: 10 32 00 00                                   cmp $3, $2
     160: 20 00 00 10                                   jeq 16
     164: 26 00 00 00                                   jmp 0
     168: 00 2d 00 20                                   ld  $2, 32($sp)
     16c: 09 22 00 01                                   addiu $2, $2, 1
     170: 01 2d 00 20                                   st  $2, 32($sp)
     174: 00 2d 00 20                                   ld  $2, 32($sp)
     178: 09 dd 00 28                                   addiu $sp, $sp, 40
     17c: 2c 00 00 00                                   ret $zero


.. _section Handle $gp register in PIC addressing mode:
	http://jonathan2251.github.com/lbd/funccall.html#handle-gp-register-in-pic-addressing-mode


.. [#] http://en.wikipedia.org/wiki/Executable_and_Linkable_Format

.. [#] http://jonathan2251.github.com/lbd/install.html#install-other-tools-on-imac

.. [#] Leland Beck, System Software: An Introduction to Systems Programming. 

.. [#] http://ccckmit.wikidot.com/lk:aout

.. [#] http://ccckmit.wikidot.com/lk:objfile

.. [#] http://ccckmit.wikidot.com/lk:elf

.. [#] http://lld.llvm.org/

