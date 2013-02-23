// clang -c ch7_1_3.cpp -emit-llvm -o ch7_1_3.bc
// /Users/Jonathan/llvm/test/cmake_debug_build/bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=asm ch7_1_3.bc -o ch7_1_3.cpu0.s

int main()
{
  int a;
  int b = 5;
  int i = 0;
  
  for (i = 0; i == 3; i++) {
    a = a + i;
  }
  for (i = 0; i != 3; i++) {
    a = a + i;
  }
  for (i = 0; i > 3; i++) {
    a = a + i;
  }
  for (i = 0; i > 3; i++) {
    a = a + i;
  }
  for (i = 0; i == b; i++) {
    a++;
  }
  for (i = 0; i != b; i++) {
    a++;
  }
  for (i = 0; i < b; i++) {
    a++;
  }
  for (i = 7; i > b; i--) {
    a--;
  }
  for (i = 0; i <= b; i++) {
    a++;
  }
label_1:
  for (i = 7; i >= b; i--) {
    a--;
  }
  
  while (i < 7) {
    a++;
    i++;
    if (a >= 4)
      continue;
    else if (a == 3) {
      break;
    }
  }
  if (a == 3)
    goto label_1; 
  
    return a;
}
