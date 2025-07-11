include "bc.inc"

db	BC_DEFINE_WORD
dq	"exit"

; 31 c0			xor    eax,eax
db	BC_COMP_BYTE, 0x31
db	BC_COMP_BYTE, 0xC0

; b0 3c			mov    al,0x3c
db	BC_COMP_BYTE, 0xB0
db	BC_COMP_BYTE, 0x3C

; 40 b7 03		mov    dil,0x7
db	BC_COMP_BYTE, 0x40
db	BC_COMP_BYTE, 0xB7
db	BC_COMP_BYTE, 0x07

; 0f 05			syscall
db	BC_COMP_BYTE, 0x0F
db	BC_COMP_BYTE, 0x05

db	BC_EXEC_WORD
dq	"dstsz"

db	BC_FIN
