// clang -c ch4_2.cpp -emit-llvm -o ch4_2.bc
// /Users/Jonathan/llvm/test/cmake_debug_build/bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=asm ch4_2.bc -o ch4_2.cpu0.s

int main()
{
  int a = 5;
  int b = 0;
  
  b = !a;
  
  return b;
}

