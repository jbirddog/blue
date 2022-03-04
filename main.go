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
	examples := []string{
		"blue/examples/exit33.blue",
		"blue/examples/fib.blue",
	}

	for _, example := range examples {
		output := example[:len(example)-5] + ".asm"

		env := NewEnvironmentForFile(example)

		for env.ParseNextWord() {
		}

		env.Validate()
		env.WriteAsm(output)
	}

	fmt.Println("ok")
}
