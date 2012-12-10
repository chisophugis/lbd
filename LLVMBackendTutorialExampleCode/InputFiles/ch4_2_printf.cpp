// clang -c ch3_1.cpp -emit-llvm -o ch3_1.bc
// /usr/local/llvm/3.1.test/cpu0/1/cmake_debug_build/bin/llc -march=cpu0 -relocation-model=pic -filetype=asm ch3_1.bc -o ch3_1.cpu0.s
// /usr/local/llvm/3.1.test/cpu0/1/cmake_debug_build/bin/llc -march=cpu0 -relocation-model=pic -filetype=obj ch3_1.bc -o ch3_1.cpu0.o

#include <stdio.h>

int main()
{
	int a = 5;
	int b = 2;
	int c = 0;
	int d = 0;
	int e, f, g, h, i, j, k = 0;

	c = a + b;
	d = a - b;
	e = a * b;
	f = a / b;
	g = (a & b);
	h = (a | b);
	i = (a ^ b);
	j = (a << 2);
	k = (a >> 2);

	printf("j = %.8x, k = %.8x\n", j, k);

	return e;
}

