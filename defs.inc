
FAILURE		= 0
SUCCESS		= 1

INTERPRET	= 0
COMPILE		= 1

_blue:
	.tib dq 1
	.tib_len dd 1
	.tib_in dd 1
	.word_len db 1
	.word rb 255
	.mode db 1
	.base db 1
	
_code_buffer:
	.length = 4096
	.base dq 1
	.here dq 1
	.entry dd 1

_data_stack:
	.length = 4096
	.base dq 1
	.here dq 1

_dictionary:
	.prev_word_offset = 8
	.entry_code_offset = 16
	.word_offset = 24
	.length = 4096
	.base dq 1
	.here dq 1
	.latest dq 1
