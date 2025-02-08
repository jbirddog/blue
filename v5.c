#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>

#define MAX_COMMANDS 32
#define MAX_COMPILATION_BLOCKS 16
#define MAX_DATA_STACK_ELEMS 16

//
// blue.h
//

#define blue_list(t) \
	struct { \
		t *start; \
		t *end; \
		t *here; \
	}

#define blue_list_each(list, var, body) \
	do { \
		for (auto var = list.start; var < list.here; ++var) body \
	} while (0)
	
#define blue_list_push(list, var, body) \
	do { \
		assert(list.here < list.end); \
		auto var = list.here; \
		body \
		++list.here; \
	} while (0)

#define blue_list_pop(list, var, body) \
	do { \
		assert(list.here > list.start); \
		--list.here; \
		auto var = list.here; \
		body \
	} while (0)

typedef struct {
	enum { ELEM_LIT, } type;
	size_t size;
	uint64_t val;
} data_stack_elem;

typedef struct {
	enum { CMD_COMMA, CMD_LIT, } type;
	size_t size;
	uint64_t val;
} command;

typedef struct {
	enum { BLK_CMDLIST, } type;
	blue_list(command) commands;
} compilation_block;

typedef struct {
	struct {
		uint8_t *mem;
		uint8_t *here;
	} code_buf;
	blue_list(data_stack_elem) data_stack;
	uint64_t shadow_stack[MAX_DATA_STACK_ELEMS];
	blue_list(command) commands;
	blue_list(compilation_block) blocks;
} blue_ctx;

//
// backend.c
//

void interpret(uint8_t *entry, blue_ctx *ctx) {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wpedantic"
	((void (*)(uint64_t *))entry)(&ctx->shadow_stack[0]);
#pragma GCC diagnostic pop
}

void compile_cmd_comma(command *c, blue_ctx *ctx) {
	assert(c->type == CMD_COMMA);
	
	blue_list_pop(ctx->data_stack, elem, {
		assert(elem->type == ELEM_LIT);

		memcpy(ctx->code_buf.here, &elem->val, c->size);
		ctx->code_buf.here += elem->size;
	});
}

void compile_cmd_lit(command *c, blue_ctx *ctx) {
	assert(c->type == CMD_LIT);

	blue_list_push(ctx->data_stack, elem, {
		elem->type = ELEM_LIT;
		elem->size = c->size;
		elem->val = c->val;
	});
}

void compile_cmdlist(compilation_block *b, blue_ctx *ctx) {
	assert(b->type == BLK_CMDLIST);
	
	uint8_t *entry = ctx->code_buf.here;

	blue_list_each(b->commands, c, {
		switch (c->type) {
		case CMD_COMMA:
			compile_cmd_comma(c, ctx);
			break;
		case CMD_LIT:
			compile_cmd_lit(c, ctx);
			break;
		}
	});
	
	*ctx->code_buf.here++ = 0xC3;

	interpret(entry, ctx);
	
	ctx->code_buf.here = entry;
}

void compile(blue_ctx *ctx) {
	blue_list_each(ctx->blocks, b, {
		switch (b->type) {
		case BLK_CMDLIST:
			compile_cmdlist(b, ctx);
			break;
		}
	});
}

//
// frontend.c
//

void parse(const char *src, blue_ctx *ctx) {
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

	blue_list_push(ctx->blocks, b, {
		b->type = BLK_CMDLIST;
		b->commands.start = ctx->commands.start;
		b->commands.end = ctx->commands.end;
		b->commands.here = ctx->commands.here;
	});
}

//
// main.c
//

static blue_ctx ctx;
static data_stack_elem data_stack_elems[MAX_DATA_STACK_ELEMS];
static command commands[MAX_COMMANDS];
static compilation_block compilation_blocks[MAX_COMPILATION_BLOCKS];

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

