
; Block 0
format ELF64 executable 3

BLK_0 = $$ - ELF_HEADERS_SIZE

segment readable writeable executable

; these registers have app lifetime
DS_REG = r12
RS_REG = r13
IP_REG = r14
OP_REG = r15

include "bluevm_defs.inc"
include "stack.inc"
include "ops_code.inc"
include "interpreter.inc"

entry $
	mov	DS_REG, data_stack
	mov	RS_REG, return_stack
	mov	IP_REG, boot_sector
	mov	OP_REG, opcode_handler_interpret
	
	mov	rax, [rsp]
	mov	[argc], rax
	lea	rax, [rsp+8]
	mov	[argv], rax
	
	call	interpreter

BLK_0_PADDING = VM_CODE_SIZE - ($ - $$)
show "Bytes left in block 0: ", BLK_0_PADDING

times BLK_0_PADDING db 0

; Blocks 1 - 4
opcode_tbl:
.offset = 0x00
include "ops_vm.inc"
times (OPCODE_TBL_SIZE - ($ - opcode_tbl)) db 0

; Block 5
boot_sector:
	db	op_litw_code
	dw	BLOCK_SIZE
	db	op_litb_code, 0x06
	db	op_blk_code
	db	op_litb_code, 0x00
	db	op_dup_code
	db	op_scall3_code
	db	op_drop_code
	db	op_litb_code, 0x06
	db	op_blk_code
	db	op_setip_code

times (BOOT_SECTOR_SIZE - ($ - boot_sector)) db 0

return_stack: times RETURN_STACK_SIZE db 0
data_stack: times DATA_STACK_SIZE db 0

; Block 6
input_buffer: times INPUT_BUFFER_SIZE db 0

; Blocks 7 - 10
code_buffer rb CODE_BUFFER_SIZE

assert ($ - $$) = VM_MEM_SIZE
