// clang -c ch8_3.cpp -emit-llvm -o ch8_3.bc
// /Users/Jonathan/llvm/3.1.test/cpu0/1/cmake_debug_build/bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=asm ch8_3.bc -o ch8_3.cpu0.s
// /Users/Jonathan/llvm/3.1.test/cpu0/1/cmake_debug_build/bin/Debug/llc -march=mips -relocation-model=pic -filetype=asm ch8_3.bc -o ch8_3.mips.s

//#include <stdio.h>
#include <stdarg.h>

int sum_i(int amount, ...)
{
  int i = 0;
  int val = 0;
  int sum = 0;
	
  va_list vl;
  va_start(vl, amount);
  for (i = 0; i < amount; i++)
  {
    val = va_arg(vl, int);
    sum += val;
  }
  va_end(vl);
  
  return sum; 
}

int main()
{
  int a = sum_i(6, 1, 2, 3, 4, 5, 6);
//  printf("a = %d\n", a);
	
  return a;
}
