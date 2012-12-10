// clang -c ch5_6.cpp -emit-llvm -o ch5_6.bc
// /Users/Jonathan/llvm/3.1.test/cpu0/1/cmake_debug_build/bin/Debug/llc -march=cpu0 -view-isel-dags -view-sched-dags -relocation-model=pic -filetype=asm ch5_6.bc -o ch5_6.cpu0.s

int main()
{
	int b = 11;
//	unsigned int b = 11;
	
	b = (b+1)%12;
	
	return b;
}
