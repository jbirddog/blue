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

buf dq 0
buf_len dd 0

; convert hex character to byte value
h2b:
	mov	r8b, al
	and	r8b, 0x40
	mov	r9b, r8b
	shr	r9b, 3
	mov	r10b, r8b
	shr	r10b, 6
	or	r9b, r10b
	add	al, r9b
	and	al, 0x0F
	ret

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

	push	rax

	;
	; rdi - output buf
	; rsi - input buf
	; ecx - length of input buf
	; edx - parsing status
	;  al - current byte
	;
	
	mov	rdi, [buf]
	mov	rsi, rdi
	mov	ecx, eax
	xor	eax, eax
	xor	edx, edx

.read_byte:
	lodsb
	
	cmp	al, " "
	je	.next_byte

	xor	ebx, ebx

	cmp	al, 10
	cmove	edx, ebx
	je	.next_byte

	not	ebx
	
	cmp	al, "#"
	cmove	edx, ebx
	je	.next_byte

	test	edx, edx
	jnz	.next_byte

	call	h2b
	shl	eax, 12

	dec	ecx
	lodsb

	call	h2b
	or	al, ah

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
	pop	rsi
	
	mov	rdi, [buf]
	mov	eax, SYS_MUNMAP
	syscall

	; exit
	xor	edi, edi
	mov	eax, SYS_EXIT
	syscall
