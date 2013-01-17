// clang -c ch4_6_2.cpp -I/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.8.sdk/usr/include/ -emit-llvm -o ch4_6_2.bc
// /Users/Jonathan/llvm/test/cmake_debug_build/bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=asm ch4_6_2.bc -o ch4_6_2.cpu0.s

#include <stdlib.h>

int main()
{
  int b = 11;
//  unsigned int b = 11;
  int c = rand();
  
  b = (b+1)%c;
  
  return b;
}
