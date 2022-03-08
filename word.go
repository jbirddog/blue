package main

import (
	"log"
)

const (
	wordFlag_Immediate = 1 << iota
	wordFlag_NoReturn
	wordFlag_Local
	wordFlag_Hidden
	wordFlag_Global
	wordFlag_Extern
)

type Word struct {
	Name    string
	Flags   uint
	Inputs  []*RegisterRef
	Outputs []*RegisterRef
	Code    []Instr
}

func ExternWord(name string) *Word {
	w := &Word{Name: name}
	return w.Extern()
}

func LocalWord(name string) *Word {
	w := &Word{Name: name}
	return w.Local()
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

func (w *Word) setFlag(flag uint) *Word {
	w.Flags |= flag
	return w
}

func (w *Word) Immediate() *Word {
	return w.setFlag(wordFlag_Immediate)
}

func (w *Word) NoReturn() *Word {
	return w.setFlag(wordFlag_NoReturn)
}

func (w *Word) Local() *Word {
	return w.setFlag(wordFlag_Local)
}

func (w *Word) Hidden() *Word {
	return w.setFlag(wordFlag_Hidden)
}

func (w *Word) Global() *Word {
	return w.setFlag(wordFlag_Global)
}

func (w *Word) Extern() *Word {
	return w.setFlag(wordFlag_Extern)
}

func (w *Word) hasFlag(flag uint) bool {
	return w.Flags&flag == flag
}

func (w *Word) IsImmediate() bool {
	return w.hasFlag(wordFlag_Immediate)
}

func (w *Word) IsNoReturn() bool {
	return w.hasFlag(wordFlag_NoReturn)
}

func (w *Word) IsLocal() bool {
	return w.hasFlag(wordFlag_Local)
}

func (w *Word) IsHidden() bool {
	return w.hasFlag(wordFlag_Hidden)
}

func (w *Word) IsGlobal() bool {
	return w.hasFlag(wordFlag_Global)
}

func (w *Word) IsExtern() bool {
	return w.hasFlag(wordFlag_Extern)
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

func (w *Word) AsmLabel() string {
	if w.IsLocal() {
		return "." + w.Name
	}

	return w.Name
}

func NewCallGoWord(name string, f GoCaller) *Word {
	return &Word{
		Name: name,
		Code: []Instr{&CallGoInstr{F: f}},
	}
}
