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
	Compiling  bool
	InputBuf   string
	Dictionary *Dictionary
	CodeBuf    []Instr
	AsmInstrs  []AsmInstr
}

func NewEnvironmentForFile(filename string) *Environment {
	bytes, err := ioutil.ReadFile(filename)
	if err != nil {
		log.Fatal(err)
	}

	return &Environment{Dictionary: DefaultDictionary(), InputBuf: string(bytes)}
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

func (e *Environment) ParseNextWord() bool {
	name := e.ReadNextWord()
	if len(name) == 0 {
		return false
	}

	var instr Instr

	if word := e.Dictionary.Find(name); word != nil {
		if !e.Compiling || word.IsImmediate() {
			context := &RunContext{}

			for _, instr := range word.Code {
				instr.Run(e, context)
			}

			return true
		}

		// TODO hack to get resb working.
		if word.IsInline() {
			instr = word.Code[0]
		} else {
			instr = &CallWordInstr{Word: word}
		}
	}

	if _, found := x8664Mnemonics[name]; found {
		instr = &X8664Instr{Mnemonic: name}
	}

	if i, err := strconv.Atoi(name); err == nil {
		instr = &LiteralIntInstr{I: i}
	}

	if instr == nil {
		log.Fatal("Did not find ", name)
	}

	if !e.Compiling {
		e.AppendInstr(instr)
	} else {
		e.Dictionary.Latest().AppendInstr(instr)
	}

	return true
}

func (c *Environment) AppendAsmInstr(i AsmInstr) {
	c.AsmInstrs = append(c.AsmInstrs, i)
}

func (e *Environment) AppendInstr(i Instr) {
	e.CodeBuf = append(e.CodeBuf, i)
}

func (e *Environment) PopInstr() Instr {
	last := len(e.CodeBuf) - 1
	instr := e.CodeBuf[last]
	e.CodeBuf = e.CodeBuf[:last]

	return instr
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
