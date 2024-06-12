
_blue:
	.tib dq 1
	.tib_len dd 1
	.in dd 1
	.mode db 1

_code_buffer:
	.length = 4096
	.base dq 1
	.here dq 1

_data_stack:
	.length = 4096
	.base dq 1
	.here dq 1

_dictionary:
	.length = 4096
	.base dq 1
	.here dq 1
	.latest dq 1
