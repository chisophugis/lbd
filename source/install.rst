Install llvm and Cpu0 example code
==================================

Before start, I have one thing hope you to know. In fact, you can work with a backend program, even a new CPU, by porting from the similar existed llvm backend or from the existed llvm supported CPU which you familiar with. In that way, maybe it include redundant code. But it's OK since compiler is running on PC or Laptop which got a lots of memory. It's a style for real working in programming. It's a way to learn, I agree. The advantage of this approach came from the fact of most RISC CPUs have similar instruction set in concept and style. All you need to do is porting from an existing CPU into a similar instruction set of CPU with different OP code. According my experience, this solution has two shortage. First, this approach can make progress better in time at beginning, I agree. But the time will be offset in debug and maintenance. The backend program is a kind of system program which is a low level program and most of the functions is triggered by call back function or override function in C++. LLVM call these backend function at proper time. As you can imagine, it's not easy to track the program execution flow. It's harder to debug compare to the front end program which you can track the program flow easily because front end call llvm interface/function when it like to. And more harder and harder then the ordinary UI or high level application because backend is a system program. Second, by this approach you won't get a full knowledge in llvm backend programming. With full llvm backend knowledge equipment, you will find the backend programming is becoming easier and easier for your daily work, day by day. So, if you are a paid time llvm backend programmer, I suggest you learn llvm backend program from beginning when you got time. Of course, put the learning task on aside when you got scheduled job, and pike up the learning task back when your time is available. It's my opinion. Just do your choice.

I will show you how I install llvm in iMac and Linux in this chapter. Currently, I can build the llvm source code on iMac Xcode and do debug by lldb. I cannot do debug on IDE Xcode at this point, so if you know how to do debug LLVM on Xcode, please let me know by email. I really need that. In Linux, I can build and debug by gdb on Linux Fedora 17, and the same I don't know how to do debug on IDE like Eclips. About ``cmake`` for llvm please reference `Building LLVM with CMake`_ further. The Xcode version I use in this book is 4.5.1, cmake is 2.8.9.

.. _Building LLVM with CMake: http://llvm.org/docs/CMake.html?highlight=cmake

This book is still a work in progress, so sections may be incomplete, but
I hope you will enjoy it as it grows.

Install LLVM, Xcode and cmake on iMac
-------------------------------------

Please download llvm version 3.1 (llvm, clang, compiler-rf) from `llvm release download`_. Then, ``tar -zxvf llvm, clang, compiler-rt``, and change the llvm source code root directory into src. After that, move clang source code to src/tools/clang, move compiler-rt source to src/project/compiler-rt as Fig 1.1.

.. figure:: ../Fig/Fig1_1.png
	:align: center

	Fig 1.1 llvm, clang, compiler-rt source code position on iMac

Next, copy llvm source to /Users/Jonathan/llvm/3.1/src by terminal command ``cp -rf /Users/Jonathan/Documents/llvmSrc/src /Users/Jonathan/llvm/3.1/.``.

Install Xcode from App Store as well as cmake from http://www.cmake.org/cmake/resources/software.html. Before install cmake, check the “Anywhere” of “Allow applications download from” of “Security & Privacy” of “System Preferences” as Fig 1.2.

.. figure:: ../Fig/Fig1_2.png
	:align: center

	Fig 1.2  Adjust iMac to allow download cmake

Create LLVM.xcodeproj by cmake Graphic UI
-----------------------------------------

Currently, I cannot do debug by lldb with cmake graphic UI operations depicted in this section, but I can do debug by lldb with section “1.4 Create LLVM.xcodeproj of support cpu0 by terminal cmake command”. Even though, let's build LLVM project with cmake graphic UI now since this LLVM build is to build the release version for clang, llvm-as, llc, ..., execution command use, not for working backend program. First, create LLVM.xcodeproj as Fig 1.3, then click configure button to enter Fig 1.4, and then click Done button on Fig 1.4 to get Fig 1.5.

.. figure:: ../Fig/Fig1_3.png
	:align: center

	Fig 1.3 Start to create LLVM.xcodeproj by cmake

.. figure:: ../Fig/Fig1_4.png
	:align: center

	Fig 1.4 Create LLVM.xcodeproj by cmake – Set option to generate Xcode project

.. figure:: ../Fig/Fig1_5.png
	:align: center

	Fig 1.5 Create LLVM.xcodeproj by cmake – Before Adjust CMAKE_INSTALL_NAME_TOOL

Click OK from Fig 1.5 and select Cmake 2.8-9.app for CMAKE_INSTALL_NAME_TOOL by click the right side button “...” of that row in Fig 1.5 to get Fig 1.6.

.. figure:: ../Fig/Fig1_6.png
	:align: center

	Fig 1.6 select Cmake 2.8-9.app

Click Configure button in Fig 1.6 to get Fig 1.7.

.. figure:: ../Fig/Fig1_7.png
	:align: center

	Fig 1.7 Click cmake Configure button first time

Check CLANG_BUILD_EXAMPLES, LLVM_BUILD_EXAMPLES, and uncheck LLVM_ENABLE_PIC as Fig 1.8.

.. figure:: ../Fig/Fig1_8.png
	:align: center

	Fig 1.8 Check CLANG_BUILD_EXAMPLES, LLVM_BUILD_EXAMPLES, and uncheck LLVM_ENABLE_PIC in cmake

Click Configure button again. If the output result message has no red color, then click Generate button to get Fig 1.9.

.. figure:: ../Fig/Fig1_9.png
	:align: center

	Fig 1.9 Click cmake Generate button second time

Build llvm by Xcode
-------------------

Now, LLVM.xcodeproj is created. Open the cmake_debug_build/LLVM.xcodeproj by Xcode and click menu “Product – Build” as Fig 1.10.

.. figure:: ../Fig/Fig1_10.png
	:align: center

	Fig 1.10 Click Build button to build LLVM.xcodeproj by Xcode

After few minutes of build, the clang, llc, llvm-as, ..., can be found in cmake_debug_build/bin/Debug/ as Fig 1.11.

.. figure:: ../Fig/Fig1_11.png
	:align: center

	Fig 1.11 Execution files built by Xcode

	To access those execution files, edit .profile (if you .profile not exists, please create file .profile), save .profile to /Users/Jonathan/, and enable $PATH by command ``source .profile`` as Fig1.12. Please add path /Applications//Xcode.app/Contents/Developer/usr/bin to .profile if you didn't add it after Xcode download.

.. figure:: ../Fig/Fig1_12.png
	:align: center

	Fig 1.12 Edit .profile and save .profile to /Users/Jonathan/

Create LLVM.xcodeproj of supporting cpu0 by terminal ``cmake`` command
----------------------------------------------------------------------

In section 1.2, we create LLVM.xcodeproj by cmake graphic UI. We can create LLVM.xcodeproj by ``cmake`` command on terminal also. Now, let's repeat above steps to create llvm/3.1.test with cpu0 modified code as Fig 1.13.

.. figure:: ../Fig/Fig1_13.png
	:align: center

	Fig 1.13 create llvm/3.1.test with cpu0 modified code

/Users/Jonathan/Documents/Gamma_flash/LLVMBackendTutorial/src_files_modify/src/ contains the files I modified for cpu0 architecture. Copy it as Fig 1.13 to replace the original 3.1 source code for cpu0 backend support. After Fig 1.13, copy cpu0 example code from LLVMBackendTutorial/1/Cpu0 to src/lib/Target/ as Fig 1.14.

.. figure:: ../Fig/Fig1_14.png
	:align: center

	Fig 1.14 copy cpu0 example code from 1/Cpu0 to src/lib/Target/

Please remove src/tools/clang since it will waste time to build clang for our working Cpu0 changes. Now, it's ready for building 1/Cpu0 code by command ``cmake -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_C_COMPILER=clang -DCMAKE_BUILD_TYPE=Debug -G "Xcode" ../src/`` as Fig 1.15. Remind, currently, the ``cmake`` terminal command can work with lldb debug, but the section “1.2 cmake graphic UI steps” cannot.

.. figure:: ../Fig/Fig1_15.png
	:align: center

	Fig 1.15 Build llvm debug cpu0 working project by ``cmake`` terminal command

Since Xcode use clang compiler and lldb instead of gcc and gdb, we can run lldb debug as Fig 1.16. About the lldb debug command, please reference http://lldb.llvm.org/lldb-gdb.html or lldb portal http://lldb.llvm.org/.

.. figure:: ../Fig/Fig1_16.png
	:align: center

	Fig 1.16 Run lldb debug


Install other tools on iMac
---------------------------

These tools mentioned in this section is for coding and debug. You can work even without these tools. Files compare tools Kdiff3 http://kdiff3.sourceforge.net. FileMerge is a part of Xcode, you can type FileMerge in Finder – Applications as Fig 1.17 and drag it into the Dock as Fig 1.18.

.. figure:: ../Fig/Fig1_17.png
	:align: center

	Fig 1.17 Type FileMerge in Finder – Applications

.. figure:: ../Fig/Fig1_18.png
	:align: center

	Fig 1.18 Drag FileMege into the Dock

Download tool Graphviz for display llvm IR nodes in debugging, http://www.graphviz.org/Download_macos.php. I choose mountainlion as Fig 1.19 since my iMac is Mountain Lion.

.. figure:: ../Fig/Fig1_19.png
	:align: center

	Fig 1.19 Download graphviz for llvm IR node display

After install Graphviz, please set the path to .profile. For example, I install the Graphviz in directory /Applications/Graphviz.app/Contents/MacOS/, so add this path to /User/Jonathan/.profile as follows,

118-165-12-177:InputFiles Jonathan$ cat /Users/Jonathan/.profile
export PATH=$PATH:/Applications/Xcode.app/Contents/Developer/usr/bin:/Applications/Graphviz.app/Contents/MacOS/:/Users/Jonathan/l lvm/3.1/cmake_debug_build/bin/Debug

The Graphviz information for llvm is in http://llvm.org/docs/CodeGenerator.html? highlight=graph%20view and http://llvm.org/docs/ProgrammersManual.html#ViewGraph.
TextWrangler is for edit file with line number display and dump binary file like the obj file, \*.o, that will be generated in chapter 2. You can download from App Store. To dump binary file, first, open the binary file, next, select menu “File – Hex Front Document” as Fig 1.20. Then select “Front document's file” as Fig 1.21.

.. figure:: ../Fig/Fig1_20.png
	:align: center

	Fig 1.20 Select Hex Dump menu

.. figure:: ../Fig/Fig1_21.png
	:align: center

	Fig 1.21 Select Front document's file in TextWrangler



Install LLVM 3.1 release build on Linux
---------------------------------------

First, install the llvm release build by,
1) Untar llvm source, rename llvm source with src.
2) Untar clang and move it src/tools/clang.
3) Untar compiler-rt and move it to src/project/compiler-rt as Fig 1.22.

.. figure:: ../Fig/Fig1_22.png
	:align: center

	Fig 1.22 Create llvm release build

Next, build with cmake command, ``cmake -DCMAKE_BUILD_TYPE=Release -DCLANG_BUILD_EXAMPLES=ON -DLLVM_BUILD_EXAMPLES=ON -G "Unix Makefiles" ../src/``, shown in Fig 1.23.

.. figure:: ../Fig/Fig1_23.png
	:align: center

	Fig 1.23 Create llvm 3.1 release build

After cmake, run command ``make``, then you can get clang, llc, llvm-as, ..., in cmake_release_build/bin/ after a few tens minutes of build. Next, edit /home/Gamma/.bash_profile with adding /usr/local/llvm/3.1/cmake_release_build/bin to PATH to enable the clang, llc, ..., command search path, as shown in Fig 1.24.

.. figure:: ../Fig/Fig1_24.png
	:align: center

	Fig 1.24 Setup llvm command path


Install cpu0 debug build on Linux
---------------------------------

Make another copy /usr/local/llvm/3.1.test/cpu0/1/src for cpu0 debug working project according the following list steps, the corresponding commands shown in Fig 1.25:

1) Enter /usr/local/llvm/3.1.test/cpu0/1 and ``cp -rf /usr/local/llvm/3.1/src .``.

2) Update my modified files to support cpu0 by command, ``cp -rf /home/Gamma/Gamma_flash/LLVMBackendTutorial/src_files_modify/src .``.

3) Enter src/lib/Target and copy example code LLVMBackendTutorial/1/Cpu0 to the directory by command ``cd src/lib/Target/`` and ``cp -rf /home/Gamma/Gamma_flash/LLVMBackendTutorial/1/Cpu0 .``.

4) Go into directory 3.1.test/cpu0/1/src and Check step 3 is effect by command ``grep -R "Cpu0" . | more```. I add the Cpu0 backend support, so check with grep.

5) Remove clang from 3.1.test/cpu0/1/src/tools/clang, and mkdir 3.1.test/cpu0/1/cmake_debug_build. Without this you will waste extra time for command ``make`` in cpu0 example code build.

.. figure:: ../Fig/Fig1_25.png
	:align: center

	Fig 1.25 Create llvm 3.1 debug copy

Now, go into directory 3.1.test/cpu0/1, create directory cmake_debug_build and do cmake like build the 3.1 release, but we do Debug build and use clang as our compiler instead, as follows,

.. literalinclude:: ../terminal_io/1_1.txt

Then do make as follows,

.. literalinclude:: ../terminal_io/1_2.txt

Now, we are ready for the cpu0 backend development. We can run gdb debug as follows. If your setting has anything about gdb errors, please follow the errors indication (maybe need to download gdb again). Finally, try gdb as Fig 1.26.

.. figure:: ../Fig/Fig1_26.png
	:align: center

	Fig 1.26 Debug llvm cpu0 backend by gdb


.. _llvm release download:
	http://llvm.org/releases/download.html#3.1


