// clang -c ch4_6.cpp -emit-llvm -o ch4_6.bc
// /Users/Jonathan/llvm/test/cmake_debug_build/bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=asm ch4_6.bc -o ch4_6.cpu0.s
// /Users/Jonathan/llvm/test/cmake_debug_build/bin/Debug/llc -march=cpu0 -view-isel-dags -view-sched-dags -relocation-model=pic -filetype=asm ch4_6.bc -o ch4_6.cpu0.s

int main()
{
  int b = 11;
//  unsigned int b = 11;
  
  b = (b+1)%12;
  
  return b;
}
