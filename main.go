package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"strings"
)

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
	"syscall": true,
}

type X8664Instr struct {
	Mnemonic string
}

func (i *X8664Instr) Run(env *Environment) {
	log.Fatal("Cannot run x8664 instructions")
}

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

const (
	WordFlag_Immediate = 1 << iota
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

func CallGoWord(name string, f GoCaller) *Word {
	return &Word{
		Name: name,
		Code: []Instr{&CallGoInstr{F: f}},
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
			CallGoWord(":", kernel_colon),
			CallGoWord("(", kernel_lparen).Immediate(),
			CallGoWord(";", kernel_semi).Immediate(),
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
		wordEnd = len(buf)-1
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

	if word := e.Dictionary.Find(name); word != nil {
		for _, instr := range word.Code {
			if !e.Compiling || word.IsImmediate() {
				instr.Run(e)
			} else {
				log.Fatal("TODO: Compile Instr", name)
			}
		}
		return true
	}

	if x8664Mnemonics[name] {
		instr := &X8664Instr{Mnemonic: name}

		if e.Compiling {
			e.Dictionary.Latest().PushInstr(instr)
		} else {
			instr.Run(e)
		}

		return true
	}

	fmt.Println("Did not find", name)

	// TODO push number to stack
	return false
}

func main() {
	env := NewEnvironmentForFile("blue/sys.blue")

	for env.ParseNextWord() {
	}

	fmt.Println(len(env.Dictionary.Words))
	fmt.Println(env.Dictionary.Latest().Name)
	fmt.Println(len(env.Dictionary.Latest().Inputs))
	fmt.Println(len(env.Dictionary.Latest().Outputs))
	fmt.Println(len(env.Dictionary.Latest().Code))
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

	fmt.Println("KERNEL_COLON", word.Name)
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

		if nextWord == ")" {
			break
		}

		parts := strings.SplitN(nextWord, ":", 2)
		latest.PushRegisterRef(parts[0], parts[len(parts)-1], target)
	}

	fmt.Println("KERNEL_LPAREN")
}

func kernel_semi(env *Environment) {
	env.Compiling = false

	fmt.Println("KERNEL_SEMI")
}
