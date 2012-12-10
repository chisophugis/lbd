// clang -c ch5_6_2.cpp -emit-llvm -o ch5_6_2.bc
// /Users/Jonathan/llvm/3.1.test/cpu0/1/cmake_debug_build/bin/Debug/llc -march=cpu0 -debug -view-isel-dags -relocation-model=pic -filetype=asm ch5_6_2.bc -o ch5_6_2.cpu0.s

struct Date
{
	int year;
	int month;
	int day;
};

Date date = {2012, 10, 12};

int a[3] =  {2011, 11, 13};

int main()
{
	int* p = &date.month;
	*p = (*p)%12+1;
	p = &a[2];
	*p = (*p)%30+1;

	return *p;
}
