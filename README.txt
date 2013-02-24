~~ LLVM Backend Tutorial ~~

This is a fork of LLVM trunk for the purposes of developing the LLVM
Backend Tutorial in situ. Since the tutorial develops real code, it needs
to be in-tree so that the code (and tests, etc.) can be integrated and not
just live in the documentation.

The source of the tutorial is in `docs/BackendTutorial/`. If you just want
to read the tutorial an up-to-date built version can be found at
<http://jonathan2251.github.com/lbd/>.



Original LLVM README.txt is below:



Low Level Virtual Machine (LLVM)
================================

This directory and its subdirectories contain source code for the Low Level
Virtual Machine, a toolkit for the construction of highly optimized compilers,
optimizers, and runtime environments.

LLVM is open source software. You may freely distribute it under the terms of
the license agreement found in LICENSE.txt.

Please see the documentation provided in docs/ for further
assistance with LLVM, and in particular docs/GettingStarted.rst for getting
started with LLVM and docs/README.txt for an overview of LLVM's
documentation setup.

If you're writing a package for LLVM, see docs/Packaging.rst for our
suggestions.
