package main

import (
	"testing"
)

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

func TestCanResb(t *testing.T) {
	cases := []struct {
		asm []AsmInstr
		name string
		size int
	}{
		{run("1024 resb buf"), "buf", 1024},
	}

	for _, c := range cases {
		if len(c.asm) != 1 {
			t.Fatalf("Expected 1 asm instr, got %d", len(c.asm))
		}

		instr := c.asm[0].(*AsmResbInstr)

		if instr.Name != c.name {
			t.Fatalf("Expected name '%s', got '%s'", c.name, instr.Name)
		}

		if instr.Size != c.size {
			t.Fatalf("Expected size '%d', got '%d'", c.size, instr.Size)
		}
	}
}

func env(buf string) *Environment {
	return &Environment{Dictionary: DefaultDictionary(), InputBuf: buf}
}

func run(buf string) []AsmInstr {
	e := env(buf)

	for e.ParseNextWord() {
	}

	return e.Run()
}
