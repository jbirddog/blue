include "bc.inc"

; x8664
db	BC_WORD_DEFINE
dq	"eax"
db	BC_NUM_EXEC
dq	0x00
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"edi"
db	BC_NUM_EXEC
dq	0x07
db	BC_WORD_END

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"/0"
db	BC_NUM_EXEC
dq	0xC0
db	BC_OR
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"/r"
db	BC_NUM_EXEC
dq	0x03
db	BC_SHL
db	BC_OR
db	BC_WORD_INTERP
dq	"/0"
db	BC_WORD_END

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"xor"
db	BC_NUM_EXEC
dq	0x31
db	BC_WORD_EXEC
dq	"b,"
db	BC_WORD_INTERP
dq	"/r"
db	BC_WORD_EXEC
dq	"b,"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"inc"
db	BC_NUM_EXEC
dq	0xFF
db	BC_WORD_EXEC
dq	"b,"
db	BC_WORD_INTERP
dq	"/0"
db	BC_WORD_EXEC
dq	"b,"
db	BC_WORD_END

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"al!"
db	BC_NUM_EXEC
dq	0xB0
db	BC_WORD_EXEC
dq	"b,"
db	BC_WORD_EXEC
dq	"b,"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"edx!"
db	BC_NUM_EXEC
dq	0xBA
db	BC_WORD_EXEC
dq	"b,"
db	BC_WORD_EXEC
dq	"d,"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"rsi!"
db	BC_NUM_EXEC
dq	0xBE48
db	BC_WORD_EXEC
dq	"w,"
db	BC_WORD_EXEC
dq	","
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"!0"
db	BC_WORD_EXEC
dq	"dup"
db	BC_WORD_INTERP
dq	"xor"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"!1"
db	BC_WORD_EXEC
dq	"dup"
db	BC_WORD_INTERP
dq	"!0"
db	BC_WORD_INTERP
dq	"inc"
db	BC_WORD_END

db	BC_ED_NL
db	BC_ED_NL

; linux

db	BC_WORD_DEFINE
dq	"syscall"
db	BC_WORD_INTERP
dq	"al!"
db	BC_NUM_EXEC
dq	0x050F
db	BC_WORD_EXEC
dq	"w,"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"write"
db	BC_NUM_EXEC
dq	0x01
db	BC_WORD_INTERP
dq	"syscall"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"exit"
db	BC_NUM_EXEC
dq	0x3C
db	BC_WORD_INTERP
dq	"syscall"
db	BC_WORD_END

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"ok"
db	BC_WORD_INTERP
dq	"edi"
db	BC_WORD_INTERP
dq	"!0"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"stdout"
db	BC_WORD_INTERP
dq	"edi"
db	BC_WORD_INTERP
dq	"!1"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"print"
db	BC_WORD_INTERP
dq	"edx!"
db	BC_WORD_INTERP
dq	"rsi!"
db	BC_WORD_INTERP
dq	"stdout"
db	BC_WORD_INTERP
dq	"write"
db	BC_WORD_END

db	BC_ED_NL
db	BC_ED_NL
