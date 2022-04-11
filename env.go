package main

import (
	"fmt"
	"hash/fnv"
	"io/ioutil"
	"log"
	"strconv"
	"strings"
)

type RunContext struct {
	Inputs        []string
	Outputs       []string
	ClobberGuards []string
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

func (c *RunContext) ClearClobberGuards() {
	c.ClobberGuards = nil
}

func (c *RunContext) AppendClobberGuard(regIdx int) {
	c.ClobberGuards = append(c.ClobberGuards, reg64Names[regIdx])
}

type Environment struct {
	Compiling            bool
	InputBuf             string
	Dictionary           *Dictionary
	CodeBuf              []Instr
	AsmInstrs            []AsmInstr
	Globals              map[string]bool
	Labels               map[string]int
	Section              string
	UserSpecifiedSection bool
}

func DefaultEnvironment() *Environment {
	return &Environment{
		Dictionary: DefaultDictionary(),
		Globals:    map[string]bool{},
		Labels:     map[string]int{},
	}
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

func (e *Environment) Merge(e2 *Environment) {
	e.CodeBuf = append(e.CodeBuf, e2.CodeBuf...)

	for _, val := range e2.Dictionary.Words {
		word := val.(*Word)
		e.AppendWord(word)
	}

	// TODO this could be unsafe
	for name, count := range e2.Labels {
		e.Labels[name] = count
	}
}

func (e *Environment) AsmLabelForWordNamed(name string) string {
	val := e.Dictionary.Words[name]
	word := val.(*Word)

	return word.AsmLabel
}

func (e *Environment) AsmLabelForName(name string) string {
	if e.Globals[name] {
		return name
	}

	prevCount := e.Labels[name]

	hasher := fnv.New32a()
	hasher.Write([]byte(name))
	hash := hasher.Sum32()

	label := fmt.Sprintf("__blue_%d_%d", hash, prevCount)
	e.Labels[name] = prevCount + 1

	return label
}

func (e *Environment) AppendWord(word *Word) {
	label := word.Name

	if !word.IsExtern() {
		label = e.AsmLabelForName(word.Name)
	}

	word.AsmLabel = label
	e.Dictionary.Append(word)
}

func (e *Environment) ValidateRegisterRefs(refs []*RegisterRef) {
	for _, r := range refs {
		if _, found := registers[r.Reg]; !found {
			log.Fatalf("Unable to map '%s' to register '%s': ", r.Name, r.Reg)
		}
	}
}

func (e *Environment) DeclWord(word *Word) {
	if !word.HasCompleteRefs() {
		InferRegisterRefs(word)
	}

	e.ValidateRegisterRefs(word.Inputs)
	e.ValidateRegisterRefs(word.Outputs)

	e.AppendWord(word)
	e.AppendCodeBufInstrs([]Instr{
		&CommentInstr{Comment: word.DeclString()},
		&DeclWordInstr{Word: word},
	})
}

func (e *Environment) LTrimBuf() {
	e.InputBuf = strings.TrimLeft(e.InputBuf, " \t\n")
}

func (e *Environment) ReadNextWord() string {
	e.LTrimBuf()
	buf := e.InputBuf
	wordEnd := strings.IndexAny(buf, " \t\n")

	if wordEnd == -1 {
		wordEnd = len(buf)
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
		return []Instr{
			&FlowWordInstr{Word: word},
			&CallWordInstr{Word: word},
		}
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
	var clobbers uint
	shouldOptimize := false

	if word := e.Dictionary.Find(name); word != nil {
		if (!e.Compiling || word.IsImmediate()) && !word.IsInline() {
			context := &RunContext{}

			for _, instr := range word.Code {
				instr.Run(e, context)
			}

			return true
		}

		clobbers = word.Clobbers
		instrs = instrsForWord(word)
	} else if _, found := x8664Lowerers[name]; found {
		instrs = []Instr{&X8664Instr{Mnemonic: name}}
		shouldOptimize = true
	} else if i, err := strconv.ParseInt(name, 0, 0); err == nil {
		instrs = []Instr{&LiteralIntInstr{I: int(i)}}
	}

	if len(instrs) == 0 {
		log.Fatal("Did not find ", name)
	}

	e.AppendInstrs(instrs)

	if !e.Compiling {
		if shouldOptimize {
			e.OptimizeInstrs()
		}
	} else {
		if !e.Dictionary.Latest.IsNoReturn() {
			clobbers &= ^e.Dictionary.Latest.Registers
			e.Dictionary.Latest.Clobbers |= clobbers
		}
	}

	return true
}

func (c *Environment) AppendAsmInstr(i AsmInstr) {
	c.AsmInstrs = append(c.AsmInstrs, i)
}

func (c *Environment) AppendAsmInstrs(i []AsmInstr) {
	if len(i) > 0 {
		c.AsmInstrs = append(c.AsmInstrs, i...)
	}
}

func (e *Environment) PopAsmInstr() AsmInstr {
	last := len(e.AsmInstrs) - 1
	instr := e.AsmInstrs[last]
	e.AsmInstrs = e.AsmInstrs[:last]

	return instr
}

func (e *Environment) AppendCodeBufInstr(i Instr) {
	e.CodeBuf = append(e.CodeBuf, i)
}

func (e *Environment) AppendCodeBufInstrs(i []Instr) {
	e.CodeBuf = append(e.CodeBuf, i...)
}

func (e *Environment) AppendInstr(i Instr) {
	if e.Compiling {
		e.Dictionary.Latest.AppendInstr(i)
	} else {
		e.CodeBuf = append(e.CodeBuf, i)
	}
}

func (e *Environment) AppendInstrs(i []Instr) {
	if e.Compiling {
		e.Dictionary.Latest.AppendInstrs(i)
	} else {
		e.CodeBuf = append(e.CodeBuf, i...)
	}
}

func (e *Environment) OptimizeInstrs() {
	e.CodeBuf = PerformPeepholeOptimizationsAtEnd(e.CodeBuf)
}

func (e *Environment) PopInstr() Instr {
	last := len(e.CodeBuf) - 1
	instr := e.CodeBuf[last]
	e.CodeBuf = e.CodeBuf[:last]

	return instr
}

func (e *Environment) Pop2Instrs() (Instr, Instr) {
	codeBufLen := len(e.CodeBuf)
	second := e.CodeBuf[codeBufLen-2]
	first := e.CodeBuf[codeBufLen-1]

	e.CodeBuf = e.CodeBuf[:codeBufLen-2]

	return second, first
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

	e.AppendCodeBufInstr(&SectionInstr{Info: section})
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
