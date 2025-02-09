#include <stdio.h>
#include <string.h>
#include "blue.h"

void parse(blue_ctx *ctx) {
	blue_list_append(ctx->blocks, b, {
		b->type = BLK_CMDLIST;
		b->commands.start = ctx->commands.here;
	});

	fprintf(stderr, "%s\n", ctx->input_buf.start);

	// xor eax, eax
	// xor edi, edi
	blue_list_append(ctx->commands, c, { c->type = CMD_LIT; c->size = 1; c->val = 0x31; });
	blue_list_append(ctx->commands, c, { c->type = CMD_COMMA; c->size = 1; });
	blue_list_append(ctx->commands, c, { c->type = CMD_LIT; c->size = 1; c->val = 0xC0; });
	blue_list_append(ctx->commands, c, { c->type = CMD_COMMA; c->size = 1; });
	blue_list_append(ctx->commands, c, { c->type = CMD_LIT; c->size = 1; c->val = 0x31; });
	blue_list_append(ctx->commands, c, { c->type = CMD_COMMA; c->size = 1; });
	blue_list_append(ctx->commands, c, { c->type = CMD_LIT; c->size = 1; c->val = 0xFF; });
	blue_list_append(ctx->commands, c, { c->type = CMD_COMMA; c->size = 1; });
	
	// mov al, 60
	blue_list_append(ctx->commands, c, { c->type = CMD_LIT; c->size = 1; c->val = 0xB0; });
	blue_list_append(ctx->commands, c, { c->type = CMD_COMMA; c->size = 1; });
	blue_list_append(ctx->commands, c, { c->type = CMD_LIT; c->size = 1; c->val = 0x3C; });
	blue_list_append(ctx->commands, c, { c->type = CMD_COMMA; c->size = 1; });

	// mov dil, 11
	blue_list_append(ctx->commands, c, { c->type = CMD_LIT; c->size = 1; c->val = 0x40; });
	blue_list_append(ctx->commands, c, { c->type = CMD_COMMA; c->size = 1; });
	blue_list_append(ctx->commands, c, { c->type = CMD_LIT; c->size = 1; c->val = 0xB7; });
	blue_list_append(ctx->commands, c, { c->type = CMD_COMMA; c->size = 1; });
	blue_list_append(ctx->commands, c, { c->type = CMD_LIT; c->size = 1; c->val = 0x0B; });
	blue_list_append(ctx->commands, c, { c->type = CMD_COMMA; c->size = 1; });
	
	// syscall
	blue_list_append(ctx->commands, c, { c->type = CMD_LIT; c->size = 1; c->val = 0x0F; });
	blue_list_append(ctx->commands, c, { c->type = CMD_COMMA; c->size = 1; });
	blue_list_append(ctx->commands, c, { c->type = CMD_LIT; c->size = 1; c->val = 0x05; });
	blue_list_append(ctx->commands, c, { c->type = CMD_COMMA; c->size = 1; });

	auto b = blue_list_last(ctx->blocks);
	b->commands.here = ctx->commands.here;
	b->commands.end = ctx->commands.here;
}
