package main

func InferStackRefs(env *Environment, word *Word) {
	if word.HasCompleteRefs() {
		return
	}

	infered, inputs, outputs := attemptInference(env, word)

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

func attemptInference(env *Environment, word *Word) (bool, []*StackRef, []*StackRef) {
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
