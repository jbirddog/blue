package main

import (
	"fmt"
	"strconv"
)

type Instr interface {
	Run(*Environment, *RunContext)
}

type GoCaller func(*Environment)

type CallGoInstr struct {
	F GoCaller
}

func (i *CallGoInstr) Run(env *Environment, context *RunContext) {
	i.F(env)
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

func op_label(mnemonic string, env *Environment, context *RunContext) AsmInstr {
	op := context.PopInput()

	return &AsmUnaryInstr{Mnemonic: mnemonic, Op: op}
}

func consume_previous(mnemonic string, env *Environment, context *RunContext) AsmInstr {
	previous := env.PopAsmInstr().(*AsmNoOperandInstr)

	return &AsmUnaryInstr{Mnemonic: mnemonic, Op: previous.Mnemonic}
}

var x8664Mnemonics = map[string]x8664Lowerer{
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
}

type X8664Instr struct {
	Mnemonic string
}

func (i *X8664Instr) Run(env *Environment, context *RunContext) {
	lowerer := x8664Mnemonics[i.Mnemonic]
	asmInstr := lowerer(i.Mnemonic, env, context)
	env.AppendAsmInstr(asmInstr)
}

type LiteralIntInstr struct {
	I int
}

func (i *LiteralIntInstr) Run(env *Environment, context *RunContext) {
	// TODO this is a hack during prototyping
	context.AppendInput(strconv.Itoa(i.I))
}

type FlowWordInstr struct {
	Word *Word
}

func (i *FlowWordInstr) Run(env *Environment, context *RunContext) {
	flowWord(i.Word, env, context)
}

type CallWordInstr struct {
	Word *Word
}

func (i *CallWordInstr) Run(env *Environment, context *RunContext) {
	if env.Compiling {
		flowWord(i.Word, env, context)
		env.AppendAsmInstr(&AsmCallInstr{Label: i.Word.AsmLabel})
		return
	}

	for _, instr := range i.Word.Code {
		instr.Run(env, context)
	}
}

type RefWordInstr struct {
	Word *Word
}

func (i *RefWordInstr) Run(env *Environment, context *RunContext) {
	context.AppendInput(i.Word.AsmLabel)
}

type ExternWordInstr struct {
	Word *Word
}

func (i *ExternWordInstr) Run(env *Environment, context *RunContext) {
	env.AppendAsmInstr(&AsmExternInstr{Label: i.Word.AsmLabel})
}

type GlobalWordInstr struct {
	Name string
}

func (i *GlobalWordInstr) Run(env *Environment, context *RunContext) {
	env.AppendAsmInstr(&AsmGlobalInstr{Label: i.Name})
}

type DeclWordInstr struct {
	Word *Word
}

func (i *DeclWordInstr) Run(env *Environment, context *RunContext) {
	env.AppendAsmInstr(&AsmLabelInstr{Name: i.Word.AsmLabel})

	context.Inputs = i.Word.InputRegisters()
	context.Outputs = i.Word.OutputRegisters()
	env.Compiling = true

	for _, instr := range i.Word.Code {
		instr.Run(env, context)
	}

	env.Compiling = false
}

type SectionInstr struct {
	Info string
}

func (i *SectionInstr) Run(env *Environment, context *RunContext) {
	env.AppendAsmInstr(&AsmSectionInstr{Info: i.Info})
}

type CommentInstr struct {
	Comment string
}

func (i *CommentInstr) Run(env *Environment, context *RunContext) {
	env.AppendAsmInstr(&AsmCommentInstr{Comment: i.Comment})
}

type ResbInstr struct {
	Name string
	Size uint
}

func (i *ResbInstr) Run(env *Environment, context *RunContext) {
	env.AppendAsmInstr(&AsmResbInstr{Name: i.Name, Size: i.Size})
}

type DecbInstr struct {
	Value int
}

func (i *DecbInstr) Run(env *Environment, context *RunContext) {
	env.AppendAsmInstr(&AsmDecbInstr{Value: i.Value})
}

type DropInstr struct{}

func (i *DropInstr) Run(env *Environment, context *RunContext) {
	context.PopInput()
}

type DupInstr struct{}

func (i *DupInstr) Run(env *Environment, context *RunContext) {
	context.AppendInput(context.Peek())
}

type SwapInstr struct{}

func (i *SwapInstr) Run(env *Environment, context *RunContext) {
	a := context.PopInput()
	b := context.PopInput()

	context.AppendInput(a)
	context.AppendInput(b)
}

type CondCallInstr struct {
	Jmp    string
	Target *RefWordInstr
}

func (i *CondCallInstr) Run(env *Environment, context *RunContext) {
	ccLabel := env.AsmLabelForName(".donecc")

	env.AppendAsmInstrs([]AsmInstr{
		&AsmUnaryInstr{Mnemonic: i.Jmp, Op: ccLabel},
		&AsmCallInstr{Label: i.Target.Word.AsmLabel},
		&AsmLabelInstr{Name: ccLabel},
	})
}

type CondLoopInstr struct {
	Jmp    string
	Target *RefWordInstr
}

func (i *CondLoopInstr) Run(env *Environment, context *RunContext) {
	clLabel := env.AsmLabelForName(".donecl")

	env.AppendAsmInstrs([]AsmInstr{
		&AsmUnaryInstr{Mnemonic: i.Jmp, Op: clLabel},
		&AsmUnaryInstr{Mnemonic: "loop", Op: i.Target.Word.AsmLabel},
		&AsmLabelInstr{Name: clLabel},
	})
}

type BracketInstr struct {
	Value        string
	Replacements int
}

func (i *BracketInstr) Run(env *Environment, context *RunContext) {
	newInput := i.Value

	if i.Replacements > 0 {
		divide := len(context.Inputs) - i.Replacements
		replacements := context.Inputs[divide:]
		context.Inputs = context.Inputs[:divide]

		// TODO believe this won't work with multiple replacements
		newInput = fmt.Sprintf(newInput, replacements)
	}

	context.AppendInput(newInput)
}

func flowWord(word *Word, env *Environment, context *RunContext) {
	expectedInputs := word.InputRegisters()

	need := len(expectedInputs)
	have := len(context.Inputs)
	neededInputs := context.Inputs[have-need:]
	context.Inputs = context.Inputs[:have-need]

	for i := need - 1; i >= 0; i-- {
		if expectedInputs[i] != neededInputs[i] {
			env.AppendAsmInstr(&AsmBinaryInstr{
				Mnemonic: "mov",
				Op1:      expectedInputs[i],
				Op2:      neededInputs[i],
			})
		}
	}

	wordOutputs := word.OutputRegisters()
	context.Inputs = append(context.Inputs, wordOutputs...)
}
