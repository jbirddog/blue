package main

import (
	"fmt"
	"log"
	"os"
)

const (
	eax = iota
	ecx
	edx
	ebx
	esp
	ebp
	esi
	edi

	r8d
	r9d
	r10d
	r11d
	r12d
	r13d
	r14d
	r15d
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

	r8
	r9
	r10
	r11
	r12
	r13
	r14
	r15
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

	"r8d",
	"r9d",
	"r10d",
	"r11d",
	"r12d",
	"r13d",
	"r14d",
	"r15d",
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

	"r8",
	"r9",
	"r10",
	"r11",
	"r12",
	"r13",
	"r14",
	"r15",
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

	"r8d":  r8d,
	"r9d":  r9d,
	"r10d": r10d,
	"r11d": r11d,
	"r12d": r12d,
	"r13d": r13d,
	"r14d": r14d,
	"r15d": r15d,

	"rax": rax,
	"rcx": rcx,
	"rdx": rdx,
	"rbx": rbx,
	"rsp": rsp,
	"rbp": rbp,
	"rsi": rsi,
	"rdi": rdi,

	"r8":  r8,
	"r9":  r9,
	"r10": r10,
	"r11": r11,
	"r12": r12,
	"r13": r13,
	"r14": r14,
	"r15": r15,
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
