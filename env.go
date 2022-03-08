package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"strconv"
	"strings"
)

type RunContext struct {
	Inputs   []string
	Outputs  []string
	RefWords []*RefWordInstr
}

func (c *RunContext) AppendInput(i string) {
	c.Inputs = append(c.Inputs, i)
}

func (c *RunContext) AppendRefWord(i *RefWordInstr) {
	c.RefWords = append(c.RefWords, i)
}

func (c *RunContext) PopRefWord() *RefWordInstr {
	refWordsLen := len(c.RefWords)
	instr := c.RefWords[refWordsLen-1]

	c.RefWords = c.RefWords[:refWordsLen-1]

	return instr
}

func (c *RunContext) Take2Inputs() (string, string) {
	inputsLen := len(c.Inputs)
	first := c.Inputs[inputsLen-2]
	second := c.Inputs[inputsLen-1]

	c.Inputs = c.Inputs[:inputsLen-2]

	return first, second
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

		instr = &CallWordInstr{Word: word}
	}

	if _, found := x8664Mnemonics[name]; found {
		instr = &X8664Instr{Mnemonic: name}
	}

	if i, err := strconv.Atoi(name); err == nil {
		instr = &LiteralIntInstr{I: i}
	}

	if instr == nil {
		fmt.Println("Did not find", name)
		return false
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
