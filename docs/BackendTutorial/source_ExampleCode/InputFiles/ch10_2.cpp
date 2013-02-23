// clang -c ch10_2.cpp -emit-llvm -o ch10_2.bc
// /Users/Jonathan/llvm/test/cmake_debug_build/bin/Debug/llc -march=cpu0 -relocation-model=static -filetype=obj ch10_2.bc -o ch10_2.cpu0.o
// /Users/Jonathan/llvm/test/cmake_debug_build/bin/Debug/llvm-objdump -d ch10_2.cpu0.o | tail -n +6| awk '{print "/* " $1 " */\t" $2 " " $3 " " $4 " " $5 "\t/* " $6"\t" $7" " $8" " $9" " $10 "\t*/"}' > ../cpu0_verilog/raw/cpu0s.hex

#include "InitRegs.h"

#define OUT_MEM 0x7000 // 28672

asm("addiu $sp, $zero, 1020");

void print_integer(int x);
int test_operators();
int test_control();

int main()
{
  int a = 0;
  a = test_operators(); // a = 13
  print_integer(a);
  a += test_control();	// a = 31
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

void print1_integer(int x)
{
  asm("ld $at, 8($sp)");
  asm("st $at, 28672($0)");
 return;
}

#if 0
// For instruction IO
void print2_integer(int x)
{
  asm("ld $at, 8($sp)");
  asm("outw $tat");
  return;
}
#endif

int test_operators()
{
  int a = 11;
  int b = 2;
  int c = 0;
  int d = 0;
  int e, f, g, h, i, j, k, l = 0;
  unsigned int a1 = -5, k1 = 0;

  c = a + b;
  d = a - b;
  e = a * b;
  f = a / b;
  b = (a+1)%12;
  g = (a & b);
  h = (a | b);
  i = (a ^ b);
  j = (a << 2);
  k = (a >> 2);
  print_integer(k);
  k1 = (a1 >> 2);
  print_integer((int)k1);

  b = !a;
  int* p = &b;
  
  return c; // 13
}

int test_control()
{
  int b = 1;
  int c = 2;
  int d = 3;
  int e = 4;
  int f = 5;
  
  if (b != 0) {
    b++;
  }
  if (c > 0) {
    c++;
  }
  if (d >= 0) {
    d++;
  }
  if (e < 0) {
    e++;
  }
  if (f <= 0) {
    f++;
  }
  
  return (b+c+d+e+f); // (2+3+4+4+5)=18
}

