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

static char *peek_tok(char *s, char **tok_end) {
	while (*s != '\0' && isspace(*s)) ++s;

	auto tok = s;
	while (*s != '\0' && !isspace(*s)) ++s;

	*tok_end = s;

	return tok;
}

static char *next_tok(char **tok_end, blue_ctx *ctx) {
	auto tok = peek_tok(ctx->input_buf, tok_end);
	ctx->input_buf = *tok_end;
	return tok;
}

static dict_entry *find(char *tok, size_t tok_len, blue_ctx *ctx) {
	blue_list_each_rev(ctx->dict, entry, {
		if (tok_len == entry->word_len && strncmp(tok, entry->word, tok_len) == 0) {
			return entry;
		}
	});

	return NULL;
}

static void seal_last_block(blue_ctx *ctx) {
	assert(blue_list_len(ctx->blocks) > 0);
	
	auto b = blue_list_last(ctx->blocks);
	b->commands.here = ctx->commands.here;
	b->commands.end = ctx->commands.here;
}

void parse(blue_ctx *ctx) {
	blue_list_append(ctx->blocks, b, {
		b->type = BLK_CMDLIST;
		b->commands.start = ctx->commands.here;
	});

	char *tok;
	char *tok_end;
	auto iters = 0;

	while (*(tok = next_tok(&tok_end, ctx)) != '\0') {
		++iters;
		assert(iters < 100);

		auto tok_len = tok_end - tok;
		auto entry = find(tok, tok_len, ctx);

		if (entry) {
			entry->handler(entry, ctx);
			continue;
		}
		
		char *num_end;
		uint64_t num = strtoll(tok, &num_end, 0);

		if (num_end != tok_end) break;

		append_lit_cmd(num, ctx);
	}

	if (*ctx->input_buf != '\0') {
		int len = tok_end - tok;
		fprintf(stderr, "Unknown word #%d: %.*s\n", iters, len, tok);
		return;
	}

	seal_last_block(ctx);
}

//
// dict
//

static char *word_b_comma = "b,";
static char *word_colon = ":";
static char *word_semi = ";";

static void b_comma(dict_entry *entry, blue_ctx *ctx) {
	blue_list_append(ctx->commands, c, { c->type = CMD_COMMA; c->size = 1; });
}

static void call_user_word(dict_entry *entry, blue_ctx *ctx) {
	assert(false);
}

static void colon(dict_entry *entry, blue_ctx *ctx) {
	seal_last_block(ctx);
	
	blue_list_append(ctx->blocks, b, {
		b->type = BLK_WORD_DECL;
		b->commands.start = ctx->commands.here;
	});

	auto block = blue_list_last(ctx->blocks);
	
	char *tok_end;
	auto tok = next_tok(&tok_end, ctx);
	auto tok_len = tok_end - tok;
	
	blue_list_append(ctx->dict, entry, {
		entry->word = tok;
		entry->word_len = tok_len;
		entry->block = block;
		entry->handler = call_user_word;
	});
}

static void semi(dict_entry *entry, blue_ctx *ctx) {
	seal_last_block(ctx);
	
	blue_list_append(ctx->blocks, b, {
		b->type = BLK_CMDLIST;
		b->commands.start = ctx->commands.here;
	});
}

void dict_init(blue_ctx *ctx) {
	blue_list_append(ctx->dict, entry, {
		entry->word = word_b_comma;
		entry->word_len = strlen(word_b_comma);
		entry->handler = b_comma;
	});
	
	blue_list_append(ctx->dict, entry, {
		entry->word = word_colon;
		entry->word_len = strlen(word_colon);
		entry->handler = colon;
	});
	
	blue_list_append(ctx->dict, entry, {
		entry->word = word_semi;
		entry->word_len = strlen(word_semi);
		entry->handler = semi;
	});

	ctx->user_dict = ctx->dict.here;
}
