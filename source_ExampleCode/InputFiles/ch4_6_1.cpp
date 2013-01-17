// clang -c ch4_6_1.cpp -emit-llvm -o ch4_6_1.bc
// /Users/Jonathan/llvm/test/cmake_debug_build/bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=asm ch4_6_1.bc -o ch4_6_1.cpu0.s

int main()
{
  int b = 11;
  int a = 12;

  b = (b+1)%a;
  
  return b;
}
