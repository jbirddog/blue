package main

/*

#include <stdint.h>

void interpret(uint64_t *data_stack, uint8_t *code) {
	((void (*)())code)(data_stack);
}

*/
import "C"

/*

# Milestone 1:

0B b, 3C b,
40 b, B7 b, 0B b,
oF b, 05 b,

# Milestone 2:

: syscall (( eax num -- eax res )) 0F b, 05 b, trust ;
: exit (( edi status -- noret )) 3C syscall ;
: bye (( -- noret )) 00 exit ;

bye

*/

type CompilationBlock interface{}

type CommandList struct {
	Outs     []*RegisterFlow
	Commands []Command
}

/*
type WordFlag uint

const (
	NoRet WordFlag = 1 << iota
)

type WordDecl struct {
	Flags WordFlag
	Ins []*RegisterFlow
	Outs []*RegisterFlow
	Commands []Command
}
*/

func Compile(rwx_mem []byte, blocks []CompilationBlock) {
	codeBuf := &CodeBuf{Mem: rwx_mem}
	dataFlowStack := NewDataFlowStack(16)

	_ = &CommandCtx{
		CodeBuf:       codeBuf,
		DataFlowStack: dataFlowStack,
	}

	for _, b := range blocks {
		switch block := b.(type) {
		case CommandList:
			block.Compile()
		default:
			panic("Unexpected block type")
		}

		/*
			for _, command := range decl.Commands {
				command.Execute(cmdCtx)
			}
		*/
	}
}

func (c *CommandList) Compile() {
}

/*
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
*/
