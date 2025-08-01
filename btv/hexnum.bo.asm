include "b.inc"

db	BC_WORD_DEFINE
dq	"hextbl"

db	BC_NUM_COMP
dq	"01234567"

db	BC_NUM_COMP
dq	"89ABCDEF"

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"nibble"
; c0 ca 04                ror    dl,0x4
db	BC_NUM_PUSH
dq	0xCAC0
db	BC_COMMA_W
db	BC_NUM_PUSH
dq	0x04
db	BC_COMMA_B
; 88 d0                   mov    al,dl
db	BC_NUM_PUSH
dq	0xD088
db	BC_COMMA_W
; 24 0f                   and    al,0xf
db	BC_NUM_PUSH
dq	0x0F24
db	BC_COMMA_W

db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"hexchr"
db	BC_WORD_INTERP
dq	"nibble"
db	BC_WORD_INTERP
dq	"xlatb"
db	BC_WORD_INTERP
dq	"stosb"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"hexdigit"
; 48 c1 c2 08             rol    rdx,0x8
db	BC_NUM_PUSH
dq	0xC148
db	BC_COMMA_W
db	BC_NUM_PUSH
dq	0x08C2
db	BC_COMMA_W
; 08 d4                   or     ah,dl
db	BC_NUM_PUSH
dq	0xD408
db	BC_COMMA_W
; 84 e4                   test   ah,ah
db	BC_NUM_PUSH
dq	0xE484
db	BC_COMMA_W
; 74 0a                   je     0xc
db	BC_NUM_PUSH
dq	0x0A74
db	BC_COMMA_W

db	BC_WORD_RCALL
dq	"hexchr"
db	BC_WORD_RCALL
dq	"hexchr"

db	BC_NUM_PUSH
dq	0x90
db	BC_COMMA_B

db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"hexstr"
db	BC_WORD_INTERP
dq	"rbx="
db	BC_WORD_RADDR
dq	"hextbl"
db	BC_COMMA

; b4 00                   mov    ah,0x0
db	BC_NUM_PUSH
dq	0x00B4
db	BC_COMMA_W

db	BC_WORD_RCALL
dq	"hexdigit"
db	BC_WORD_RCALL
dq	"hexdigit"
db	BC_WORD_RCALL
dq	"hexdigit"
db	BC_WORD_RCALL
dq	"hexdigit"
db	BC_WORD_RCALL
dq	"hexdigit"
db	BC_WORD_RCALL
dq	"hexdigit"
db	BC_WORD_RCALL
dq	"hexdigit"

; b4 01                   mov    ah,0x1
db	BC_NUM_PUSH
dq	0x01B4
db	BC_COMMA_W
db	BC_WORD_RCALL
dq	"hexdigit"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"ashex"
; 48 89 c2                mov    rdx,rax
db	BC_NUM_PUSH
dq	0x8948
db	BC_COMMA_W
db	BC_NUM_PUSH
dq	0xC2
db	BC_COMMA_B
db	BC_WORD_RCALL
dq	"hexstr"
db	BC_WORD_END

db	BC_DSP_NL
db	BC_DSP_NL
