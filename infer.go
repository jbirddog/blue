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
		log.Fatal("Inferred different input len than declared")
	}

	if len(outputs) != len(word.Outputs) {
		log.Fatal("Inferred different output len than declared")
	}

	for i, r := range word.Inputs {
		if r.Reg == "" {
			r.Reg = inputs[i].Reg
		}
	}

	for i, r := range word.Outputs {
		if r.Reg == "" {
			r.Reg = outputs[i].Reg
		}
	}
}

func attemptInference(word *Word) (bool, []*RegisterRef, []*RegisterRef) {
	var inputs []*RegisterRef
	var outputs []*RegisterRef

	for _, code := range word.Code {
		switch instr := code.(type) {
		case *CallWordInstr:
			if !instr.Word.HasCompleteRefs() {
				return false, nil, nil
			}

			inputs = instr.Word.Inputs
			outputs = instr.Word.Outputs
		}
	}

	return true, inputs, outputs
}
