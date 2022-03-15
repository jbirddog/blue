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

	instr := asm[2].(*AsmResbInstr)
	label := e.AsmLabelForWordNamed("buf")

	if instr.Name != label {
		t.Fatalf("Expected buf, got '%s'", instr.Name)
	}

	if instr.Size != 1024 {
		t.Fatalf("Expected size 1024, got '%d'", instr.Size)
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

func env(buf string) *Environment {
	env := DefaultEnvironment()
	env.InputBuf = buf

	return env
}

func run(e *Environment) []AsmInstr {
	for e.ParseNextWord() {
	}

	return e.Run()
}
