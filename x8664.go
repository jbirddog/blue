package main

import (
	"log"
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
	ax = iota
	cx
	dx
	bx
	sp
	bp
	si
	di
	r8w
	r9w
	r10w
	r11w
	r12w
	r13w
	r14w
	r15w
)

const (
	al = iota
	cl
	dl
	bl
	spl
	bpl
	sil
	dil
	r8l
	r9l
	r10l
	r11l
	r12l
	r13l
	r14l
	r15l
)

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

var reg16Names = []string{
	"ax",
	"cx",
	"dx",
	"bx",
	"sp",
	"bp",
	"si",
	"di",
	"r8w",
	"r9w",
	"r10w",
	"r11w",
	"r12w",
	"r13w",
	"r14w",
	"r15w",
}

var reg8Names = []string{
	"al",
	"cl",
	"dl",
	"bl",
	"spl",
	"bpl",
	"sil",
	"dil",
	"r8l",
	"r9l",
	"r10l",
	"r11l",
	"r12l",
	"r13l",
	"r14l",
	"r15l",
}

var registers = map[string]int{
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

	"eax":  eax,
	"ecx":  ecx,
	"edx":  edx,
	"ebx":  ebx,
	"esp":  esp,
	"ebp":  ebp,
	"esi":  esi,
	"edi":  edi,
	"r8d":  r8d,
	"r9d":  r9d,
	"r10d": r10d,
	"r11d": r11d,
	"r12d": r12d,
	"r13d": r13d,
	"r14d": r14d,
	"r15d": r15d,

	"ax":   ax,
	"cx":   cx,
	"dx":   dx,
	"bx":   bx,
	"sp":   sp,
	"bp":   bp,
	"si":   si,
	"di":   di,
	"r8w":  r8w,
	"r9w":  r9w,
	"r10w": r10w,
	"r11w": r11w,
	"r12w": r12w,
	"r13w": r13w,
	"r14w": r14w,
	"r15w": r15w,

	"al":   al,
	"cl":   cl,
	"dl":   dl,
	"bl":   bl,
	"spl":  spl,
	"bpl":  bpl,
	"sil":  sil,
	"dil":  dil,
	"r8l":  r8l,
	"r9l":  r9l,
	"r10l": r10l,
	"r11l": r11l,
	"r12l": r12l,
	"r13l": r13l,
	"r14l": r14l,
	"r15l": r15l,
}

var registerSize = map[string]string{
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

	"eax":  "dword",
	"ecx":  "dword",
	"edx":  "dword",
	"ebx":  "dword",
	"esp":  "dword",
	"ebp":  "dword",
	"esi":  "dword",
	"edi":  "dword",
	"r8d":  "dword",
	"r9d":  "dword",
	"r10d": "dword",
	"r11d": "dword",
	"r12d": "dword",
	"r13d": "dword",
	"r14d": "dword",
	"r15d": "dword",

	"ax":   "word",
	"cx":   "word",
	"dx":   "word",
	"bx":   "word",
	"sp":   "word",
	"bp":   "word",
	"si":   "word",
	"di":   "word",
	"r8w":  "word",
	"r9w":  "word",
	"r10w": "word",
	"r11w": "word",
	"r12w": "word",
	"r13w": "word",
	"r14w": "word",
	"r15w": "word",

	"al":   "byte",
	"cl":   "byte",
	"dl":   "byte",
	"bl":   "byte",
	"spl":  "byte",
	"bpl":  "byte",
	"sil":  "byte",
	"dil":  "byte",
	"r8l":  "byte",
	"r9l":  "byte",
	"r10l": "byte",
	"r11l": "byte",
	"r12l": "byte",
	"r13l": "byte",
	"r14l": "byte",
	"r15l": "byte",
}

type x8664Lowerer = func(string, *Environment, *RunContext) AsmInstr

func ops_0(mnemonic string, env *Environment, context *RunContext) AsmInstr {
	return &AsmNoOperandInstr{Mnemonic: mnemonic}
}

func ops_0_2_1(mnemonic string, env *Environment, context *RunContext) AsmInstr {
	op1, _ := context.Pop2Inputs()
	context.AppendInput(op1)

	return &AsmNoOperandInstr{Mnemonic: mnemonic}
}

// TODO hack
func ops_0_al(mnemonic string, env *Environment, context *RunContext) AsmInstr {
	context.AppendInput("al")

	return &AsmNoOperandInstr{Mnemonic: mnemonic}
}

// TODO hack
func ops_2_sil_dil(mnemonic string, env *Environment, context *RunContext) AsmInstr {
	context.Pop2Inputs()
	context.AppendInput("sil")
	context.AppendInput("dil")

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

func ops_loopx(mnemonic string, env *Environment, context *RunContext) AsmInstr {
	op := context.PopInput()

	ref := context.PopInput()
	// TODO improve this check as the hacks mentioned below are addressed
	if ref != "ecx" && ref != "rcx" {
		log.Fatalf("%s expects rcx variant, got %s\n", mnemonic, ref)
	}

	return &AsmUnaryInstr{Mnemonic: mnemonic, Op: op}
}

func ops_repx(mnemonic string, env *Environment, context *RunContext) AsmInstr {
	ref := context.PopInput()
	// TODO improve this check as the hacks mentioned below are addressed
	if ref != "ecx" && ref != "rcx" {
		log.Fatalf("%s expects rcx variant, got %s\n", mnemonic, ref)
	}

	previous := env.PopAsmInstr().(*AsmNoOperandInstr)

	return &AsmUnaryInstr{Mnemonic: mnemonic, Op: previous.Mnemonic}
}

var x8664Lowerers = map[string]x8664Lowerer{
	"add":     ops_2_1,
	"and":     ops_2_1,
	"cld":     ops_0,
	"cmp":     ops_2,
	"cmpsb":   ops_2_sil_dil, // TODO hack - needs to enforce rsi/rdi -> rsi/rdi (variant)
	"cmpsw":   ops_0,         // TODO hack - needs to enforce rsi/rdi -> rsi/rdi (variant)
	"cmpsd":   ops_0,         // TODO hack - needs to enforce rsi/rdi -> rsi/rdi (variant)
	"cmpsq":   ops_0,         // TODO hack - needs to enforce rsi/rdi -> rsi/rdi (variant)
	"dec":     ops_1_1,
	"inc":     ops_1_1,
	"lodsb":   ops_0_al,      // TODO hack - needs to consume esi, assumes al
	"loop":    ops_loopx,     // TODO hack - needs to consume ecx
	"loope":   ops_loopx,     // TODO hack - needs to consume ecx
	"loopne":  ops_loopx,     // TODO hack - needs to consume ecx
	"movsb":   ops_2_sil_dil, // TODO same hack as all around this
	"movsw":   ops_2_sil_dil, // TODO next 3 need right registers, ideally with real fix
	"movsd":   ops_2_sil_dil,
	"movsq":   ops_2_sil_dil,
	"neg":     ops_1_1,
	"or":      ops_2_1,
	"rep":     ops_repx,
	"repe":    ops_repx,
	"repz":    ops_repx,
	"repne":   ops_repx,
	"repnz":   ops_repx,
	"ret":     ops_0,
	"scasb":   ops_0_2_1, // TODO needs to enforce rdi/rax -> rdi (variant)
	"scasw":   ops_0_2_1, // TODO needs to enforce rdi/rax -> rdi (variant)
	"scasd":   ops_0_2_1, // TODO needs to enforce rdi/rax -> rdi (variant)
	"scasq":   ops_0_2_1, // TODO needs to enforce rdi/rax -> rdi (variant)
	"sal":     ops_shift,
	"sar":     ops_shift,
	"shl":     ops_shift,
	"shr":     ops_shift,
	"std":     ops_0,
	"sub":     ops_2_1,
	"syscall": ops_0,
	"xadd":    ops_2_1,
	"xchg":    ops_2_x2,
}
