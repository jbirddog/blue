package main

import (
	"log"
)

const (
	WordFlag_Immediate = 1 << iota
	WordFlag_HiddenFromAsm
	WordFlag_NoReturn
	WordFlag_Local
	WordFlag_Hidden
)

type Word struct {
	Name    string
	Flags   uint
	Inputs  []*RegisterRef
	Outputs []*RegisterRef
	Code    []Instr
}

func (w *Word) AppendInstr(instr Instr) {
	w.Code = append(w.Code, instr)
}

func (w *Word) AppendInput(r *RegisterRef) {
	if _, found := registers[r.Reg]; !found {
		log.Fatal("Unknown input register: ", r.Reg)
	}

	w.Inputs = append(w.Inputs, r)
}

func (w *Word) AppendOutput(r *RegisterRef) {
	if _, found := registers[r.Reg]; !found {
		log.Fatal("Unknown ouput register: ", r.Reg)
	}

	w.Outputs = append(w.Outputs, r)
}

func (w *Word) Immediate() *Word {
	w.Flags |= WordFlag_Immediate
	return w
}

func (w *Word) NoReturn() *Word {
	w.Flags |= WordFlag_NoReturn
	return w
}

func (w *Word) Local() *Word {
	w.Flags |= WordFlag_Local
	return w
}

func (w *Word) Hidden() *Word {
	w.Flags |= WordFlag_Hidden
	return w
}

func (w *Word) hasFlag(flag uint) bool {
	return w.Flags&flag == flag
}

func (w *Word) IsImmediate() bool {
	return w.hasFlag(WordFlag_Immediate)
}

func (w *Word) IsHiddenFromAsm() bool {
	return w.hasFlag(WordFlag_HiddenFromAsm)
}

func (w *Word) IsNoReturn() bool {
	return w.hasFlag(WordFlag_NoReturn)
}

func (w *Word) IsLocal() bool {
	return w.hasFlag(WordFlag_Local)
}

func (w *Word) IsHidden() bool {
	return w.hasFlag(WordFlag_Hidden)
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
