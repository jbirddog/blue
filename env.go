package main

import (
	"io/ioutil"
	"log"
	"strconv"
	"strings"
)

type RunContext struct {
	Inputs  []string
	Outputs []string
}

func (c *RunContext) AppendInput(i string) {
	c.Inputs = append(c.Inputs, i)
}

func (c *RunContext) Peek() string {
	return c.Inputs[len(c.Inputs)-1]
}

func (c *RunContext) PopInput() string {
	lastIdx := len(c.Inputs) - 1
	input := c.Inputs[lastIdx]
	c.Inputs = c.Inputs[:lastIdx]

	return input
}

func (c *RunContext) Pop2Inputs() (string, string) {
	inputsLen := len(c.Inputs)
	second := c.Inputs[inputsLen-2]
	first := c.Inputs[inputsLen-1]

	c.Inputs = c.Inputs[:inputsLen-2]

	return second, first
}

type Environment struct {
	Compiling            bool
	InputBuf             string
	Dictionary           *Dictionary
	CodeBuf              []Instr
	AsmInstrs            []AsmInstr
	Globals              map[string]bool
	Section              string
	UserSpecifiedSection bool
}

func DefaultEnvironment() *Environment {
	return &Environment{Dictionary: DefaultDictionary(), Globals: make(map[string]bool)}
}

func NewEnvironmentForFile(filename string) *Environment {
	bytes, err := ioutil.ReadFile(filename)
	if err != nil {
		log.Fatal(err)
	}

	env := DefaultEnvironment()
	env.InputBuf = string(bytes)

	return env
}

func ParseFileInNewEnvironment(filename string) *Environment {
	env := NewEnvironmentForFile(filename)

	for env.ParseNextWord() {
	}

	env.Validate()

	return env
}

func (e *Environment) LTrimBuf() {
	e.InputBuf = strings.TrimLeft(e.InputBuf, " \t\n")
}

func (e *Environment) ReadNextWord() string {
	e.LTrimBuf()
	buf := e.InputBuf
	wordEnd := strings.IndexAny(buf, " \t\n")

	if wordEnd == -1 {
		wordEnd = len(buf) - 1
	}

	if wordEnd == -1 {
		return ""
	}

	word := buf[:wordEnd]
	e.InputBuf = buf[wordEnd:]

	return word
}

func (e *Environment) ReadTil(s string) string {
	buf, read := "", ""

	parts := strings.SplitN(e.InputBuf, s, 2)
	lenParts := len(parts)

	if lenParts > 0 {
		read = parts[0]

		if lenParts > 1 {
			buf = parts[1]
		}
	}

	e.InputBuf = buf

	return read
}

func instrsForWord(word *Word) []Instr {
	if !word.IsInline() {
		return []Instr{&CallWordInstr{Word: word}}
	}

	lastIdx := len(word.Code)
	if instr, x8664 := word.Code[lastIdx-1].(*X8664Instr); x8664 {
		if instr.Mnemonic == "ret" {
			lastIdx -= 1
		}
	}

	return word.Code[:lastIdx]
}

func (e *Environment) ParseNextWord() bool {
	name := e.ReadNextWord()
	if len(name) == 0 {
		return false
	}

	var instrs []Instr

	if word := e.Dictionary.Find(name); word != nil {
		if (!e.Compiling || word.IsImmediate()) && !word.IsInline() {
			context := &RunContext{}

			for _, instr := range word.Code {
				instr.Run(e, context)
			}

			return true
		}

		instrs = instrsForWord(word)
	}

	if _, found := x8664Mnemonics[name]; found {
		instrs = []Instr{&X8664Instr{Mnemonic: name}}
	}

	if i, err := strconv.Atoi(name); err == nil {
		instrs = []Instr{&LiteralIntInstr{I: i}}
	}

	if len(instrs) == 0 {
		log.Fatal("Did not find ", name)
	}

	if !e.Compiling {
		e.AppendInstrs(instrs)
	} else {
		e.Dictionary.Latest.AppendInstrs(instrs)
	}

	return true
}

func (c *Environment) AppendAsmInstr(i AsmInstr) {
	c.AsmInstrs = append(c.AsmInstrs, i)
}

func (c *Environment) AppendAsmInstrs(i []AsmInstr) {
	c.AsmInstrs = append(c.AsmInstrs, i...)
}

func (e *Environment) AppendInstr(i Instr) {
	e.CodeBuf = append(e.CodeBuf, i)
}

func (e *Environment) AppendInstrs(i []Instr) {
	e.CodeBuf = append(e.CodeBuf, i...)
}

func (e *Environment) PopInstr() Instr {
	last := len(e.CodeBuf) - 1
	instr := e.CodeBuf[last]
	e.CodeBuf = e.CodeBuf[:last]

	return instr
}

func (e *Environment) SuggestSection(section string) {
	if e.UserSpecifiedSection {
		return
	}

	if len(e.Section) == 0 {
		e.Section = ".text"
	}

	if e.Section == section {
		return
	}

		e.AppendInstr(&SectionInstr{Info: section})
		e.Section = section
}

func (e *Environment) Validate() {
	if e.Compiling {
		log.Fatal("Still compiling")
	}
}

func (e *Environment) Run() []AsmInstr {
	context := &RunContext{}

	for _, instr := range e.CodeBuf {
		instr.Run(e, context)
	}

	return e.AsmInstrs
}

func (e *Environment) WriteAsm(filename string) {
	var asmWriter AsmWriter

	asmWriter.WriteStringToFile(filename, e.Run())
}
