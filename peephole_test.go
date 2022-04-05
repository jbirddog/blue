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

	optimized := PerformPeepholeOptimizations(instrs)

	if len(optimized) != 1 {
		t.Fatalf("Expected 1 optimized instr, got %d", len(optimized))
	}
}
