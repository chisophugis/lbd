// clang -c ch7_3_2.cpp -emit-llvm -o ch7_3_2.bc
// /Users/Jonathan/llvm/test/cmake_debug_build/bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=asm ch7_3_2.bc -o ch7_3_2.cpu0.s
// /Users/Jonathan/llvm/test/cmake_debug_build/bin/Debug/llc -march=mips -relocation-model=pic -filetype=asm ch7_3_2.bc -o ch7_3_2.mips.s

//#include <stdio.h>
#include <stdarg.h>

class Vector_2D
{
public:
  int x;
  int y;
  Vector_2D(int x1, int y1);
  void operator+(Vector_2D& v1);
};

Vector_2D::Vector_2D(int x1, int y1)
{
  x = x1;
  y = y1;
}

void Vector_2D::operator+(Vector_2D& v1)
{
  x += v1.x;
  y += v1.y;
}

template<class T>
T sum(int amount, ...)
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
  Vector_2D v = sum<Vector_2D>(6, (1, 0), (2, 1), (3, 0), (4, 1), (5, 0), (6, 1));
//  printf("a = %d\n", a);
	
  return a;
}
