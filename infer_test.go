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
		{`
		: bob ( eax -- edi ) ;
		: sue ( joe -- sam ) bob ;
		`, []string{"eax"}, []string{"edi"}},
		{`
		: bob ( eax -- ) ;
		: sue ( joe -- ) bob ;
		: joe ( bob -- ) sue ;
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
		// adapted crashes during integration
		{`
		: syscall ( num:eax -- result:eax ) syscall ;

		: read ( fd:edi len:edx buf:esi -- result:eax ) 0 syscall ;

		1024 const buf.cap
		buf.cap resb buf

		: read ( fd -- read ) buf.cap buf read ;
		`, []string{"edi"}, []string{"eax"}},
		/*
			{`
			: println ( r10 r11 -- ) drop drop ;
			: cstrlen ( str:rdi -- len:rsi ) ;
			: cstr>str ( cstr:rdx -- str:rsi len:rdx ) dup cstrlen xchg ;

			: print-arg ( arg -- ) cstr>str println ;
			`, []string{}, []string{}},
		*/
	}

	for cnum, c := range cases {
		e := env(c.codeUnderTest)
		e.InferV2 = true
		for e.ParseNextWord() {
		}

		w := e.Dictionary.Latest

		if len(w.Inputs) != len(c.expectedInputs) {
			t.Fatalf("%da) Expected %d inputs got %d", cnum, len(c.expectedInputs), len(w.Inputs))
		}

		for i, input := range w.Inputs {
			if input.Ref != c.expectedInputs[i] {
				t.Fatalf("%db) Expected '%s' got '%s' @ %d", cnum, c.expectedInputs[i], input.Ref, i)
			}
		}

		if len(w.Outputs) != len(c.expectedOutputs) {
			t.Fatalf("%dc) Expected %d outputs got %d", cnum, len(c.expectedOutputs), len(w.Outputs))
		}

		for i, output := range w.Outputs {
			if output.Ref != c.expectedOutputs[i] {
				t.Fatalf("%dd) Expected '%s' got '%s'", cnum, c.expectedOutputs[i], output.Ref)
			}
		}
	}
}
