#include <assert.h>
#include <stdint.h>
#include <string.h>
#include "blue.h"

//
// x8664 specific - move to own header with regs, etc
//

static void compile_call(uint8_t *here, uint8_t *where, blue_ctx *ctx) {
	assert(false);
}

static void compile_ret(blue_ctx *ctx) {
	blue_buf_append_val(ctx->code_buf, 0xC3);
}

//
//
//

static void interpret(uint8_t *entry, blue_ctx *ctx) {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wpedantic"
	((void (*)(uint64_t *))entry)(ctx->shadow_stack.start);
#pragma GCC diagnostic pop
}

static void compile_cmd_call(command *c, blue_ctx *ctx) {
	assert(c->type == CMD_CALL);

	auto code_loc = blue_list_elem(ctx->code_locs, c->val);
	assert(*code_loc < ctx->code_buf.here);

	compile_call(ctx->code_buf.here, *code_loc, ctx);
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
		case CMD_CALL:
			compile_cmd_call(c, ctx);
			break;
		case CMD_COMMA:
			compile_cmd_comma(c, ctx);
			break;
		case CMD_LIT:
			compile_cmd_lit(c, ctx);
			break;
		case CMD_RET:
			compile_ret(ctx);
			break;
		}
	});
}

static void compile_cmdlist(compilation_block *b, blue_ctx *ctx) {
	assert(b->type == BLK_CMDLIST);
	
	uint8_t *entry = ctx->code_buf.here;

	compile_commands(b, ctx);
	compile_ret(ctx);

	interpret(entry, ctx);
	
	ctx->code_buf.here = entry;
}

static void compile_word_decl(compilation_block *b, blue_ctx *ctx) {
	assert(b->type == BLK_WORD_DECL);

	blue_list_append(ctx->code_locs, loc, {
		*loc = ctx->code_buf.here;
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
