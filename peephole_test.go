package main

import (
	"testing"
)

func TestCanConstantFoldOr(t *testing.T) {
	instrs := []Instr{
		&LiteralIntInstr{I: 1},
		&LiteralIntInstr{I: 2},
		&X8664Instr{Mnemonic: "or"},
	}

	optimized := PerformPeepholeOptimizationsAtEnd(instrs)

	if len(optimized) != 1 {
		t.Fatalf("Expected 1 optimized instr, got %d", len(optimized))
	}

	value := optimized[0].(*LiteralIntInstr).I

	if value != 3 {
		t.Fatalf("Expected optimized value of 3, got %d", value)
	}
}

func TestCanOptimizeMovReg0ToXorRegReg(t *testing.T) {
	instr := &AsmBinaryInstr{Mnemonic: "mov", Op1: "eax", Op2: "0"}

	optimized := PeepholeAsmBinaryInstr(instr)

	if len(optimized) != 1 {
		t.Fatalf("Expected 1 optimized instr, go %d", len(optimized))
	}

	newInstr := optimized[0].(*AsmBinaryInstr)

	if newInstr.Mnemonic != "xor" {
		t.Fatalf("Expected xor, got %s", newInstr.Mnemonic)
	}

	if newInstr.Op1 != "eax" || newInstr.Op2 != "eax" {
		t.Fatalf("Expected xor eax eax, got xor %s %s", newInstr.Op1, newInstr.Op2)
	}
}

func TestDoesNotOptimizeMovNonReg0(t *testing.T) {
	instr := &AsmBinaryInstr{Mnemonic: "mov", Op1: "[bob]", Op2: "0"}

	optimized := PeepholeAsmBinaryInstr(instr)

	if len(optimized) != 1 {
		t.Fatalf("Expected 1 optimized instr, go %d", len(optimized))
	}

	newInstr := optimized[0].(*AsmBinaryInstr)

	if newInstr.Mnemonic != instr.Mnemonic {
		t.Fatalf("Expected mov, got %s", newInstr.Mnemonic)
	}

	if newInstr.Op1 != instr.Op1 || newInstr.Op2 != instr.Op2 {
		t.Fatalf("Expected mov [bob] 0, got xor %s %s", newInstr.Op1, newInstr.Op2)
	}
}
