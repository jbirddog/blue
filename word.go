package main

import (
	"log"
)

const (
	WordFlag_Immediate = 1 << iota
	WordFlag_HiddenFromAsm
	WordFlag_NoReturn
)

type Word struct {
	Name    string
	Flags   uint
	Inputs  []*RegisterRef
	Outputs []*RegisterRef
	Code    []Instr
}

func (w *Word) PushInstr(instr Instr) {
	w.Code = append(w.Code, instr)
}

func (w *Word) PushRegisterRef(name, reg string, target int) {
	if _, found := registers[reg]; !found {
		log.Fatal("Unknown register", reg)
	}

	ref := &RegisterRef{Name: name, Reg: reg}

	if target == RegisterRefTarget_Input {
		w.Inputs = append(w.Inputs, ref)
	} else if target == RegisterRefTarget_Output {
		w.Outputs = append(w.Outputs, ref)
	} else {
		log.Fatal("Invalid register ref target")
	}
}

func (w *Word) Immediate() *Word {
	w.Flags |= WordFlag_Immediate
	return w
}

func (w *Word) NoReturn() *Word {
	w.Flags |= WordFlag_NoReturn
	return w
}

func (w *Word) IsImmediate() bool {
	return w.Flags&WordFlag_Immediate == WordFlag_Immediate
}

func (w *Word) IsHiddenFromAsm() bool {
	return w.Flags&WordFlag_HiddenFromAsm == WordFlag_HiddenFromAsm
}

func (w *Word) IsNoReturn() bool {
	return w.Flags&WordFlag_NoReturn == WordFlag_NoReturn
}

func (w *Word) InputRegisters() []string {
	var registers []string

	for _, i := range w.Inputs {
		registers = append(registers, i.Reg)
	}

	return registers
}

func (w *Word) OutputRegisters() []string {
	var registers []string

	for _, o := range w.Outputs {
		registers = append(registers, o.Reg)
	}

	return registers
}

func (w *Word) AppendCode(asmInstrs []AsmInstr) []AsmInstr {
	context := &LowerContext{
		AsmInstrs: asmInstrs,
		Inputs:    w.InputRegisters(),
		Outputs:   w.OutputRegisters(),
	}

	for _, instr := range w.Code {
		instr.Lower(context)
	}

	return context.AsmInstrs
}

func NewCallGoWord(name string, f GoCaller) *Word {
	return &Word{
		Name:  name,
		Flags: WordFlag_HiddenFromAsm,
		Code:  []Instr{&CallGoInstr{F: f}},
	}
}

func NewWord(name string) *Word {
	return &Word{Name: name}
}

