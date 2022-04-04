package main

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
	"and":     ops_2, // TODO needs to push op1 back
	"cmp":     ops_2,
	"dec":     ops_1_1,
	"lodsb":   ops_0_al, // TODO hack - needs to consume esi, assumes al
	"loop":    op_label, // TODO hack - needs to consume ecx
	"loopne":  op_label, // TODO hack - needs to consume ecx
	"neg":     ops_1_1,
	"repne":   consume_previous,
	"ret":     ops_0,
	"scasb":   ops_0,
	"sub":     ops_2_1,
	"syscall": ops_0,
	"xadd":    ops_2, // TODO needs to push op1 back
	"xchg":    ops_2_x2,
}
