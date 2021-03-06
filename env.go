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
	Inputs        []*StackRef
	Outputs       []*StackRef
	ClobberGuards []string
}

func (c *RunContext) AppendInput(i *StackRef) {
	c.Inputs = append(c.Inputs, i)
}

func (c *RunContext) AppendInputs(i []*StackRef) {
	c.Inputs = append(c.Inputs, i...)
}

func (c *RunContext) Peek() *StackRef {
	return c.Inputs[len(c.Inputs)-1]
}

func (c *RunContext) PopInput() *StackRef {
	lastIdx := len(c.Inputs) - 1
	input := c.Inputs[lastIdx]
	c.Inputs = c.Inputs[:lastIdx]

	return input
}

func (c *RunContext) Pop2Inputs() (*StackRef, *StackRef) {
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
	RefSizes             map[string]string
}

func DefaultEnvironment() *Environment {
	return &Environment{
		Dictionary: DefaultDictionary(),
		Globals:    map[string]bool{},
		Labels:     map[string]int{},
		RefSizes:   map[string]string{},
	}
}

func (e *Environment) Sandbox() *Environment {
	return &Environment{
		Dictionary: e.Dictionary,
		Globals:    e.Globals,
		Labels:     e.Labels,
		RefSizes:   e.RefSizes,
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

func (e *Environment) ParseFile(filename string) {
	bytes, err := ioutil.ReadFile(filename)
	if err != nil {
		log.Fatal(err)
	}

	currentInputBuf := e.InputBuf
	e.InputBuf = string(bytes)

	for e.ParseNextWord() {
	}

	e.Validate()
	e.InputBuf = currentInputBuf
}

func (e *Environment) Merge(e2 *Environment) {
	e.CodeBuf = append(e.CodeBuf, e2.CodeBuf...)

	for _, word := range e2.Dictionary.Words {
		e.AppendWord(word)
	}

	// TODO this could be unsafe
	for name, count := range e2.Labels {
		e.Labels[name] = count
	}
}

func (e *Environment) AsmLabelForWordNamed(name string) string {
	word := e.Dictionary.Words[name]

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

func (e *Environment) AppendRefSize(label string, size string) {
	switch size {
	case "b":
		e.RefSizes[label] = "byte"
	case "d":
		e.RefSizes[label] = "dword"
	case "q":
		e.RefSizes[label] = "qword"
	default:
		log.Fatal("Unexpected size: ", size)
	}
}

func (e *Environment) ValidateStackRefs(refs []*StackRef) {
	for _, r := range refs {
		if _, found := registers[r.Ref]; !found {
			log.Fatalf("Unable to map '%s' to register '%s': ", r.Name, r.Ref)
		}
	}
}

func (e *Environment) DeclWord(word *Word) {
	if !word.HasCompleteRefs() {
		InferStackRefs(e, word)
	}

	e.ValidateStackRefs(word.Inputs)
	e.ValidateStackRefs(word.Outputs)

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
	var instrs []Instr

	if word.HasStackRefs() {
		instrs = append(instrs, &FlowWordInstr{Word: word})
	}

	if !word.IsInline() {
		instrs = append(instrs, &CallWordInstr{Word: word})
	} else {
		// TODO inline handling should be moved when whole word optimizations land
		lastIdx := len(word.Code)
		if _, isRet := word.Code[lastIdx-1].(*RetInstr); isRet {
			lastIdx -= 1
		}

		instrs = append(instrs, word.Code[:lastIdx]...)
	}

	return instrs
}

func (e *Environment) ParseNextWord() bool {
	name := e.ReadNextWord()
	if len(name) == 0 {
		return false
	}

	var instrs []Instr
	var clobbers uint
	var indirectRegisters uint
	shouldOptimize := false

	if word := e.Dictionary.Find(name); word != nil {
		// TODO this IsInline check isn't quite right
		// eg: rot doesn't run when not compiling
		// ---
		// inline is here working around the fact that we start a new
		// run context to execute words. A word like rot expects 3
		// inputs at runtime, but in the case of not compiling the
		// previous inputs are LiteralIntInstr on the code buf.
		// since these types of words do not currently declare their
		// inputs/outputs we can't convert codebuf->stackrefs
		if (!e.Compiling || word.IsImmediate()) && !word.IsInline() {
			context := &RunContext{}

			for _, instr := range word.Code {
				instr.Run(e, context)
			}

			return true
		}

		clobbers = word.Clobbers
		indirectRegisters = word.Registers
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

	if shouldOptimize {
		// TODO this should be done once when the word has finished compiling
		// and cover more cases than just asm instructions (move leading string
		// before word, etc). Need to consider how this interacts with computing
		// the flow between words
		// ---
		// this is also working around the same issue described above. We can't
		// properly interpret things like 1 2 or, so instead rely on the
		// optimizer after each instruction which isn't good
		e.OptimizeInstrs()
	}

	if e.Compiling {
		e.Dictionary.Latest.Clobbers |= UpdatedClobbers(clobbers,
			e.Dictionary.Latest.Registers,
			indirectRegisters)
	}

	return true
}

func (e *Environment) AppendAsmInstr(i AsmInstr) {
	e.AsmInstrs = append(e.AsmInstrs, i)
}

func (e *Environment) AppendAsmInstrs(i []AsmInstr) {
	if len(i) > 0 {
		e.AsmInstrs = append(e.AsmInstrs, i...)
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
	if e.Compiling {
		latest := e.Dictionary.Latest
		latest.Code = PerformPeepholeOptimizationsAtEnd(latest.Code)
	} else {
		e.CodeBuf = PerformPeepholeOptimizationsAtEnd(e.CodeBuf)
	}
}

func (e *Environment) PopCodeBufInstr() Instr {
	last := len(e.CodeBuf) - 1
	instr := e.CodeBuf[last]
	e.CodeBuf = e.CodeBuf[:last]

	return instr
}

func (e *Environment) PopInstr() Instr {
	if e.Compiling {
		return e.Dictionary.Latest.PopInstr()
	}

	return e.PopCodeBufInstr()
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
