package main

import (
	"fmt"
	"log"
	"strconv"
	"strings"
)

func KernelColon(env *Environment) {
	flowPreviousWord := env.Compiling
	env.Compiling = true

	name := env.ReadNextWord()
	if len(name) == 0 {
		log.Fatal(": expects a name")
	}

	word := &Word{Name: name}
	word.RawRefs = parseRefs(word, env)

	if flowPreviousWord {
		previous := env.Dictionary.Latest
		previous.AppendInstr(&FlowWordInstr{Word: word})
		env.DeclWord(previous)
	}

	env.Dictionary.Latest = word

	env.SuggestSection(".text")
}

func KernelExtern(env *Environment) {
	name := env.ReadNextWord()
	if len(name) == 0 {
		log.Fatal("extern expects a name")
	}

	word := ExternWord(name)
	parseRefs(word, env)
	env.AppendWord(word)
	env.AppendInstr(&ExternWordInstr{Word: word})
}

func KernelLatest(env *Environment) {
	latest := env.Dictionary.Latest
	latest.AppendInstr(&RefWordInstr{Word: latest})
}

func KernelSemi(env *Environment) {
	env.Compiling = false
	latest := env.Dictionary.Latest

	if !latest.IsNoReturn() {
		latest.AppendInstr(&X8664Instr{Mnemonic: "ret"})
	}

	env.DeclWord(latest)
}

func KernelGlobal(env *Environment) {
	name := env.ReadNextWord()
	if len(name) == 0 {
		log.Fatal("global expects a name")
	}

	env.Globals[name] = true
	env.AppendInstr(&GlobalWordInstr{Name: name})
}

func KernelGlobalLParen(env *Environment) {
	for {
		name := env.ReadNextWord()
		if len(name) == 0 {
			log.Fatal("global( expects a name")
		}

		if name == ")" {
			break
		}

		env.Globals[name] = true
		env.AppendInstr(&GlobalWordInstr{Name: name})
	}
}

func KernelInline(env *Environment) {
	env.Dictionary.Latest.Inline()
}

func KernelSection(env *Environment) {
	env.LTrimBuf()
	info := env.ReadTil("\n")
	env.AppendInstr(&SectionInstr{Info: info})
	env.UserSpecifiedSection = true
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

	env.Merge(importEnv)
}

func KernelResb(env *Environment) {
	name := env.ReadNextWord()
	if len(name) == 0 {
		log.Fatal("resb expects a name")
	}

	sizeInstr := env.PopInstr().(*LiteralIntInstr)
	size := uint(sizeInstr.I)

	env.SuggestSection(".bss")

	word := &Word{Name: name}
	env.AppendWord(word)

	env.AppendInstrs([]Instr{
		&CommentInstr{Comment: fmt.Sprintf("%d resb %s", size, name)},
		&ResbInstr{Name: word.AsmLabel, Size: size},
	})

	instr := &RefWordInstr{Word: word}
	word.AppendInstr(instr)
	word.Inline()
}

func KernelDecb(env *Environment) {
	latest := env.Dictionary.Latest
	valueInstr := latest.PopInstr().(*LiteralIntInstr)
	value := valueInstr.I

	latest.AppendInstr(&DecbInstr{Value: value})
}

func KernelDecbLParen(env *Environment) {
	for {
		name := env.ReadNextWord()
		if name == ")" {
			break
		}
		if value, err := strconv.Atoi(name); err == nil {
			env.Dictionary.Latest.AppendInstr(&DecbInstr{Value: value})
			continue
		}

		log.Fatal("decb( expects a numeric value")
	}
}

func KernelConst(env *Environment) {
	name := env.ReadNextWord()
	if len(name) == 0 {
		log.Fatal("const expects a name")
	}

	instr := env.PopInstr().(*LiteralIntInstr)
	word := NewInlineWord(name, instr)

	env.AppendWord(word)
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

func condCallLatest(env *Environment, jmp string) {
	latest := env.Dictionary.Latest
	refWord := latest.PopInstr().(*RefWordInstr)
	condCall := &CondCallInstr{Jmp: jmp, Target: refWord}
	latest.AppendInstr(condCall)
}

func KernelXl(env *Environment) {
	condCallLatest(env, "jge")
}

func KernelXne(env *Environment) {
	condCallLatest(env, "je")
}

func condLoopLatest(env *Environment, jmp string) {
	latest := env.Dictionary.Latest
	refWord := latest.PopInstr().(*RefWordInstr)
	condLoop := &CondLoopInstr{Jmp: jmp, Target: refWord}
	latest.AppendInstr(condLoop)
}

func KernelLoople(env *Environment) {
	condLoopLatest(env, "jg")
}

func KernelHide(env *Environment) {
	word := env.Dictionary.Find(env.ReadNextWord())
	if word == nil {
		log.Fatal("hide expects a valid word")
	}

	word.Hidden()
}

func KernelLBracket(env *Environment) {
	var parts []string
	replacements := 0

	for {
		name := env.ReadNextWord()
		if len(name) == 0 {
			log.Fatal("[ expects a ]")
		}

		if name == "]" {
			break
		}

		if name == "_" {
			replacements += 1
			parts = append(parts, "%s")
			continue
		}

		parts = append(parts, name)
	}

	if len(parts) == 0 {
		log.Fatal("[ expects a word before ]")
	}

	env.Dictionary.Latest.AppendInstr(&BracketInstr{
		Value:        strings.Join(parts, " "),
		Replacements: replacements,
	})
}

func buildRegisterRef(rawRef string) *RegisterRef {
	parts := strings.SplitN(rawRef, ":", 2)
	partsLen := len(parts)

	if partsLen == 1 {
		part := parts[0]

		if _, found := registers[part]; found {
			return &RegisterRef{Name: part, Reg: part}
		}

		return &RegisterRef{Name: part, Reg: ""}
	}

	return &RegisterRef{Name: parts[0], Reg: parts[1]}
}

func parseRefs(word *Word, env *Environment) []string {
	if env.ReadNextWord() != "(" {
		log.Fatal("Expected (")
	}

	rawParts := []string{"("}
	parsingInputs := true

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
			ref := buildRegisterRef(nextWord)
			word.AppendInput(ref)
		} else {
			ref := buildRegisterRef(nextWord)
			word.AppendOutput(ref)
		}
	}

	return rawParts
}
