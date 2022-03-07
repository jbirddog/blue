package main

import (
	"fmt"
)

// TODO R8D..., RAX..., R8...
const (
	eax = iota
	ecx
	edx
	ebx
	esp
	ebp
	esi
	edi
)

var registers = map[string]int{
	"eax": eax,
	"ecx": ecx,
	"edx": edx,
	"ebx": ebx,
	"esp": esp,
	"ebp": ebp,
	"esi": esi,
	"edi": edi,
}

type RegisterRef struct {
	Name string
	Reg  string
}

func main() {
	blueFiles := []string{
		"blue/sys.blue",
		"blue/examples/exit33.blue",
		"blue/examples/fib.blue",
		"blue/examples/scratch.blue",
	}

	for _, blueFile := range blueFiles {
		asmFile := blueFile[:len(blueFile)-5] + ".asm"

		env := NewEnvironmentForFile(blueFile)

		for env.ParseNextWord() {
		}

		env.Validate()
		env.WriteAsm(asmFile)
	}

	fmt.Println("ok")
}
