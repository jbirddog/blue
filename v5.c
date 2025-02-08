#include <assert.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <sys/mman.h>

#define DATA_STACK_SIZE 16

typedef struct {
	uint8_t *mem;
	uint8_t *here;
} code_buf;

typedef struct {
	enum { ELEM_LIT, } type;
	size_t size;
	uint64_t val;
} data_stack_elem;

typedef struct {
	data_stack_elem elems[DATA_STACK_SIZE];
	data_stack_elem *tos;
} data_stack;

typedef struct {
	code_buf *code_buf;
	data_stack *data_stack;
	uint64_t shadow_stack[DATA_STACK_SIZE];
} blue_ctx;

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


void interpret(uint8_t *where, blue_ctx *ctx) {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wpedantic"
	((void (*)())where)(&ctx->shadow_stack[0]);
#pragma GCC diagnostic pop
}

void compile_cmd_comma(command *c, blue_ctx *ctx) {
	assert(c->type == CMD_COMMA);
	
	--ctx->data_stack->tos;
	data_stack_elem *tos = ctx->data_stack->tos;
	assert(tos->type == ELEM_LIT);

	memcpy(ctx->code_buf->here, &tos->val, c->size);
	ctx->code_buf->here += tos->size;
}

void compile_cmd_lit(command *c, blue_ctx *ctx) {
	assert(c->type == CMD_LIT);
	
	data_stack_elem *tos = ctx->data_stack->tos;
	tos->type = ELEM_LIT;
	tos->size = c->size;
	tos->val = c->val;
	++ctx->data_stack->tos;
}

void compile_cmdlist(compilation_block *b, blue_ctx *ctx) {
	assert(b->type == BLK_CMDLIST);
	
	uint8_t *entry = ctx->code_buf->here;

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
	
	*ctx->code_buf->here++ = 0xC3;

	interpret(entry, ctx);
	
	ctx->code_buf->here = entry;
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


int main(int argc, char **argv) {
	// TODO: move to linux/sys.{c,h}
	const size_t mem_size = 4096;
	uint8_t *rwx_mem = mmap(NULL, mem_size,
		PROT_READ | PROT_WRITE | PROT_EXEC,
		MAP_PRIVATE | MAP_ANONYMOUS,
		-1, 0);
	
	code_buf cb = { .mem = rwx_mem, .here = rwx_mem };
	
	data_stack ds = {0};
	ds.tos = &ds.elems[0];
	
	blue_ctx ctx = { .code_buf = &cb, .data_stack = &ds };

	command m1_cmds[] = {
		//{ .type = CMD_LIT, .size = 1, .val = 0xC3 },
		//{ .type = CMD_COMMA, .size = 1 },
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
