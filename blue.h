#include <assert.h>
#include <stddef.h>
#include <stdint.h>

#define blue_list(t) \
	struct { \
		t *start; \
		t *end; \
		t *here; \
	}

#define blue_list_each(list, var, body) \
	do { \
		for (auto var = list.start; var < list.here; ++var) body \
	} while (0)
	
#define blue_list_push(list, var, body) \
	do { \
		assert(list.here < list.end); \
		auto var = list.here; \
		body \
		++list.here; \
	} while (0)

#define blue_list_pop(list, var, body) \
	do { \
		assert(list.here > list.start); \
		--list.here; \
		auto var = list.here; \
		body \
	} while (0)

#define blue_list_last(list) (assert(list.here > list.start), list.here - 1)

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
	blue_list(command) commands;
} compilation_block;

typedef struct {
	struct {
		uint8_t *mem;
		uint8_t *here;
	} code_buf;
	blue_list(data_stack_elem) data_stack;
	blue_list(uint64_t) shadow_stack;
	blue_list(command) commands;
	blue_list(compilation_block) blocks;
} blue_ctx;
