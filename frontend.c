#include <assert.h>
#include <ctype.h>
#include <limits.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include "blue.h"

static void append_lit_cmd(uint64_t lit, blue_ctx *ctx) {
	size_t size = 1;

	if (lit > UINT_MAX) size = 8;
	else if (lit > USHRT_MAX) size = 4;
	else if (lit > UCHAR_MAX) size = 2;
	
	blue_list_append(ctx->commands, c, { c->type = CMD_LIT; c->size = size; c->val = lit; });
}

void parse(blue_ctx *ctx) {
	blue_list_append(ctx->blocks, b, {
		b->type = BLK_CMDLIST;
		b->commands.start = ctx->commands.here;
	});

	auto s = ctx->input_buf;
	int iters = 0;

	while (*s != '\0') {
		++iters;
		assert(iters < 100000);

		while (isspace(*s)) ++s;
		if (*s == '\0') break;

		auto tok = s;
		while (*s != '\0' && !isspace(*s)) ++s;

		auto tok_end = s;
		auto tok_len = tok_end - tok;

		// TODO: check dictionary
		if (tok_len == 2 && strncmp(tok, "b,", tok_len) == 0) {
			blue_list_append(ctx->commands, c, { c->type = CMD_COMMA; c->size = 1; });
			continue;
		}
		
		char *num_end;
		uint64_t num = strtoll(tok, &num_end, 0);

		if (num_end != tok_end) break;

		append_lit_cmd(num, ctx);
	}

	if (*s != '\0') {
		fprintf(stderr, "invalid input: %d\n", iters);
		return;
	}

	auto b = blue_list_last(ctx->blocks);
	b->commands.here = ctx->commands.here;
	b->commands.end = ctx->commands.here;
}
