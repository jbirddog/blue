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
	env := NewEnvironmentForFile("blue/examples/fib.blue")

	for env.ParseNextWord() {
	}

	env.Validate()
	env.WriteAsm("blue/examples/fib.asm")

	fmt.Println("ok")
}
