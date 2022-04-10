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
