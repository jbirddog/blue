package main

import (
	"log"
)

func KernelColon(env *Environment) {
	// needToFlowWords := env.Compiling
	env.Compiling = true

	name := env.ReadNextWord()
	if len(name) == 0 {
		log.Fatal(": expects a name")
	}

	word := &Word{Name: name}
	parseRefs(word, env)
	env.Dictionary.Append(word)
}

func KernelColonGT(env *Environment) {
	parent := env.Dictionary.LatestNonLocal()

	if parent == nil || !env.Compiling {
		log.Fatal(":> expects to be nested")
	}

	name := env.ReadNextWord()
	if len(name) == 0 {
		log.Fatal(":> expects a name")
	}

	word := LocalWord(name)
	parseRefs(word, env)

	previous := env.Dictionary.Latest()
	previous.AppendInstr(&FlowWordInstr{Word: word})

	env.Dictionary.Append(word)
}

func KernelSemi(env *Environment) {
	env.Compiling = false
	latest := env.Dictionary.Latest()

	if !latest.IsNoReturn() {
		latest.AppendInstr(&X8664Instr{Mnemonic: "ret"})
	}

	env.Dictionary.HideLocalWords()
}

func parseRefs(word *Word, env *Environment) {
	if env.ReadNextWord() != "(" {
		log.Fatal("Expected (")
	}

	parsingInputs := true

	var parentInputs []*RegisterRef
	var parentOutputs []*RegisterRef

	if word.IsLocal() {
		parent := env.Dictionary.LatestNonLocal()
		parentInputs = parent.Inputs
		parentOutputs = parent.Outputs
	}

	for {
		nextWord := env.ReadNextWord()
		if len(nextWord) == 0 {
			log.Fatal("unexpected eof")
		}

		if nextWord == "--" {
			parsingInputs = false
			continue
		}

		if nextWord == "noret" {
			word.NoReturn()
			continue
		}

		if nextWord == ")" {
			break
		}

		if parsingInputs {
			ref := buildRegisterRef(nextWord, parentInputs)
			word.AppendInput(ref)
		} else {
			ref := buildRegisterRef(nextWord, parentOutputs)
			word.AppendOutput(ref)
		}
	}
}
