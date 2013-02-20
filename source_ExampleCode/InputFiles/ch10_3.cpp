// clang -target `llvm-config --host-target` -c ch10_3.cpp -emit-llvm -o ch10_3.bc
// /Users/Jonathan/llvm/test/cmake_debug_build/bin/Debug/llc -march=cpu0 -relocation-model=static -filetype=asm ch10_3.bc -o ch10_3.cpu0.s
// /Users/Jonathan/llvm/test/cmake_debug_build/bin/Debug/llc -march=cpu0 -relocation-model=static -filetype=obj ch10_3.bc -o ch10_3.cpu0.o
// /Users/Jonathan/llvm/test/cmake_debug_build/bin/Debug/llvm-objdump -d ch10_3.cpu0.o | tail -n +6| awk '{print "/* " $1 " */\t" $2 " " $3 " " $4 " " $5 "\t/* " $6"\t" $7" " $8" " $9" " $10 "\t*/"}' > ../cpu0_verilog/raw/cpu0s.hex

//#include <stdio.h>
#include <stdarg.h>

#include "InitRegs.h"

#define OUT_MEM 0x7000 // 28672

asm("addiu $sp, $zero, 1020");

void print_integer(int x);
int sum_i(int amount, ...);

int main()
{
  int a = sum_i(6, 0, 1, 2, 3, 4, 5);
  print_integer(a);
	
  return a;
}

// For memory IO
void print_integer(int x)
{
  int *p = (int*)OUT_MEM;
  *p = x;
 return;
}

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

