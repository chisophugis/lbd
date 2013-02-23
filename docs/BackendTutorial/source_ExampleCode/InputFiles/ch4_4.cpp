// clang -c ch4_4.cpp -emit-llvm -o ch4_4.bc
// /Users/Jonathan/llvm/test/cmake_debug_build/bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=asm ch4_4.bc -o ch4_4.cpu0.s

int main()
{
  int a = 1;
  int b = 2;
  int k = 0;
  unsigned int a1 = -5, f1 = 0;
  
  f1 = a1 / b;
  k = (a >> 2);

  return k;
}
