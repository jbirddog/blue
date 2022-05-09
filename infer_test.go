package main

import (
	"testing"
)

func TestInference(t *testing.T) {
	cases := []struct {
		codeUnderTest   string
		expectedInputs  []string
		expectedOutputs []string
	}{
		{": bob ( eax -- edi ) ;", []string{"eax"}, []string{"edi"}},
		{`
		: bob ( eax -- ) ;
		: sue ( joe -- ) bob ;
	`, []string{"eax"}, nil},
		{`
		: syscall3 ( edi edx esi num:eax -- result:eax ) syscall ;
		: read ( fd len buf -- result ) 0 syscall3 ;
	`, []string{"edi", "edx", "esi"}, []string{"eax"}},
	}

	for _, c := range cases {
		w := parseForLatest(c.codeUnderTest)

		InferStackRefs(w)

		if len(w.Inputs) != len(c.expectedInputs) {
			t.Fatalf("Expected %d inputs got %d", len(w.Inputs), len(c.expectedInputs))
		}

		for i, input := range w.Inputs {
			if input.Ref != c.expectedInputs[i] {
				t.Fatalf("Expected '%s' got '%s'", c.expectedInputs[i], input.Ref)
			}
		}

		if len(w.Outputs) != len(c.expectedOutputs) {
			t.Fatalf("Expected %d outputs got %d", len(w.Outputs), len(c.expectedOutputs))
		}

		for i, output := range w.Outputs {
			if output.Ref != c.expectedOutputs[i] {
				t.Fatalf("Expected '%s' got '%s'", c.expectedOutputs[i], output.Ref)
			}
		}
	}
}

func TestEchoSecondWriteExample(t *testing.T) {
	w := parseForLatest(`
		1 resb buf
		: syscall3 ( edi edx esi num:eax -- result:eax ) syscall ;
		: write ( len fd -- result ) swap buf 0 syscall3 ;
	`)

	InferStackRefs(w)

	if len(w.Inputs) != 2 {
		t.Fatal("Unexpected input len")
	}
	if w.Inputs[0].Ref != "edx" {
		t.Fatalf("Expected edx, got '%s'", w.Inputs[0].Ref)
	}
	if w.Inputs[1].Ref != "edi" {
		t.Fatalf("Expected edi, got '%s'", w.Inputs[1].Ref)
	}

	if len(w.Outputs) != 1 {
		t.Fatal("Unexpected output len")
	}
	if w.Outputs[0].Ref != "eax" {
		t.Fatalf("Expected eax, got '%s'", w.Outputs[0].Ref)
	}
}

func TestWriteDropsResult(t *testing.T) {
	w := parseForLatest(`
		1 resb buf
		: syscall3 ( edi edx esi num:eax -- result:eax ) syscall ;
		: write ( fd len -- ) swap buf 0 syscall3 drop ;
	`)

	InferStackRefs(w)

	if len(w.Inputs) != 2 {
		t.Fatal("Unexpected input len")
	}
	if w.Inputs[0].Ref != "edx" {
		t.Fatalf("Expected edx, got '%s'", w.Inputs[0].Ref)
	}
	if w.Inputs[1].Ref != "edi" {
		t.Fatalf("Expected edi, got '%s'", w.Inputs[1].Ref)
	}

	if len(w.Outputs) != 0 {
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
