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

const (
	RegisterRefTarget_Input = iota
	RegisterRefTarget_Output
)

func main() {
	env := NewEnvironmentForFile("blue/examples/exit33.blue")

	for env.ParseNextWord() {
	}

	env.Validate()
	env.WriteAsm("blue/examples/exit33.asm")

	fmt.Println("ok")
}
