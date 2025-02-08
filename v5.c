#include <sys/mman.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>

#define DATA_STACK_SIZE 16

typedef struct {
	uint8_t *mem;
	int i;
} code_buf;

typedef struct {
	enum { ELEM_LIT, } type;
	int size;
	uint64_t val;
} data_stack_elem;

typedef struct {
	data_stack_elem elems[DATA_STACK_SIZE];
	int i;
} data_stack;

typedef struct {
	code_buf *code_buf;
	data_stack *data_stack;
} blue_ctx;

typedef struct {
	enum { CMD_LIT, CMD_COMMA, } type;
	int size;
	uint64_t val;
} command;

int main(int argc, char **argv) {
	// TODO: move to linux/sys.{c,h}
	const size_t mem_size = 4096;
	uint8_t *rwx_mem = mmap(NULL, mem_size,
		PROT_READ | PROT_WRITE | PROT_EXEC,
		MAP_PRIVATE | MAP_ANONYMOUS,
		-1, 0);
	
	code_buf cb = { .mem = rwx_mem };
	data_stack ds = {0};
	blue_ctx ctx = { .code_buf = &cb, .data_stack = &ds };

	command milestone1[] = {
		{ .type = CMD_LIT, .size = 1, .val = 0xB0 },
		{ .type = CMD_COMMA, .size = 1 },
		{ .type = CMD_LIT, .size = 1, .val = 0x3C },
		{ .type = CMD_COMMA, .size = 1 },
		{ .type = CMD_LIT, .size = 1, .val = 0x40 },
		{ .type = CMD_COMMA, .size = 1 },
		{ .type = CMD_LIT, .size = 1, .val = 0xB7 },
		{ .type = CMD_COMMA, .size = 1 },
		{ .type = CMD_LIT, .size = 1, .val = 0x0B },
		{ .type = CMD_COMMA, .size = 1 },
		{ .type = CMD_LIT, .size = 1, .val = 0x0F },
		{ .type = CMD_COMMA, .size = 1 },
		{ .type = CMD_LIT, .size = 1, .val = 0x05 },
		{ .type = CMD_COMMA, .size = 1 },
	};
	size_t milestone1_len = sizeof(milestone1) / sizeof(milestone1[0]);

	munmap(rwx_mem, mem_size);
	
	return 0;
}







	/*
	uint8_t *here = code_buf;

	*tos++ = 4;
	*tos++ = 5;

	printf("tos: %ld, depth: %ld\n", *(tos - 1), tos - &data_stack[0]);

	*here++ = 0xB0;
	*here++ = 0x3C;
	*here++ = 0x40;
	*here++ = 0xB7;
	*here++ = 0x0B;
	*here++ = 0x0F;
	*here++ = 0x05;
	
	
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
	*/
