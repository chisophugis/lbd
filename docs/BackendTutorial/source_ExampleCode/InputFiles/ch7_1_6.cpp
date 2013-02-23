// clang -c ch7_1_6.cpp -emit-llvm -o ch7_1_6.bc
// /Users/Jonathan/llvm/test/cmake_debug_build/bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=asm ch7_1_6.bc -o ch7_1_6.cpu0.s

int main()
{
  int a = 3;
  
  if (a != 0)
    a++;
  goto L1;
  a++;
L1:
  a--;
    
  return a;
}
