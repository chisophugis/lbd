// clang -c ch4_5.cpp -emit-llvm -o ch4_5.bc
// /Users/Jonathan/llvm/test/cmake_debug_build/bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=asm ch4_5.bc -o ch4_5.cpu0.s

int main()
{
  int b = 3;
  
  int* p = &b;

  return *p;
}
