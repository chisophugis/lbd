// clang -c ch7_1_2.cpp -emit-llvm -o ch7_1_2.bc
// /Users/Jonathan/llvm/test/cmake_debug_build/bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=asm ch7_1_2.bc -o ch7_1_2.cpu0.s

int main()
{
  int a = 5;
  int b = 0;
  int* p = &a;
  
  b = !(*p);
  if (b == 0) {
    a = a + b;
  } else if (b < 0) {
    a = a--;
  } else if (b > 0) {
    a = a++;
  } else if (b != 0) {
    a = a - b;
  }
  return a;
}
