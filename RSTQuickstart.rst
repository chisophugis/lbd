The reStructuredText skill used in this book
=============================================

Build reStructuredText by command sphinx-build. 
Reference <http://sphinx-doc.org/.

Currently skills/setting use in this document

1. Font
  Bold **bold**
  Command ``cp -f source dest``

2. hyper link
  `Building LLVM with CMake`_
    .. _Building LLVM with CMake: http://llvm.org/docs/CMake.html?highlight=cmake

3. figure

  for example:
  
  Shown as as :ref:`_install_f12`.
  
  .. _install_f12: 
  .. figure:: ../Fig/install/12.png
    :height: 158 px
    :width: 1104 px
    :scale: 90 %
    :align: center
  
    Edit .profile and save .profile to /Users/Jonathan/

4. Code fragment and terminal io

for example:

  .. code-block:: c++
  
    //  Cpu0ISelLowering.cpp
    ...
      // %hi/%lo relocation
      SDValue GAHi = DAG.getTargetGlobalAddress(GV, dl, MVT::i32, 0,
                            Cpu0II::MO_ABS_HI);
      SDValue GALo = DAG.getTargetGlobalAddress(GV, dl, MVT::i32, 0,
                            Cpu0II::MO_ABS_LO);
      SDValue HiPart = DAG.getNode(Cpu0ISD::Hi, dl, VTs, &GAHi, 1);
      SDValue Lo = DAG.getNode(Cpu0ISD::Lo, dl, MVT::i32, GALo);
      return DAG.getNode(ISD::ADD, dl, MVT::i32, HiPart, Lo);

  .. code-block:: bash
  
    118-165-16-22:InputFiles Jonathan$ /Users/Jonathan/llvm/3.1.test/cpu0/1/
    cmake_debug_build/bin/Debug/llc -march=cpu0 -debug -relocation-model=pic 
    -filetype=asm ch5_3.bc -o ch5_3.cpu0.s
    ...
  
6. Use hyper link in reference our book section. But use "section name" of 
   `web link`_ to reference outside web section. Because I find the hyper link 
   for reference section of LLVM is changed from version to version.

