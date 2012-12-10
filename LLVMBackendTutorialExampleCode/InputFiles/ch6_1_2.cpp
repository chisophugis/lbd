// clang -c ch6_1_2.cpp -emit-llvm -o ch6_1_2.bc
// /Users/Jonathan/llvm/3.1.test/cpu0/1/cmake_debug_build/bin/Debug/llc -march=cpu0 -view-isel-dags -view-sched-dags -relocation-model=pic -filetype=asm ch6_1_2.bc -o ch6_1_2.cpu0.s

int main()
{
	int a = 5;
	int b = 0;
	int* p = &a;
	
	b = !(*p);
	if (b == 0) {
		a = a + b;
	} else if (b < 0) {
		a = a--;
	} else if (b > 0) {
		a = a++;
	} else if (b != 0) {
		a = a - b;
	}
	return a;

}
