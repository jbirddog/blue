package main

type InstrMatcher interface {
	Matches(instr Instr) bool
}

type AnyLiteralIntMatcher struct{}

func (m *AnyLiteralIntMatcher) Matches(instr Instr) bool {
	_, matches := instr.(*LiteralIntInstr)

	return matches
}

type CallWordMatcher struct{}

func (m *CallWordMatcher) Matches(instr Instr) bool {
	_, matches := instr.(*CallWordInstr)

	return matches
}

type OrMatcher struct{}

func (m *OrMatcher) Matches(instr Instr) bool {
	x8664, matches := instr.(*X8664Instr)

	return matches && x8664.Mnemonic == "or"
}

type RetMatcher struct{}

func (m *RetMatcher) Matches(instr Instr) bool {
	x8664, matches := instr.(*X8664Instr)

	return matches && x8664.Mnemonic == "ret"
}

type InstrPattern []InstrMatcher

func (p InstrPattern) Matches(instrs []Instr) bool {
	patternLen := len(p)
	instrsLen := len(instrs)

	if patternLen > instrsLen {
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

type JmpInsteadOfCallRetOptimization struct{}

func (o *JmpInsteadOfCallRetOptimization) Pattern() InstrPattern {
	return InstrPattern{
		&CallWordMatcher{},
		&RetMatcher{},
	}
}

func (o *JmpInsteadOfCallRetOptimization) Optimize(current []Instr) []Instr {
	word := current[0].(*CallWordInstr).Word

	return []Instr{&JmpWordInstr{Word: word}}
}

var optimizations = []PeepholeOptimization{
	&ConstantFoldOrOptimization{},
	&JmpInsteadOfCallRetOptimization{},
}

// TODO not very efficient or correct at this stage
// only used for folding of asm instructions currently
func PerformPeepholeOptimizationsAtEnd(instrs []Instr) []Instr {
	for _, optimization := range optimizations {
		pattern := optimization.Pattern()
		if !pattern.Matches(instrs) {
			continue
		}

		splitIdx := len(instrs) - len(pattern)
		keep := instrs[:splitIdx]
		optimize := instrs[splitIdx:]
		optimized := optimization.Optimize(optimize)
		return append(keep, optimized...)
	}

	return instrs
}

func peepholeMovToReg(instr *AsmBinaryInstr) []AsmInstr {
	if instr.Op2 == "0" {
		return []AsmInstr{&AsmBinaryInstr{
			Mnemonic: "xor",
			Op1:      instr.Op1,
			Op2:      instr.Op1,
		}}
	}

	if instr.Op2 == "1" {
		return []AsmInstr{
			&AsmBinaryInstr{
				Mnemonic: "xor",
				Op1:      instr.Op1,
				Op2:      instr.Op1,
			},
			&AsmUnaryInstr{
				Mnemonic: "inc",
				Op:       instr.Op1,
			},
		}
	}

	return []AsmInstr{instr}
}

func PeepholeAsmBinaryInstr(instr *AsmBinaryInstr) []AsmInstr {
	if instr.Mnemonic == "mov" {
		if _, found := registers[instr.Op1]; found {
			return peepholeMovToReg(instr)
		}
	}

	return []AsmInstr{instr}
}
