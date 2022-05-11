package main

import (
	"log"
)

// TODO this is going to fit into a larger overhaul discussed in TODO.md
// each instr should be able to desribe its effects so they can be computed
// together and a) compared to a full effect declaration or used to infer
// the effect for a word. this implementation will be quick and dirty to
// see how it works in the language before the more correct implementation

func InferStackRefs(env *Environment, word *Word) {
	if word.HasCompleteRefs() {
		return
	}

	inferred, inputs, outputs := attemptInference(word)

	if !inferred {
		return
	}

	if len(inputs) != len(word.Inputs) {
		log.Printf("Inferred different input len (%d) than declared (%d)", len(inputs), len(word.Inputs))
		return
	}

	if len(outputs) != len(word.Outputs) {
		log.Print("Inferred different output len than declared")
		return
	}

	for i, r := range word.Inputs {
		if r.Ref == "" {
			r.Ref = inputs[i].Ref
		}
	}

	for i, r := range word.Outputs {
		if r.Ref == "" {
			r.Ref = outputs[i].Ref
		}
	}
}

func InferStackRefs2(env *Environment, word *Word) {
	if word.HasCompleteRefs() {
		return
	}

	infered, inputs, outputs := attemptInference2(env, word)

	if !infered {
		return
	}

	applyInference(word.Inputs, inputs)
	applyInference(word.Outputs, outputs)
}

func applyInference(dest []*StackRef, src []*StackRef) {
	for i, d := range dest {
		if d.Ref == "" {
			d.Ref = src[i].Ref
		}
	}
}

func min(a, b int) int {
	if a < b {
		return a
	}

	return b
}

func attemptInferenceToNextWord(word *Word, inputs []*StackRef, outputs []*StackRef) ([]*StackRef, []*StackRef) {
	wordInputs := word.InputRegisters()
	wordInputsLen := len(wordInputs)
	outputsLen := len(outputs)
	outputsConsumed := min(outputsLen, wordInputsLen)

	wordInputs = wordInputs[:wordInputsLen-outputsConsumed]
	inputs = append(inputs, wordInputs...)

	wordOutputs := word.OutputRegisters()
	outputs = outputs[:outputsLen-outputsConsumed]
	outputs = append(outputs, wordOutputs...)

	return inputs, outputs
}

func indexStackRefs(refs []*StackRef) map[string]int {
	indexes := map[string]int{}

	for i, r := range refs {
		indexes[r.Name] = i
	}

	return indexes
}

func prepCodeForInference(instrs []Instr) (bool, []Instr) {
	var prepped []Instr

	for _, i := range instrs {
		switch instr := i.(type) {
		case *CallWordInstr:
			if !instr.Word.HasCompleteRefs() {
				return false, nil
			}
		case *JmpWordInstr:
			if !instr.Word.HasCompleteRefs() {
				return false, nil
			}
		default:
			prepped = append(prepped, instr)
		}
	}

	return true, prepped
}

func findMovInstrs(asmInstrs []AsmInstr) []*AsmBinaryInstr {
	var movs []*AsmBinaryInstr

	for _, instr := range asmInstrs {
		if mov, ok := instr.(*AsmBinaryInstr); ok && mov.Mnemonic == "mov" {
			movs = append(movs, mov)
		}
	}

	return movs
}

func attemptInference2(env *Environment, word *Word) (bool, []*StackRef, []*StackRef) {
	inputs := word.InputRegisters()
	inputIndexes := indexStackRefs(inputs)
	outputs := word.OutputRegisters()
	outputIndexes := indexStackRefs(outputs)
	context := &RunContext{
		Inputs:  word.InputRegisters(),
		Outputs: word.OutputRegisters(),
	}
	env = env.Sandbox()
	inferable, code := prepCodeForInference(word.Code)

	if !inferable {
		return false, nil, nil
	}

	for _, instr := range code {
		instr.Run(env, context)
	}

	movInstrs := findMovInstrs(env.AsmInstrs)

	if len(movInstrs) < len(inputs)+len(outputs) {
		return false, nil, nil
	}

	for _, mov := range movInstrs {
		if index, found := inputIndexes[mov.Op2]; found {
			inputs[index].Ref = mov.Op1
			continue
		}

		if index, found := outputIndexes[mov.Op1]; found {
			outputs[index].Ref = mov.Op2
		}
	}

	if !RefsAreComplete(inputs) || !RefsAreComplete(outputs) {
		return false, nil, nil
	}

	return true, inputs, outputs
}

func attemptInference(word *Word) (bool, []*StackRef, []*StackRef) {
	var inputs []*StackRef
	var outputs []*StackRef
	pendingSwapIdx := -1

	for i, code := range word.Code {
		switch instr := code.(type) {
		case *DropInstr:
			outputs = outputs[:len(outputs)-1]
		case *SwapInstr:
			if pendingSwapIdx >= 0 {
				return false, nil, nil
			}

			pendingSwapIdx = i
		case *LiteralIntInstr:
			outputs = append(outputs, &StackRef{
				Type: StackRefType_LiteralInt,
				Ref:  "I",
			})
		case *RefWordInstr:
			outputs = append(outputs, &StackRef{
				Type: StackRefType_Label,
				Ref:  "RW",
			})
		case *CallWordInstr:
			if !instr.Word.HasCompleteRefs() {
				return false, nil, nil
			}

			inputs, outputs = attemptInferenceToNextWord(instr.Word,
				inputs,
				outputs)
		case *JmpWordInstr:
			if !instr.Word.HasCompleteRefs() {
				return false, nil, nil
			}

			inputs, outputs = attemptInferenceToNextWord(instr.Word,
				inputs,
				outputs)
		}

		if pendingSwapIdx >= 0 && len(inputs) > pendingSwapIdx+1 {
			i := pendingSwapIdx
			j := pendingSwapIdx + 1
			inputs[i], inputs[j] = inputs[j], inputs[i]
			pendingSwapIdx = -1
		}
	}

	if pendingSwapIdx >= 0 {
		return false, nil, nil
	}

	return true, inputs, outputs
}
