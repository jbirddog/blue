#include <assert.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>

#define MAX_WORD_SIZE 64

#define blue_list(t) \
	struct { \
		t *start; \
		t *end; \
		t *here; \
	}

#define blue_list_from(dst, src) \
	do { \
		dst.start = src.here; \
		dst.here = src.here; \
		dst.end = src.end; \
	} while (0)

#define blue_list_seal(list, src) \
	do { \
		list.here = src.here; \
		list.end = src.here; \
	} while (0)
	
#define blue_list_len(list) (list.here - list.start)

#define blue_list_each(list, var, body) \
	do { \
		for (auto var = list.start; var < list.here; ++var) body \
	} while (0)

#define blue_list_each_rev(list, var, body) \
	do { \
		for (auto var = list.here; var >= list.start; --var) body \
	} while (0)

#define blue_list_append(list) (assert(list.here < list.end), list.here++)
#define blue_list_pop(list) (assert(list.here > list.start), --list.here)
#define blue_list_last(list) (assert(list.here > list.start), list.here - 1)
#define blue_list_elem(list, i) (assert(i >= 0 && i < list.here - list.start), list.start + i)

//
// blue_buf
//

#define blue_buf blue_list
#define blue_buf_len blue_list_len

#define blue_buf_append(buf, src, size) \
	do { \
		assert(buf.here + size < buf.end); \
		memcpy(buf.here, src, size); \
		buf.here += size; \
	} while (0)

#define blue_buf_append_val(buf, val) \
	do { \
		assert(buf.here < buf.end); \
		*buf.here++ = val; \
	} while (0)

//
// blue_stack
//
	
#define blue_stack blue_list
#define blue_stack_depth blue_list_len
#define blue_stack_peek blue_list_last
#define blue_stack_push blue_list_append
#define blue_stack_pop blue_list_pop

//
// types
//

typedef struct {
	enum { ELEM_LIT, ELEM_REG } type;
	size_t size;
	uint64_t val;
} data_stack_elem;

typedef struct {
	enum { EFFECT_REG } type;
	size_t size;
	uint8_t val;
} stack_effect_elem;

typedef struct {
	enum { CMD_CALL, CMD_COMMA, CMD_RET } type;
	size_t size;
	uint64_t val;
} command;

typedef struct {
	enum { BLK_CMDLIST, BLK_WORD_DECL } type;
	blue_list(command) commands;
} compilation_block;

typedef struct blue_ctx blue_ctx;
typedef struct dict_entry dict_entry;

struct dict_entry {
	char *word;
	size_t word_len;
	blue_list(stack_effect_elem) ins;
	blue_list(stack_effect_elem) outs;
	compilation_block *block;
	void (*handler)(dict_entry *entry, blue_ctx *ctx);
};

struct blue_ctx {
	enum { PARSE_BODY, PARSE_EFFECTS } parse_type;
	char *input_buf;
	blue_buf(uint8_t) code_buf;
	blue_stack(data_stack_elem) data_stack;
	blue_stack(uint64_t) shadow_stack;
	blue_list(stack_effect_elem) stack_effects;
	blue_list(dict_entry) dict;
	dict_entry *user_dict;
	blue_list(command) commands;
	blue_list(compilation_block) blocks;
	blue_list(uint8_t *) code_locs;
};
