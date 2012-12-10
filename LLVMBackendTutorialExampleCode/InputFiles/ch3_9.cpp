// By change MipsInstrInfo.td, search "Gamma modify"
// clang -c ch3_2.cpp -emit-llvm -o ch3_2.bc
// /usr/local/llvm/3.1.test/cpu0/1/cmake_debug_build/bin/llc -march=cpu0 -relocation-model=pic -filetype=asm ch3_2.bc -o ch3_2.cpu0.s
// /usr/local/llvm/3.1.test/cpu0/1/cmake_debug_build/bin/llc -march=cpu0 -relocation-model=pic -filetype=obj ch3_2.bc -o ch3_2.cpu0.o


#include <stdio.h>

#include <stdarg.h>

#if 0
int gi = 20;
#endif
#if 0
int ga[] = {10, 20, 30, 40, 50};
#endif
#if 0
int sum_i(int x, int y)
{
	int z = x + y;

	return z;
}
#endif
#if 0
long sum_l(long x, long y)
{
	long z = x + y;

	return z;
}
#endif
#if 0
float sum_f(float x, float y)
{
	float z = x + y;

	return z;
}
#endif
#if 0
// double arguments not work in my current llvm working
double sum_d(double x, double y)
{
	double z = x + y;

	return z;
}
#endif
#if 0
template <class type>
type sum_all ( type arg, ...)
{
  type i;
  type sum;
  va_list vl;
  va_start(vl,arg);
  for (i=0;i<arg;i++)
  {
    sum+=va_arg(vl,type);
  }
  va_end(vl);
  return sum;
}
#endif
#if 0
void printstr(const char* arg)
{
// only work on release build
  const char* p = 0;

  for (p = arg; *p != '\0'; p++)
  {
    putchar(*p);
  }
  return;
}
#endif
#if 0
int delayslot_fill_test()
{
  int a, b, c;

  a = 3;
  b = 4;
  c = 5;
  a = a + b + c;
  b = a * b * c;
  c = c + b - a ;
  if (c > (b - 10)) {
    c = c + 10;
  }
  else if (c > (b - 8)) {
    c = c + 8;
  }
  else {
    c = c - 1;
  }

  return c;
}
#endif

#if 0
int ReplaceUsesWithZeroReg_test()
{
// won't trigger ReplaceUsesWithZeroReg()
  int a, b, c;

  a = 0;
  b = 0;
  c = 0;
  a = 0 + 0;
  b = 0 + 0;
  c = 0 + 0;
  b = a * b * c;
  c = c + b - a ;
  if (c > (b - 10)) {
    c = c + 10;
  }
  else if (c > (b - 8)) {
    c = c + 8;
  }
  else {
    c = c - 1;
  }

  return c;
}
#endif
int main()
{
#if 1
// printf(%i or %f) only work on release build
	int a = -5;
	int b = 3;
	int c = 0;
//	long l = 0;

  if (c > (b - 10)) {
    c = c + 10;
  }
  else if (c > (b - 8)) {
    c = c + 8;
  }
  else {
    c = c - 1;
  }

//	asm ("addiu t0, $0, 10");
//	c = sum_i(a, b);
//	c = sum_all<int>(a, b, 5, 6, 7, 8, 9, 1, 2, 3);
//	l = sum_l(a, b);
//	c = sum_all<long>(a, b, 5, 6, 7, 8, 9, 1, 2, 3);
/*	gi += b;
	c = c + gi + ga[3];
    c= delayslot_fill_test();
    c= ReplaceUsesWithZeroReg_test();
	c += (int)l;*/
//	printstr("Hello world\n");

	return c;
#endif
#if 0
// float is work
	float f1, f2, f3 = 0;
	
	f2 = 5.01 + 7.03;
	f1 = sum_f(f2, f3);
//	f1 = sum_all<float>((float)a, (float)b, 5.3, 6, 7, 8, 9, 1, 2, 3); // not allow in var_arg()
//	printf("f1 = %f\n", f1);
	
	return f2;
#endif
#if 0
	double f1, f2, f3 = 0;

	f2 = 7.2; f3 = 6.3;
	f1 = 2.3 + 4.6 + f2 + f3;
//	printf("f1 = %f\n", f1);

	return f1;
#endif
#if 0
// double arguments not work in my current llvm working
	double f1, f2, f3 = 0;

//	f1 = sum_d(f2, f3);
	f1 = sum_all<double>(4.2, 5.3, 6, 7, 8, 9, 1, 2, 3);
//	printf("f1 = %f\n", (float)f1);

	return f1;
#endif
}
