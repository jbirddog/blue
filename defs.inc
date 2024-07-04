
FAILURE		= 0
SUCCESS		= 1

COMPILE		= 0
INTERPRET	= 1

ERR_NOT_A_WORD	= 165
ERR_NO_IMPL	= 166
ERR_BAD_BASE	= 167
ERR_BAD_PAD	= 168
ERR_NO_WORD	= 169

TYPE_OFFSET	= 0x00

_IMMEDIATE	= 0x01
_REGISTER	= 0x02

SIZE_OFFSET	= 0x08

_BYTE		= 0x01 shl SIZE_OFFSET
_WORD		= 0x02 shl SIZE_OFFSET
_DWORD		= 0x04 shl SIZE_OFFSET
_QWORD		= 0x08 shl SIZE_OFFSET

REG_OFFSET	= 0x10
REG_MASK	= 0xff shl REG_OFFSET

REG_RAX		= _REGISTER or (0x00 shl REG_OFFSET)
REG_RCX		= _REGISTER or (0x01 shl REG_OFFSET)
REG_RDX		= _REGISTER or (0x02 shl REG_OFFSET)
REG_RBX		= _REGISTER or (0x03 shl REG_OFFSET)
REG_RSP		= _REGISTER or (0x04 shl REG_OFFSET)
REG_RBP		= _REGISTER or (0x05 shl REG_OFFSET)
REG_RSI		= _REGISTER or (0x06 shl REG_OFFSET)
REG_RDI		= _REGISTER or (0x07 shl REG_OFFSET)
REG_R8		= _REGISTER or (0x08 shl REG_OFFSET)
REG_R9		= _REGISTER or (0x09 shl REG_OFFSET)
REG_R10		= _REGISTER or (0x0a shl REG_OFFSET)
REG_R11		= _REGISTER or (0x0b shl REG_OFFSET)
REG_R12		= _REGISTER or (0x0c shl REG_OFFSET)
REG_R13		= _REGISTER or (0x0d shl REG_OFFSET)
REG_R14		= _REGISTER or (0x0e shl REG_OFFSET)
REG_R15		= _REGISTER or (0x0f shl REG_OFFSET)

_AL		= REG_RAX or _BYTE
_EAX		= REG_RAX or _DWORD

_blue:
	.tib dq 0
	.tib_len dd 0
	.tib_in dd 0
	.word_len db 0
	.word rb 255
	.mode db 0
	.base db 0

_code_buffer:
	.length = 4096
	.base dq 0
	.here dq 0

_data_stack:
	.length = 4096
	.base dq 0
	.here dq 0

_dictionary:
	.prev_word_offset = 8
	.code_offset = 16
	.word_offset = 24
	.length = 4096
	.base dq 0
	.here dq 0
	.latest dq 0
