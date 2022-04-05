package main

import (
	"log"
)

type InstrMatcher interface {
	Matches(instr Instr) bool
}

type AnyLiteralIntMatcher struct{}

func (m *AnyLiteralIntMatcher) Matches(instr Instr) bool {
	_, matches := instr.(*LiteralIntInstr)

	return matches
}

type OrMatcher struct{}

func (m *OrMatcher) Matches(instr Instr) bool {
	x8664, matches := instr.(*X8664Instr)

	return matches && x8664.Mnemonic == "or"
}

type InstrPattern []InstrMatcher

func (p InstrPattern) Matches(instrs []Instr) bool {
	patternLen := len(p)
	instrsLen := len(instrs)

	if patternLen > instrsLen {
		log.Print("patternLen > instrsLen")
		return false
	}

	start := instrsLen - patternLen

	for i, pattern := range p {
		if !pattern.Matches(instrs[start+i]) {
			return false
		}
	}

	return true
}

type PeepholeOptimization interface {
	Pattern() InstrPattern
	Optimize([]Instr) []Instr
}

type ConstantFoldOrOptimization struct{}

func (o *ConstantFoldOrOptimization) Pattern() InstrPattern {
	return InstrPattern{
		&AnyLiteralIntMatcher{},
		&AnyLiteralIntMatcher{},
		&OrMatcher{},
	}
}

func (o *ConstantFoldOrOptimization) Optimize(current []Instr) []Instr {
	i1 := current[0].(*LiteralIntInstr).I
	i2 := current[1].(*LiteralIntInstr).I

	return []Instr{&LiteralIntInstr{I: i1 | i2}}
}

var optimizations = []PeepholeOptimization{
	&ConstantFoldOrOptimization{},
}

// TODO not very efficient or correct for anything but the constant
// folding of asm instructions at this stage
func PerformPeepholeOptimizations(instrs []Instr) []Instr {
	for _, optimization := range optimizations {
		pattern := optimization.Pattern()
		if !pattern.Matches(instrs) {
			log.Print("Pattern does not match")
			continue
		}

		splitIdx := len(instrs) - len(pattern)
		keep := instrs[:splitIdx]
		optimize := instrs[splitIdx:]
		optimized := optimization.Optimize(optimize)
		return append(keep, optimized...)
	}

	log.Print("Exit with no match")

	return instrs
}
