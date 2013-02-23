// clang -c ch8_4.cpp -I/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.8.sdk/usr/include/ -emit-llvm -o ch8_4.bc
// /Users/Jonathan/llvm/test/cmake_debug_build/bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=asm ch8_4.bc -o ch8_4.cpu0.s

#include <time.h>
#include <stdlib.h>
#include <stdio.h>

int main()
{
  int b = 11;
  int iSecret = 0;

  // initialize random seed:
  srand ( time(NULL) );

  // generate secret number: 
  iSecret = rand() % 12 + 1;

//  int c = rand();
  
  b = (b+1)%iSecret;
//  printf("iSecret = %d, b = %d\n", iSecret, b);
  
  return b;
}
