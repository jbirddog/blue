include "b.inc"

db	BC_WORD_DEFINE
dq	"srcsz"
db	BC_NUM_PUSH
dq	0x1000
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"dstsz"
db	BC_NUM_PUSH
dq	0x1000
db	BC_WORD_END

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"opcode"
db	BC_WORD_INTERP
dq	"eax"
db	BC_WORD_INTERP
dq	"!0"
db	BC_WORD_INTERP
dq	"lodsb"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"dispatch"
db	BC_NUM_PUSH
dq	0x14FF
db	BC_COMMA_W
db	BC_NUM_PUSH
dq	0xC5
db	BC_COMMA_B
db	BC_COMMA_D
db	BC_WORD_END

db	BC_ED_NL

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"reset"
db	BC_NUM_PUSH
db	0x1B, "[0m", 0, 0, 0, 0
db	BC_WORD_INTERP
dq	"eax!"
db	BC_WORD_INTERP
dq	"stosd"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"is"
db	BC_NUM_PUSH
db	0x1B, "[", 0, 0, 0, 0, 0, 0
db	BC_WORD_INTERP
dq	"eax!"
db	BC_WORD_INTERP
dq	"stosd"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"and"
db	BC_WORD_END

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"red"
db	BC_NUM_PUSH
dq	"33"
db	BC_WORD_INTERP
dq	"ax!"
db	BC_WORD_INTERP
dq	"stosw"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"yellow"
db	BC_WORD_END

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"bold"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"italic"
db	BC_WORD_END

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"shows"
db	BC_NUM_PUSH
dq	"m"
db	BC_WORD_INTERP
dq	"al!"
db	BC_WORD_INTERP
dq	"stosb"
db	BC_WORD_END

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"name"
db	BC_WORD_INTERP
dq	"movsq"
db	BC_WORD_END

db	BC_ED_NL
db	BC_ED_NL
