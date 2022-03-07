package main

import (
	"strconv"
)

type LowerContext struct {
	Inputs    []string
	Outputs   []string
	RefWords  []*RefWordInstr
	AsmInstrs []AsmInstr
}

func (c *LowerContext) AppendAsmInstr(i AsmInstr) {
	c.AsmInstrs = append(c.AsmInstrs, i)
}

func (c *LowerContext) AppendInput(i string) {
	c.Inputs = append(c.Inputs, i)
}

func (c *LowerContext) AppendRefWord(i *RefWordInstr) {
	c.RefWords = append(c.RefWords, i)
}

func (c *LowerContext) PopRefWord() *RefWordInstr {
	refWordsLen := len(c.RefWords)
	instr := c.RefWords[refWordsLen-1]

	c.RefWords = c.RefWords[:refWordsLen-1]

	return instr
}

func (c *LowerContext) Take2Inputs() (string, string) {
	inputsLen := len(c.Inputs)
	first := c.Inputs[inputsLen-2]
	second := c.Inputs[inputsLen-1]

	c.Inputs = c.Inputs[:inputsLen-2]

	return first, second
}

type Instr interface {
	Lower(*Environment, *LowerContext)
}

type GoCaller func(*Environment)

type CallGoInstr struct {
	F GoCaller
}

func (i *CallGoInstr) Lower(env *Environment, context *LowerContext) {
	i.F(env)
}

type x8664Lowerer = func(string, *LowerContext) AsmInstr

func ops_0(mnemonic string, context *LowerContext) AsmInstr {
	return &AsmNoOperandInstr{Mnemonic: mnemonic}
}

func ops_2(mnemonic string, context *LowerContext) AsmInstr {
	op1, op2 := context.Take2Inputs()

	return &AsmBinaryInstr{Mnemonic: mnemonic, Op1: op1, Op2: op2}
}

func op_label(mnemonic string, context *LowerContext) AsmInstr {
	op := context.PopRefWord().Word.AsmLabel()

	return &AsmUnaryInstr{Mnemonic: mnemonic, Op: op}
}

var x8664Mnemonics = map[string]x8664Lowerer{
	"loop":    op_label,
	"ret":     ops_0,
	"syscall": ops_0,
	"xadd":    ops_2,
}

type X8664Instr struct {
	Mnemonic string
}

func (i *X8664Instr) Lower(env *Environment, context *LowerContext) {
	lowerer := x8664Mnemonics[i.Mnemonic]
	asmInstr := lowerer(i.Mnemonic, context)
	context.AppendAsmInstr(asmInstr)
}

type LiteralIntInstr struct {
	I int
}

func (i *LiteralIntInstr) Lower(env *Environment, context *LowerContext) {
	// TODO this is a hack during prototyping
	context.AppendInput(strconv.Itoa(i.I))
}

type FlowWordInstr struct {
	Word *Word
}

func (i *FlowWordInstr) Lower(env *Environment, context *LowerContext) {
	flowWord(i.Word, context)
}

type CallWordInstr struct {
	Word *Word
}

func (i *CallWordInstr) Lower(env *Environment, context *LowerContext) {
	if env.Compiling {
		flowWord(i.Word, context)
		context.AppendAsmInstr(&AsmCallInstr{Label: i.Word.AsmLabel()})
		return
	}

	for _, instr := range i.Word.Code {
		instr.Lower(env, context)
	}
}

type RefWordInstr struct {
	Word *Word
}

func (i *RefWordInstr) Lower(env *Environment, context *LowerContext) {
	context.AppendRefWord(i)
}

type ExternWordInstr struct {
	Word *Word
}

func (i *ExternWordInstr) Lower(env *Environment, context *LowerContext) {
	context.AppendAsmInstr(&AsmExternInstr{Label: i.Word.AsmLabel()})
}

type GlobalWordInstr struct {
	Word *Word
}

func (i *GlobalWordInstr) Lower(env *Environment, context *LowerContext) {
	context.AppendAsmInstr(&AsmGlobalInstr{Label: i.Word.AsmLabel()})
}

type DeclWordInstr struct {
	Word *Word
}

func (i *DeclWordInstr) Lower(env *Environment, context *LowerContext) {
	context.AppendAsmInstr(&AsmLabelInstr{Name: i.Word.AsmLabel()})

	context.Inputs = i.Word.InputRegisters()
	context.Outputs = i.Word.OutputRegisters()
	env.Compiling = true

	for _, instr := range i.Word.Code {
		instr.Lower(env, context)
	}

	env.Compiling = false
}

type SectionInstr struct {
	Info string
}

func (i *SectionInstr) Lower(env *Environment, context *LowerContext) {
	context.AppendAsmInstr(&AsmSectionInstr{Info: i.Info})
}

func flowWord(word *Word, context *LowerContext) {
	expectedInputs := word.InputRegisters()

	need := len(expectedInputs)
	have := len(context.Inputs)
	neededInputs := context.Inputs[have-need:]
	context.Inputs = context.Inputs[:have-need]

	for i := need - 1; i >= 0; i-- {
		if expectedInputs[i] != neededInputs[i] {
			context.AppendAsmInstr(&AsmBinaryInstr{
				Mnemonic: "mov",
				Op1:      expectedInputs[i],
				Op2:      neededInputs[i],
			})
		}
	}

	wordOutputs := word.OutputRegisters()
	context.Inputs = append(context.Inputs, wordOutputs...)
}
