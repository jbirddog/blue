#include <assert.h>
#include <stdint.h>
#include <string.h>
#include "blue.h"

static void interpret(uint8_t *entry, blue_ctx *ctx) {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wpedantic"
	((void (*)(uint64_t *))entry)(ctx->shadow_stack.start);
#pragma GCC diagnostic pop
}

static void compile_cmd_comma(command *c, blue_ctx *ctx) {
	assert(c->type == CMD_COMMA);
	
	blue_stack_pop(ctx->data_stack, elem, {
		assert(elem->type == ELEM_LIT);

		blue_buf_append(ctx->code_buf, &elem->val, c->size);
	});
}

static void compile_cmd_lit(command *c, blue_ctx *ctx) {
	assert(c->type == CMD_LIT);

	blue_stack_push(ctx->data_stack, elem, {
		elem->type = ELEM_LIT;
		elem->size = c->size;
		elem->val = c->val;
	});
}

static void compile_commands(compilation_block *b, blue_ctx *ctx) {
	blue_list_each(b->commands, c, {
		switch (c->type) {
		case CMD_COMMA:
			compile_cmd_comma(c, ctx);
			break;
		case CMD_LIT:
			compile_cmd_lit(c, ctx);
			break;
		case CMD_RET:
			blue_buf_append_val(ctx->code_buf, 0xC3);
			break;
		}
	});
}

static void compile_cmdlist(compilation_block *b, blue_ctx *ctx) {
	assert(b->type == BLK_CMDLIST);
	
	uint8_t *entry = ctx->code_buf.here;

	compile_commands(b, ctx);
	blue_buf_append_val(ctx->code_buf, 0xC3);

	interpret(entry, ctx);
	
	ctx->code_buf.here = entry;
}

static void compile_word_decl(compilation_block *b, blue_ctx *ctx) {
	assert(b->type == BLK_WORD_DECL);

	blue_list_append(ctx->code_locs, l, {
		*l = ctx->code_buf.here;
	}); 
	compile_commands(b, ctx);
}

void compile(blue_ctx *ctx) {
	blue_list_each(ctx->blocks, b, {
		switch (b->type) {
		case BLK_CMDLIST:
			compile_cmdlist(b, ctx);
			break;
		case BLK_WORD_DECL:
			compile_word_decl(b, ctx);
			break;
		}
	});
}
