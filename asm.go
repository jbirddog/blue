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
	return fmt.Sprintf("global %s\n", i.Label)
}

type AsmLabelInstr struct {
	Name string
}

func (i *AsmLabelInstr) StringRepresentation() string {
	return fmt.Sprintf("\n%s:\n", i.Name)
}

type AsmCallInstr struct {
	Label string
}

func (i *AsmCallInstr) StringRepresentation() string {
	return fmt.Sprintf("\tcall %s\n", i.Label)
}

type AsmNoOperandInstr struct {
	Mnemonic string
}

func (i *AsmNoOperandInstr) StringRepresentation() string {
	return fmt.Sprintf("\t%s\n", i.Mnemonic)
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
