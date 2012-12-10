// clang -c ch5_5_1.cpp -emit-llvm -o ch5_5_1.bc
// /Users/Jonathan/llvm/3.1.test/cpu0/1/cmake_debug_build/bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=asm ch5_5_1.bc -o ch5_5_1.cpu0.s

int main()
{
	int a = 1;
	int b = 2;
	int k = 0;
	unsigned int a1 = -5, f1 = 0;
	
	f1 = a1 / b;
	k = (a >> 2);

	return k;
}
