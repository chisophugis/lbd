.. _sec-runbackend:

Run backend
===========

This chapter will add LLVM AsmParser support first. 
With AsmParser, we can hand code the assembly language in C/C++ file and 
translate it into obj (elf format). 
With AsmParser support we can write a C++ main 
function as well as the boot code by assembly hand code, and translate this 
main()+bootcode() into obj file.
By combined with llvm-objdump support in last chapter, 
this main()+bootcode() elf can translated back to hex file format which include 
the disassembler code as comment. 
Further, we can design the Cpu0 with Verilog language tool and run the Cpu0 
backend on PC by feed the hex file and see the Cpu0 instructions execution 
result.


AsmParser support
------------------

Directory AsmParser include the assembly to obj translation.
Continue...