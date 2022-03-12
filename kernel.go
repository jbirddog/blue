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
	rawRefs := parseRefs(word, env)
	env.Dictionary.Append(word)

	declComment := fmt.Sprintf(": %s %s", name, strings.Join(rawRefs, " "))
	env.AppendInstrs([]Instr{
		&CommentInstr{Comment: declComment},
		&DeclWordInstr{Word: word},
	})
}

func KernelColonGT(env *Environment) {
	parent := env.Dictionary.LatestNonLocal

	if parent == nil || !env.Compiling {
		log.Fatal(":> expects to be nested")
	}

	name := env.ReadNextWord()
	if len(name) == 0 {
		log.Fatal(":> expects a name")
	}

	word := LocalWord(name)
	rawRefs := parseRefs(word, env)

	previous := env.Dictionary.Latest
	previous.AppendInstr(&FlowWordInstr{Word: word})

	env.Dictionary.Append(word)

	declComment := fmt.Sprintf(":> %s %s", name, strings.Join(rawRefs, " "))
	env.AppendInstrs([]Instr{
		&CommentInstr{Comment: declComment},
		&DeclWordInstr{Word: word},
	})
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
	latest := env.Dictionary.Latest
	latest.AppendInstr(&RefWordInstr{Word: latest})
}

func KernelSemi(env *Environment) {
	env.Compiling = false

	if !env.Dictionary.LatestNonLocal.IsNoReturn() {
		latest := env.Dictionary.Latest
		latest.AppendInstr(&X8664Instr{Mnemonic: "ret"})
	}

	env.Dictionary.HideLocalWords()
}

func KernelGlobal(env *Environment) {
	name := env.ReadNextWord()
	if len(name) == 0 {
		log.Fatal("global expects a name")
	}

	env.Globals[name] = true
	env.AppendInstr(&GlobalWordInstr{Name: name})
}

func KernelInline(env *Environment) {
	env.Dictionary.LatestNonLocal.Inline()
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

	for _, val := range importEnv.Dictionary.Words {
		word := val.(*Word)
		env.Dictionary.Append(word)
	}
}

func KernelResb(env *Environment) {
	name := env.ReadNextWord()
	if len(name) == 0 {
		log.Fatal("resb expects a name")
	}

	lastIdx := len(env.CodeBuf) - 1
	sizeInstr := env.CodeBuf[lastIdx].(*LiteralIntInstr)
	size := uint(sizeInstr.I)

	resbInstr := &ResbInstr{Name: name, Size: size}
	env.CodeBuf[lastIdx] = resbInstr

	word := &Word{Name: name}
	instr := &RefWordInstr{Word: word}
	word.AppendInstr(instr)
	word.Inline()

	env.Dictionary.Append(word)
}

func KernelConst(env *Environment) {
	name := env.ReadNextWord()
	if len(name) == 0 {
		log.Fatal("const expects a name")
	}

	instr := env.PopInstr().(*LiteralIntInstr)
	word := NewInlineWord(name, instr)

	env.Dictionary.Append(word)
}

func KernelTick(env *Environment) {
	word := env.Dictionary.Find(env.ReadNextWord())
	if word == nil {
		log.Fatal("' expects a valid word")
	}

	instr := &RefWordInstr{Word: word}
	// TODO won't work when not compiling
	env.Dictionary.Latest.AppendInstr(instr)
}

func KernelXl(env *Environment) {
	latest := env.Dictionary.Latest
	refWord := latest.PopInstr().(*RefWordInstr)
	condCall := &CondCallInstr{Jmp: "jge", Target: refWord}
	latest.AppendInstr(condCall)
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

func parseRefs(word *Word, env *Environment) []string {
	if env.ReadNextWord() != "(" {
		log.Fatal("Expected (")
	}

	rawParts := []string{"("}
	parsingInputs := true

	var parentInputs []*RegisterRef
	var parentOutputs []*RegisterRef

	if word.IsLocal() {
		parent := env.Dictionary.LatestNonLocal
		parentInputs = parent.Inputs
		parentOutputs = parent.Outputs
	}

	for {
		nextWord := env.ReadNextWord()
		if len(nextWord) == 0 {
			log.Fatal("unexpected eof")
		}

		rawParts = append(rawParts, nextWord)

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

	return rawParts
}
