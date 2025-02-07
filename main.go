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

	Compile(rwx_mem, []WordDecl{
		// : syscall (( eax num -- eax res )) 0F b, 05 b, ;
		WordDecl{
			Ins: []RegisterFlow{ RegisterFlow{ Idx: 0, Size: 4 }, },
			Outs: []RegisterFlow{ RegisterFlow{ Idx: 0, Size: 4 }, },
			Commands: []Command{
				PushNumber { Val: 0x0F, Size: 1 },
				BComma{},
				PushNumber { Val: 0x05, Size: 1 },
				BComma{},
			},
		},
		// : exit (( edi status -- noret )) 3C syscall ;
		// : bye (( -- noret )) 00 exit ;
		// bye
	})
	
	fmt.Println("Done in main")
}
