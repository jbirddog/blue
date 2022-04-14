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
	env.AppendInstr(&RefWordInstr{Word: latest})
}

func KernelSemi(env *Environment) {
	latest := env.Dictionary.Latest

	if !latest.IsNoReturn() {
		latest.AppendInstr(&X8664Instr{Mnemonic: "ret"})
	}

	// TODO this should be a whole word optimization pass instead of
	// just optimizing the tail
	env.OptimizeInstrs()
	env.Compiling = false
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

func res(env *Environment, size string) {
	if env.Compiling {
		log.Fatal("res", size, " does not expect to be declared in a word")
	}

	name := env.ReadNextWord()
	if len(name) == 0 {
		log.Fatal("res", size, " expects a name")
	}

	countInstr := env.PopCodeBufInstr().(*LiteralIntInstr)
	count := uint(countInstr.I)

	env.SuggestSection(".bss")

	word := &Word{Name: name}
	env.AppendWord(word)

	env.AppendCodeBufInstrs([]Instr{
		&CommentInstr{Comment: fmt.Sprintf("%d res%s %s", count, size, name)},
		&ResInstr{Name: word.AsmLabel, Size: size, Count: count},
	})

	instr := &RefWordInstr{Word: word}
	word.AppendInstr(instr)
	word.Inline()
}

func KernelResb(env *Environment) {
	res(env, "b")
}

func KernelResd(env *Environment) {
	res(env, "d")
}

func KernelResq(env *Environment) {
	res(env, "q")
}

func KernelDecb(env *Environment) {
	if !env.Compiling {
		log.Fatal("decb expects to be inside a word")
	}
	latest := env.Dictionary.Latest
	valueInstr := latest.PopInstr().(*LiteralIntInstr)
	value := valueInstr.I

	latest.AppendInstr(&DecbInstr{Value: value})
}

func KernelDecbLParen(env *Environment) {
	if !env.Compiling {
		log.Fatal("decb( expects to be inside a word")
	}
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
	if env.Compiling {
		log.Fatal("const does not expect to be declared in a word")
	}
	name := env.ReadNextWord()
	if len(name) == 0 {
		log.Fatal("const expects a name")
	}

	instr := env.PopCodeBufInstr().(*LiteralIntInstr)
	word := NewInlineWord(name, instr)

	env.AppendWord(word)
}

func KernelTick(env *Environment) {
	word := env.Dictionary.Find(env.ReadNextWord())
	if word == nil {
		log.Fatal("' expects a valid word")
	}

	instr := &RefWordInstr{Word: word}
	env.AppendInstr(instr)
}

func condCall(env *Environment, jmp string) {
	refWord := env.PopInstr().(*RefWordInstr)
	condCall := &CondCallInstr{Jmp: jmp, Target: refWord}
	env.AppendInstr(condCall)
}

func KernelXl(env *Environment) {
	condCall(env, "jge")
}

func KernelXne(env *Environment) {
	condCall(env, "je")
}

func condLoop(env *Environment, jmp string) {
	refWord := env.PopInstr().(*RefWordInstr)
	condLoop := &CondLoopInstr{Jmp: jmp, Target: refWord}
	env.AppendInstr(condLoop)
}

func KernelLoople(env *Environment) {
	condLoop(env, "jg")
}

func KernelHide(env *Environment) {
	word := env.Dictionary.Find(env.ReadNextWord())
	if word == nil {
		log.Fatal("hide expects a valid word")
	}

	word.Hidden()
}

func asciiStr(env *Environment, pushLen bool) {
	// TODO this won't handle nested quotes
	str := env.ReadTil(`"`)
	strLen := len(str)

	if strLen < 1 {
		log.Fatal(`s" expects closing "`)
	}

	if strLen > 2 {
		str = str[1:]
	}

	env.AppendInstr(&AsciiStrInstr{Str: str, PushLen: pushLen})
}

func KernelCQuote(env *Environment) {
	asciiStr(env, false)
}

func KernelSQuote(env *Environment) {
	asciiStr(env, true)
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

	const (
		inputs = iota
		outputs
		clobbers
	)

	rawParts := []string{"("}
	parsing := inputs

	for {
		nextWord := env.ReadNextWord()
		if len(nextWord) == 0 {
			log.Fatal("unexpected eof")
		}

		rawParts = append(rawParts, nextWord)

		if nextWord == "--" {
			parsing = outputs
			continue
		}

		if nextWord == "|" {
			parsing = clobbers
			continue
		}

		if nextWord == "noret" {
			if parsing != outputs {
				log.Fatal("noret in non output position")
			}

			word.NoReturn()
			continue
		}

		if nextWord == ")" {
			break
		}

		ref := buildRegisterRef(nextWord)
		regIndex, found := registers[ref.Reg]

		if found && parsing != clobbers {
			word.Registers |= 1 << regIndex
		}

		switch parsing {
		case inputs:
			word.AppendInput(ref)
		case outputs:
			word.AppendOutput(ref)
		case clobbers:
			if !found {
				log.Fatal("Clobber expects a register")
			}

			word.Clobbers |= 1 << regIndex
		}
	}

	return rawParts
}
