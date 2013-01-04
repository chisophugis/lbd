// clang -c -I/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.8.sdk/usr/include/ ch5_5_3.cpp -emit-llvm -o ch5_5_3.bc
// clang -c ch5_5_3.cpp -emit-llvm -o ch5_5_3.bc
// /Users/Jonathan/llvm/3.1.test/cpu0/1/cmake_debug_build/bin/Debug/llc -march=cpu0 -debug -view-isel-dags -relocation-model=pic -filetype=asm ch5_5_3.bc -o ch5_5_3.cpu0.s

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
	*p = *p+1;
	p = &a[2];

	return *p;
}
