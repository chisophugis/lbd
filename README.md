lbd: llvm backend document
===

This document aims to provide a simple, concise, and clear step-by-step tutorial
in creating a new LLVM backend from scratch.  It is written in reStructuredText,
and built using the Sphinx Python Documentation Generator.

If you would like to to view an up to date version of this book in your browser
without checking out and building the book, please visit: http://jonathan2251.github.com/lbd/


Notes on reStructuredText editing
=================================
Currently skills/setting use in this document

1. Font
	Bold **bold**
	Command ``cp -f source dest``

2. hyper link
	`Building LLVM with CMake`_
		.. _Building LLVM with CMake: http://llvm.org/docs/CMake.html?highlight=cmake

3. figure & table
	.. figure:: ../Fig/Fig1_1.png
		:align: center

		Fig 1.1 llvm, clang, compiler-rt source code position on iMac

	Minor issue: cannot show figure description at center

4. Code fragment and terminal io
	.. literalinclude:: ../terminal_io/2_1.txt
	.. literalinclude:: ../code_fragment/2_14.txt
	Minor issue: cannot set **bold** in literalinclude

5. LaTeX issue
	index.rst.latex_ok can generate latex which can generate pdf through iMac TexShop.
	index.rst.latex_not_ok cannot generate pdf through iMac TexShop.
	Chinese author name cannot appear in LaTeX, so Jonathan use .png file to display Chinese name.
	Author name can be display on more than one line by \\and, but will shift a little right on the second line.
	The Chinese name size is OK in html but too large in LaTeX.
