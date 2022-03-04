package main

import (
	"testing"
)

func env(buf string) *Environment {
	return &Environment{InputBuf: buf}
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
