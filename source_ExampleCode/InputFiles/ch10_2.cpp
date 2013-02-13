// clang -c ch10_2.cpp -emit-llvm -o ch10_2.bc
// /Users/Jonathan/llvm/test/cmake_debug_build/bin/Debug/llc -march=cpu0 -relocation-model=static -filetype=obj ch10_2.bc -o ch10_2.cpu0.o
// /Users/Jonathan/llvm/test/cmake_debug_build/bin/Debug/llvm-objdump -d ch10_2.cpu0.o | tail -n +6| awk '{print "/* " $1 " */\t" $2 " " $3 " " $4 " " $5 "\t/* " $6"\t" $7" " $8" " $9" " $10 "\t*/"}' > ../cpu0_verilog/raw/cpu0s.hex

#include "InitRegs.h"

asm("addiu $sp, $zero, 1020");

int test_operators();
int test_control();

int main()
{
  int a = 0;
  a = test_operators();
  a += test_control();

  return a;
}

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
  k1 = (a1 >> 2);

  b = !a;
  int* p = &b;
  
  return c;
}

int test_control()
{
  unsigned int a = 0;
  int b = 1;
  int c = 2;
  int d = 3;
  int e = 4;
  int f = 5;
  int g = 6;
  int h = 7;
  int i = 8;
  
  if (a == 0) {
    a++;
  }
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
  if (g <= 1) {
    g++;
  }
  if (h >= 1) {
    h++;
  }
  if (i < h) {
    i++;
  }
  if (a != b) {
    a++;
  }
  
  return (b+c+d+e+f+g+h+i);
}

