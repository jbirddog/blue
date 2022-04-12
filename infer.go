package main

import (
	"log"
)

// TODO this is going to fit into a larger overhaul discussed in TODO.md
// each instr should be able to desribe its effects so they can be computed
// together and a) compared to a full effect declaration or used to infer
// the effect for a word. this implementation will be quick and dirty to
// see how it works in the language before the more correct implementation

func InferRegisterRefs(word *Word) {
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
		if r.Reg == "" {
			r.Reg = inputs[i]
		}
	}

	for i, r := range word.Outputs {
		if r.Reg == "" {
			r.Reg = outputs[i]
		}
	}
}

func min(a, b int) int {
	if a < b {
		return a
	}

	return b
}

func attemptInferenceToNextWord(word *Word, inputs []string, outputs []string) ([]string, []string) {
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

func attemptInference(word *Word) (bool, []string, []string) {
	var inputs []string
	var outputs []string
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
			outputs = append(outputs, "I")
		case *RefWordInstr:
			outputs = append(outputs, "RW")
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
