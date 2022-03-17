package main

import (
	"testing"
)

func TestDoesNothingIfRefsAreComplete(t *testing.T) {
	w := &Word{
		Name:    "bob",
		Inputs:  []*RegisterRef{&RegisterRef{Name: "eax", Reg: "eax"}},
		Outputs: []*RegisterRef{&RegisterRef{Name: "edi", Reg: "edi"}},
	}

	InferRegisterRefs(w)

	if w.Inputs[0].Reg != "eax" {
		t.Fatalf("Unexpected inputs reg")
	}

	if w.Outputs[0].Reg != "edi" {
		t.Fatalf("Unexpected output reg")
	}
}

func TestInfersBasicInputRegs(t *testing.T) {
	// : bob ( eax -- ) ;
	w1 := &Word{
		Name:   "bob",
		Inputs: []*RegisterRef{&RegisterRef{Name: "eax", Reg: "eax"}},
	}

	// : sue ( joe -- ) bob ;
	w2 := &Word{
		Name:   "sue",
		Inputs: []*RegisterRef{&RegisterRef{Name: "joe", Reg: ""}},
		Code:   []Instr{&CallWordInstr{Word: w1}},
	}

	InferRegisterRefs(w2)

	if w2.Inputs[0].Reg != "eax" {
		t.Fatalf("Failed to infer eax")
	}
}

func TestEchoReadExample(t *testing.T) {
	// : syscall3 ( edi edx esi num:eax -- result:eax ) syscall ;
	w1 := &Word{
		Name: "syscall3",
		Inputs: []*RegisterRef{
			&RegisterRef{Name: "edi", Reg: "edi"},
			&RegisterRef{Name: "edx", Reg: "edx"},
			&RegisterRef{Name: "esi", Reg: "esi"},
			&RegisterRef{Name: "num", Reg: "eax"},
		},
		Outputs: []*RegisterRef{&RegisterRef{Name: "result", Reg: "eax"}},
	}

	// : read ( fd len buf -- result ) 0 syscall3 ;
	w2 := &Word{
		Name: "read",
		Inputs: []*RegisterRef{
			&RegisterRef{Name: "fd", Reg: ""},
			&RegisterRef{Name: "len", Reg: ""},
			&RegisterRef{Name: "buf", Reg: ""},
		},
		Outputs: []*RegisterRef{&RegisterRef{Name: "result", Reg: ""}},
		Code: []Instr{
			&LiteralIntInstr{I: 0},
			&CallWordInstr{Word: w1},
		},
	}

	InferRegisterRefs(w2)

	for i, r := range w2.Inputs {
		if r.Reg != w1.Inputs[i].Reg {
			t.Fatalf("Expected '%s', got '%s'", w1.Inputs[i].Reg, r.Reg)
		}
	}

	for i, r := range w2.Outputs {
		if r.Reg != w1.Outputs[i].Reg {
			t.Fatalf("Expected '%s', got '%s'", w1.Outputs[i].Reg, r.Reg)
		}
	}
}

func TestEchoSecondWriteExample(t *testing.T) {
	// : syscall3 ( edi edx esi num:eax -- result:eax ) syscall ;
	w1 := &Word{
		Name: "syscall3",
		Inputs: []*RegisterRef{
			&RegisterRef{Name: "edi", Reg: "edi"},
			&RegisterRef{Name: "edx", Reg: "edx"},
			&RegisterRef{Name: "esi", Reg: "esi"},
			&RegisterRef{Name: "num", Reg: "eax"},
		},
		Outputs: []*RegisterRef{&RegisterRef{Name: "result", Reg: "eax"}},
	}

	// : write ( len fd -- result ) swap buf 0 syscall3 ;
	w2 := &Word{
		Name: "write",
		Inputs: []*RegisterRef{
			&RegisterRef{Name: "len", Reg: ""},
			&RegisterRef{Name: "fd", Reg: ""},
		},
		Outputs: []*RegisterRef{&RegisterRef{Name: "wrote", Reg: ""}},
		Code: []Instr{
			&SwapInstr{},
			&LiteralIntInstr{I: 33}, // Dummy value - test is swap
			&LiteralIntInstr{I: 0},
			&CallWordInstr{Word: w1},
		},
	}

	InferRegisterRefs(w2)

	if len(w2.Inputs) != 2 {
		t.Fatal("Unexpected input len")
	}

	if w2.Inputs[0].Reg != "edx" {
		t.Fatalf("Expected edx, got '%s'", w2.Inputs[0].Reg)
	}

	if w2.Inputs[1].Reg != "edi" {
		t.Fatalf("Expected edi, got '%s'", w2.Inputs[1].Reg)
	}

	if len(w2.Outputs) != 1 {
		t.Fatal("Unexpected output len")
	}

	if w2.Outputs[0].Reg != "eax" {
		t.Fatalf("Expected eax, got '%s'", w2.Outputs[0].Reg)
	}
}
