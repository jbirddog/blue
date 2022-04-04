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

type X8664Instr struct {
	Mnemonic string
}

func (i *X8664Instr) Run(env *Environment, context *RunContext) {
	lowerer := x8664Lowerers[i.Mnemonic]
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
		pushes, pops := clobberGuardInstrs(context)
		env.AppendAsmInstrs(pushes)
		env.AppendAsmInstr(&AsmCallInstr{Label: i.Word.AsmLabel})
		env.AppendAsmInstrs(pops)
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

type ResInstr struct {
	Name  string
	Size  string
	Count uint
}

func (i *ResInstr) Run(env *Environment, context *RunContext) {
	env.AppendAsmInstr(&AsmResInstr{Name: i.Name, Size: i.Size, Count: i.Count})
}

type DecbInstr struct {
	Value int // TODO why isn't this a byte?
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

type SetInstr struct{}

func (i *SetInstr) Run(env *Environment, context *RunContext) {
	op2, op1 := context.Pop2Inputs()
	op1 = fmt.Sprintf("[%s]", op1)

	env.AppendAsmInstr(&AsmBinaryInstr{Mnemonic: "mov", Op1: op1, Op2: op2})
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

type AsciiStrInstr struct {
	Str string
}

func (i *AsciiStrInstr) Run(env *Environment, context *RunContext) {
	bytes := []byte(i.Str)
	bytes = unescape(bytes)
	refLabel := env.AsmLabelForName("<str>")
	jmpLabel := env.AsmLabelForName("</str>")

	asmInstrs := []AsmInstr{
		&AsmUnaryInstr{Mnemonic: "jmp", Op: jmpLabel},
		&AsmLabelInstr{Name: refLabel},
	}

	for _, b := range bytes {
		asmInstrs = append(asmInstrs, &AsmDecbInstr{Value: int(b)})
	}

	asmInstrs = append(asmInstrs, &AsmLabelInstr{Name: jmpLabel})

	env.AppendAsmInstrs(asmInstrs)
	context.AppendInput(refLabel)
	context.AppendInput(fmt.Sprint(len(bytes)))
}

func unescape(bytes []byte) []byte {
	bytesLen := len(bytes)
	unescaped := make([]byte, 0, bytesLen)

	for i := 0; i < bytesLen; i++ {
		b := bytes[i]

		if b == '\\' {
			switch bytes[i+1] {
			case 'n':
				b = 10
			case '0':
				b = (bytes[i+2] - 48) * 8
				b += bytes[i+3] - 48
				i += 2
			}

			i += 1
		}

		unescaped = append(unescaped, b)
	}

	return unescaped
}

func buildClobberGuards(word *Word, context *RunContext) {
	context.ClearClobberGuards()

	for _, input := range context.Inputs {
		if regIdx, found := registers[input]; found {
			if word.Clobbers&(1<<regIdx) == 0 {
				continue
			}

			context.AppendClobberGuard(regIdx)
		}
	}
}

func clobberGuardInstrs(context *RunContext) ([]AsmInstr, []AsmInstr) {
	var pushes []AsmInstr
	var pops []AsmInstr

	for _, guard := range context.ClobberGuards {
		pushes = append(pushes, &AsmUnaryInstr{Mnemonic: "push", Op: guard})
	}

	guardsLen := len(context.ClobberGuards)

	for i := guardsLen - 1; i >= 0; i -= 1 {
		guard := context.ClobberGuards[i]
		pops = append(pops, &AsmUnaryInstr{Mnemonic: "pop", Op: guard})
	}

	return pushes, pops
}

func flowWord(word *Word, env *Environment, context *RunContext) {
	expectedInputs := word.InputRegisters()

	need := len(expectedInputs)
	have := len(context.Inputs)
	neededInputs := context.Inputs[have-need:]
	context.Inputs = context.Inputs[:have-need]

	for i := need - 1; i >= 0; i-- {
		op1 := expectedInputs[i]
		op2 := neededInputs[i]

		if op1 == op2 {
			continue
		}

		if op2RegIndex, found := registers[op2]; found {
			if op1RegIndex, found := registers[op1]; found {
				if op1RegIndex == op2RegIndex {
					continue
				}
			}
		}

		env.AppendAsmInstr(&AsmBinaryInstr{
			Mnemonic: "mov",
			Op1:      op1,
			Op2:      op2,
		})
	}

	buildClobberGuards(word, context)

	wordOutputs := word.OutputRegisters()
	context.Inputs = append(context.Inputs, wordOutputs...)
}
