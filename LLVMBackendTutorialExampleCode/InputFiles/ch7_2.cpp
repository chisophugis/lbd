// clang -c ch7_2.cpp -emit-llvm -o ch7_2.bc
// /Users/Jonathan/llvm/3.1.test/cpu0/1/cmake_debug_build/bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=asm ch7_2.bc -o ch7_2.cpu0.s
// /Users/Jonathan/llvm/3.1.test/cpu0/1/cmake_debug_build/bin/Debug/llc -march=mips -relocation-model=pic -filetype=asm ch7_2.bc -o ch7_2.mips.s

int gI = 100;

int sum_i(int x1, int x2, int x3, int x4, int x5, int x6)
{
	int sum = gI + x1 + x2 + x3 + x4 + x5 + x6;
	
	return sum; 
}

int main()
{	
	int a = sum_i(1, 2, 3, 4, 5, 6);	
	
	return a;
}
