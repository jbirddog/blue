
format ELF64 executable 3

BLK_0 = $$ - ELF_HEADERS_SIZE

OPCODE_HANDLER_COMPILE = opcode_handler_compile
OPCODE_HANDLER_INTERPRET = opcode_handler_interpret
OPCODE_HANDLER_INVALID = _opcode_handler_invalid

segment readable writeable executable

instruction_pointer dq input_buffer

opcode_handler dq OPCODE_HANDLER_INTERPRET
opcode_handler_invalid dq OPCODE_HANDLER_INVALID

return_stack_here dq return_stack
data_stack_here dq data_stack

include "bluevm_defs.inc"
include "stack.inc"
include "ops_code.inc"
include "interpreter.inc"

; expects status in edi
exit:
	mov	eax, 60
	syscall

read_boot_code:
	mov	rsi, input_buffer
	xor	eax, eax

	cmp	[rsi], rax
	jne	.done

	mov	edx, INPUT_BUFFER_SIZE
	xor	edi, edi
	syscall
	
	test	rax, rax
	cmovng	edi, eax
	jng	exit

.done:
	ret

entry $
	mov	rax, [rsp]
	mov	[argc], rax
	lea	rax, [rsp+8]
	mov	[argv], rax
	
	call	read_boot_code	
	call	interpreter

times (VM_CODE_SIZE - ($ - $$)) db 0

opcode_tbl:
.offset = 0x00
include "ops_vm.inc"
times (OPCODE_TBL_SIZE - ($ - opcode_tbl)) db 0

input_buffer: times INPUT_BUFFER_SIZE db 0

return_stack rb RETURN_STACK_SIZE
data_stack rb DATA_STACK_SIZE
code_buffer rb CODE_BUFFER_SIZE

assert ($ - $$) = VM_MEM_SIZE
