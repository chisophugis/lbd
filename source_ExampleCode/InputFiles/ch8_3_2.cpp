// clang -c ch8_3_2.cpp -emit-llvm -o ch8_3_2.bc
// /Users/Jonathan/llvm/3.1.test/cpu0/1/cmake_debug_build/bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=asm ch8_3_2.bc -o ch8_3_2.cpu0.s
// /Users/Jonathan/llvm/3.1.test/cpu0/1/cmake_debug_build/bin/Debug/llc -march=mips -relocation-model=pic -filetype=asm ch8_3_2.bc -o ch8_3_2.mips.s

//#include <stdio.h>
#include <stdarg.h>

template<class T>
T sum(T amount, ...)
{
  T i = 0;
  T val = 0;
  T sum = 0;
	
  va_list vl;
  va_start(vl, amount);
  for (i = 0; i < amount; i++)
  {
    val = va_arg(vl, T);
    sum += val;
  }
  va_end(vl);
  
  return sum; 
}

int main()
{
  int a = sum<int>(6, 1, 2, 3, 4, 5, 6);
//  printf("a = %d\n", a);
	
  return a;
}
