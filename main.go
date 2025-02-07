package main

import "fmt"
import "syscall"

func main() {
	// TODO: move to sys_linux.go
	rwx_mem, err := syscall.Mmap(-1, 0, 4096,
		syscall.PROT_READ|syscall.PROT_WRITE|syscall.PROT_EXEC,
		syscall.MAP_ANONYMOUS|syscall.MAP_PRIVATE,
	)
	if err != nil {
		panic(err)
	}
	defer syscall.Munmap(rwx_mem)

	ctx := &CompileCtx{
		CodeBuf:       &CodeBuf{Mem: rwx_mem},
		DataFlowStack: NewDataFlowStack(16),
	}
	
	/*
		0:  b0 3c                   mov    al,0x3c
		2:  40 b7 0b                mov    dil,0xb
		5:  0f 05                   syscall
	*/
	Compile(ctx, []CompilationBlock{
		CommandList{
			Commands: []Command{
				&Lit{Val: 0xC3, Size: 1},
				&Comma{Size: 1},
				/*
				&Lit{Val: 0xB0, Size: 1},
				&Comma{Size: 1},
				&Lit{Val: 0x3C, Size: 1},
				&Comma{Size: 1},
				&Lit{Val: 0x40, Size: 1},
				&Comma{Size: 1},
				&Lit{Val: 0xB7, Size: 1},
				&Comma{Size: 1},
				&Lit{Val: 0x0B, Size: 1},
				&Comma{Size: 1},
				&Lit{Val: 0x0F, Size: 1},
				&Comma{Size: 1},
				&Lit{Val: 0x05, Size: 1},
				&Comma{Size: 1},
				*/
			},
		},
	})

	/*
		Compile(rwx_mem, []WordDecl{
			// : syscall (( eax num -- eax res )) 0F b, 05 b, trust ;
			WordDecl{
				Ins: []RegisterFlow{ RegisterFlow{ Idx: 0, Size: 4 }, },
				Outs: []RegisterFlow{ RegisterFlow{ Idx: 0, Size: 4 }, },
				Commands: []Command{
					Lit { Val: 0x0F, Size: 1 },
					Comma{},
					Lit { Val: 0x05, Size: 1 },
					Comma{},
					Trust{},
				},
			},
			// : exit (( edi status -- noret )) 3C syscall ;
			// : bye (( -- noret )) 00 exit ;
			// bye
		})
	*/

	fmt.Println("Done in main")
}
