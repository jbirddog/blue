package main

import (
	"fmt"
	"log"
	"os"
)

// TODO R8D..., R8...
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

const (
	rax = iota
	rcx
	rdx
	rbx
	rsp
	rbp
	rsi
	rdi
)

var reg32Names = []string{
	"eax",
	"ecx",
	"edx",
	"ebx",
	"esp",
	"ebp",
	"esi",
	"edi",
}

var reg64Names = []string{
	"rax",
	"rcx",
	"rdx",
	"rbx",
	"rsp",
	"rbp",
	"rsi",
	"rdi",
}

var registers = map[string]int{
	"eax": eax,
	"ecx": ecx,
	"edx": edx,
	"ebx": ebx,
	"esp": esp,
	"ebp": ebp,
	"esi": esi,
	"edi": edi,

	"rax": rax,
	"rcx": rcx,
	"rdx": rdx,
	"rbx": rbx,
	"rsp": rsp,
	"rbp": rbp,
	"rsi": rsi,
	"rdi": rdi,
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
	env := ParseFileInNewEnvironment(blueFile)

	env.WriteAsm(asmFile)

	fmt.Printf("ok\t%s\n", blueFile)
}
