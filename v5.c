#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#include "blue.h"

#define MAX_COMMANDS 32
#define MAX_COMPILATION_BLOCKS 16
#define MAX_DATA_STACK_ELEMS 16

void compile(blue_ctx *ctx);

//
// frontend.c
//

void parse(const char *src, blue_ctx *ctx) {
	blue_list_push(ctx->blocks, b, {
		b->type = BLK_CMDLIST;
		b->commands.start = ctx->commands.here;
	});
	
	// xor eax, eax
	// xor edi, edi
	blue_list_push(ctx->commands, c, { c->type = CMD_LIT; c->size = 1; c->val = 0x31; });
	blue_list_push(ctx->commands, c, { c->type = CMD_COMMA; c->size = 1; });
	blue_list_push(ctx->commands, c, { c->type = CMD_LIT; c->size = 1; c->val = 0xC0; });
	blue_list_push(ctx->commands, c, { c->type = CMD_COMMA; c->size = 1; });
	blue_list_push(ctx->commands, c, { c->type = CMD_LIT; c->size = 1; c->val = 0x31; });
	blue_list_push(ctx->commands, c, { c->type = CMD_COMMA; c->size = 1; });
	blue_list_push(ctx->commands, c, { c->type = CMD_LIT; c->size = 1; c->val = 0xFF; });
	blue_list_push(ctx->commands, c, { c->type = CMD_COMMA; c->size = 1; });
	
	// mov al, 60
	blue_list_push(ctx->commands, c, { c->type = CMD_LIT; c->size = 1; c->val = 0xB0; });
	blue_list_push(ctx->commands, c, { c->type = CMD_COMMA; c->size = 1; });
	blue_list_push(ctx->commands, c, { c->type = CMD_LIT; c->size = 1; c->val = 0x3C; });
	blue_list_push(ctx->commands, c, { c->type = CMD_COMMA; c->size = 1; });

	// mov dil, 11
	blue_list_push(ctx->commands, c, { c->type = CMD_LIT; c->size = 1; c->val = 0x40; });
	blue_list_push(ctx->commands, c, { c->type = CMD_COMMA; c->size = 1; });
	blue_list_push(ctx->commands, c, { c->type = CMD_LIT; c->size = 1; c->val = 0xB7; });
	blue_list_push(ctx->commands, c, { c->type = CMD_COMMA; c->size = 1; });
	blue_list_push(ctx->commands, c, { c->type = CMD_LIT; c->size = 1; c->val = 0x0B; });
	blue_list_push(ctx->commands, c, { c->type = CMD_COMMA; c->size = 1; });
	
	// syscall
	blue_list_push(ctx->commands, c, { c->type = CMD_LIT; c->size = 1; c->val = 0x0F; });
	blue_list_push(ctx->commands, c, { c->type = CMD_COMMA; c->size = 1; });
	blue_list_push(ctx->commands, c, { c->type = CMD_LIT; c->size = 1; c->val = 0x05; });
	blue_list_push(ctx->commands, c, { c->type = CMD_COMMA; c->size = 1; });

	auto b = blue_list_last(ctx->blocks);
	b->commands.here = ctx->commands.here;
	b->commands.end = ctx->commands.here;
}

//
// main.c
//

static blue_ctx ctx;
static data_stack_elem data_stack_elems[MAX_DATA_STACK_ELEMS];
static command commands[MAX_COMMANDS];
static compilation_block compilation_blocks[MAX_COMPILATION_BLOCKS];
static uint64_t shadow_stack[MAX_DATA_STACK_ELEMS];

static const char src[] = ""
"B0 b, 3C b, "
"40 b, B7 b, 0B b, "
"0F b, 05 b, "
"";

#define assign_to_list(l, s, sz) \
	l.start = &s[0]; \
	l.end = l.start + sz; \
	l.here = l.start;

static void init_ctx(uint8_t *rwx_mem) {
	ctx.code_buf.mem = rwx_mem;
	ctx.code_buf.here = rwx_mem;

	assign_to_list(ctx.data_stack, data_stack_elems, MAX_DATA_STACK_ELEMS);
	assign_to_list(ctx.commands, commands, MAX_COMMANDS);
	assign_to_list(ctx.blocks, compilation_blocks, MAX_COMPILATION_BLOCKS);
	assign_to_list(ctx.shadow_stack, shadow_stack, MAX_DATA_STACK_ELEMS);
}

int main(int argc, char **argv) {
	// TODO: move to linux/sys.{c,h}
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

