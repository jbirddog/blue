format elf64 executable 3

segment readable writable executable

BUF_LEN = 4096

MAP_ANONYMOUS = 32
MAP_PRIVATE = 2

PROT_READ = 1
PROT_WRITE = 2

SYS_MMAP = 9
SYS_MUNMAP = 11
SYS_EXIT = 60

buf dq 1
buf_len dd 1
flags dd 1

entry $
	; mmap buf
	xor	edi, edi
	mov	esi, BUF_LEN
	mov	edx, PROT_READ or PROT_WRITE
	mov	r8d, -1
	xor	r9d, r9d
	mov	r10d, MAP_ANONYMOUS or MAP_PRIVATE
	mov	eax, SYS_MMAP
	syscall

	mov	[buf], rax

	; read stdin into buf
	mov	rsi, rax
	
	xor	edi, edi
	mov	edx, BUF_LEN
	xor	eax, eax
	syscall

	test	eax, eax
	jz	.done

	mov	[buf_len], eax

	; use the buf for both input and output
	mov	rdi, [buf]
	mov	rsi, rdi
	
	mov	ecx, eax

.read_byte:
	lodsb
	stosb

.next_byte:
	dec	ecx
	jnz	.read_byte
	
.done:
	; write output part of buf to stdout
	xor	eax, eax
	inc	eax

	mov	rdx, rdi
	sub	rdx, [buf]

	mov	rsi, [buf]
	
	mov	edi, eax
	syscall
	
	; munmap buf
	mov	rdi, [buf]
	mov	esi, [buf_len]
	mov	eax, SYS_MUNMAP
	syscall

	; exit
	xor	edi, edi
	mov	eax, SYS_EXIT
	syscall
