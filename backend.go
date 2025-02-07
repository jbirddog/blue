package main

import "fmt"
import "unsafe"

/*

#include <stdint.h>

void interpret(uint64_t *data_stack, uint8_t *code) {
	((void (*)())code)(data_stack);
}

*/
import "C"

/*

: syscall (( eax num -- eax res )) 0F b, 05 b, ;
: exit (( edi status -- noret )) 3C syscall ;
: bye (( -- noret )) 00 exit ;

bye

*/

type Flag uint

const (
	Anon Flag = 1 << iota
	Immed
	NoRet
)

type NumberFlow struct {
	Val uint64
	Size int
}

type RegisterFlow struct {
	Idx int
	Size int
}

type Instruction interface {
}

type WordDecl struct {
	Flags Flag
	Ins []RegisterFlow
	Outs []RegisterFlow
	Instrs []Instruction
}

func Compile(rwx_mem []byte, decls []WordDecl) {
	codeBuf := NewCodeBuf(rwx_mem)

	dataStack := NewStack(16)
	dataStack.Push(4)
	dataStack.Push(5)

	// mov ecx, ds[tos--]
	codeBuf.Append(0xB9)
	codeBuf.AppendUint32(uint32(dataStack.Pop()))

	// mov eax, ds[tos--]
	codeBuf.Append(0xB8)
	codeBuf.AppendUint32(uint32(dataStack.Pop()))

	codeBuf.Append(
		// add eax, ecx
		0x01, 0xC8,
		// stosq
		0x48, 0xAB,
		// ret
		0xC3,
	)

	fmt.Println("before: ", dataStack.I, dataStack.Elems[0], len(codeBuf.Mem))

	// call machine code
	C.interpret(
		(*C.uint64_t)(dataStack.Top()),
		(*C.uint8_t)(unsafe.Pointer(&codeBuf.Mem[0])),
	)

	// update based on number of stosq's
	dataStack.I += 1

	fmt.Println("after: ", dataStack.I, dataStack.Elems[0], len(codeBuf.Mem))
}
