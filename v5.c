#include <sys/mman.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>

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

	// jit the interpretation of `4 5 add` where add has a stack effect (( eax a ecx b -- eax res ))
	
	// mov ecx, *(--tos)
	*here++ = 0xB9;
	memcpy(here, --tos, sizeof(uint32_t));
	here += sizeof(uint32_t);

	// mov eax, *(--tos)
	*here++ = 0xB8;
	memcpy(here, --tos, sizeof(uint32_t));
	here += sizeof(uint32_t);

	// add eax, ecx
	*here++ = 0x01;
	*here++ = 0xC8;

	// stosq since result of add is in rax and tos is in rdi
	*here++ = 0x48;
	*here++ = 0xAB;
	
	// ret
	*here++ = 0xC3;

	// call machine code
	((void (*)())code_buf)(tos);

	// add number of output effects stosq'd to tos
	++tos;
	
	printf("tos: %ld, depth: %ld\n", *(tos - 1), tos - &data_stack[0]);
	
	return 0;
}
