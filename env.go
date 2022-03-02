package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"strconv"
	"strings"
)

type Environment struct {
	Compiling  bool
	Dictionary *Dictionary
	DataStack  []Instr
	InputBuf   string
}

func NewEnvironmentForFile(filename string) *Environment {
	bytes, err := ioutil.ReadFile(filename)
	if err != nil {
		log.Fatal(err)
	}

	return &Environment{Dictionary: DefaultDictionary(), InputBuf: string(bytes)}
}

func (e *Environment) ReadNextWord() string {
	buf := strings.TrimLeft(e.InputBuf, " \t\r\n")
	wordEnd := strings.IndexAny(buf, " \t\r\n")

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

func (e *Environment) ParseNextWord() bool {
	name := e.ReadNextWord()
	if len(name) == 0 {
		return false
	}

	var instr Instr

	if word := e.Dictionary.Find(name); word != nil {
		if !e.Compiling || word.IsImmediate() {
			for _, instr := range word.Code {
				instr.Run(e)
			}
			return true
		}

		instr = &CallWordInstr{Word: word}
	}

	if x8664Mnemonics[name] {
		instr = &X8664Instr{Mnemonic: name}
	}

	if i, err := strconv.Atoi(name); err == nil {
		instr = &LiteralIntInstr{I: i}
	}

	if instr == nil {
		fmt.Println("Did not find", name)
		return false
	}

	if e.Compiling {
		e.Dictionary.Latest().PushInstr(instr)
	} else {
		instr.Run(e)
	}

	return true
}

func (e *Environment) Validate() {
	if e.Compiling {
		log.Fatal("Still compiling")
	}
}

func (e *Environment) WriteAsm(filename string) {
	var asmInstrs []AsmInstr
	var asmWriter AsmWriter

	asmInstrs = e.Dictionary.AppendGlobalDecls(asmInstrs)
	asmInstrs = e.Dictionary.AppendWords(asmInstrs)

	asmWriter.WriteStringToFile(filename, asmInstrs)
}
