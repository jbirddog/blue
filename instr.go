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

type JmpWordInstr struct {
	Word *Word
}

func (i *JmpWordInstr) Run(env *Environment, context *RunContext) {
	env.AppendAsmInstr(&AsmUnaryInstr{Mnemonic: "jmp", Op: i.Word.AsmLabel})
}

type CallInstr struct{}

func (i *CallInstr) Run(env *Environment, context *RunContext) {
	target := context.PopInput()

	// TODO AsmCallInstr -> AsmUnaryInstr
	env.AppendAsmInstr(&AsmCallInstr{Label: target})
}

type CallWordInstr struct {
	Word *Word
}

func (i *CallWordInstr) Run(env *Environment, context *RunContext) {
	if env.Compiling {
		if i.Word.IsNoReturn() {
			env.AppendAsmInstr(&AsmUnaryInstr{
				Mnemonic: "jmp",
				Op:       i.Word.AsmLabel,
			})

			return
		}

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

type DecInstr struct {
	Size  string
	Value string
}

func (i *DecInstr) Run(env *Environment, context *RunContext) {
	env.AppendAsmInstr(&AsmDecInstr{Size: i.Size, Value: i.Value})
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

	if size, found := env.RefSizes[op1]; found {
		op1 = fmt.Sprintf("%s [%s]", size, op1)
	} else {
		op1 = fmt.Sprintf("[%s]", op1)
	}

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

type BracketInstr struct{}

func (i *BracketInstr) Run(env *Environment, context *RunContext) {
	ident := context.PopInput()

	if size, found := registerSize[ident]; found {
		context.AppendInput(fmt.Sprintf("%s [%s]", size, ident))
	} else {
		context.AppendInput(fmt.Sprintf("[%s]", ident))
	}
}

type RotInstr struct{}

func (i *RotInstr) Run(env *Environment, context *RunContext) {
	input3 := context.PopInput()
	input2 := context.PopInput()
	input1 := context.PopInput()

	context.AppendInput(input2)
	context.AppendInput(input3)
	context.AppendInput(input1)
}

type AsciiStrInstr struct {
	Str     string
	PushLen bool
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
		asmInstrs = append(asmInstrs, &AsmDecInstr{
			Size:  "b",
			Value: fmt.Sprintf("%d", b),
		})
	}

	asmInstrs = append(asmInstrs, &AsmDecInstr{Size: "b", Value: "0"})
	asmInstrs = append(asmInstrs, &AsmLabelInstr{Name: jmpLabel})

	env.AppendAsmInstrs(asmInstrs)
	context.AppendInput(refLabel)

	if i.PushLen {
		context.AppendInput(fmt.Sprint(len(bytes)))
	}
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
				op1RegSize := registerSize[op1]
				op2RegSize := registerSize[op2]

				// TODO will need some more work to support all  all combos
				if op1RegSize == "dword" && op2RegSize == "qword" {
					op2 = reg32Names[op2RegIndex]
				} else if op1RegSize == "qword" && op2RegSize == "dword" {
					op1 = reg32Names[op1RegIndex]
				}
			}
		}

		flowInstrs := PeepholeAsmBinaryInstr(&AsmBinaryInstr{
			Mnemonic: "mov",
			Op1:      op1,
			Op2:      op2,
		})

		env.AppendAsmInstrs(flowInstrs)
	}

	buildClobberGuards(word, context)

	wordOutputs := word.OutputRegisters()
	context.Inputs = append(context.Inputs, wordOutputs...)
}
