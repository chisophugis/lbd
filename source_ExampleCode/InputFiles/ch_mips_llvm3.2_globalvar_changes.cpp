// clang -c ch_mips_llvm3.2_globalvar_changes.cpp -emit-llvm -o ch_mips_llvm3.2_globalvar_changes.bc
// /Users/Jonathan/llvm/test/cmake_debug_build/bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=asm ch_mips_llvm3.2_globalvar_changes.bc -o ch_mips_llvm3.2_globalvar_changes.cpu0.s
// /Users/Jonathan/llvm/test/cmake_debug_build/bin/Debug/llc -march=mips -relocation-model=pic -filetype=asm ch_mips_llvm3.2_globalvar_changes.bc -o ch_mips_llvm3.2_globalvar_changes.mips.3.1.s
// /Users/Jonathan/llvm/test/cmake_debug_build/bin/Debug/llc -march=mips -relocation-model=pic -filetype=asm ch_mips_llvm3.2_globalvar_changes.bc -o ch_mips_llvm3.2_globalvar_changes.mips.3.2.s

int gI = 100;

int g()
{
	int a = 1 + gI;
	
	return a;
}

int f()
{
	int a = 3 + gI;
	
	return a;
}

int sum_i(int x1, int x2, int x3, int x4, int x5, int x6)
{
  int sum = gI + x1 + x2 + x3 + x4 + x5 + x6;
  sum += f();
  
  return sum; 
}

int main()
{ 
  int a = sum_i(1, 2, 3, 4, 5, 6);  
  
  return a;
}
