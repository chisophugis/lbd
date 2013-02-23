// clang -c ch_test_8_1.cpp -emit-llvm -o ch_test_8_1.bc
// /Users/Jonathan/llvm/test/cmake_debug_build/bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=asm -view-isel-dags ch_test_8_1.bc -o ch_test_8_1.cpu0.s

struct date {
	char year;
	char month;
	char day;
};

int main()
{
	date d;
	d.year = char(12);
	d.month = char(12);
	d.day = char(2);
	char month = d.month;
	
//	int month = d.month;
//	d.day = char(1);
	
	return 0;
}
