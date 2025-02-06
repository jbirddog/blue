package main

import "encoding/binary"
import "fmt"
import "unsafe"
import "syscall"

/*

#include <stdint.h>
#include <stdio.h>

void interpret(int64_t *data_stack, uint8_t *code_buffer) {
	((void (*)())code_buffer)(data_stack);
	printf("OK? %d\n", *code_buffer);
}

*/
import "C"

func main() {
	var data_stack [16]int64
	tos := 0
	code_buffer := make([]byte, 0, 4096)
	int32_buf := make([]byte, 4)

	data_stack[tos] = 4
	tos++
	data_stack[tos] = 5
	tos++

	// mov ecx, ds[tos--]
	code_buffer = append(code_buffer, 0xB9)
	tos--
	fmt.Println("ecx: ", data_stack[tos])
	binary.LittleEndian.PutUint32(int32_buf, uint32(data_stack[tos]))
	code_buffer = append(code_buffer, int32_buf...)

	// mov eax, ds[tos--]
	code_buffer = append(code_buffer, 0xB8)
	tos--
	fmt.Println("eax: ", data_stack[tos])
	binary.LittleEndian.PutUint32(int32_buf, uint32(data_stack[tos]))
	code_buffer = append(code_buffer, int32_buf...)

	// add eax, ecx
	code_buffer = append(code_buffer, 0x01)
	code_buffer = append(code_buffer, 0xC8)
	
	// stosq
	code_buffer = append(code_buffer, 0x48)
	code_buffer = append(code_buffer, 0xAB)
	
	// ret
	code_buffer = append(code_buffer, 0xC3)

	cb, err := syscall.Mmap(-1, 0, 4096, syscall.PROT_READ|syscall.PROT_WRITE|syscall.PROT_EXEC, syscall.MAP_ANONYMOUS|syscall.MAP_PRIVATE)
	if err != nil {
		panic(err)
	}
	defer syscall.Munmap(cb)

	copy(cb, code_buffer)
	
	fmt.Println("blue: ", tos, data_stack[0], len(code_buffer), len(cb))
	data_stack[0] = 111

	// call machine code
	C.interpret(
		(*C.int64_t)(&data_stack[tos]),
		(*C.uint8_t)(unsafe.Pointer(&cb[0])),
	)

	tos++
	
	fmt.Println("blue: ", tos, data_stack[0], len(code_buffer), len(cb))
}
