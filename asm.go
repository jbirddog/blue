package main

import (
	"fmt"
	"log"
	"os"
	"strings"
)

type AsmInstr interface {
	StringRepresentation() string
}

type AsmGlobalInstr struct {
	Label string
}

func (i *AsmGlobalInstr) StringRepresentation() string {
	return "global " + i.Label
}

type AsmLabelInstr struct {
	Name string
}

func (i *AsmLabelInstr) StringRepresentation() string {
	return fmt.Sprintf("\n%s:", i.Name)
}

type AsmWriter struct {
	sb strings.Builder
}

func (w *AsmWriter) WriteStringRepresentationToFile(filename string, instrs []AsmInstr) {
	for _, instr := range instrs {
		w.sb.WriteString(instr.StringRepresentation())
	}

	output := []byte(w.sb.String())

	if err := os.WriteFile(filename, output, 0644); err != nil {
		log.Fatal("Failed to write to file:", filename)
	}
}
