// clang -c ch8_1.cpp -emit-llvm -o ch8_1.bc
// /Users/Jonathan/llvm/test/cmake_debug_build/bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=asm ch8_1.bc -o ch8_1.cpu0.s
// /Users/Jonathan/llvm/test/cmake_debug_build/bin/Debug/llc -march=mips -relocation-model=pic -filetype=asm ch8_1.bc -o ch8_1.mips.s

int sum_i(int x1, int x2, int x3, int x4, int x5, int x6)
{
  int sum = x1 + x2 + x3 + x4 + x5 + x6;
  
  return sum; 
}

int main()
{
  int a = sum_i(1, 2, 3, 4, 5, 6);
  
  return a;
}
