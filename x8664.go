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

var size64 = "qword"
var size32 = "dword"
var size16 = "word"
var size8 = "byte"

var registerNamesBySize = map[string][]string{
	size64: reg64Names,
	size32: reg32Names,
	size16: reg16Names,
	size8:  reg8Names,
}

var registerSizeInBytes = map[string]uint{
	size64: 8,
	size32: 4,
	size16: 2,
	size8:  1,
}

var registerSize = map[string]string{
	"rax": size64,
	"rcx": size64,
	"rdx": size64,
	"rbx": size64,
	"rsp": size64,
	"rbp": size64,
	"rsi": size64,
	"rdi": size64,
	"r8":  size64,
	"r9":  size64,
	"r10": size64,
	"r11": size64,
	"r12": size64,
	"r13": size64,
	"r14": size64,
	"r15": size64,

	"eax":  size32,
	"ecx":  size32,
	"edx":  size32,
	"ebx":  size32,
	"esp":  size32,
	"ebp":  size32,
	"esi":  size32,
	"edi":  size32,
	"r8d":  size32,
	"r9d":  size32,
	"r10d": size32,
	"r11d": size32,
	"r12d": size32,
	"r13d": size32,
	"r14d": size32,
	"r15d": size32,

	"ax":   size16,
	"cx":   size16,
	"dx":   size16,
	"bx":   size16,
	"sp":   size16,
	"bp":   size16,
	"si":   size16,
	"di":   size16,
	"r8w":  size16,
	"r9w":  size16,
	"r10w": size16,
	"r11w": size16,
	"r12w": size16,
	"r13w": size16,
	"r14w": size16,
	"r15w": size16,

	"al":   size8,
	"cl":   size8,
	"dl":   size8,
	"bl":   size8,
	"spl":  size8,
	"bpl":  size8,
	"sil":  size8,
	"dil":  size8,
	"r8l":  size8,
	"r9l":  size8,
	"r10l": size8,
	"r11l": size8,
	"r12l": size8,
	"r13l": size8,
	"r14l": size8,
	"r15l": size8,
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
	context.AppendInput(&StackRef{Ref: "al"})

	return &AsmNoOperandInstr{Mnemonic: mnemonic}
}

// TODO hack
func ops_2_sil_dil(mnemonic string, env *Environment, context *RunContext) AsmInstr {
	context.Pop2Inputs()
	context.AppendInput(&StackRef{Ref: "sil"})
	context.AppendInput(&StackRef{Ref: "dil"})

	return &AsmNoOperandInstr{Mnemonic: mnemonic}
}

func ops_1_1(mnemonic string, env *Environment, context *RunContext) AsmInstr {
	op := context.Peek().Ref

	return &AsmUnaryInstr{Mnemonic: mnemonic, Op: op}
}

func ops_2(mnemonic string, env *Environment, context *RunContext) AsmInstr {
	ref1, ref2 := context.Pop2Inputs()
	op1, op2 := ref1.Ref, ref2.Ref

	return &AsmBinaryInstr{Mnemonic: mnemonic, Op1: op1, Op2: op2}
}

func ops_2_1(mnemonic string, env *Environment, context *RunContext) AsmInstr {
	ref1, ref2 := context.Pop2Inputs()
	op1, op2 := ref1.Ref, ref2.Ref

	context.AppendInput(ref1)

	return &AsmBinaryInstr{Mnemonic: mnemonic, Op1: op1, Op2: op2}
}

func ops_shift(mnemonic string, env *Environment, context *RunContext) AsmInstr {
	ref1, ref2 := context.Pop2Inputs()
	op1, op2 := ref1.Ref, ref2.Ref

	context.AppendInput(ref1)

	if ref2.Type == StackRefType_Register {
		if registers[op2] != ecx {
			log.Fatal("Shift expects ECX register flavor")
		}

		op2 = "cl"
	}

	return &AsmBinaryInstr{Mnemonic: mnemonic, Op1: op1, Op2: op2}
}

func ops_2_x2(mnemonic string, env *Environment, context *RunContext) AsmInstr {
	ref1, ref2 := context.Pop2Inputs()
	op1, op2 := ref1.Ref, ref2.Ref

	context.AppendInput(ref2)
	context.AppendInput(ref1)

	return &AsmBinaryInstr{Mnemonic: mnemonic, Op1: op1, Op2: op2}
}

func ops_loopx(mnemonic string, env *Environment, context *RunContext) AsmInstr {
	ref2, ref1 := context.Pop2Inputs()
	op2, op1 := ref1.Ref, ref2.Ref

	// TODO improve this check as the hacks mentioned below are addressed
	// TODO can also enforce label on the stack now
	if op1 != "ecx" && op1 != "rcx" {
		log.Fatalf("%s expects rcx variant, got %s\n", mnemonic, op1)
	}

	return &AsmUnaryInstr{Mnemonic: mnemonic, Op: op2}
}

func ops_repx(mnemonic string, env *Environment, context *RunContext) AsmInstr {
	ref := context.PopInput()
	// TODO improve this check as the hacks mentioned below are addressed
	if ref.Ref != "ecx" && ref.Ref != "rcx" {
		log.Fatalf("%s expects rcx variant, got %s\n", mnemonic, ref.Ref)
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
