package main

import (
	"fmt"
	"log"
	"strings"
)

func KernelColon(env *Environment) {
	env.Compiling = true

	name := env.ReadNextWord()
	if len(name) == 0 {
		log.Fatal(": expects a name")
	}

	word := &Word{Name: name}
	parseRefs(word, env)
	env.Dictionary.Append(word)
	env.AppendInstr(&DeclWordInstr{Word: word})
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
	env.AppendInstr(&DeclWordInstr{Word: word})
}

func KernelExtern(env *Environment) {
	name := env.ReadNextWord()
	if len(name) == 0 {
		log.Fatal("extern expects a name")
	}

	word := ExternWord(name)
	parseRefs(word, env)
	env.Dictionary.Append(word)
	env.AppendInstr(&ExternWordInstr{Word: word})
}

func KernelLatest(env *Environment) {
	latest := env.Dictionary.Latest()
	latest.AppendInstr(&RefWordInstr{Word: latest})
}

func KernelSemi(env *Environment) {
	env.Compiling = false

	if !env.Dictionary.LatestNonLocal().IsNoReturn() {
		latest := env.Dictionary.Latest()
		latest.AppendInstr(&X8664Instr{Mnemonic: "ret"})
	}

	env.Dictionary.HideLocalWords()
}

func KernelGlobal(env *Environment) {
	latest := env.Dictionary.LatestNonLocal()
	latest.Global()
	env.AppendInstr(&GlobalWordInstr{Word: latest})
}

func KernelSection(env *Environment) {
	env.LTrimBuf()
	info := env.ReadTil("\n")
	env.AppendInstr(&SectionInstr{Info: info})
}

func KernelCommentToEol(env *Environment) {
	comment := env.ReadTil("\n")
	env.AppendInstr(&CommentInstr{Comment: comment})
}

func KernelImport(env *Environment) {
	env.LTrimBuf()
	file := env.ReadNextWord()
	if len(file) == 0 {
		log.Fatal("import expects a file")
	}

	file = fmt.Sprintf("%s.blue", file)
	importEnv := ParseFileInNewEnvironment(file)

	env.CodeBuf = append(env.CodeBuf, importEnv.CodeBuf...)
	env.Dictionary.Words = append(env.Dictionary.Words, importEnv.Dictionary.Words...)
}

func KernelResb(env *Environment) {
	name := env.ReadNextWord()
	lastIdx := len(env.CodeBuf) - 1
	sizeInstr := env.CodeBuf[lastIdx].(*LiteralIntInstr)
	size := uint(sizeInstr.I)

	instr := &ResbInstr{Name: name, Size: size}
	env.CodeBuf[lastIdx] = instr
}

func buildRegisterRef(rawRef string, parentRefs []*RegisterRef) *RegisterRef {
	parts := strings.SplitN(rawRef, ":", 2)
	partsLen := len(parts)

	if partsLen == 1 {
		reg := parts[0]

		for _, parentRef := range parentRefs {
			if parentRef.Name == parts[0] {
				reg = parentRef.Reg
				break
			}
		}

		return &RegisterRef{Name: parts[0], Reg: reg}
	}

	return &RegisterRef{Name: parts[0], Reg: parts[1]}
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
