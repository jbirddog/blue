include "bc.inc"

CELL_SIZE = 8
DICT_ENTRY_SIZE = CELL_SIZE * 3
DICT_SIZE = DICT_ENTRY_SIZE * 256

DS_SIZE = CELL_SIZE * 16
DS_MASK = DS_SIZE - 1
DS_BASE = 0x400000

db	BC_WORD_DEFINE
dq	"cellsz"
db	BC_NUM_PUSH
dq	CELL_SIZE
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"desz"
db	BC_NUM_PUSH
dq	DICT_ENTRY_SIZE
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"dictsz"
db	BC_NUM_PUSH
dq	DICT_SIZE
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"org"
db	BC_WORD_DEFINE
dq	"dsbase"
db	BC_NUM_PUSH
dq	DS_BASE
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"dsmask"
db	BC_NUM_PUSH
dq	DS_MASK
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"srcsz"
db	BC_WORD_DEFINE
dq	"dstsz"
db	BC_NUM_PUSH
dq	0x2000
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"resmemsz"
db	BC_WORD_INTERP
dq	"dictsz"
db	BC_WORD_INTERP
dq	"dstsz"
db	BC_ADD
db	BC_WORD_INTERP
dq	"srcsz"
db	BC_ADD
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"dstoff"
db	BC_WORD_INTERP
dq	"dictsz"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"srcoff"
db	BC_WORD_INTERP
dq	"dstoff"
db	BC_WORD_INTERP
dq	"dstsz"
db	BC_ADD
db	BC_WORD_END

db	BC_DSP_NL
db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"reg.src"
db	BC_WORD_INTERP
dq	"rsi"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"reg.dst"
db	BC_WORD_INTERP
dq	"rdi"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"reg.dstb"
db	BC_WORD_INTERP
dq	"r11"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"reg.tos"
db	BC_WORD_INTERP
dq	"rax"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"reg.tos2"
db	BC_WORD_INTERP
dq	"rcx"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"reg.last"
db	BC_WORD_INTERP
dq	"r12"
db	BC_WORD_END

db	BC_DSP_NL
db	BC_DSP_NL
