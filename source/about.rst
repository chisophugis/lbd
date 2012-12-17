About
======

Authors
-------


.. figure:: ../Fig/Author_ChineseName.png
	:align: right

Chen Chung-Shu
	gamma_chen@yahoo.com.tw
	
	http://jonathan2251.github.com/web/index.html

Anoushe Jamshidi
	ajamshidi@gmail.com


Revision history
----------------

Version 3.1.1, Released November 28, 2012
	Add Revision history.
	Correct ldi instruction error (replace ldi instruction with addiu from the 
	beginning and in the all example code).
	Move ldi instruction change from section of "Adjust cpu0 instruction and 
	support type of local variable pointer" to Section ”CPU0 
	processor architecture”.
	Correct some English & typing errors.
Version 3.1.2, Released February 28, 2012
	Fix section 6.1 error by add “def : Pat<(brcond RC:$cond, bb:$dst), 
	(JNEOp (CMPOp RC:$cond, ZEROReg), bb:$dst)>;” in last pattern.
	Modify section 5.5
	Fix bug Cpu0InstrInfo.cpp SW to ST.
	Correct LW to LD; LB to LDB; SB to STB.

Licensing
---------
.. todo:: Add info about LLVM documentation licensing.

Preface
-------

.. start of original text (commented out, feel free to erase)
	LLVM has a well structure for writing a back end. It provide a good frame work to add 
	a new back end for a new CPU instruction set. However, it is harder in reading than 
	front end documents in spite of back end has well documentation on it's web site. 
	The point is LLVM front end documents include the tutorials. Allow user writing a 
	front end compiler by following tutorial step by step, begin from simple and expand to
	complex more and more.

.. Let's omit this paragraph.
	Knowledge is needed by a software engineer for his work. In computer industry, quick 
	to learn is valuable. So, I write this document following the front end style. Start 
	from scratch, then add more and more code in each chapter to expand it's function.

	For simple, I write a back end named Cpu0 which is a simple RISC CPU designed for 
	teaching purpose. Please refer to http://ccckmit.wikidot.com/ocs:cpu0 for it's 
	instruction set. I put the cpu0 example code for this book in 
	https://www.dropbox.com/sh/2pkh1fewlq2zag9/r9n4gnqPm7.

	I reference llvm 3.1 Mips back end codes to write the cpu0 example code because I know
	Mips well more than other CPU. And since cpu0 has not defined it's Application Binary 
	Interface (ABI), I borrow the ABI from the MIPS architecture.
	
	Readers should know C++ well since LLVM is designed in C++, and is another state of 
	the art example using the C++ OOP beautiful structure in compiler designed field in 
	addition to QT in UI application. So, if you are a C++ advocate, maybe you will 
	appreciate it, and give you a reason by real example to against people's wrong 
	challenge that C++ OOP is not suit for system program like OS or compiler design.

	I will introduce the related compiler knowledges on demand. So, you don't need to have 
	the deep compiler knowledge for reading this book, concept is enough. But it will 
	offset your debug time if you have the knowledge well.

.. Hopefully once we're done editing, this won't be necessary :)
	Say sorry in advance for my English. I am a Chinese from Taiwan. It's very different 
	between English and Chinese.
.. end original text
	
.. start of edited text

The LLVM Compiler Infrastructure provides a versatile structure for creating new
backends. Creating a new backend should not be too difficult once you 
familiarize yourself with this structure. However, the available backend 
documentation is fairly high level and leaves out many details. This tutorial 
will provide step-by-step instructions to write a new backend for a new target 
architecture from scratch. 

We will use the Cpu0 architecture as an example to build our new backend. Cpu0 
is a simple RISC architecture that has been designed for educational purposes. 
More information about Cpu0, including its instruction set, is available 
`here <http://ccckmit.wikidot.com/ocs:cpu0>`_. The Cpu0 example code referenced in
this book can be found `here <http://jonathan2251.github.com/lbd/LLVMBackendTutorialExampleCode.tar.gz>`_.
As you progress from one chapter to the next, you will incrementally build the 
backend's functionality.

This tutorial was written using the LLVM 3.1 Mips backend as a reference. Since 
Cpu0 is an educational architecture, it is missing some key pieces of 
documentation needed when developing a compiler, such as an Application Binary 
Interface (ABI). We implement our backend borrowing information from the Mips 
ABI as a guide. You may want to familiarize yourself with the relevant parts of 
the Mips ABI as you progress through this tutorial.
	

Prerequisites
-------------
Readers should be comfortable with the C++ language and Object-Oriented 
Programming concepts. LLVM has been developed and implemented in C++, and it is 
written in a modular way so that various classes can be adapted and reused as 
often as possible.

Already having conceptual knowledge of how compilers work is a plus, and if you 
already have implemented compilers in the past you will likely have no trouble 
following this tutorial. As this tutorial will build up an LLVM backend 
step-by-step, we will introduce important concepts as necessary.

This tutorial references the following materials.  We highly recommend you read 
these documents to get a deeper understanding of what the tutorial is teaching:

`The Architecture of Open Source Applications Chapter on LLVM <http://www.aosabook.org/en/llvm.html>`_

`LLVM's Target-Independent Code Generation documentation <http://llvm.org/docs/CodeGenerator.html>`_

`LLVM's TableGen Fundamentals documentation <http://llvm.org/docs/TableGenFundamentals.html>`_

`LLVM's Writing an LLVM Compiler Backend documentation <http://llvm.org/docs/WritingAnLLVMBackend.html>`_

`Description of the Tricore LLVM Backend <http://www.opus.ub.uni-erlangen.de/opus/volltexte/2010/1659/pdf/tricore_llvm.pdf>`_

Mips ABI document (Search for it on Google)

.. todo:: Find official link for Mips ABI.
