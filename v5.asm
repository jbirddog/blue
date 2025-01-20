format elf64 executable 3

segment readable writable executable

block_size = 1024
target_size = block_size
elf_size = 120
app_space = target_size - elf_size

opcode_tbl_addr = $ + app_space
opcode_tbl_size = (block_size shl 2)

return_stack_addr = opcode_tbl_addr + opcode_tbl_size
return_stack_size = block_size

data_stack_addr = return_stack_addr + return_stack_size
data_stack_size = block_size

code_buffer_addr = data_stack_addr + data_stack_size
code_buffer_size = (block_size shl 2)

input_buffer_addr = code_buffer_addr + code_buffer_size

entry $
	mov	r8, opcode_tbl_addr
	mov	r9, return_stack_addr
	mov	r10, data_stack_addr
	mov	r11, code_buffer_addr
	mov	r12, input_buffer_addr
	
	mov	dil, byte [r8]
	mov	eax, 60
	syscall

assert ($ - $$) <= app_space
times (app_space - ($ - $$)) db 0
assert ($ - $$) = app_space
