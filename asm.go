package main

import (
	"fmt"
	"log"
	"os"
	"strings"
)

type AsmInstr interface {
	String() string
}

type AsmGlobalInstr struct {
	Label string
}

func (i *AsmGlobalInstr) String() string {
	return fmt.Sprintf("global %s\n", i.Label)
}

type AsmLabelInstr struct {
	Name string
}

func (i *AsmLabelInstr) String() string {
	return fmt.Sprintf("\n%s:\n", i.Name)
}

type AsmCallInstr struct {
	Label string
}

func (i *AsmCallInstr) String() string {
	return fmt.Sprintf("\tcall %s\n", i.Label)
}

type AsmNoOperandInstr struct {
	Mnemonic string
}

func (i *AsmNoOperandInstr) String() string {
	return fmt.Sprintf("\t%s\n", i.Mnemonic)
}

type AsmUnaryInstr struct {
	Mnemonic string
	Op       string
}

func (i *AsmUnaryInstr) String() string {
	return fmt.Sprintf("\t%s %s\n", i.Mnemonic, i.Op)
}

type AsmBinaryInstr struct {
	Mnemonic string
	Op1      string
	Op2      string
}

func (i *AsmBinaryInstr) String() string {
	return fmt.Sprintf("\t%s %s, %s\n", i.Mnemonic, i.Op1, i.Op2)
}

type AsmWriter struct {
	sb strings.Builder
}

func (w *AsmWriter) WriteStringToFile(filename string, instrs []AsmInstr) {
	for _, instr := range instrs {
		w.sb.WriteString(instr.String())
	}

	output := []byte(w.sb.String())

	if err := os.WriteFile(filename, output, 0644); err != nil {
		log.Fatal("Failed to write to file:", filename)
	}
}
