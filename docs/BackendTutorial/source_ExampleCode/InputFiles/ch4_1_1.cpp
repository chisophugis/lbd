// clang -c ch4_1_1.cpp -emit-llvm -o ch4_1_1.bc
// /usr/local/llvm/test/cmake_debug_build/bin/llc -march=cpu0 -relocation-model=pic -filetype=asm ch4_1.bc -o ch4_1.cpu0.s
// /usr/local/llvm/test/cmake_debug_build/bin/llc -march=cpu0 -relocation-model=pic -filetype=obj ch4_1.bc -o ch4_1.cpu0.o

// /Users/Jonathan/llvm/test/cmake_debug_build/bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=asm ch4_1_1.bc -o ch4_1_1.cpu0.s

int main()
{
  int a = 5;
  int b = 2;
  int c = 0;

  c = a + b;

  return c;
}

