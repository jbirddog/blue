package main

import (
	"log"
)

func kernel_colon(env *Environment) {
	env.Compiling = true

	name := env.ReadNextWord()
	if len(name) == 0 {
		log.Fatal(": expects a name")
	}

	env.Dictionary.Append(&Word{Name: name})
}

func kernel_colon_gt(env *Environment) {
	parent := env.Dictionary.LatestNonLocal()

	if parent == nil {
		log.Fatal(":> expects to be nested")
	}

	kernel_colon(env)

	latest := env.Dictionary.Latest()
	latest.Local()
}

func kernel_lparen(env *Environment) {
	latest := env.Dictionary.Latest()
	parsingInputs := true

	var parentInputs []*RegisterRef
	var parentOutputs []*RegisterRef

	if latest.IsLocal() {
		parent := env.Dictionary.LatestNonLocal()
		parentInputs = parent.Inputs
		parentOutputs = parent.Outputs
	}

	for {
		nextWord := env.ReadNextWord()
		if len(nextWord) == 0 {
			log.Fatal("( unexpected eof")
		}

		if nextWord == "--" {
			parsingInputs = false
			continue
		}

		if nextWord == "noret" {
			latest.NoReturn()
			continue
		}

		if nextWord == ")" {
			break
		}

		if parsingInputs {
			ref := buildRegisterRef(nextWord, parentInputs)
			latest.AppendInput(ref)
		} else {
			ref := buildRegisterRef(nextWord, parentOutputs)
			latest.AppendOutput(ref)
		}
	}
}

func kernel_semi(env *Environment) {
	env.Compiling = false
	latest := env.Dictionary.Latest()

	if !latest.IsNoReturn() {
		latest.AppendInstr(&X8664Instr{Mnemonic: "ret"})
	}

	env.Dictionary.HideLocalWords()
}
