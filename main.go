package main

import "encoding/binary"
import "fmt"
import "unsafe"
import "syscall"

/*

#include <stdint.h>

void interpret(uint64_t *data_stack, uint8_t *code) {
	((void (*)())code)(data_stack);
}

*/
import "C"

/*
type Stack[T any] struct {
	elems []T
	i int
}

func NewStack[T any](cap int) Stack[T] {
	return Stack[T]{
		elems: make([]T, cap),
	};
}
*/

func main() {
	//data_stack := NewStack[int64](16)
	data_stack := make([]uint64, 16)
	tos := 0
	here := 0
	uint32_buf := make([]byte, 4)

	code_buffer, err := syscall.Mmap(-1, 0, 4096,
		syscall.PROT_READ|syscall.PROT_WRITE|syscall.PROT_EXEC,
		syscall.MAP_ANONYMOUS|syscall.MAP_PRIVATE,
	)
	if err != nil {
		panic(err)
	}
	defer syscall.Munmap(code_buffer)

	data_stack[tos] = 4
	tos++
	data_stack[tos] = 5
	tos++

	// mov ecx, ds[tos--]
	code_buffer[here] = 0xB9
	here++
	tos--
	binary.LittleEndian.PutUint32(uint32_buf, uint32(data_stack[tos]))
	copy(code_buffer[here:], uint32_buf)
	here += 4

	// mov eax, ds[tos--]
	code_buffer[here] = 0xB8
	here++
	tos--
	binary.LittleEndian.PutUint32(uint32_buf, uint32(data_stack[tos]))
	copy(code_buffer[here:], uint32_buf)
	here += 4

	// add eax, ecx
	code_buffer[here] = 0x01
	here++
	code_buffer[here] = 0xC8
	here++

	// stosq
	code_buffer[here] = 0x48
	here++
	code_buffer[here] = 0xAB
	here++

	// ret
	code_buffer[here] = 0xC3
	here++

	fmt.Println("blue: ", tos, data_stack[0], len(code_buffer))

	// call machine code
	C.interpret(
		(*C.uint64_t)(&data_stack[tos]),
		(*C.uint8_t)(unsafe.Pointer(&code_buffer[0])),
	)

	tos++

	fmt.Println("blue: ", tos, data_stack[0], len(code_buffer))
}
