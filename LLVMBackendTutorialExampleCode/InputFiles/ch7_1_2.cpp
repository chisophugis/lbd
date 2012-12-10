// clang -c ch6_2_1.cpp -emit-llvm -o ch6_2_1.bc
// /Users/Jonathan/llvm/3.1.test/cpu0/1/cmake_debug_build/bin/Debug/llc -march=cpu0 -view-isel-dags -view-sched-dags -relocation-model=pic -filetype=asm ch6_2_1.bc -o ch6_2_1.cpu0.s

int sum_i(int x, int y, int* c)
{
	int* p = c;
	int sum = x + y;
	
	return sum; 
}

int main()
{
	int cc = 5;
	int a = sum_i(1, 2, &cc);
	
	return a;
}
