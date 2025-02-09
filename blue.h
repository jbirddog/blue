#include <assert.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>

#define blue_list(t) \
	struct { \
		t *start; \
		t *end; \
		t *here; \
	}

#define blue_list_len(list) (list.here - list.start)

#define blue_list_each(list, var, body) \
	do { \
		for (auto var = list.start; var < list.here; ++var) body \
	} while (0)
	
#define blue_list_append(list, var, body) \
	do { \
		assert(list.here < list.end); \
		auto var = list.here; \
		body \
		++list.here; \
	} while (0)

#define blue_list_last(list) (assert(list.here > list.start), list.here - 1)

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

//
// blue_stack
//
	
#define blue_stack blue_list
#define blue_stack_depth blue_list_len
#define blue_stack_peek blue_list_last
#define blue_stack_push blue_list_append

#define blue_stack_pop(list, var, body) \
	do { \
		assert(list.here > list.start); \
		--list.here; \
		auto var = list.here; \
		body \
	} while (0)

//
// types
//

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
	blue_buf(uint8_t) code_buf;
	blue_stack(data_stack_elem) data_stack;
	blue_stack(uint64_t) shadow_stack;
	blue_list(command) commands;
	blue_list(compilation_block) blocks;
} blue_ctx;
