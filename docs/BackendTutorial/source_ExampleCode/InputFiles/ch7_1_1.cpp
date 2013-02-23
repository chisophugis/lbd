// clang -c ch7_1_1.cpp -emit-llvm -o ch7_1_1.bc
// /Users/Jonathan/llvm/test/cmake_debug_build/bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=asm ch7_1_1.bc -o ch7_1_1.cpu0.s
// /Users/Jonathan/llvm/test/cmake_debug_build/bin/Debug/llc -march=cpu0 -view-isel-dags -relocation-model=pic -filetype=asm ch7_1_1.bc -o ch7_1_1.cpu0.s

int main()
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
  
  return a;
}
