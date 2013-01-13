.. _sec-appendix-installing:

Appendix A: Getting Started: Installing LLVM and the Cpu0 example code
======================================================================

In this chapter, we will run through how to set up LLVM using if you are using 
Mac OS X or Linux.  When discussing Mac OS X, we are using Apple's Xcode IDE 
(version 4.5.1) running on Mac OS X Mountain Lion (version 10.8) to modify and 
build LLVM from source, and we will be debugging using lldb.  
We cannot debug our LLVM builds within Xcode at the 
moment, but if you have experience with this, please contact us and help us 
build documentation that covers this.  For Linux machines, we are building and 
debugging (using gdb) our LLVM installations on a Fedora 17 system.  We will 
not be using an IDE for Linux, but once again, if you have experience building/
debugging LLVM using Eclipse or other major IDEs, please contact the authors. 
For information on using ``cmake`` to build LLVM, please refer to the "Building 
LLVM with CMake" [#]_ documentation for further information. 
We are using cmake version 2.8.9.

We will install two llvm directories in this chapter. One is the directory 
llvm/3.1/ which contains the clang, clang++ compiler we will use to translate 
the C/C++ input file into llvm IR. 
The other is the directory llvm/3.1.test/cpu0/1 which contains our cpu0 backend 
program and without clang and clang++.

.. todo:: Find information on debugging LLVM within Xcode for Macs.
.. todo:: Find information on building/debugging LLVM within Eclipse for Linux.


Setting Up Your Mac
-------------------

Installing LLVM, Xcode and cmake
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. todo:: Fix centering for figure captions.

Please download LLVM version 3.1 (llvm, clang, compiler-rf) from the 
"LLVM Download Page" [#]_. Then extract them using 
``tar -zxvf {llvm-3.1.src.tar, clang-3.1.src.tar, compiler-rt-3.1.src.tar}``,
and change the llvm source code root directory into src. 
After that, move the clang source code to src/tools/clang, and move the 
compiler-rt source to src/project/compiler-rt as shown in :ref:`install_f1`.

.. _install_f1: 
.. figure:: ../Fig/install/1.png
	:align: center

	LLVM, clang, compiler-rt source code positions on Mac OS X

Next, copy the LLVM source to /Users/Jonathan/llvm/3.1/src by executing the 
terminal command ``cp -rf /Users/Jonathan/Documents/llvmSrc/src /Users/Jonathan/
llvm/3.1/.``.

Install Xcode from the Mac App Store. Then install cmake, which can be found 
here: [#]_. 
Before installing cmake, make sure you can install applications you download 
from the Internet. Open "System Preferences"->"Security & Privacy." Click the 
lock to make changes, and under "Allow applications downloaded from:" select 
the radio button next to "Anywhere." See :ref:`install_f2` below for an 
illustration. You may want to revert this setting after installing cmake.

.. _install_f2:
.. figure:: ../Fig/install/2.png
	:align: center

	Adjusting Mac OS X security settings to allow cmake installation.
	
Alternatively, you can mount the cmake .dmg image file you downloaded, right
-click (or 
control-click) the cmake .pkg package file and click "Open." Mac OS X will ask y
ou if you 
are sure you want to install this package, and you can click "Open" to start the 
installer.

.. stop 12/5/12 10PM (just a bookmark for me to continue from)

Create LLVM.xcodeproj by cmake Graphic UI
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

We install llvm source code with clang on directory /Users/Jonathan/llvm/3.1/ 
in last section.
Now, will generate the LLVM.xcodeproj in this chapter.

Currently, we cannot do debug by lldb with cmake graphic UI operations depicted 
in this section, but we can do debug by lldb with "section Create LLVM.xcodeproj 
of supporting cpu0 by terminal cmake command" [#]_. 
Even with that, let's build LLVM project with cmake graphic UI since this LLVM 
directory contains the release version for clang and clang++ execution file. 
First, create LLVM.xcodeproj as 
:ref:`install_f3`, then click **configure** button to enter :ref:`install_f4`, 
and then click **Done** button to get :ref:`install_f5`.

.. _install_f3:
.. figure:: ../Fig/install/3.png
	:align: center

	Start to create LLVM.xcodeproj by cmake

.. _install_f4:
.. figure:: ../Fig/install/4.png
	:align: center

	Create LLVM.xcodeproj by cmake – Set option to generate Xcode project

.. _install_f5:
.. figure:: ../Fig/install/5.png
	:align: center

	Create LLVM.xcodeproj by cmake – Before Adjust CMAKE_INSTALL_NAME_TOOL


Click OK from :ref:`install_f5` and select Cmake 2.8-9.app for CMAKE_INSTALL_NAM
E_TOOL by click the right side button **“...”** of that row to get 
:ref:`install_f6`.

.. _install_f6:
.. figure:: ../Fig/install/6.png
	:align: center

	Select Cmake 2.8-9.app

Click Configure button to get :ref:`install_f7`.

.. _install_f7:
.. figure:: ../Fig/install/7.png
	:align: center

	Click cmake Configure button first time

Check CLANG_BUILD_EXAMPLES, LLVM_BUILD_EXAMPLES, and uncheck LLVM_ENABLE_PIC as 
:ref:`install_f8`.

.. _install_f8:
.. figure:: ../Fig/install/8.png
	:align: center

	Check CLANG_BUILD_EXAMPLES, LLVM_BUILD_EXAMPLES, and uncheck 
	LLVM_ENABLE_PIC in cmake

Click Configure button again. If the output result message has no red color, 
then click Generate button to get :ref:`install_f9`.

.. _install_f9:
.. figure:: ../Fig/install/9.png
	:align: center

	Click cmake Generate button second time

Build llvm by Xcode
~~~~~~~~~~~~~~~~~~~

Now, LLVM.xcodeproj is created. Open the cmake_debug_build/LLVM.xcodeproj by 
Xcode and click menu **“Product – Build”** as :ref:`install_f10`.

.. _install_f10:
.. figure:: ../Fig/install/10.png
	:align: center

	Click Build button to build LLVM.xcodeproj by Xcode

After few minutes of build, the clang, llc, llvm-as, ..., can be found in 
cmake_debug_build/bin/Debug/ as follows.

.. code-block:: bash

  118-165-65-128:Debug Jonathan$ pwd
  /Users/Jonathan/llvm/3.1/cpu0/1/cmake_debug_build/bin/Debug
  118-165-65-128:Debug Jonathan$ ls
  BrainF            clang             llvm-ld
  ExceptionDemo     clang++           llvm-link
  Fibonacci         clang-check       llvm-mc
  FileCheck         clang-interpreter llvm-nm
  FileUpdate        clang-tblgen      llvm-objdump
  HowToUseJIT       count             llvm-prof
  Kaleidoscope-Ch2  diagtool          llvm-ranlib
  Kaleidoscope-Ch3  llc               llvm-readobj
  Kaleidoscope-Ch4  lli               llvm-rtdyld
  Kaleidoscope-Ch5  llvm-ar           llvm-size
  Kaleidoscope-Ch6  llvm-as           llvm-stress
  Kaleidoscope-Ch7  llvm-bcanalyzer   llvm-stub
  ModuleMaker       llvm-config       llvm-tblgen
  ParallelJIT       llvm-cov          macho-dump
  arcmt-test        llvm-diff         not
  bugpoint          llvm-dis          opt
  c-arcmt-test      llvm-dwarfdump    yaml-bench
  c-index-test      llvm-extract
  118-165-65-128:Debug Jonathan$ 

To access those execution files, edit .profile (if you .profile not exists, 
please create file .profile), save .profile to /Users/Jonathan/, and enable 
$PATH by command ``source .profile`` as follows. 
Please add path /Applications//Xcode.app/Contents/Developer/usr/bin to .profile 
if you didn't add it after Xcode download.

.. code-block:: bash

  118-165-65-128:~ Jonathan$ pwd
  /Users/Jonathan
  118-165-65-128:~ Jonathan$ cat .profile 
  export PATH=$PATH:/Applications/Xcode.app/Contents/Developer/usr/bin:/Applicatio
  ns/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/:/Ap
  plications/Graphviz.app/Contents/MacOS/:/Users/Jonathan/llvm/3.1/cmake_debug_bui
  ld/bin/Debug
  export WORKON_HOME=$HOME/.virtualenvs
  source /usr/local/bin/virtualenvwrapper.sh # where Homebrew places it
  export VIRTUALENVWRAPPER_VIRTUALENV_ARGS='--no-site-packages' # optional
  118-165-65-128:~ Jonathan$ 

Create LLVM.xcodeproj of supporting cpu0 by terminal cmake command
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

We have installed llvm with clang on directory llvm/3.1/. 
Now, we want to install llvm with our cpu0 backend code on directory 
llvm/3.1.test/cpu0/1 in this section.

In "section Create LLVM.xcodeproj by cmake Graphic UI" [#]_, we create 
LLVM.xcodeproj by cmake graphic UI. 
We can create LLVM.xcodeproj by ``cmake`` command on terminal also. 
Now, let's repeat above steps to create llvm/3.1.test with cpu0 modified code 
, and check the copy is effected by ``grep -R "Cpu0" .|more`` as follows,

.. code-block:: bash

  118-165-65-128:3.1.test Jonathan$ pwd
  /Users/Jonathan/llvm/3.1.test
  118-165-65-128:3.1.test Jonathan$ mkdir cpu0
  118-165-65-128:3.1.test Jonathan$ cd cpu0/
  118-165-65-128:cpu0 Jonathan$ mkdir 1
  118-165-65-128:cpu0 Jonathan$ cd 1
  118-165-65-128:1 Jonathan$ cp -rf /Users/Jonathan/llvm/3.1/src .
  118-165-65-128:1 Jonathan$ cp -rf /Users/Jonathan/LLVMBackendTutorialExampleCod
  e/src_files_modify/src .
  118-165-65-128:1 Jonathan$ cd src
  118-165-65-128:src Jonathan$ grep -R "Cpu0" .|more
  ./cmake/config-ix.cmake:  set(LLVM_NATIVE_ARCH Cpu0)
  ./CMakeLists.txt:  Cpu0
  ./include/llvm/MC/MCExpr.h:    VK_Cpu0_GPREL,
  ./include/llvm/MC/MCExpr.h:    VK_Cpu0_GOT_CALL,
  ./include/llvm/MC/MCExpr.h:    VK_Cpu0_GOT16,
  ./include/llvm/MC/MCExpr.h:    VK_Cpu0_GOT,
  ./include/llvm/MC/MCExpr.h:    VK_Cpu0_ABS_HI,
  ./include/llvm/MC/MCExpr.h:    VK_Cpu0_ABS_LO,
  ./include/llvm/MC/MCExpr.h://    VK_Cpu0_ABS,
  ./include/llvm/MC/MCExpr.h:    VK_Cpu0_TLSGD,
  ./include/llvm/MC/MCExpr.h:    VK_Cpu0_TLSLDM,
  ./include/llvm/MC/MCExpr.h:    VK_Cpu0_DTPREL_HI,
  ./include/llvm/MC/MCExpr.h:    VK_Cpu0_DTPREL_LO,
  ./include/llvm/MC/MCExpr.h:    VK_Cpu0_GOTTPREL,
  ./include/llvm/MC/MCExpr.h:    VK_Cpu0_TPREL_HI,
  ./include/llvm/MC/MCExpr.h:    VK_Cpu0_TPREL_LO,
  ./include/llvm/MC/MCExpr.h:    VK_Cpu0_GPOFF_HI,
  ./include/llvm/MC/MCExpr.h:    VK_Cpu0_GPOFF_LO,
  ./include/llvm/MC/MCExpr.h:    VK_Cpu0_GOT_DISP,
  ./include/llvm/MC/MCExpr.h:    VK_Cpu0_GOT_PAGE,
  ./include/llvm/MC/MCExpr.h:    VK_Cpu0_GOT_OFST 
  ./include/llvm/Support/ELF.h:// Cpu0 Specific e_flags
  ./include/llvm/Support/ELF.h:// ELF Relocation types for Cpu0
  ./lib/MC/MCDwarf.cpp:  // AT_language, a 4 byte value.  We use DW_LANG_Cpu0_Ass
  embler as the dwarf2
  ./lib/MC/MCDwarf.cpp://  MCOS->EmitIntValue(dwarf::DW_LANG_Cpu0_Assembler, 2);
  ./lib/MC/MCELFStreamer.cpp:    case MCSymbolRefExpr::VK_Cpu0_TLSGD:
  ./lib/MC/MCELFStreamer.cpp:    case MCSymbolRefExpr::VK_Cpu0_GOTTPREL:
  ./lib/MC/MCELFStreamer.cpp:    case MCSymbolRefExpr::VK_Cpu0_TPREL_HI:
  ./lib/MC/MCELFStreamer.cpp:    case MCSymbolRefExpr::VK_Cpu0_TPREL_LO:
  ./lib/MC/MCExpr.cpp:  case VK_Cpu0_GPREL: return "GPREL";
  ./lib/MC/MCExpr.cpp:  case VK_Cpu0_GOT_CALL: return "GOT_CALL";
  ./lib/MC/MCExpr.cpp:  case VK_Cpu0_GOT16: return "GOT16";
  ./lib/MC/MCExpr.cpp:  case VK_Cpu0_GOT: return "GOT";
  ./lib/MC/MCExpr.cpp:  case VK_Cpu0_ABS_HI: return "ABS_HI";
  ./lib/MC/MCExpr.cpp:  case VK_Cpu0_ABS_LO: return "ABS_LO";
  ./lib/MC/MCExpr.cpp:  case VK_Cpu0_TLSGD: return "TLSGD";
  ./lib/MC/MCExpr.cpp:  case VK_Cpu0_TLSLDM: return "TLSLDM";
  ./lib/MC/MCExpr.cpp:  case VK_Cpu0_DTPREL_HI: return "DTPREL_HI";
  ./lib/MC/MCExpr.cpp:  case VK_Cpu0_DTPREL_LO: return "DTPREL_LO";
  ./lib/MC/MCExpr.cpp:  case VK_Cpu0_GOTTPREL: return "GOTTPREL";
  ./lib/MC/MCExpr.cpp:  case VK_Cpu0_TPREL_HI: return "TPREL_HI";
  ./lib/MC/MCExpr.cpp:  case VK_Cpu0_TPREL_LO: return "TPREL_LO";
  ./lib/MC/MCExpr.cpp:  case VK_Cpu0_GPOFF_HI: return "GPOFF_HI";
  ./lib/MC/MCExpr.cpp:  case VK_Cpu0_GPOFF_LO: return "GPOFF_LO";
  ./lib/MC/MCExpr.cpp:  case VK_Cpu0_GOT_DISP: return "GOT_DISP";
  ./lib/MC/MCExpr.cpp:  case VK_Cpu0_GOT_PAGE: return "GOT_PAGE";
  ./lib/MC/MCExpr.cpp:  case VK_Cpu0_GOT_OFST: return "GOT_OFST";
  ./lib/Target/LLVMBuild.txt:subdirectories = ARM CellSPU CppBackend Hexagon MBla
  ze MSP430 Mips Cpu0 PTX PowerPC Sparc X86 XCore
  118-165-65-128:src Jonathan$ 

Now, copy cpu0 example code from LLVMBackendTutorial/2/Cpu0 to src/lib/Target/, 
and please remove src/tools/clang since it will waste time to build clang for 
our working Cpu0 changes, as follows,

.. code-block:: bash

  118-165-65-128:src Jonathan$ cd lib/Target/
  118-165-65-128:Target Jonathan$ pwd
  /Users/Jonathan/llvm/3.1.test/cpu0/1/src/lib/Target
  118-165-65-128:Target Jonathan$ 
  118-165-65-128:Target Jonathan$ cp -rf /Users/Jonathan/LLVMBackendTutorialExampleCode/2/Cpu0 .
  118-165-65-128:Target Jonathan$ ls
  ARM       Sparc
  CMakeLists.txt      Target.cpp
  CellSPU       TargetData.cpp
  CppBackend      TargetELFWriterInfo.cpp
  Cpu0        TargetInstrInfo.cpp
  Hexagon       TargetIntrinsicInfo.cpp
  LLVMBuild.txt     TargetJITInfo.cpp
  MBlaze        TargetLibraryInfo.cpp
  MSP430        TargetLoweringObjectFile.cpp
  Makefile      TargetMachine.cpp
  Mangler.cpp     TargetMachineC.cpp
  Mips        TargetRegisterInfo.cpp
  PTX       TargetSubtargetInfo.cpp
  PowerPC       X86
  README.txt      XCore
  118-165-65-128:Target Jonathan$ cd ../..
  118-165-65-128:src Jonathan$ pwd
  /Users/Jonathan/llvm/3.1.test/cpu0/4/src
  118-165-65-128:src Jonathan$ rm -rf tools/clang


Now, it's ready for building 1/Cpu0 code by command 
``cmake -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_C_COMPILER=clang -DCMAKE_BUILD_TYPE
=Debug -G "Xcode" ../src/`` as follows. 
Remind, currently, the ``cmake`` terminal command can work with lldb debug, but 
the "section Create LLVM.xcodeproj by cmake Graphic UI" [5]_ cannot.

.. code-block:: bash

  118-165-65-128:1 Jonathan$ pwd
  /Users/Jonathan/llvm/3.1.test/cpu0/1
  118-165-65-128:1 Jonathan$ mkdir cmake_debug_build
  118-165-65-128:1 Jonathan$ cd cmake_debug_build/
  118-165-65-128:cmake_debug_build Jonathan$ pwd
  /Users/Jonathan/llvm/3.1.test/cpu0/1/cmake_debug_build
  118-165-65-128:cmake_debug_build Jonathan$ cmake -DCMAKE_CXX_COMPILER=clang++ 
  -DCMAKE_C_COMPILER=clang -DCMAKE_BUILD_TYPE=Debug -G "Xcode" ../src/
  -- The C compiler identification is Clang 4.1.0
  ...
  -- Targeting ARM
  -- Targeting CellSPU
  -- Targeting CppBackend
  -- Targeting Hexagon
  -- Targeting Mips
  -- Targeting Cpu0
  -- Targeting MBlaze
  -- Targeting MSP430
  -- Targeting PowerPC
  -- Targeting PTX
  -- Targeting Sparc
  -- Targeting X86
  -- Targeting XCore
  -- Configuring done
  -- Generating done
  -- Build files have been written to: /Users/Jonathan/llvm/3.1.test/cpu0/1/cmake
  _debug_build
  118-165-65-128:cmake_debug_build Jonathan$ 

Since Xcode use clang compiler and lldb instead of gcc and gdb, we can run lldb 
debug as follows, 

.. code-block:: bash

  118-165-65-128:InputFiles Jonathan$ pwd
  /Users/Jonathan/LLVMBackendTutorialExampleCode/InputFiles
  118-165-65-128:InputFiles Jonathan$ clang -c ch3.cpp -emit-llvm -o ch3.bc
  118-165-65-128:InputFiles Jonathan$ /Users/Jonathan/llvm/3.1.test/cpu0/1/
  cmake_debug_build/bin/Debug/llc -march=mips -relocation-model=pic -filetype=asm 
  ch3.bc -o ch3.mips.s
  118-165-65-128:InputFiles Jonathan$ lldb -- /Users/Jonathan/llvm/3.1.test/cpu0/
  1/cmake_debug_build/bin/Debug/llc -march=mips -relocation-model=pic -filetype=
  asm ch3.bc -o ch3.mips.s
  Current executable set to '/Users/Jonathan/llvm/3.1.test/cpu0/1/cmake_debug_bui
  ld/bin/Debug/llc' (x86_64).
  (lldb) b MipsTargetInfo.cpp:19
  breakpoint set --file 'MipsTargetInfo.cpp' --line 19
  Breakpoint created: 1: file ='MipsTargetInfo.cpp', line = 19, locations = 1
  (lldb) run
  Process 6058 launched: '/Users/Jonathan/llvm/3.1.test/cpu0/1/cmake_debug_build/
  bin/Debug/llc' (x86_64)
  Process 6058 stopped
  * thread #1: tid = 0x1c03, 0x000000010077f231 llc`LLVMInitializeMipsTargetInfo 
  + 33 at MipsTargetInfo.cpp:20, stop reason = breakpoint 1.1
    frame #0: 0x000000010077f231 llc`LLVMInitializeMipsTargetInfo + 33 at 
    MipsTargetInfo.cpp:20
     17   
     18   extern "C" void LLVMInitializeMipsTargetInfo() {
     19     RegisterTarget<Triple::mips,
  -> 20           /*HasJIT=*/true> X(TheMipsTarget, "mips", "Mips");
     21   
     22     RegisterTarget<Triple::mipsel,
     23           /*HasJIT=*/true> Y(TheMipselTarget, "mipsel", "Mipsel");
  (lldb) n
  Process 6058 stopped
  * thread #1: tid = 0x1c03, 0x000000010077f24f llc`LLVMInitializeMipsTargetInfo 
  + 63 at MipsTargetInfo.cpp:23, stop reason = step over
    frame #0: 0x000000010077f24f llc`LLVMInitializeMipsTargetInfo + 63 at 
    MipsTargetInfo.cpp:23
     20           /*HasJIT=*/true> X(TheMipsTarget, "mips", "Mips");
     21   
     22     RegisterTarget<Triple::mipsel,
  -> 23           /*HasJIT=*/true> Y(TheMipselTarget, "mipsel", "Mipsel");
     24   
     25     RegisterTarget<Triple::mips64,
     26           /*HasJIT=*/false> A(TheMips64Target, "mips64", "Mips64 
     [experimental]");
  (lldb) print X
  (llvm::RegisterTarget<llvm::Triple::ArchType, true>) $0 = {}
  (lldb) quit
  118-165-65-128:InputFiles Jonathan$ 

About the lldb debug command, please reference [#]_ or lldb portal [#]_. 


Install other tools on iMac
~~~~~~~~~~~~~~~~~~~~~~~~~~~

These tools mentioned in this section is for coding and debug. 
You can work even without these tools. 
Files compare tools Kdiff3 came from web site [#]_. 
FileMerge is a part of Xcode, you can type FileMerge in Finder – Applications 
as :ref:`install_f11` and drag it into the Dock as :ref:`install_f12`.

.. _install_f11:
.. figure:: ../Fig/install/11.png
	:align: center

	Type FileMerge in Finder – Applications

.. _install_f12:
.. figure:: ../Fig/install/12.png
	:align: center

	Drag FileMege into the Dock

Download tool Graphviz for display llvm IR nodes in debugging, 
[#]_. 
We choose mountainlion as :ref:`install_f13` since our iMac is Mountain Lion.

.. _install_f13:
.. figure:: ../Fig/install/13.png
	:height: 738 px
	:width: 1181 px
	:scale: 80 %
	:align: center

	Download graphviz for llvm IR node display

After install Graphviz, please set the path to .profile. 
For example, we install the Graphviz in directory 
/Applications/Graphviz.app/Contents/MacOS/, so add this path to 
/User/Jonathan/.profile as follows,

.. code-block:: bash

	118-165-12-177:InputFiles Jonathan$ cat /Users/Jonathan/.profile
	export PATH=$PATH:/Applications/Xcode.app/Contents/Developer/usr/bin:
	/Applications/Graphviz.app/Contents/MacOS/:/Users/Jonathan/llvm/3.1/
	cmake_debug_build/bin/Debug

The Graphviz information for llvm is in 
the section "SelectionDAG Instruction Selection Process" of 
[#]_ and 
the section "Viewing graphs while debugging code" of 
[#]_.
TextWrangler is for edit file with line number display and dump binary file 
like the obj file, \*.o, that will be generated in chapter of Other 
instructions. 
You can download from App Store. 
To dump binary file, first, open the binary file, next, select menu 
**“File – Hex Front Document”** as :ref:`install_f14`. 
Then select **“Front document's file”** as :ref:`install_f15`.

.. _install_f14:
.. figure:: ../Fig/install/14.png
	:align: center

	Select Hex Dump menu

.. _install_f15:
.. figure:: ../Fig/install/15.png
	:align: center

	Select Front document's file in TextWrangler
	
Install binutils by command ``brew install binutils`` as follows,

.. code-block:: bash

  118-165-77-214:~ Jonathan$ brew install binutils
  ==> Downloading http://ftpmirror.gnu.org/binutils/binutils-2.22.tar.gz
  ######################################################################## 100.0%
  ==> ./configure --program-prefix=g --prefix=/usr/local/Cellar/binutils/2.22 
  --infodir=/usr/loca
  ==> make
  ==> make install
  /usr/local/Cellar/binutils/2.22: 90 files, 19M, built in 4.7 minutes
  118-165-77-214:~ Jonathan$ objdump --help
  -bash: objdump: command not found
  118-165-77-214:~ Jonathan$ man objdump
  No manual entry for objdump
  118-165-77-214:~ Jonathan$ ls /usr/local/Cellar/binutils/2.22
  COPYING     README      lib
  ChangeLog     bin       share
  INSTALL_RECEIPT.json    include       x86_64-apple-darwin12.2.0
  118-165-77-214:binutils-2.23 Jonathan$ ls /usr/local/Cellar/binutils/2.22/bin
  gaddr2line  gc++filt  gnm   gobjdump  greadelf  gstrings
  gar   gelfedit  gobjcopy  granlib gsize   gstrip


Setting Up Your Linux Machine
-----------------------------

Install LLVM 3.1 release build on Linux
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

First, install the llvm release build by,

	1) Untar llvm source, rename llvm source with src.
	
	2) Untar clang and move it src/tools/clang.
	
	3) Untar compiler-rt and move it to src/project/compiler-rt as :ref:`install_f16`.

.. _install_f16:
.. figure:: ../Fig/install/16.png
	:align: center

	Create llvm release build

Next, build with cmake command, ``cmake -DCMAKE_BUILD_TYPE=Release -DCLANG_BUILD
_EXAMPLES=ON -DLLVM_BUILD_EXAMPLES=ON -G "Unix Makefiles" ../src/``, as follows.

.. code-block:: bash

  [Gamma@localhost cmake_release_build]$ cmake -DCMAKE_BUILD_TYPE=Release 
  -DCLANG_BUILD_EXAMPLES=ON -DLLVM_BUILD_EXAMPLES=ON -G "Unix Makefiles" ../src/
  -- The C compiler identification is GNU 4.7.0
  ...
  -- Constructing LLVMBuild project information
  -- Targeting ARM
  -- Targeting CellSPU
  -- Targeting CppBackend
  -- Targeting Hexagon
  -- Targeting Mips
  -- Targeting MBlaze
  -- Targeting MSP430
  -- Targeting PowerPC
  -- Targeting PTX
  -- Targeting Sparc
  -- Targeting X86
  -- Targeting XCore
  -- Clang version: 3.1
  -- Found Subversion: /usr/bin/svn (found version "1.7.6") 
  -- Configuring done
  -- Generating done
  -- Build files have been written to: /usr/local/llvm/3.1/cmake_release_build

After cmake, run command ``make``, then you can get clang, llc, llvm-as, ..., 
in cmake_release_build/bin/ after a few tens minutes of build. Next, edit 
/home/Gamma/.bash_profile with adding /usr/local/llvm/3.1/cmake_release_build/
bin to PATH 
to enable the clang, llc, ..., command search path, as follows,

.. code-block:: bash

  [Gamma@localhost ~]$ pwd
  /home/Gamma
  [Gamma@localhost ~]$ cat .bash_profile
  # .bash_profile
  
  # Get the aliases and functions
  if [ -f ~/.bashrc ]; then
    . ~/.bashrc
  fi
  
  # User specific environment and startup programs
  
  PATH=$PATH:/usr/local/sphinx/bin:/usr/local/llvm/3.1/cmake_release_build/bin:
  /opt/mips_linux_toolchain_clang/mips_linux_toolchain/bin:$HOME/.local/bin:
  $HOME/bin
  
  export PATH
  [Gamma@localhost ~]$ source .bash_profile
  [Gamma@localhost ~]$ $PATH
  bash: /usr/lib64/qt-3.3/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:
  /usr/sbin:/usr/local/sphinx/bin:/opt/mips_linux_toolchain_clang/mips_linux_tool
  chain/bin:/home/Gamma/.local/bin:/home/Gamma/bin:/usr/local/sphinx/bin:/usr/
  local/llvm/3.1/cmake_release_build/bin


Install cpu0 debug build on Linux
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Make another copy /usr/local/llvm/3.1.test/cpu0/1/src for cpu0 debug working 
project 
according the following list steps, the corresponding commands shown as follows,

1) Enter /usr/local/llvm/3.1.test/cpu0/1 and 
``cp -rf /usr/local/llvm/3.1/src .``.

2) Update my modified files to support cpu0 by command, 
``cp -rf /home/Gamma/Gamma_flash/LLVMBackendTutorial/src_files_modify/src .``.

3) Check step 3 is effect by command 
``grep -R "Cpu0" . | more```. I add the Cpu0 backend support, so check with 
grep.

4) Enter src/lib/Target and copy example code LLVMBackendTutorialExampleCode/2/
Cpu0 to the directory by command ``cd lib/Target/`` and 
``cp -rf /home/Gamma/LLVMBackendTutorialExample/2/Cpu0 .``.

5) Remove clang from 3.1.test/cpu0/1/src/tools/clang, and mkdir 
3.1.test/cpu0/1/cmake_debug_build. Without this you will waste extra time for 
command ``make`` in cpu0 example code build.

.. code-block:: bash

  [Gamma@localhost 1]$ pwd
  /usr/local/llvm/3.1.test/cpu0/1
  [Gamma@localhost 1]$ cp -rf /usr/local/llvm/3.1/src .
  [Gamma@localhost Target]$ cd ../..
  [Gamma@localhost src]$ grep -R "Cpu0" .|more
  ./CMakeLists.txt:  Cpu0
  ./lib/Target/LLVMBuild.txt:subdirectories = ARM CellSPU CppBackend Hexagon MBlaz
  e MSP430 Mips Cpu0 PTX PowerPC Sparc X86 XCore
  ./lib/MC/MCExpr.cpp:  case VK_Cpu0_GPREL: return "GPREL";
  ./lib/MC/MCExpr.cpp:  case VK_Cpu0_GOT_CALL: return "GOT_CALL";
  ./lib/MC/MCExpr.cpp:  case VK_Cpu0_GOT16: return "GOT16";
  ./lib/MC/MCExpr.cpp:  case VK_Cpu0_GOT: return "GOT";
  ./lib/MC/MCExpr.cpp:  case VK_Cpu0_ABS_HI: return "ABS_HI";
  ./lib/MC/MCExpr.cpp:  case VK_Cpu0_ABS_LO: return "ABS_LO";
  ./lib/MC/MCExpr.cpp:  case VK_Cpu0_TLSGD: return "TLSGD";
  ./lib/MC/MCExpr.cpp:  case VK_Cpu0_TLSLDM: return "TLSLDM";
  ./lib/MC/MCExpr.cpp:  case VK_Cpu0_DTPREL_HI: return "DTPREL_HI";
  ./lib/MC/MCExpr.cpp:  case VK_Cpu0_DTPREL_LO: return "DTPREL_LO";
  ./lib/MC/MCExpr.cpp:  case VK_Cpu0_GOTTPREL: return "GOTTPREL";
  ./lib/MC/MCExpr.cpp:  case VK_Cpu0_TPREL_HI: return "TPREL_HI";
  ./lib/MC/MCExpr.cpp:  case VK_Cpu0_TPREL_LO: return "TPREL_LO";
  ./lib/MC/MCExpr.cpp:  case VK_Cpu0_GPOFF_HI: return "GPOFF_HI";
  ./lib/MC/MCExpr.cpp:  case VK_Cpu0_GPOFF_LO: return "GPOFF_LO";
  ./lib/MC/MCExpr.cpp:  case VK_Cpu0_GOT_DISP: return "GOT_DISP";
  ./lib/MC/MCExpr.cpp:  case VK_Cpu0_GOT_PAGE: return "GOT_PAGE";
  ./lib/MC/MCExpr.cpp:  case VK_Cpu0_GOT_OFST: return "GOT_OFST";
  ./lib/MC/MCELFStreamer.cpp:    case MCSymbolRefExpr::VK_Cpu0_TLSGD:
  ./lib/MC/MCELFStreamer.cpp:    case MCSymbolRefExpr::VK_Cpu0_GOTTPREL:
  ./lib/MC/MCELFStreamer.cpp:    case MCSymbolRefExpr::VK_Cpu0_TPREL_HI:
  ./lib/MC/MCELFStreamer.cpp:    case MCSymbolRefExpr::VK_Cpu0_TPREL_LO:
  ./lib/MC/MCDwarf.cpp:  // AT_language, a 4 byte value.  We use DW_LANG_Cpu0_Asse
  mbler as the dwarf2
  ./lib/MC/MCDwarf.cpp://  MCOS->EmitIntValue(dwarf::DW_LANG_Cpu0_Assembler, 2);
  ./include/llvm/MC/MCExpr.h:    VK_Cpu0_GPREL,
  ./include/llvm/MC/MCExpr.h:    VK_Cpu0_GOT_CALL,
  ./include/llvm/MC/MCExpr.h:    VK_Cpu0_GOT16,
  ./include/llvm/MC/MCExpr.h:    VK_Cpu0_GOT,
  ./include/llvm/MC/MCExpr.h:    VK_Cpu0_ABS_HI,
  ./include/llvm/MC/MCExpr.h:    VK_Cpu0_ABS_LO,
  ./include/llvm/MC/MCExpr.h://    VK_Cpu0_ABS,
  ./include/llvm/MC/MCExpr.h:    VK_Cpu0_TLSGD,
  ./include/llvm/MC/MCExpr.h:    VK_Cpu0_TLSLDM,
  ./include/llvm/MC/MCExpr.h:    VK_Cpu0_DTPREL_HI,
  ./include/llvm/MC/MCExpr.h:    VK_Cpu0_DTPREL_LO,
  ./include/llvm/MC/MCExpr.h:    VK_Cpu0_GOTTPREL,
  ./include/llvm/MC/MCExpr.h:    VK_Cpu0_TPREL_HI,
  ./include/llvm/MC/MCExpr.h:    VK_Cpu0_TPREL_LO,
  ./include/llvm/MC/MCExpr.h:    VK_Cpu0_GPOFF_HI,
  ./include/llvm/MC/MCExpr.h:    VK_Cpu0_GPOFF_LO,
  ./include/llvm/MC/MCExpr.h:    VK_Cpu0_GOT_DISP,
  ./include/llvm/MC/MCExpr.h:    VK_Cpu0_GOT_PAGE,
  ./include/llvm/MC/MCExpr.h:    VK_Cpu0_GOT_OFST 
  ./include/llvm/Support/ELF.h:// Cpu0 Specific e_flags
  ./include/llvm/Support/ELF.h:// ELF Relocation types for Cpu0
  ./cmake/config-ix.cmake:  set(LLVM_NATIVE_ARCH Cpu0)
  [Gamma@localhost src]$ cd lib/Target/
  [Gamma@localhost Target]$ cp -rf /home/Gamma/Gamma_flash/LLVMBackendTutorial/LLVMBackendTutorialExampleCode/2/Cpu0 .
  [Gamma@localhost Target]$ ls
  ARM             Mips                     TargetIntrinsicInfo.cpp
  CellSPU         MSP430                   TargetJITInfo.cpp
  CMakeLists.txt  PowerPC                  TargetLibraryInfo.cpp
  CppBackend      PTX                      TargetLoweringObjectFile.cpp
  Cpu0            README.txt               TargetMachineC.cpp
  Hexagon         Sparc                    TargetMachine.cpp
  LLVMBuild.txt   Target.cpp               TargetRegisterInfo.cpp
  Makefile        TargetData.cpp           TargetSubtargetInfo.cpp
  Mangler.cpp     TargetELFWriterInfo.cpp  X86
  MBlaze          TargetInstrInfo.cpp      XCore
  [Gamma@localhost Target]$ cd ../..
  [Gamma@localhost src]$ rm -rf tools/clang

Now, go into directory 3.1.test/cpu0/1, create directory cmake_debug_build and 
do cmake 
like build the 3.1 release, but we do Debug build and use clang as our compiler 
instead, 
as follows,

.. code-block:: bash

  [Gamma@localhost src]$ cd ..
  [Gamma@localhost 1]$ pwd
  /usr/local/llvm/3.1.test/cpu0/1
  [Gamma@localhost 1]$ mkdir cmake_debug_build
  [Gamma@localhost 1]$ cd cmake_debug_build/
  [Gamma@localhost cmake_debug_build]$ cmake 
  -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_C_COMPILER=clang
  -DCMAKE_BUILD_TYPE=Debug -G "Unix Makefiles" ../src/
  -- The C compiler identification is Clang 3.1.0
  -- The CXX compiler identification is Clang 3.1.0
  -- Check for working C compiler: /usr/local/llvm/3.1/cmake_release_build/bin/cla
  ng
  -- Check for working C compiler: /usr/local/llvm/3.1/cmake_release_build/bin/cla
  ng
   -- works
  -- Detecting C compiler ABI info
  -- Detecting C compiler ABI info - done
  -- Check for working CXX compiler: /usr/local/llvm/3.1/cmake_release_build/bin/c
  lang++
  -- Check for working CXX compiler: /usr/local/llvm/3.1/cmake_release_build/bin/c
  lang++
   -- works
  -- Detecting CXX compiler ABI info
  -- Detecting CXX compiler ABI info – done ...
  -- Targeting Mips
  -- Targeting Cpu0
  -- Targeting MBlaze
  -- Targeting MSP430
  -- Targeting PowerPC
  -- Targeting PTX
  -- Targeting Sparc
  -- Targeting X86
  -- Targeting XCore
  -- Configuring done
  -- Generating done
  -- Build files have been written to: /usr/local/llvm/3.1.test/cpu0/1/cmake_debug
  _build
  [Gamma@localhost cmake_debug_build]$

Then do make as follows,

.. code-block:: bash

  [Gamma@localhost cmake_debug_build]$ make
  Scanning dependencies of target LLVMSupport
  [ 0%] Building CXX object lib/Support/CMakeFiles/LLVMSupport.dir/APFloat.cpp.o
  [ 0%] Building CXX object lib/Support/CMakeFiles/LLVMSupport.dir/APInt.cpp.o
  [ 0%] Building CXX object lib/Support/CMakeFiles/LLVMSupport.dir/APSInt.cpp.o
  [ 0%] Building CXX object lib/Support/CMakeFiles/LLVMSupport.dir/Allocator.cpp.o
  [ 1%] Building CXX object lib/Support/CMakeFiles/LLVMSupport.dir/BlockFrequency.
  cpp.o ...
  Linking CXX static library ../../lib/libgtest.a
  [100%] Built target gtest
  Scanning dependencies of target gtest_main
  [100%] Building CXX object utils/unittest/CMakeFiles/gtest_main.dir/UnitTestMain
  /
  TestMain.cpp.o Linking CXX static library ../../lib/libgtest_main.a
  [100%] Built target gtest_main
  [Gamma@localhost cmake_debug_build]$
  
  Now, we are ready for the cpu0 backend development. We can run gdb debug as 
  follows. 
  If your setting has anything about gdb errors, please follow the errors indication 
  (maybe need to download gdb again). 
  Finally, try gdb as follows.

.. code-block:: bash

  [Gamma@localhost InputFiles]$ pwd
  /home/Gamma/LLVMBackendTutorialExampleCode/InputFiles
  [Gamma@localhost InputFiles]$ clang -c ch3.cpp -emit-llvm -o ch3.bc
  [Gamma@localhost InputFiles]$ gdb -args /usr/local/llvm/3.1.test/cpu0/1/
  cmake_debug_build/bin/llc -march=cpu0 -relocation-model=pic -filetype=obj 
  ch3.bc -o ch3.cpu0.o
  GNU gdb (GDB) Fedora (7.4.50.20120120-50.fc17)
  Copyright (C) 2012 Free Software Foundation, Inc.
  License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
  This is free software: you are free to change and redistribute it.
  There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
  and "show warranty" for details.
  This GDB was configured as "x86_64-redhat-linux-gnu".
  For bug reporting instructions, please see:
  <http://www.gnu.org/software/gdb/bugs/>...
  Reading symbols from /usr/local/llvm/3.1.test/cpu0/1/cmake_debug_build/bin/llc.
  ..done.
  (gdb) break MipsTargetInfo.cpp:19
  Breakpoint 1 at 0xd54441: file /usr/local/llvm/3.1.test/cpu0/1/src/lib/Target/
  Mips/TargetInfo/MipsTargetInfo.cpp, line 19.
  (gdb) run
  Starting program: /usr/local/llvm/3.1.test/cpu0/1/cmake_debug_build/bin/llc 
  -march=cpu0 -relocation-model=pic -filetype=obj ch3.bc -o ch3.cpu0.o
  [Thread debugging using libthread_db enabled]
  Using host libthread_db library "/lib64/libthread_db.so.1".
  
  Breakpoint 1, LLVMInitializeMipsTargetInfo ()
    at /usr/local/llvm/3.1.test/cpu0/1/src/lib/Target/Mips/TargetInfo/MipsTar
    getInfo.cpp:20
  20          /*HasJIT=*/true> X(TheMipsTarget, "mips", "Mips");
  (gdb) next
  23          /*HasJIT=*/true> Y(TheMipselTarget, "mipsel", "Mipsel");
  (gdb) print X
  $1 = {<No data fields>}
  (gdb) quit
  A debugging session is active.
  
    Inferior 1 [process 10165] will be killed.
  
  Quit anyway? (y or n) y
  [Gamma@localhost InputFiles]$ 



Install other tools on Linux
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Download Graphviz from [#]_ according your 
Linux distribution. Files compare tools Kdiff3 came from web site [8]_. 



.. [#] http://llvm.org/docs/CMake.html?highlight=cmake

.. [#] http://llvm.org/releases/download.html#3.1

.. [#] http://www.cmake.org/cmake/resources/software.html

.. [#] http://jonathan2251.github.com/lbd/install.html#create-llvm-xcodeproj-of-supporting-cpu0-by-terminal-cmake-command

.. [#] http://jonathan2251.github.com/lbd/install.html#create-llvm-xcodeproj-by-cmake-graphic-ui

.. [#] http://lldb.llvm.org/lldb-gdb.html

.. [#] http://lldb.llvm.org/

.. [#] http://kdiff3.sourceforge.net

.. [#] http://www.graphviz.org/Download_macos.php

.. [#] http://llvm.org/docs/CodeGenerator.html

.. [#] http://llvm.org/docs/ProgrammersManual.html

.. [#] http://www.graphviz.org/Download..php