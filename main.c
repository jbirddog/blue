#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#include "blue.h"

void compile(blue_ctx *ctx);

void dict_init(blue_ctx *ctx);
void parse(blue_ctx *ctx);

#define CODE_BUFFER_SIZE 4096
#define INPUT_BUFFER_SIZE 4096

#define MAX_COMMANDS 32
#define MAX_COMPILATION_BLOCKS 16
#define MAX_DATA_STACK_ELEMS 16
#define MAX_DICT_ENTRIES 16

static char input_buf[INPUT_BUFFER_SIZE];
static data_stack_elem data_stack[MAX_DATA_STACK_ELEMS];
static uint64_t shadow_stack[MAX_DATA_STACK_ELEMS];
static dict_entry dict[MAX_DICT_ENTRIES];
static command commands[MAX_COMMANDS];
static compilation_block compilation_blocks[MAX_COMPILATION_BLOCKS];
static blue_ctx ctx;

#define assign_ptr(dest, src, size) \
	dest.start = src; \
	dest.here = dest.start; \
	dest.end = dest.start + size;

#define assign_array(dest, src, size) assign_ptr(dest, &src[0], size)


static void init_ctx(uint8_t *rwx_mem) {
	ctx.input_buf = input_buf;
	
	assign_ptr(ctx.code_buf, rwx_mem, CODE_BUFFER_SIZE);
	assign_array(ctx.data_stack, data_stack, MAX_DATA_STACK_ELEMS);
	assign_array(ctx.shadow_stack, shadow_stack, MAX_DATA_STACK_ELEMS);
	assign_array(ctx.dict, dict, MAX_DICT_ENTRIES);
	assign_array(ctx.commands, commands, MAX_COMMANDS);
	assign_array(ctx.blocks, compilation_blocks, MAX_COMPILATION_BLOCKS);
}

int main(int argc, char **argv) {
	uint8_t *rwx_mem = mmap(NULL, CODE_BUFFER_SIZE,
		PROT_READ | PROT_WRITE | PROT_EXEC,
		MAP_PRIVATE | MAP_ANONYMOUS,
		-1, 0);

	init_ctx(rwx_mem);

	static char src[] = ""
": syscall 0x0F b, 0x05 b, ; "
""
"0x31 b, 0xC0 b, "
"0x31 b, 0xFF b, "
"0xB0 b, 0x3C b, "
"0x40 b, 0xB7 b, 0x0B b, "
"0x0F b, 0x05 b,"
"";
	ctx.input_buf = src;

	dict_init(&ctx);
	parse(&ctx);
	compile(&ctx);
	
	munmap(rwx_mem, CODE_BUFFER_SIZE);

	printf("Return from main\n");
	
	return 0;
}
