package main

import "encoding/binary"
import "fmt"

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
	binary.LittleEndian.PutUint32(int32_buf, uint32(data_stack[tos]))
	tos--
	code_buffer = append(code_buffer, int32_buf...)

	// mov ecx, ds[tos--]
	code_buffer = append(code_buffer, 0xB8)
	binary.LittleEndian.PutUint32(int32_buf, uint32(data_stack[tos]))
	tos--
	code_buffer = append(code_buffer, int32_buf...)

	// add eax, ecx
	code_buffer = append(code_buffer, 0x01)
	code_buffer = append(code_buffer, 0xC8)
	
	// stosq
	code_buffer = append(code_buffer, 0x48)
	code_buffer = append(code_buffer, 0xAB)
	
	// ret
	code_buffer = append(code_buffer, 0xC3)

	// call machine code
	
	fmt.Println("blue: ", tos, len(code_buffer), len(int32_buf))
}
