package main

import (
	"fmt"
	"log"
	"strconv"
	"strings"
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

type LowerContext struct {
	Inputs    []string
	Outputs   []string
	AsmInstrs []AsmInstr
}

func (c *LowerContext) AppendAsmInstr(i AsmInstr) {
	c.AsmInstrs = append(c.AsmInstrs, i)
}

func (c *LowerContext) AppendInput(i string) {
	c.Inputs = append(c.Inputs, i)
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

var x8664Mnemonics = map[string]bool{
	"ret":     true,
	"syscall": true,
}

type X8664Instr struct {
	Mnemonic string
}

func (i *X8664Instr) Lower(context *LowerContext) {
	context.AppendAsmInstr(&AsmNoOperandInstr{Mnemonic: i.Mnemonic})
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

type CallWordInstr struct {
	Word *Word
}

func (i *CallWordInstr) Lower(context *LowerContext) {
	expectedInputs := i.Word.InputRegisters()

	need := len(expectedInputs)
	have := len(context.Inputs)
	neededInputs := context.Inputs[have-need:]
	context.Inputs = context.Inputs[:have-need]

	// TODO probably doesn't need to be backwards
	for i := need - 1; i >= 0; i-- {
		if expectedInputs[i] != neededInputs[i] {
			context.AppendAsmInstr(&AsmBinaryInstr{
				Mnemonic: "mov",
				Op1:      expectedInputs[i],
				Op2:      neededInputs[i],
			})
		}
	}

	calledWordOutputs := i.Word.OutputRegisters()
	context.Inputs = append(context.Inputs, calledWordOutputs...)

	context.AppendAsmInstr(&AsmCallInstr{Label: i.Word.Name})
}

func (i *CallWordInstr) Run(env *Environment) {
	log.Fatal("Cannot run call word instructions")
}

const (
	RegisterRefTarget_Input = iota
	RegisterRefTarget_Output
)

func main() {
	env := NewEnvironmentForFile("blue/examples/exit33.blue")

	for env.ParseNextWord() {
	}

	env.Validate()
	env.WriteAsm("blue/examples/exit33.asm")

	fmt.Println("ok")
}

func kernel_colon(env *Environment) {
	env.Compiling = true

	name := env.ReadNextWord()
	if len(name) == 0 {
		log.Fatal(": expects a name")
	}

	word := NewWord(name)
	env.Dictionary.Append(word)
}

func kernel_lparen(env *Environment) {
	target := RegisterRefTarget_Input
	latest := env.Dictionary.Latest()

	for {
		nextWord := env.ReadNextWord()
		if len(nextWord) == 0 {
			log.Fatal("( unexpected eof")
		}

		if nextWord == "--" {
			target = RegisterRefTarget_Output
			continue
		}

		if nextWord == "noret" {
			latest.NoReturn()
			continue
		}

		if nextWord == ")" {
			break
		}

		parts := strings.SplitN(nextWord, ":", 2)
		latest.PushRegisterRef(parts[0], parts[len(parts)-1], target)
	}
}

func kernel_semi(env *Environment) {
	env.Compiling = false
	latest := env.Dictionary.Latest()

	if !latest.IsNoReturn() {
		latest.PushInstr(&X8664Instr{Mnemonic: "ret"})
	}
}
