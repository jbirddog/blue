#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>

#define MAX_COMMANDS 16
#define MAX_COMPILATION_BLOCKS 16
#define MAX_DATA_STACK_ELEMS 16

//
// blue.h
//

#define blue_list(t, size) \
	struct { \
		t elems[size]; \
		t *start; \
		t *end; \
		t *here; \
	} 

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
	command *commands;
	size_t commands_len;
} compilation_block;

typedef struct {
	struct {
		uint8_t *mem;
		uint8_t *here;
	} code_buf;
	blue_list(data_stack_elem, MAX_DATA_STACK_ELEMS) data_stack;
	uint64_t shadow_stack[MAX_DATA_STACK_ELEMS];
} blue_ctx;

#define data_stack_push(ctx, var, body) \
	do { \
		auto var = ctx->data_stack.here; \
		body \
		++ctx->data_stack.here; \
	} while (0)

#define data_stack_pop(ctx, var, body) \
	do { \
		--ctx->data_stack.here; \
		auto var = ctx->data_stack.here; \
		body \
	} while (0)

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
	
	data_stack_pop(ctx, elem, {
		assert(elem->type == ELEM_LIT);

		memcpy(ctx->code_buf.here, &elem->val, c->size);
		ctx->code_buf.here += elem->size;
	});
}

void compile_cmd_lit(command *c, blue_ctx *ctx) {
	assert(c->type == CMD_LIT);

	data_stack_push(ctx, elem, {
		elem->type = ELEM_LIT;
		elem->size = c->size;
		elem->val = c->val;
	});
}

void compile_cmdlist(compilation_block *b, blue_ctx *ctx) {
	assert(b->type == BLK_CMDLIST);
	
	uint8_t *entry = ctx->code_buf.here;

	for (int i = 0; i < b->commands_len; ++i) {
		command c = b->commands[i];

		switch (c.type) {
		case CMD_COMMA:
			compile_cmd_comma(&c, ctx);
			break;
		case CMD_LIT:
			compile_cmd_lit(&c, ctx);
			break;
		}
	}
	
	*ctx->code_buf.here++ = 0xC3;

	interpret(entry, ctx);
	
	ctx->code_buf.here = entry;
}

void compile(compilation_block *blocks, size_t blocks_len, blue_ctx *ctx) {
	for (int i = 0; i < blocks_len; ++i) {
		compilation_block b = blocks[i];
		
		switch (b.type) {
		case BLK_CMDLIST:
			compile_cmdlist(&b, ctx);
			break;
		}
	}
}

//
// frontend.c
//

void parse(const char *src, blue_ctx *ctx) {
}

//
// main.c
//

static blue_ctx ctx;
//static compilation_block blocks[MAX_COMPILATION_BLOCKS];

static const char src[] = ""
"B0 b, 3C b, "
"40 b, B7 b, 0B b, "
"0F b, 05 b, "
"";

static void init_ctx(uint8_t *rwx_mem) {
	ctx.code_buf.mem = rwx_mem;
	ctx.code_buf.here = rwx_mem;
	
	ctx.data_stack.start = &ctx.data_stack.elems[0];
	ctx.data_stack.end = &ctx.data_stack.elems[MAX_DATA_STACK_ELEMS - 1];
	ctx.data_stack.here = ctx.data_stack.start;
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
		
	command m1_cmds[] = {
		// xor eax, eax
		// xor edi, edi
		{ .type = CMD_LIT, .size = 1, .val = 0x31 },
		{ .type = CMD_COMMA, .size = 1 },
		{ .type = CMD_LIT, .size = 1, .val = 0xC0 },
		{ .type = CMD_COMMA, .size = 1 },
		{ .type = CMD_LIT, .size = 1, .val = 0x31 },
		{ .type = CMD_COMMA, .size = 1 },
		{ .type = CMD_LIT, .size = 1, .val = 0xFF },
		{ .type = CMD_COMMA, .size = 1 },

		// mov al, 60
		{ .type = CMD_LIT, .size = 1, .val = 0xB0 },
		{ .type = CMD_COMMA, .size = 1 },
		{ .type = CMD_LIT, .size = 1, .val = 0x3C },
		{ .type = CMD_COMMA, .size = 1 },

		// mov dil, 11
		{ .type = CMD_LIT, .size = 1, .val = 0x40 },
		{ .type = CMD_COMMA, .size = 1 },
		{ .type = CMD_LIT, .size = 1, .val = 0xB7 },
		{ .type = CMD_COMMA, .size = 1 },
		{ .type = CMD_LIT, .size = 1, .val = 0x0B },
		{ .type = CMD_COMMA, .size = 1 },		

		// syscall
		{ .type = CMD_LIT, .size = 1, .val = 0x0F },
		{ .type = CMD_COMMA, .size = 1 },
		{ .type = CMD_LIT, .size = 1, .val = 0x05 },
		{ .type = CMD_COMMA, .size = 1 },
	};
	size_t m1_cmds_len = sizeof(m1_cmds) / sizeof(m1_cmds[0]);

	compilation_block milestone1[] = {
		{ .type = BLK_CMDLIST, .commands = &m1_cmds[0], .commands_len = m1_cmds_len },
	};
	size_t milestone1_len = sizeof(milestone1) / sizeof(milestone1[0]);
	
	compile(&milestone1[0], milestone1_len, &ctx);
	
	munmap(rwx_mem, mem_size);

	printf("Done from main\n");
	
	return 0;
}

