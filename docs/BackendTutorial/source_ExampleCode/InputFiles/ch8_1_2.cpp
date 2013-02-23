// clang -c ch8_1_2.cpp -emit-llvm -o ch8_1_2.bc
// /Users/Jonathan/llvm/test/cmake_debug_build/bin/Debug/llc -march=cpu0 -view-isel-dags -view-sched-dags -relocation-model=pic -filetype=asm ch8_1_2.bc -o ch8_1_2.cpu0.s

int sum_i(int x, int y, int* c)
{
  int* p = c;
  int sum = x + y;
  
  return sum; 
}

int main()
{
  int cc = 5;
  int a = sum_i(1, 2, &cc);
  
  return a;
}
