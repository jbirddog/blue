#include <sys/mman.h>
#include <stdio.h>
#include <stdint.h>

int64_t data_stack[16];
int64_t *tos = &data_stack[0];

int main(int argc, char **argv) {
	uint8_t *code_buf = mmap(NULL, 4096,
		PROT_READ | PROT_WRITE | PROT_EXEC,
		MAP_PRIVATE | MAP_ANONYMOUS,
		-1, 0);
	uint8_t *here = code_buf;

	*tos++ = 4;
	*tos++ = 5;

	printf("tos: %ld, depth: %ld\n", *(tos - 1), tos - &data_stack[0]);

	// push rax
	// push rcx
	*here++ = 0x50;
	*here++ = 0x51;

	// pop rcx
	// pop rax
	*here++ = 0x59;
	*here++ = 0x58;

	// ret
	*here++ = 0xC3;

	// call machine code
	((void (*)())code_buf)(); 

	printf("tos: %ld, depth: %ld\n", *(tos - 1), tos - &data_stack[0]);
	
	return 0;
}
