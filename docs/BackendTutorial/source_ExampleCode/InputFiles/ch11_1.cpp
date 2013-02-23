// clang -target `llvm-config --host-target` -c ch11_1.cpp -emit-llvm -o ch11_1.bc
// /Users/Jonathan/llvm/test/cmake_debug_build/bin/Debug/llc -march=cpu0 -relocation-model=static -filetype=asm -enable-cpu0-del-useless-jmp=false ch11_1.bc -o ch11_1.cpu0.s
// /Users/Jonathan/llvm/test/cmake_debug_build/bin/Debug/llc -march=cpu0 -relocation-model=static -filetype=asm -stats ch11_1.bc -o ch11_1.cpu0.s
int main()
{
  int a = 0;
  int b = 1;
  int c = 2;
  
  if (a == 0) {
    a++;
  }
  if (b == 0) {
    a = a + b;
  } else if (b < 0) {
    a = a--;
  }
  if (c > 0) {
    c++;
  }
  
  return a;
}
