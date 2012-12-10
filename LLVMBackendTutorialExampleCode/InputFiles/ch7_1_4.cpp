// clang -c ch7_1_4.cpp -emit-llvm -o ch7_1_4.bc
// /Users/Jonathan/llvm/3.1.test/cpu0/1/cmake_debug_build/bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=asm ch7_1_4.bc -o ch7_1_4.cpu0.s

int multiply(int x, int y)
{
	return (x*y);
}

int add(int x, int y)
{
	return (x+y);
}

int madd(int x, int y, int z)
{
	return add(z, multiply(x, y));
}

/*int multiply(int x, int y)
{
	int result = x*y;
	return result;
}

int add(int x, int y)
{
	int sum = x+y;
	return sum;
}

int madd(int x, int y, int z)
{
	int result = add(z, multiply(x, y));
	
	return result;
}*/

int main()
{
	int cc = 5;
	int a = madd(1, 2, cc);
	
	return a;
}
