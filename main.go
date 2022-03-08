package main

import (
	"fmt"
	"log"
	"os"
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
	if len(os.Args) != 2 {
		log.Fatal("Usage: gfe blueFile")
	}

	blueFile := os.Args[1]
	asmFile := blueFile[:len(blueFile)-5] + ".asm"
	env := NewEnvironmentForFile(blueFile)

	for env.ParseNextWord() {
	}

	env.Validate()
	env.WriteAsm(asmFile)

	fmt.Printf("ok\t%s\n", blueFile)
}
