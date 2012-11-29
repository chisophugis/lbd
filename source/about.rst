
About
=====

Authors
-------


.. figure:: ../Fig/Author_ChineseName.png
	:align: right

Chen Chung-Shu
	gamma_chen@yahoo.com.tw

Anoushe Jamshidi
	ajamshidi@gmail.com


Revision history
----------------

Version 1, Released
	Chapter 1, 2, 3
Version 2, Released February 4, 2012
	Added Chapter 0, Section 3.3
	Correct some English & typing errors in book
Version 3, Released February 19, 2012
	Shift Chapter 0..2 to Chapter 1..3; Move Section 3.1, 3.2 to 4.1, 4.2; Move 	Section 3.3 to 5.1 Added Section 5.2 to 5.6; Added Chapter 6; Added Section 7.1 to 7.4
	Added first paragraph in Chapter 1; Added Section” 2.1 CPU0 processor architecture” and shift other sections in Chapter 2
	Correct some English & typing errors
Version 3.1.1, Released November 28, 2012
	Add Revision history
	Correct ldi instruction error (replace ldi instruction with addiu from the beginning and in the all example code)
	Move ldi instruction change from section 5.5 to 2.1
	Correct some English & typing errors

Licensing
---------
LLVM documentation license, To do...

Preface
-------

LLVM has a well structure for writing a back end. It provide a good frame work to add a new back end for a new CPU instruction set. However, it is harder in reading than front end documents in spite of back end has well documentation on it's web site. The point is LLVM front end documents include the tutorials. Allow user writing a front end compiler by following tutorial step by step, begin from simple and expand to complex more and more.

Knowledge is needed by a software engineer for his work. In computer industry, quick to learn is valuable. So, I write this document following the front end style. Start from scratch, then add more and more code in each chapter to expand it's function.

For simple, I write a back end named Cpu0 which is a simple RISC CPU designed for teaching purpose. Please refer to http://ccckmit.wikidot.com/ocs:cpu0 for it's instruction set. I put the cpu0 example code for this book in https://www.dropbox.com/sh/2pkh1fewlq2zag9/r9n4gnqPm7.

I reference llvm 3.1 Mips back end codes to write the cpu0 example code because I know Mips well more than other CPU. And since cpu0 has not defined it's Application Binary Interface (ABI), I borrow the ABI from the MIPS architecture.

Readers should know C++ well since LLVM is designed in C++, and is another state of the art example using the C++ OOP beautiful structure in compiler designed field in addition to QT in UI application. So, if you are a C++ advocate, maybe you will appreciate it, and give you a reason by real example to against people's wrong challenge that C++ OOP is not suit for system program like OS or compiler design.

I will introduce the related compiler knowledges on demand. So, you don't need to have the deep compiler knowledge for reading this book, concept is enough. But it will offset your debug time if you have the knowledge well.

Say sorry in advance for my English. I am a Chinese from Taiwan. It's very different between English and Chinese.
	
The book references the following materials in major,

tricore_llvm.pdf (get from internet).

http://llvm.org/docs/CodeGenerator.html

http://llvm.org/docs/TableGenFundamentals.html

http://llvm.org/docs/WritingAnLLVMBackend.html


