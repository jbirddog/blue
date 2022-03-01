package main

import (
	"bufio"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"strconv"
	"strings"
)

// TODO R8D..., RAX..., R8...
const (
	eax = iota
	ecx
	edx
	ebx
	esp
	ebp
	esi
	edi
)

var registers = map[string]int{
	"eax": eax,
	"ecx": ecx,
	"edx": edx,
	"ebx": ebx,
	"esp": esp,
	"ebp": ebp,
	"esi": esi,
	"edi": edi,
}

type RegisterRef struct {
	Name string
	Reg  string
}

type Instr interface {
	Run(*Environment)
}

type GoCaller func(*Environment)

type CallGoInstr struct {
	F GoCaller
}

func (i *CallGoInstr) Run(env *Environment) {
	i.F(env)
}

var x8664Mnemonics = map[string]bool{
	"ret":     true,
	"syscall": true,
}

type X8664Instr struct {
	Mnemonic string
}

func (i *X8664Instr) Run(env *Environment) {
	log.Fatal("Cannot run x8664 instructions")
}

type LiteralIntInstr struct {
	I int
}

func (i *LiteralIntInstr) Run(env *Environment) {
	log.Fatal("Cannot run literal int instructions")
}

type CallWordInstr struct {
	Word *Word
}

func (i *CallWordInstr) Run(env *Environment) {
	log.Fatal("Cannot run call word instructions")
}

const (
	WordFlag_Immediate = 1 << iota
	WordFlag_HiddenFromAsm
)

const (
	RegisterRefTarget_Input = iota
	RegisterRefTarget_Output
)

type Word struct {
	Name    string
	Flags   uint
	Inputs  []*RegisterRef
	Outputs []*RegisterRef
	Code    []Instr
}

func (w *Word) PushInstr(instr Instr) {
	w.Code = append(w.Code, instr)
}

func (w *Word) PushRegisterRef(name, reg string, target int) {
	if _, found := registers[reg]; !found {
		log.Fatal("Unknown register", reg)
	}

	ref := &RegisterRef{Name: name, Reg: reg}

	if target == RegisterRefTarget_Input {
		w.Inputs = append(w.Inputs, ref)
	} else if target == RegisterRefTarget_Output {
		w.Outputs = append(w.Outputs, ref)
	} else {
		log.Fatal("Invalid register ref target")
	}
}

func (w *Word) Immediate() *Word {
	w.Flags |= WordFlag_Immediate
	return w
}

func (w *Word) IsImmediate() bool {
	return w.Flags&WordFlag_Immediate == WordFlag_Immediate
}

func (w *Word) IsHiddenFromAsm() bool {
	return w.Flags&WordFlag_HiddenFromAsm == WordFlag_HiddenFromAsm
}

func NewCallGoWord(name string, f GoCaller) *Word {
	return &Word{
		Name:  name,
		Flags: WordFlag_HiddenFromAsm,
		Code:  []Instr{&CallGoInstr{F: f}},
	}
}

func NewWord(name string) *Word {
	return &Word{Name: name}
}

type Dictionary struct {
	Name  string
	Words []*Word
}

func DefaultDictionary() *Dictionary {
	return &Dictionary{
		Name: "default",
		Words: []*Word{
			NewCallGoWord(":", kernel_colon),
			NewCallGoWord("(", kernel_lparen).Immediate(),
			NewCallGoWord(";", kernel_semi).Immediate(),
		},
	}
}

func (d *Dictionary) Append(word *Word) {
	d.Words = append(d.Words, word)
}

func (d *Dictionary) Find(wordName string) *Word {
	wordsLen := len(d.Words)

	for i := wordsLen - 1; i >= 0; i-- {
		if d.Words[i].Name == wordName {
			return d.Words[i]
		}
	}

	return nil
}

func (d *Dictionary) Latest() *Word {
	return d.Words[len(d.Words)-1]
}

func (d *Dictionary) WriteGlobalDeclarations(w *bufio.Writer) {
	for _, word := range d.Words {
		if word.IsHiddenFromAsm() {
			continue
		}

		fmt.Fprintf(w, "global %s\n", word.Name)
	}

	fmt.Fprint(w, "\n")
}

func (d *Dictionary) WriteWords(w *bufio.Writer) {
	for _, word := range d.Words {
		if word.IsHiddenFromAsm() {
			continue
		}

		fmt.Fprintf(w, "%s:\n", word.Name)
		fmt.Fprint(w, "\n")
	}
}

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
	file, err := os.Create(filename)
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()

	writer := bufio.NewWriter(file)
	defer writer.Flush()

	e.Dictionary.WriteGlobalDeclarations(writer)
	e.Dictionary.WriteWords(writer)
}

func main() {
	env := NewEnvironmentForFile("blue/sys.blue")

	for env.ParseNextWord() {
	}

	env.Validate()
	env.WriteAsm("blue/sys.asm")

	fmt.Println("ok")
}

func Split2(s string, delim string) (string, string) {
	parts := strings.SplitN(s, delim, 2)

	if len(parts) == 2 {
		return parts[0], parts[1]
	}

	return parts[0], ""
}

func kernel_colon(env *Environment) {
	env.Compiling = true

	name := env.ReadNextWord()
	if len(name) == 0 {
		log.Fatal(": expects a name")
	}

	word := NewWord(name)
	env.Dictionary.Append(word)
}

func kernel_lparen(env *Environment) {
	target := RegisterRefTarget_Input
	latest := env.Dictionary.Latest()

	for {
		nextWord := env.ReadNextWord()
		if len(nextWord) == 0 {
			log.Fatal("( unexpected eof")
		}

		if nextWord == "--" {
			target = RegisterRefTarget_Output
			continue
		}

		if nextWord == "noret" {
			// TODO need to surface
			continue
		}

		if nextWord == ")" {
			break
		}

		parts := strings.SplitN(nextWord, ":", 2)
		latest.PushRegisterRef(parts[0], parts[len(parts)-1], target)
	}
}

func kernel_semi(env *Environment) {
	env.Compiling = false
	instr := &X8664Instr{Mnemonic: "ret"}
	latest := env.Dictionary.Latest()

	latest.PushInstr(instr)
}
