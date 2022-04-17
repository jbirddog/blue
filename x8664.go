package main

import (
	"log"
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

var registerSize = map[string]string{
	"eax": "dword",
	"ecx": "dword",
	"edx": "dword",
	"ebx": "dword",
	"esp": "dword",
	"ebp": "dword",
	"esi": "dword",
	"edi": "dword",

	"r8d":  "dword",
	"r9d":  "dword",
	"r10d": "dword",
	"r11d": "dword",
	"r12d": "dword",
	"r13d": "dword",
	"r14d": "dword",
	"r15d": "dword",

	"rax": "qword",
	"rcx": "qword",
	"rdx": "qword",
	"rbx": "qword",
	"rsp": "qword",
	"rbp": "qword",
	"rsi": "qword",
	"rdi": "qword",

	"r8":  "qword",
	"r9":  "qword",
	"r10": "qword",
	"r11": "qword",
	"r12": "qword",
	"r13": "qword",
	"r14": "qword",
	"r15": "qword",
}

type x8664Lowerer = func(string, *Environment, *RunContext) AsmInstr

func ops_0(mnemonic string, env *Environment, context *RunContext) AsmInstr {
	return &AsmNoOperandInstr{Mnemonic: mnemonic}
}

// TODO hack
func ops_0_al(mnemonic string, env *Environment, context *RunContext) AsmInstr {
	context.AppendInput("al")

	return &AsmNoOperandInstr{Mnemonic: mnemonic}
}

func ops_1_1(mnemonic string, env *Environment, context *RunContext) AsmInstr {
	op := context.Peek()

	return &AsmUnaryInstr{Mnemonic: mnemonic, Op: op}
}

func ops_2(mnemonic string, env *Environment, context *RunContext) AsmInstr {
	op1, op2 := context.Pop2Inputs()

	return &AsmBinaryInstr{Mnemonic: mnemonic, Op1: op1, Op2: op2}
}

func ops_2_1(mnemonic string, env *Environment, context *RunContext) AsmInstr {
	op1, op2 := context.Pop2Inputs()
	context.AppendInput(op1)

	return &AsmBinaryInstr{Mnemonic: mnemonic, Op1: op1, Op2: op2}
}

func ops_shift(mnemonic string, env *Environment, context *RunContext) AsmInstr {
	op1, op2 := context.Pop2Inputs()
	context.AppendInput(op1)

	if reg, found := registers[op2]; found {
		if reg != ecx {
			log.Fatal("Shift expects ECX register flavor")
		}

		op2 = "cl"
	}

	return &AsmBinaryInstr{Mnemonic: mnemonic, Op1: op1, Op2: op2}
}

func ops_2_x2(mnemonic string, env *Environment, context *RunContext) AsmInstr {
	op1, op2 := context.Pop2Inputs()
	context.AppendInput(op2)
	context.AppendInput(op1)

	return &AsmBinaryInstr{Mnemonic: mnemonic, Op1: op1, Op2: op2}
}

func op_label(mnemonic string, env *Environment, context *RunContext) AsmInstr {
	op := context.PopInput()

	return &AsmUnaryInstr{Mnemonic: mnemonic, Op: op}
}

func consume_previous(mnemonic string, env *Environment, context *RunContext) AsmInstr {
	previous := env.PopAsmInstr().(*AsmNoOperandInstr)

	return &AsmUnaryInstr{Mnemonic: mnemonic, Op: previous.Mnemonic}
}

var x8664Lowerers = map[string]x8664Lowerer{
	"add":     ops_2_1,
	"and":     ops_2_1,
	"cmp":     ops_2,
	"dec":     ops_1_1,
	"inc":     ops_1_1,
	"lodsb":   ops_0_al, // TODO hack - needs to consume esi, assumes al
	"loop":    op_label, // TODO hack - needs to consume ecx
	"loopne":  op_label, // TODO hack - needs to consume ecx
	"neg":     ops_1_1,
	"or":      ops_2_1,
	"repne":   consume_previous,
	"ret":     ops_0,
	"scasb":   ops_0, // TODO needs to enforce rdi/rax -> rdi (variant)
	"scasw":   ops_0, // TODO needs to enforce rdi/rax -> rdi (variant)
	"scasd":   ops_0, // TODO needs to enforce rdi/rax -> rdi (variant)
	"scasq":   ops_0, // TODO needs to enforce rdi/rax -> rdi (variant)
	"sal":     ops_shift,
	"sar":     ops_shift,
	"shl":     ops_shift,
	"shr":     ops_shift,
	"sub":     ops_2_1,
	"syscall": ops_0,
	"xadd":    ops_2, // TODO needs to push op1 back
	"xchg":    ops_2_x2,
}
