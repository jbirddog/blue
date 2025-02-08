#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#include "blue.h"

void compile(blue_ctx *ctx);
void parse(const char *src, blue_ctx *ctx);

#define MAX_COMMANDS 32
#define MAX_COMPILATION_BLOCKS 16
#define MAX_DATA_STACK_ELEMS 16

static blue_ctx ctx;
static data_stack_elem data_stack_elems[MAX_DATA_STACK_ELEMS];
static command commands[MAX_COMMANDS];
static compilation_block compilation_blocks[MAX_COMPILATION_BLOCKS];
static uint64_t shadow_stack[MAX_DATA_STACK_ELEMS];

static const char src[] = ""
"0xB0 b, 0x3C b, "
"0x40 b, 0xB7 b, 0x0B b, "
"0x0F b, 0x05 b, "
"";

#define assign_array_to_list(l, s, sz) \
	l.start = &s[0]; \
	l.end = l.start + sz; \
	l.here = l.start;

static void init_ctx(uint8_t *rwx_mem) {
	ctx.code_buf.mem = rwx_mem;
	ctx.code_buf.here = rwx_mem;

	assign_array_to_list(ctx.data_stack, data_stack_elems, MAX_DATA_STACK_ELEMS);
	assign_array_to_list(ctx.commands, commands, MAX_COMMANDS);
	assign_array_to_list(ctx.blocks, compilation_blocks, MAX_COMPILATION_BLOCKS);
	assign_array_to_list(ctx.shadow_stack, shadow_stack, MAX_DATA_STACK_ELEMS);
}

int main(int argc, char **argv) {
	const size_t mem_size = 4096;
	uint8_t *rwx_mem = mmap(NULL, mem_size,
		PROT_READ | PROT_WRITE | PROT_EXEC,
		MAP_PRIVATE | MAP_ANONYMOUS,
		-1, 0);

	init_ctx(rwx_mem);
	parse(src, &ctx);
	compile(&ctx);
	
	munmap(rwx_mem, mem_size);

	printf("Return from main\n");
	
	return 0;
}
