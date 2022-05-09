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
		{`
		1 resb buf
		: syscall3 ( edi edx esi num:eax -- result:eax ) syscall ;
		: write ( len fd -- result ) swap buf 0 syscall3 ;
		`, []string{"edx", "edi"}, []string{"eax"}},
		{`
		1 resb buf
		: syscall3 ( edi edx esi num:eax -- result:eax ) syscall ;
		: write ( fd len -- ) swap buf 0 syscall3 drop ;
		`, []string{"edx", "edi"}, []string{}},
	}

	for _, c := range cases {
		e := env(c.codeUnderTest)
		for e.ParseNextWord() {
		}

		w := e.Dictionary.Latest

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

func TestInference2(t *testing.T) {
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
		/*
			{`
			: syscall3 ( edi edx esi num:eax -- result:eax ) syscall ;
			: read ( fd len buf -- result ) 0 syscall3 ;
			`, []string{"edi", "edx", "esi"}, []string{"eax"}},
			{`
			1 resb buf
			: syscall3 ( edi edx esi num:eax -- result:eax ) syscall ;
			: write ( len fd -- result ) swap buf 0 syscall3 ;
			`, []string{"edx", "edi"}, []string{"eax"}},
			{`
			1 resb buf
			: syscall3 ( edi edx esi num:eax -- result:eax ) syscall ;
			: write ( fd len -- ) swap buf 0 syscall3 drop ;
			`, []string{"edx", "edi"}, []string{}},
		*/
	}

	for _, c := range cases {
		e := env(c.codeUnderTest)
		e.InferV2 = true
		for e.ParseNextWord() {
		}

		w := e.Dictionary.Latest

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
