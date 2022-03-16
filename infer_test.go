package main

import (
	"testing"
)

func TestDoesNothingIfRefsAreComplete(t *testing.T) {
	w := &Word{
		Name: "bob",
		Inputs: []*RegisterRef{&RegisterRef{Name: "eax", Reg: "eax"}},
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
		Name: "bob",
		Inputs: []*RegisterRef{&RegisterRef{Name: "eax", Reg: "eax"}},
	}

	// : sue ( joe -- ) bob ;
	w2 := &Word{
		Name: "sue",
		Inputs: []*RegisterRef{&RegisterRef{Name: "joe", Reg: ""}},
		Code: []Instr{&CallWordInstr{Word: w1}},
	}

	InferRegisterRefs(w2)

	if w2.Inputs[0].Reg != "eax" {
		t.Fatalf("Failed to infer eax")
	}
}

