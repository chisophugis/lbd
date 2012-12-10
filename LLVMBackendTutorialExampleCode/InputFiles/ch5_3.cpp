// clang -c ch5_3.cpp -emit-llvm -o ch5_3.bc
// /Users/Jonathan/llvm/3.1.test/cpu0/1/cmake_debug_build/bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=asm ch5_3.bc -o ch5_3.cpu0.s

int main()
{
	int a = 5;
	int b = 0;
	
	b = !a;
	
	return b;
}

