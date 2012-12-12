Cpu0 Instruction and LLVM Target Description
============================================

This chapter shows you the cpu0 instruction format first. 
Next, the llvm structure is introduced to you by copy and paste the related 
article from llvm web site. The llvm structure introduced here is extracted 
from the asop web site. You can read the whole article from the asop web site. 
After that we will show you how to write register and instruction definitions 
(Target Description File) which will be used in next chapter.

CPU0 processor architecture
---------------------------

We copy and redraw figures in english in this section. This 
`web site <http://ccckmit.wikidot.com/ocs:cpu0>`_ is chinese version and here 
is `english version 
<http://translate.google.com.tw/translate?js=n&prev=_t&hl=zh-TW&ie=UTF-8&layout=
2&eotf=1&sl=zh-CN&tl=en&u=http://ccckmit.wikidot.com/ocs:cpu0>`_.

Brief introduction
++++++++++++++++++

CPU0 is a 32-bit processor which has registers R0 .. R15, IR, MAR, MDR, etc., 
and its structure is shown below.

.. _llvmstructure_f1: 
.. figure:: ../Fig/llvmstructure/1.png
	:align: center

	The structure of the processor of CPU0

Uses of each register as follows:

.. _llvmstructure_t1: 
.. figure:: ../Table/llvmstructure/1.png
	:align: center

	Cpu0 registers table

Instruction Set for CPU0
++++++++++++++++++++++++

The CPU0 instruction divided into three types, L-type usually load the saved 
instruction, A-type arithmetic instruction-based J-type usually jump 
instruction, the following figure shows the three types of instruction encoding 
format.

.. _llvmstructure_f2: 
.. figure:: ../Fig/llvmstructure/2.png
	:align: center

	CPU0 three instruction formats

The following is the CPU0 processor's instruction table format

.. _llvmstructure_t2: 
.. figure:: ../Table/llvmstructure/2.png
	:align: center

	CPU0 instruction table

In the second edition of CPU0_v2 we fill the following command:

.. _llvmstructure_t3: 
.. figure:: ../Table/llvmstructure/3.png
	:align: center

	CPU0_v2 instruction table

Status register
+++++++++++++++

CPU0 status register contains the state of the N, Z, C, V, and I, T and other 
interrupt mode bit. 
Its structure is shown below.

.. _llvmstructure_f3: 
.. figure:: ../Fig/llvmstructure/3.png
	:align: center

	CPU0 status register

When CMP Ra, Rb instruction execution, the state flag will thus change.

If Ra> Rb, then the setting state of N = 0, Z = 0. 
If Ra <Rb, it will set the state of N = 1, Z = 0. 
If Ra = Rb, then the setting state of N = 0, Z = 1.

So conditional jump the JGT, JLT, JGE, JLE, JEQ, JNE instruction jumps N, Z 
flag in the status register.

The execution of the instruction step
+++++++++++++++++++++++++++++++++++++

CPU0 has three stage pipeline: Instruction fetch, Decode and Execution.

1) Instruction fetch

-	Action 1. The instruction fetch: IR = [PC]
-	Action 2. Update program counter: PC = PC + 4

2) Decode

-	Action 3. Decode: Control unit decodes IR, then set data flow switch 
	and ALU operation mode. 

3) Execute

-	Action 4. Execute: Data flow into ALU. After ALU done the operation, 
	the result stored back into destination register. 

Replace ldi instruction by addiu instruction
++++++++++++++++++++++++++++++++++++++++++++

We have recognized the ldi instruction is a bad design and replace it with mips 
instruction addiu. 
The reason we replace ldi with addiu is that ldi use only one register even 
though ldi is L type format and has two registers, as :ref:`llvmstructure_f4`. 
Mips addiu which allow programmer to do load constant to register like ldi, 
and add constant to a register. So, it's powerful and fully contains the ldi 
ability. 
These two instructions format as :ref:`llvmstructure_f4` and :ref:`llvmstructure_f5`.

.. _llvmstructure_f4: 
.. figure:: ../Fig/llvmstructure/4.png
	:align: center

	Cpu0 ldi instruction

.. _llvmstructure_f5: 
.. figure:: ../Fig/llvmstructure/5.png
	:align: center

	Mips addiu instruction format

From :ref:`llvmstructure_f4` and :ref:`llvmstructure_f5`, you can find ldi $Ra, 
5 can be replaced by addiu $Ra, $zero, 5. 
And more, addiu can do addiu $Ra, $Rb, 5 which add $Rb and 5 then save to $Ra, 
but ldi cannot. 
As a cpu design, it's common to redesign CPU instruction when find a better 
solution during design the compiler backend for that CPU. 
So, we add addiu instruction to cpu0. 
The cpu0 is my brother's work, I will find time to talk with him.

LLVM structure
--------------

Following came from `AOSA <http://www.aosabook.org/en/llvm.html>`_.

The most popular design for a traditional static compiler (like most C 
compilers) is the three phase design whose major components are the front end, 
the optimizer and the back end (:ref:`llvmstructure_f6`). 
The front end parses source code, checking it for errors, and builds a 
language-specific Abstract Syntax Tree (AST) to represent the input code. 
The AST is optionally converted to a new representation for optimization, and 
the optimizer and back end are run on the code.

.. _llvmstructure_f6: 
.. figure:: ../Fig/llvmstructure/6.png
	:align: center

	Tree major components of a Three Phase Compiler

The optimizer is responsible for doing a broad variety of transformations to 
try to improve the code's running time, such as eliminating redundant 
computations, and is usually more or less independent of language and target. 
The back end (also known as the code generator) then maps the code onto the 
target instruction set. 
In addition to making correct code, it is responsible for generating good code 
that takes advantage of unusual features of the supported architecture. 
Common parts of a compiler back end include instruction selection, register 
allocation, and instruction scheduling.

This model applies equally well to interpreters and JIT compilers. 
The Java Virtual Machine (JVM) is also an implementation of this model, which 
uses Java bytecode as the interface between the front end and optimizer.

The most important win of this classical design comes when a compiler decides 
to support multiple source languages or target architectures. 
If the compiler uses a common code representation in its optimizer, then a 
front end can be written for any language that can compile to it, and a back 
end can be written for any target that can compile from it, as shown in 
:ref:`llvmstructure_f7`.

.. _llvmstructure_f7: 
.. figure:: ../Fig/llvmstructure/7.png
	:align: center

	Retargetablity

With this design, porting the compiler to support a new source language (e.g., 
Algol or BASIC) requires implementing a new front end, but the existing 
optimizer and back end can be reused. 
If these parts weren't separated, implementing a new source language would 
require starting over from scratch, so supporting N targets and M source 
languages would need N*M compilers.

Another advantage of the three-phase design (which follows directly from 
retargetability) is that the compiler serves a broader set of programmers than 
it would if it only supported one source language and one target. 
For an open source project, this means that there is a larger community of 
potential contributors to draw from, which naturally leads to more enhancements 
and improvements to the compiler. 
This is the reason why open source compilers that serve many communities (like 
GCC) tend to generate better optimized machine code than narrower compilers 
like FreePASCAL. 
This isn't the case for proprietary compilers, whose quality is directly 
related to the project's budget. 
For example, the Intel ICC Compiler is widely known for the quality of code it 
generates, even though it serves a narrow audience.

A final major win of the three-phase design is that the skills required to 
implement a front end are different than those required for the optimizer and 
back end. 
Separating these makes it easier for a "front-end person" to enhance and 
maintain their part of the compiler. 
While this is a social issue, not a technical one, it matters a lot in 
practice, particularly for open source projects that want to reduce the barrier 
to contributing as much as possible.

The most important aspect of its design is the LLVM Intermediate Representation 
(IR), which is the form it uses to represent code in the compiler. 
LLVM IR is designed to host mid-level analyses and transformations that you 
find in the optimizer section of a compiler. 
It was designed with many specific goals in mind, including supporting 
lightweight runtime optimizations, cross-function/interprocedural 
optimizations, whole program analysis, and aggressive restructuring 
transformations, etc. 
The most important aspect of it, though, is that it is itself defined as a 
first class language with well-defined semantics. 
To make this concrete, here is a simple example of a .ll file:

.. literalinclude:: ../code_fragment/llvmstructure/1.txt

As you can see from this example, LLVM IR is a low-level RISC-like virtual 
instruction set. 
Like a real RISC instruction set, it supports linear sequences of simple 
instructions like add, subtract, compare, and branch. 
These instructions are in three address form, which means that they take some 
number of inputs and produce a result in a different register. 
LLVM IR supports labels and generally looks like a weird form of assembly 
language.

Unlike most RISC instruction sets, LLVM is strongly typed with a simple type 
system (e.g., i32 is a 32-bit integer, i32** is a pointer to pointer to 32-bit 
integer) and some details of the machine are abstracted away. 
For example, the calling convention is abstracted through call and ret 
instructions and explicit arguments. 
Another significant difference from machine code is that the LLVM IR doesn't 
use a fixed set of named registers, it uses an infinite set of temporaries 
named with a % character.

Beyond being implemented as a language, LLVM IR is actually defined in three 
isomorphic forms: the textual format above, an in-memory data structure 
inspected and modified by optimizations themselves, and an efficient and dense 
on-disk binary "bitcode" format. 
The LLVM Project also provides tools to convert the on-disk format from text to 
binary: llvm-as assembles the textual .ll file into a .bc file containing the 
bitcode goop and llvm-dis turns a .bc file into a .ll file.

The intermediate representation of a compiler is interesting because it can be 
a "perfect world" for the compiler optimizer: unlike the front end and back end 
of the compiler, the optimizer isn't constrained by either a specific source 
language or a specific target machine. 
On the other hand, it has to serve both well: it has to be designed to be easy 
for a front end to generate and be expressive enough to allow important 
optimizations to be performed for real targets.
	

Target Description td
---------------------

The "mix and match" approach allows target authors to choose what makes sense 
for their architecture and permits a large amount of code reuse across 
different targets. 
This brings up another challenge: each shared component needs to be able to 
reason about target specific properties in a generic way. 
For example, a shared register allocator needs to know the register file of 
each target and the constraints that exist between instructions and their 
register operands. 
LLVM's solution to this is for each target to provide a target description 
in a declarative domain-specific language (a set of .td files) processed by the 
tblgen tool. 
The (simplified) build process for the x86 target is shown in 
:ref:`llvmstructure_f8`.

.. _llvmstructure_f8: 
.. figure:: ../Fig/llvmstructure/8.png
	:align: center

	Simplified x86 Target Definition

The different subsystems supported by the .td files allow target authors to 
build up the different pieces of their target. 
For example, the x86 back end defines a register class that holds all of its 
32-bit registers named "GR32" (in the .td files, target specific definitions 
are all caps) like this:

.. literalinclude:: ../code_fragment/llvmstructure/2.txt


Write td (Target Description)
-----------------------------

The llvm using .td file (Target Description) to describe register and 
instruction format. 
After finish the .td files, llvm can generate C++ files (\*.inc) by llvm-tblgen 
tools. 
The \*.inc file is a text file (C++ file) with table driven in concept. 
http://llvm.org/docs/TableGenFundamentals.html is the web site.

Every back end has a target td which define it's own target information. 
File td is like C++ in syntax. For example the Cpu0.td as follows,

.. literalinclude:: ../code_fragment/llvmstructure/3.txt

The registers td named Cpu0RegisterInfo.td included by Cpu0.td is defined as 
follows,

.. literalinclude:: ../code_fragment/llvmstructure/4.txt

In C++ the data layout is declared by class. Declaration tells the variable 
layout; definition allocates memory for the variable. 
For example,

.. literalinclude:: ../code_fragment/llvmstructure/5.txt

Just like C++ class, the keyword “class” is used for declaring data structure 
layout. 
``Cpu0Reg<string n>`` declare a derived class from ``Register<n>`` which is 
declared by llvm already, where n is the argument of type string. 
In addition to inherited from all the fields of Register class, Cpu0Reg add a 
new field "Num" of type 4 bits. 
Namespace is same with  C++ namespace. 
“Def” is used by define(instance) a concrete variable.

As above, we define a ZERO register which type is Cpu0GPRReg, it's field Num 
is 0 (4 bits) and field n is “ZERO” (declared in Register class). 
Note the use of “let” expressions to override values that are initially defined 
in a superclass. For example, let Namespace = “Cpu0” in class Cpu0Reg, will 
override Namespace declared in Register class. 
The Cpu0RegisterInfo.td also define that CPURegs is a variable for type of 
RegisterClass, where the RegisterClass is a llvm built-in class. 
The type of RegisterClass is a set/group of Register, so CPURegs variable is 
defined with a set of Register.

The cpu0 instructions td is named to Cpu0InstrInfo.td which contents as follows,

.. literalinclude:: ../code_fragment/llvmstructure/6.txt

The Cpu0InstrFormats.td is included by Cpu0InstInfo.td as follows,

.. literalinclude:: ../code_fragment/llvmstructure/7.txt

ADDiu is class ArithLogicI inherited from FL, can expand and get member value 
as follows,

.. literalinclude:: ../code_fragment/llvmstructure/8.txt

Expand with FL further,

.. literalinclude:: ../code_fragment/llvmstructure/9.txt

Expand with Cpu0Inst further,

.. literalinclude:: ../code_fragment/llvmstructure/10.txt

It's a lousy process. 
Similarly, LW and ST instruction definition can be expanded in this way. 
Please notify the Pattern =  
[(set CPURegs:$ra, (add RC:$rb, immSExt16:$imm16))] which include keyword 
“add”. 
We will use it in DAG transformations later. 


Write cmake file
----------------

Target/Cpu0 directory has two files CMakeLists.txt and LLVMBuild.txt, 
contents as follows,

.. literalinclude:: ../code_fragment/llvmstructure/11.txt

LLVMBuild.txt files are written in a simple variant of the INI or configuration 
file format. 
Comments are prefixed by ``#`` in both files. 
We explain the setting for these 2 files in comments. 
Please spend a little time to read it.

Both CMakeLists.txt and LLVMBuild.txt coexist in sub-directories 
``MCTargetDesc`` and ``TargetInfo``. 
Their contents indicate they will generate Cpu0Desc and Cpu0Info libraries. 
After building, you will find three libraries: ``libLLVMCpu0CodeGen.a``, 
``libLLVMCpu0Desc.a`` and ``libLLVMCpu0Info.a`` in lib/ of your build 
directory. 
For more details please see 
`Building LLVM with CMake <http://llvm.org/docs/CMake.html>`_ and 
`LLVMBuild Guide <http://llvm.org/docs/LLVMBuild.html>`_.

Target Registration
-------------------

You must also register your target with the TargetRegistry, which is what other 
LLVM tools use to be able to lookup and use your target at runtime. 
The TargetRegistry can be used directly, but for most targets there are helper 
templates which should take care of the work for you.

All targets should declare a global Target object which is used to represent 
the target during registration. 
Then, in the target's TargetInfo library, the target should define that object 
and use the RegisterTarget template to register the target. 
For example, the file TargetInfo/Cpu0TargetInfo.cpp register TheCpu0Target for 
big endian and TheCpu0elTarget for little endian, as follows.

.. literalinclude:: ../code_fragment/llvmstructure/12.txt

Files Cpu0TargetMachine.cpp and MCTargetDesc/Cpu0MCTargetDesc.cpp just define 
the empty initialize function since we register nothing in them for this moment.

.. literalinclude:: ../code_fragment/llvmstructure/13.txt

http://llvm.org/docs/WritingAnLLVMBackend.html#TargetRegistration for reference.


Build libraries and td
----------------------

The llvm3.1 source code is put in /usr/local/llvm/3.1/src and have llvm3.1 
release-build in /usr/local/llvm/3.1/configure_release_build. 
About how to build llvm, please refer http://clang.llvm.org/get_started.html. 
We made a copy from /usr/local/llvm/3.1/src to 
/usr/local/llvm/3.1.test/cpu0/1/src for working with my Cpu0 target back end. 
Sub-directories src is for source code and cmake_debug_build is for debug 
build directory.

Except directory src/lib/Target/Cpu0, there are a couple of files modified to 
support cpu0 new Target. 
Please check files in src_files_modify/src/. 
You can search cpu0 without case sensitive to find the modified files by 
command,

.. literalinclude:: ../terminal_io/llvmstructure/1.txt

You can update your llvm working copy by,

.. literalinclude:: ../terminal_io/llvmstructure/2.txt

Now, run the cmake and make command to build td (the following cmake command is 
for my setting),

.. literalinclude:: ../terminal_io/llvmstructure/3.txt

After build, you can type command llc –version to find the cpu0 backend,

.. literalinclude:: ../terminal_io/llvmstructure/4.txt

The “llc -version” can display “cpu0” and “cpu0el” message, because the 
following code from file TargetInfo/Cpu0TargetInfo.cpp what in 
`section Target Registration`_ we made. 
List them as follows again,

.. literalinclude:: ../code_fragment/llvmstructure/14.txt

Now try to do llc command to compile input file ch3.cpp as follows,

.. literalinclude:: ../code_fragment/llvmstructure/15.txt

First step, compile it with clang and get output ch3.bc as follows,

.. literalinclude:: ../terminal_io/llvmstructure/5.txt

Next step, transfer bitcode .bc to human readable text format as follows,

.. literalinclude:: ../terminal_io/llvmstructure/6.txt

Now, compile ch3.bc into ch3.cpu0.s, we get the error message as follows,

.. literalinclude:: ../terminal_io/llvmstructure/7.txt

Currently we just define target td files (Cpu0.td, Cpu0RegisterInfo.td, ...). 
According to LLVM structure, we need to define our target machine and include 
those td related files. 
The error message say we didn't define our target machine.


.. _section Target Registration:
    http://jonathan2251.github.com/lbd/llvmstructure.html#target-registration
