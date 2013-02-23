// clang -c ch6_1.cpp -emit-llvm -o ch6_1.bc
// /usr/local/llvm/test/cmake_debug_build/bin/llc -march=cpu0 -relocation-model=pic -filetype=asm ch6_1.bc -o ch6_1.cpu0.s
// /usr/local/llvm/test/cmake_debug_build/bin/llc -march=cpu0 -relocation-model=static -cpu0-islinux-format=false -filetype=asm ch6_1.bc -o ch6_1.cpu0.islinux-format-false.s
// /usr/local/llvm/test/cmake_debug_build/bin/llc -march=cpu0 -relocation-model=static -filetype=asm ch6_1.bc -o ch6_1.cpu0.static.s
// /usr/local/llvm/test/cmake_debug_build/bin/llc -march=cpu0 -relocation-model=pic -filetype=obj ch6_1.bc -o ch6_1.cpu0.o
// /usr/local/llvm/test/cmake_debug_build/bin/llc -march=cpu0 -relocation-model=static -filetype=obj ch6_1.bc -o ch6_1.cpu0.static.o

// /Users/Jonathan/llvm/test/cmake_debug_build/bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=asm ch6_1.bc -o ch6_1.cpu0.s
// /Users/Jonathan/llvm/test/cmake_debug_build/bin/Debug/llc -march=cpu0 -relocation-model=static -cpu0-islinux-format=false -filetype=asm ch6_1.bc -o ch6_1.cpu0.islinux-format-false.s
// /Users/Jonathan/llvm/test/cmake_debug_build/bin/Debug/llc -march=cpu0 -relocation-model=static -filetype=asm ch6_1.bc -o ch6_1.cpu0.static.s
// /Applications/Xcode.app/Contents/Developer/usr/bin/lldb -- /Users/Jonathan/llvm/test/cmake_debug_build/bin/Debug/llc -march=cpu0 -filetype=asm ch6_1.bc -o ch6_1.cpu0.s 

int gI = 100;
int main()
{
  int c = 0;

  c = gI;

  return c;
}

