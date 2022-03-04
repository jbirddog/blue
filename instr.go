package main

import (
	"log"
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
	Lower(*LowerContext)
	Run(*Environment)
}

type GoCaller func(*Environment)

type CallGoInstr struct {
	F GoCaller
}

func (i *CallGoInstr) Lower(context *LowerContext) {
}

func (i *CallGoInstr) Run(env *Environment) {
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

var x8664Mnemonics = map[string]x8664Lowerer{
	"ret":     ops_0,
	"syscall": ops_0,
	"xadd":    ops_2,
}

type X8664Instr struct {
	Mnemonic string
}

func (i *X8664Instr) Lower(context *LowerContext) {
	lowerer := x8664Mnemonics[i.Mnemonic]
	asmInstr := lowerer(i.Mnemonic, context)
	context.AppendAsmInstr(asmInstr)
}

func (i *X8664Instr) Run(env *Environment) {
	log.Fatal("Cannot run x8664 instructions")
}

type LiteralIntInstr struct {
	I int
}

func (i *LiteralIntInstr) Lower(context *LowerContext) {
	// TODO this is a hack during prototyping
	context.AppendInput(strconv.Itoa(i.I))
}

func (i *LiteralIntInstr) Run(env *Environment) {
	log.Fatal("Cannot run literal int instructions")
}

type FlowWordInstr struct {
	Word *Word
}

func (i *FlowWordInstr) Lower(context *LowerContext) {
	flowWord(i.Word, context)
}

func (i *FlowWordInstr) Run(env *Environment) {
	log.Fatal("Cannot run flow word instructions")
}

type CallWordInstr struct {
	Word *Word
}

func (i *CallWordInstr) Lower(context *LowerContext) {
	flowWord(i.Word, context)
	context.AppendAsmInstr(&AsmCallInstr{Label: i.Word.AsmLabel()})
}

func (i *CallWordInstr) Run(env *Environment) {
	log.Fatal("Cannot run call word instructions")
}

type RefWordInstr struct {
	Word *Word
}

func (i *RefWordInstr) Lower(context *LowerContext) {
	context.AppendRefWord(i)
}

func (i *RefWordInstr) Run(env *Environment) {
	log.Fatal("Cannot run reference word instructions")
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
