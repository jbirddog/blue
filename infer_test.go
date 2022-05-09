package main

import (
	"testing"
)

func TestDoesNothingIfRefsAreComplete(t *testing.T) {
	w := parseForLatest(": bob ( eax -- edi ) ;")

	InferStackRefs(w)

	if w.Inputs[0].Ref != "eax" {
		t.Fatalf("Unexpected inputs reg")
	}

	if w.Outputs[0].Ref != "edi" {
		t.Fatalf("Unexpected output reg")
	}
}

func TestInfersBasicInputRefs(t *testing.T) {
	w := parseForLatest(`
		: bob ( eax -- ) ;
		: sue ( joe -- ) bob ;
	`)

	InferStackRefs(w)

	if w.Inputs[0].Ref != "eax" {
		t.Fatalf("Failed to infer eax")
	}
}

func TestEchoReadExample(t *testing.T) {
	w := parseForLatest(`
		: syscall3 ( edi edx esi num:eax -- result:eax ) syscall ;
		: read ( fd len buf -- result ) 0 syscall3 ;
	`)

	InferStackRefs(w)

	if len(w.Inputs) != 3 {
		t.Fatalf("Expected 3 inputs got %d", len(w.Inputs))
	}
	if w.Inputs[0].Ref != "edi" {
		t.Fatalf("Expected edi got '%s'", w.Inputs[0].Ref)
	}
	if w.Inputs[1].Ref != "edx" {
		t.Fatalf("Expected edx got '%s'", w.Inputs[1].Ref)
	}
	if w.Inputs[2].Ref != "esi" {
		t.Fatalf("Expected esi got '%s'", w.Inputs[2].Ref)
	}

	if len(w.Outputs) != 1 {
		t.Fatalf("Expected 1 outputs got %d", len(w.Outputs))
	}
	if w.Outputs[0].Ref != "eax" {
		t.Fatalf("Expected eax got '%s'", w.Outputs[0].Ref)
	}
}

func TestEchoSecondWriteExample(t *testing.T) {
	// : syscall3 ( edi edx esi num:eax -- result:eax ) syscall ;
	w1 := &Word{
		Name: "syscall3",
		Inputs: []*StackRef{
			&StackRef{Name: "edi", Ref: "edi"},
			&StackRef{Name: "edx", Ref: "edx"},
			&StackRef{Name: "esi", Ref: "esi"},
			&StackRef{Name: "num", Ref: "eax"},
		},
		Outputs: []*StackRef{&StackRef{Name: "result", Ref: "eax"}},
	}

	// : write ( len fd -- result ) swap buf 0 syscall3 ;
	w2 := &Word{
		Name: "write",
		Inputs: []*StackRef{
			&StackRef{Name: "len", Ref: ""},
			&StackRef{Name: "fd", Ref: ""},
		},
		Outputs: []*StackRef{&StackRef{Name: "wrote", Ref: ""}},
		Code: []Instr{
			&SwapInstr{},
			&LiteralIntInstr{I: 33}, // Dummy value - test is swap
			&LiteralIntInstr{I: 0},
			&CallWordInstr{Word: w1},
		},
	}

	InferStackRefs(w2)

	if len(w2.Inputs) != 2 {
		t.Fatal("Unexpected input len")
	}

	if w2.Inputs[0].Ref != "edx" {
		t.Fatalf("Expected edx, got '%s'", w2.Inputs[0].Ref)
	}

	if w2.Inputs[1].Ref != "edi" {
		t.Fatalf("Expected edi, got '%s'", w2.Inputs[1].Ref)
	}

	if len(w2.Outputs) != 1 {
		t.Fatal("Unexpected output len")
	}

	if w2.Outputs[0].Ref != "eax" {
		t.Fatalf("Expected eax, got '%s'", w2.Outputs[0].Ref)
	}
}

func TestWriteDropsResult(t *testing.T) {
	// : syscall3 ( edi edx esi num:eax -- result:eax ) syscall ;
	w1 := &Word{
		Name: "syscall3",
		Inputs: []*StackRef{
			&StackRef{Name: "edi", Ref: "edi"},
			&StackRef{Name: "edx", Ref: "edx"},
			&StackRef{Name: "esi", Ref: "esi"},
			&StackRef{Name: "num", Ref: "eax"},
		},
		Outputs: []*StackRef{&StackRef{Name: "result", Ref: "eax"}},
	}

	// : write ( fd len -- ) swap buf 0 syscall3 drop ;
	w2 := &Word{
		Name: "write",
		Inputs: []*StackRef{
			&StackRef{Name: "fd", Ref: ""},
			&StackRef{Name: "len", Ref: ""},
		},
		Code: []Instr{
			&LiteralIntInstr{I: 33}, // Dummy value - test is drop
			&LiteralIntInstr{I: 0},
			&CallWordInstr{Word: w1},
			&DropInstr{},
		},
	}

	InferStackRefs(w2)

	if len(w2.Inputs) != 2 {
		t.Fatal("Unexpected input len")
	}

	if w2.Inputs[0].Ref != "edi" {
		t.Fatalf("Expected edi, got '%s'", w2.Inputs[0].Ref)
	}

	if w2.Inputs[1].Ref != "edx" {
		t.Fatalf("Expected edx, got '%s'", w2.Inputs[1].Ref)
	}

	if len(w2.Outputs) != 0 {
		t.Fatal("Unexpected output len")
	}
}

// TODO move these test helpers somewhere
func parseForLatest(buf string) *Word {
	e := env(buf)
	for e.ParseNextWord() {
	}

	return e.Dictionary.Latest
}
