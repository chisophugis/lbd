// clang -c ch_test_8_2.cpp -emit-llvm -o ch_test_8_2.bc
// /Users/Jonathan/llvm/test/cmake_debug_build/bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=asm -view-isel-dags ch_test_8_2.bc -o ch_test_8_2.cpu0.s

struct date {
	char year;
	char month;
	char day;
};

/*
struct date {
	int year;
	int month;
	int day;
};

date d = {int(12), int(11), int(30)};*/

int main()
{

date d = {char(12), char(11), char(30)};
	char month = d.month;
//	int month = d.month;
//	d.day = char(1);
	
	return 0;
}
