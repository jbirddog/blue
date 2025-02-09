#include <ctype.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include "blue.h"

void parse(blue_ctx *ctx) {
	blue_list_append(ctx->blocks, b, {
		b->type = BLK_CMDLIST;
		b->commands.start = ctx->commands.here;
	});

	auto s = ctx->input_buf;

	while (*s != '\0') {
		while (isspace(*s)) ++s;
		if (*s == '\0') break;

		auto tok = s;
		while (*s != '\0' && !isspace(*s)) ++s;

		auto tok_end = s;
		auto tok_len = tok_end - tok;

		// TODO: check dictionary
		char *num_end;
		uint64_t num = strtoll(tok, &num_end, 0);

		if (num_end != tok_end) break;
		
		fprintf(stderr, "num: %ld, tok: '%s' %ld\n", num, tok, tok_len);
		break;
	}

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
