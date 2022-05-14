package main

import (
	"fmt"
	"log"
	"strconv"
	"strings"
)

func KernelColon(env *Environment) {
	fallthroughFromPreviousWord := env.Compiling
	env.Compiling = true

	name := env.ReadNextWord()
	if len(name) == 0 {
		log.Fatal(": expects a name")
	}

	word := &Word{Name: name}
	word.RawRefs = parseRefs(word, env)

	if fallthroughFromPreviousWord {
		previous := env.Dictionary.Latest

		if previous.HasStackRefs() {
			previous.AppendInstr(&FlowWordInstr{Word: word})
		}

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
		if latest.HasStackRefs() {
			latest.AppendInstr(
				&FlowWordInstr{
					Word:      latest,
					Direction: FlowDirection_Output,
				})
		}

		latest.AppendInstr(
			&RetInstr{},
		)
	}

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
	env.ParseFile(file)
}

func KernelColonColon(env *Environment) {
	name := env.ReadNextWord()
	if len(name) == 0 {
		log.Fatal(":: expects a name")
	}

	word := &Word{Name: name}
	env.AppendWord(word)

	env.AppendCodeBufInstrs([]Instr{
		&CommentInstr{Comment: fmt.Sprintf(":: %s", word.Name)},
		&LabelInstr{Name: word.AsmLabel},
	})

	instr := &RefWordInstr{Word: word}
	word.AppendInstr(instr)
	word.Inline()
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

	env.AppendRefSize(word.AsmLabel, size)

	instr := &RefWordInstr{Word: word}
	word.AppendInstr(instr)
	word.Inline()
}

func KernelResb(env *Environment) {
	res(env, "b")
}

func KernelResw(env *Environment) {
	res(env, "w")
}

func KernelResd(env *Environment) {
	res(env, "d")
}

func KernelResq(env *Environment) {
	res(env, "q")
}

func lit(env *Environment, size string) {
	instr := env.PopInstr()

	var value string

	if intInstr, ok := instr.(*LiteralIntInstr); ok {
		value = fmt.Sprintf("%d", intInstr.I)
	} else {
		value = instr.(*RefWordInstr).Word.AsmLabel
	}

	env.SuggestSection(".text")
	env.AppendInstr(&DecInstr{Size: size, Value: []string{value}})
}

func KernelLitb(env *Environment) {
	lit(env, "b")
}

func KernelLitw(env *Environment) {
	lit(env, "w")
}

func KernelLitd(env *Environment) {
	lit(env, "d")
}

func KernelLitq(env *Environment) {
	lit(env, "q")
}

func litLParen(env *Environment, size string) {
	var decValues []string

	for {
		name := env.ReadNextWord()
		if name == ")" {
			break
		}
		if _, err := strconv.Atoi(name); err == nil {
			decValues = append(decValues, name)
			continue
		}

		log.Fatalf("lit%s( expects a numeric value", size)
	}

	env.SuggestSection(".text")
	env.AppendInstr(&DecInstr{Size: size, Value: decValues})
}

func KernelLitbLParen(env *Environment) {
	litLParen(env, "b")
}

func KernelLitwLParen(env *Environment) {
	litLParen(env, "w")
}

func KernelLitdLParen(env *Environment) {
	litLParen(env, "d")
}

func KernelLitqLParen(env *Environment) {
	litLParen(env, "q")
}

func dec(env *Environment, size string) {
	lit(env, size)

	name := env.ReadNextWord()
	if len(name) == 0 {
		log.Fatalf("dec%s expects a name", size)
	}

	// TODO refactor this pattern, in res*, decLparen and coloncolon, etc
	word := &Word{Name: name}
	env.AppendWord(word)

	decInstr := env.PopInstr().(*DecInstr)
	decInstr.Name = word.AsmLabel

	env.AppendInstrs([]Instr{
		&CommentInstr{Comment: fmt.Sprintf("%s dec%s %s", decInstr.Value, size, name)},
		decInstr,
	})

	env.AppendRefSize(word.AsmLabel, size)

	word.AppendInstr(&RefWordInstr{Word: word})
	word.Inline()
}

func KernelDecb(env *Environment) {
	dec(env, "b")
}

func KernelDecw(env *Environment) {
	dec(env, "w")
}

func KernelDecd(env *Environment) {
	dec(env, "d")
}

func KernelDecq(env *Environment) {
	dec(env, "q")
}

// TODO take a name like dec
func decLParen(env *Environment, size string) {
	litLParen(env, size)

	name := env.ReadNextWord()
	if len(name) == 0 {
		log.Fatalf("dec%s( expects a name", size)
	}

	// TODO refactor this pattern, in res*, decLparen and coloncolon, etc
	word := &Word{Name: name}
	env.AppendWord(word)

	decInstr := env.PopInstr().(*DecInstr)
	decInstr.Name = word.AsmLabel

	env.AppendInstrs([]Instr{
		&CommentInstr{Comment: fmt.Sprintf("dec%s( .. ) %s", size, name)},
		decInstr,
	})

	env.AppendRefSize(word.AsmLabel, size)

	word.AppendInstr(&RefWordInstr{Word: word})
	word.Inline()
}

func KernelDecbLParen(env *Environment) {
	decLParen(env, "b")
}

func KernelDecwLParen(env *Environment) {
	decLParen(env, "w")
}

func KernelDecdLParen(env *Environment) {
	decLParen(env, "d")
}

func KernelDecqLParen(env *Environment) {
	decLParen(env, "q")
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

func KernelXe(env *Environment) {
	condCall(env, "jne")
}

func KernelXne(env *Environment) {
	condCall(env, "je")
}

func KernelXl(env *Environment) {
	condCall(env, "jge")
}

func KernelXz(env *Environment) {
	condCall(env, "jnz")
}

func KernelXnz(env *Environment) {
	condCall(env, "jz")
}

func KernelXg(env *Environment) {
	condCall(env, "jle")
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

	if !env.Compiling {
		env.SuggestSection(".text")
	}
	env.AppendInstr(&AsciiStrInstr{Str: str, PushLen: pushLen})
}

func KernelCQuote(env *Environment) {
	asciiStr(env, false)
}

func KernelSQuote(env *Environment) {
	asciiStr(env, true)
}

func buildStackRef(rawRef string) *StackRef {
	parts := strings.SplitN(rawRef, ":", 2)
	partsLen := len(parts)

	if partsLen == 1 {
		part := parts[0]

		if _, found := registers[part]; found {
			return &StackRef{Name: part, Ref: part}
		}

		return &StackRef{Name: part, Ref: ""}
	}

	return &StackRef{Name: parts[0], Ref: parts[1]}
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

		ref := buildStackRef(nextWord)
		regIndex, found := registers[ref.Ref]

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
