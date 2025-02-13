#include <assert.h>
#include <ctype.h>
#include <limits.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include "blue.h"

static void push_lit(uint64_t val, blue_ctx *ctx) {
	size_t size = 1;

	if (val > UINT_MAX) size = 8;
	else if (val > USHRT_MAX) size = 4;
	else if (val > UCHAR_MAX) size = 2;
	
	auto elem = blue_stack_push(ctx->data_stack);
	elem->type = ELEM_LIT;
	elem->size = size;
	elem->val = val;
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

static void eat_tok(blue_ctx *ctx) {
	char *tok_end;
	next_tok(&tok_end, ctx);
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
	blue_list_seal(b->commands, ctx->commands);
}

void parse(blue_ctx *ctx) {
	auto block = blue_list_append(ctx->blocks);
	block->type = BLK_CMDLIST;
	block->commands.start = ctx->commands.here;

	char *tok;
	char *tok_end;

	while (*(tok = next_tok(&tok_end, ctx)) != '\0') {
		auto tok_len = tok_end - tok;
		auto entry = find(tok, tok_len, ctx);

		if (entry) {
			entry->handler(entry, ctx);
			continue;
		}

		if (ctx->parse_type != PARSE_BODY) break;
		
		char *num_end;
		uint64_t num = strtoll(tok, &num_end, 0);

		if (num_end != tok_end) break;

		push_lit(num, ctx);
	}

	if (*ctx->input_buf != '\0') {
		int len = tok_end - tok;
		fprintf(stderr, "Unknown word: %.*s\n", len, tok);
		return;
	}

	seal_last_block(ctx);
}

static void flow_in(dict_entry *entry, blue_ctx *ctx) {
	blue_list_each_rev(entry->ins, in, {
		assert(in->type == EFFECT_REG);

		auto elem = blue_stack_pop(ctx->data_stack);
		assert(elem->type == ELEM_LIT);
		
		auto cmd = blue_list_append(ctx->commands);
		cmd->type = CMD_FLOW_LIT;
		cmd->size = elem->size;
		cmd->val = elem->val;
		cmd->data = in;
	});
}

static void flow_out(dict_entry *entry, blue_ctx *ctx) {
}

//
// dict
//

static char *word_b_comma = "b,";
static char *word_colon = ":";
static char *word_ddash = "--";
static char *word_dlparen = "((";
static char *word_drparen = "))";
static char *word_semi = ";";

static void call(dict_entry *entry, blue_ctx *ctx) {
	assert(entry >= ctx->user_dict);

	flow_in(entry, ctx);
	
	auto cmd = blue_list_append(ctx->commands);
	cmd->type = CMD_CALL;
	cmd->val = entry - ctx->user_dict;

	flow_out(entry, ctx);
}

static void b_comma(dict_entry *entry, blue_ctx *ctx) {
	auto elem = blue_stack_pop(ctx->data_stack);
	assert(elem->type == ELEM_LIT);

	auto cmd = blue_list_append(ctx->commands);
	cmd->type = CMD_COMMA;
	cmd->size = 1;
	cmd->val = elem->val;
}

static void colon(dict_entry *entry, blue_ctx *ctx) {
	seal_last_block(ctx);
	
	auto block = blue_list_append(ctx->blocks);
	block->type = BLK_WORD_DECL;
	block->commands.start = ctx->commands.here;
	
	char *tok_end;
	auto tok = next_tok(&tok_end, ctx);
	auto tok_len = tok_end - tok;

	auto new_entry = blue_list_append(ctx->dict);
	new_entry->word = tok;
	new_entry->word_len = tok_len;
	new_entry->block = block;
	new_entry->handler = call;
}

static void ddash(dict_entry *entry, blue_ctx *ctx) {
	auto latest = blue_list_last(ctx->dict);
	blue_list_seal(latest->ins, ctx->stack_effects);

	blue_list_from(latest->outs, ctx->stack_effects);
}

static void dlparen(dict_entry *entry, blue_ctx *ctx) {
	ctx->parse_type = PARSE_EFFECTS;

	auto latest = blue_list_last(ctx->dict);
	blue_list_from(latest->ins, ctx->stack_effects);
}

static void drparen(dict_entry *entry, blue_ctx *ctx) {
	auto latest = blue_list_last(ctx->dict);
	blue_list_seal(latest->outs, ctx->stack_effects);

	ctx->parse_type = PARSE_BODY;
}

static void semi(dict_entry *entry, blue_ctx *ctx) {
	auto cmd = blue_list_append(ctx->commands);
	cmd->type = CMD_RET;
	seal_last_block(ctx);
	
	auto block = blue_list_append(ctx->blocks);
	block->type = BLK_CMDLIST;
	block->commands.start = ctx->commands.here;
}

//
// x8664 specific - move to own header with backend code, etc
//

static char *word_eax = "eax";
static char *word_edi = "edi";

static void append_effect_reg(size_t size, uint64_t val, blue_ctx *ctx) {	
	eat_tok(ctx);
	
	auto effect = blue_list_append(ctx->stack_effects);
	effect->type = EFFECT_REG;
	effect->size = size;
	effect->val = val;
}

static void eax(dict_entry *entry, blue_ctx *ctx) {
	append_effect_reg(4, 0, ctx);
}

static void edi(dict_entry *entry, blue_ctx *ctx) {
	append_effect_reg(4, 7, ctx);
}

//
//
//

void dict_init(blue_ctx *ctx) {
	dict_entry *entry;
	
	entry = blue_list_append(ctx->dict);
	entry->word = word_b_comma;
	entry->word_len = strlen(word_b_comma);
	entry->handler = b_comma;
	
	entry = blue_list_append(ctx->dict);
	entry->word = word_colon;
	entry->word_len = strlen(word_colon);
	entry->handler = colon;
	
	entry = blue_list_append(ctx->dict);
	entry->word = word_semi;
	entry->word_len = strlen(word_semi);
	entry->handler = semi;
	
	entry = blue_list_append(ctx->dict);
	entry->word = word_ddash;
	entry->word_len = strlen(word_ddash);
	entry->handler = ddash;
	
	entry = blue_list_append(ctx->dict);
	entry->word = word_dlparen;
	entry->word_len = strlen(word_dlparen);
	entry->handler = dlparen;
	
	entry = blue_list_append(ctx->dict);
	entry->word = word_drparen;
	entry->word_len = strlen(word_drparen);
	entry->handler = drparen;
	
	entry = blue_list_append(ctx->dict);
	entry->word = word_eax;
	entry->word_len = strlen(word_eax);
	entry->handler = eax;
	
	entry = blue_list_append(ctx->dict);
	entry->word = word_edi;
	entry->word_len = strlen(word_edi);
	entry->handler = edi;

	ctx->user_dict = ctx->dict.here;
}
