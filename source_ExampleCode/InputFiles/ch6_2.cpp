// clang -c ch6_2.cpp -emit-llvm -o ch6_2.bc
// /usr/local/llvm/test/cmake_debug_build/bin/llc -march=cpu0 -relocation-model=pic -filetype=asm ch6_2.bc -o ch6_2.cpu0.s
// /usr/local/llvm/test/cmake_debug_build/bin/llc -march=cpu0 -relocation-model=static -cpu0-islinux-format=false -filetype=asm ch6_2.bc -o ch6_2.cpu0.islinux-format-false.s
// /usr/local/llvm/test/cmake_debug_build/bin/llc -march=cpu0 -relocation-model=static -filetype=asm ch6_2.bc -o ch6_2.cpu0.static.s
// /usr/local/llvm/test/cmake_debug_build/bin/llc -march=cpu0 -relocation-model=pic -filetype=obj ch6_2.bc -o ch6_2.cpu0.o
// /usr/local/llvm/test/cmake_debug_build/bin/llc -march=cpu0 -relocation-model=static -filetype=obj ch6_2.bc -o ch6_2.cpu0.static.o

// /Users/Jonathan/llvm/test/cmake_debug_build/bin/Debug/llc -march=cpu0 -relocation-model=static -filetype=asm ch6_2.bc -o ch6_2.cpu0.static.s
// /Applications/Xcode.app/Contents/Developer/usr/bin/lldb -- /Users/Jonathan/llvm/test/cmake_debug_build/bin/Debug/llc -march=cpu0 -filetype=asm ch6_2.bc -o ch6_2.cpu0.s 

struct Date
{
  int year;
  int month;
  int day;
};

Date date = {2012, 10, 12};
int a[3] = {2012, 10, 12};

int main()
{
  int day = date.day;
  int i = a[1];

  return 0;
}

