// clang -c ch5_5_2.cpp -emit-llvm -o ch5_5_2.bc
// /Users/Jonathan/llvm/3.1.test/cpu0/1/cmake_debug_build/bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=asm ch5_5_2.bc -o ch5_5_2.cpu0.s

int main()
{
	int b = 3;
	
	int* p = &b;

	return *p;
}
