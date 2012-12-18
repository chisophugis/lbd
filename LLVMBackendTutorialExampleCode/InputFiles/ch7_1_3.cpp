// clang -c ch_1_3.cpp -emit-llvm -o ch7_1_3.bc
// /Users/Jonathan/llvm/3.1.test/cpu0/1/cmake_debug_build/bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=asm ch7_1_3.bc -o ch7_1_3.cpu0.s

extern int sum_i(int x, int y);

int main()
{
	int b = 1;
	int c = 2;
	int a = sum_i(b, c);
	
	return a;
}
