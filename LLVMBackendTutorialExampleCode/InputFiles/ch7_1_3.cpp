// clang -c ch6_2_3.cpp -emit-llvm -o ch6_2_3.bc
// /Users/Jonathan/llvm/3.1.test/cpu0/1/cmake_debug_build/bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=asm ch6_2_3.bc -o ch6_2_3.cpu0.s

extern int sum_i(int x, int y);

int main()
{
	int b = 1;
	int c = 2;
	int a = sum_i(b, c);
	
	return a;
}
