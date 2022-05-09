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

	inferred, inputs, outputs := attemptInference2(env, word)

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

func attemptInference2(env *Environment, word *Word) (bool, []*StackRef, []*StackRef) {
	inputs := word.InputRegisters()
	outputs := word.OutputRegisters()
	context := &RunContext{Inputs: inputs, Outputs: outputs}
	env = env.Sandbox()

	for _, instr := range word.Code {
		instr.Run(env, context)
	}

	var movInstrs []*AsmBinaryInstr

	for _, instr := range env.AsmInstrs {
		if mov, ok := instr.(*AsmBinaryInstr); ok {
			movInstrs = append(movInstrs, mov)
			log.Printf("%s - f: %s, %s", word.Name, mov.Op1, mov.Op2)
		}
	}

	movsLen := len(movInstrs)
	inputsLen := len(inputs)
	outputsLen := len(outputs)

	if movsLen < inputsLen+outputsLen {
		return false, nil, nil
	}

	var inferedInputs []*StackRef
	var inferedOutputs []*StackRef

	for _, inputMov := range movInstrs[:inputsLen] {
		inferedInputs = append(inferedInputs, &StackRef{Ref: inputMov.Op1})
		log.Printf("%s - i: %s, %s", word.Name, inputMov.Op1, inputMov.Op2)
	}

	for _, outputMov := range movInstrs[movsLen-outputsLen:] {
		inferedOutputs = append(inferedOutputs, &StackRef{Ref: outputMov.Op2})
		log.Printf("%s - o: %s, %s", word.Name, outputMov.Op1, outputMov.Op2)
	}

	return true, inferedInputs, inferedOutputs
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
