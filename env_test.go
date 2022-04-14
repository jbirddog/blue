package main

import (
	"testing"
)

func TestReadNextWord(t *testing.T) {
	cases := []struct {
		env      *Environment
		expected []string
	}{
		{env(""), []string{}},
		{env("1024 resb buf"), []string{"1024", "resb", "buf"}},
		{env("1024 resb buf\n"), []string{"1024", "resb", "buf"}},
		{env("\n\n1024 resb buf  \t  "), []string{"1024", "resb", "buf"}},
		{
			env(": xyz ( -- ) buf loop ;"),
			[]string{":", "xyz", "(", "--", ")", "buf", "loop", ";"},
		},
		{
			env("\n\t\n\t: xyz ( -- ) buf loop ;           \n\n"),
			[]string{":", "xyz", "(", "--", ")", "buf", "loop", ";"},
		},
	}

	for _, c := range cases {
		for _, expected := range c.expected {
			read := c.env.ReadNextWord()

			if read != expected {
				t.Fatalf("Expected '%s' got '%s'", expected, read)
			}
		}
	}
}

func TestReadTil(t *testing.T) {
	cases := []struct {
		env       *Environment
		til       string
		expected  string
		remaining string
	}{
		{env(""), "", "", ""},
		{env(""), "bob", "", ""},
		{env("joe bob sue"), "bob", "joe ", " sue"},
		{env("some words\n"), "\n", "some words", ""},
		{env("some words\n  "), "\n", "some words", "  "},
	}

	for _, c := range cases {
		read := c.env.ReadTil(c.til)

		if read != c.expected {
			t.Fatalf("Expected '%s', got '%s'", c.expected, read)
		}

		if c.env.InputBuf != c.remaining {
			t.Fatalf("Expected buf '%s', found '%s'", c.remaining, c.env.InputBuf)
		}
	}
}

// TODO these are fragile
func TestCanDeclResb(t *testing.T) {
	e := env("1024 resb buf")
	asm := run(e)

	if len(asm) != 3 {
		t.Fatalf("Expected 3 asms instr, got %d", len(asm))
	}

	instr := asm[2].(*AsmResInstr)
	label := e.AsmLabelForWordNamed("buf")

	if instr.Name != label {
		t.Fatalf("Expected buf, got '%s'", instr.Name)
	}

	if instr.Count != 1024 {
		t.Fatalf("Expected count 1024, got '%d'", instr.Count)
	}

	if instr.Size != "b" {
		t.Fatalf("Expected size b, got '%s'", instr.Size)
	}
}

func TestCanFindResbRef(t *testing.T) {
	e := env("1024 resb buf : xyz ( -- ) buf loop ;")
	asm := run(e)

	loopInstr := asm[6].(*AsmUnaryInstr)
	label := e.AsmLabelForWordNamed("buf")

	if loopInstr.Op != label {
		t.Fatalf("Expected buf, got '%s'", loopInstr.Op)
	}
}

func TestCanFindSQuote(t *testing.T) {
	e := env(`s" bob"`)
	asm := run(e)

	if len(asm) == 0 {
		t.Fatal("Expected asm instrs, got none")
	}
}

func TestCanFindSQuoteWhenCompiling(t *testing.T) {
	e := env(`: xyz ( -- ) s" testing" ;`)
	asm := run(e)

	if len(asm) == 0 {
		t.Fatal("Expected asm instrs, got none")
	}
}

func TestCanParseCQuote(t *testing.T) {
	instrs := parse(`c" bob"`)

	if len(instrs) == 0 {
		t.Fatal("Expected instrs, got none")
	}
}

func TestCanFindCQuoteWhenCompiling(t *testing.T) {
	e := env(`: xyz ( -- ) c" testing" ;`)
	asm := run(e)

	if len(asm) == 0 {
		t.Fatal("Expected asm instrs, got none")
	}
}

func TestCanEvaluateRuntimeOr(t *testing.T) {
	instrs := parse("1 2 or")
	instrsLen := len(instrs)

	if instrsLen != 1 {
		t.Fatalf("Expected one instr, got %d", instrsLen)
	}

	litInstr := instrs[0].(*LiteralIntInstr)

	if litInstr.I != 3 {
		t.Fatalf("Expected 1 2 or to be 3, got %d", litInstr.I)
	}
}

func TestCanRot(t *testing.T) {
	instrs := parse("1 2 3 rot")

	if len(instrs) == 0 {
		t.Fatal("Expected instrs, got none")
	}
}

func env(buf string) *Environment {
	env := DefaultEnvironment()
	env.InputBuf = buf

	return env
}

func parse(buf string) []Instr {
	e := env(buf)
	for e.ParseNextWord() {
	}

	return e.CodeBuf
}

func run(e *Environment) []AsmInstr {
	for e.ParseNextWord() {
	}

	return e.Run()
}
