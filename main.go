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

type RegisterRef struct {
	Name string
	Reg  string
}

type Word struct {
	Name    string
	Inputs  []*RegisterRef
	Outputs []*RegisterRef
	Code    []Instr
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
		},
	}
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
	word, buf := Split2(buf, " ")
	e.InputBuf = buf

	return word
}

func (e *Environment) ParseNextWord() {
	name := e.ReadNextWord()
	if len(name) == 0 {
		return
	}

	if word := e.Dictionary.Find(name); word != nil {
		for _, instr := range word.Code {
			if e.Compiling {
				log.Fatal("TODO: Compile Instr")
			} else {
				instr.Run(e)
			}
		}
		return
	}

	// TODO push number to stack

}

func main() {
	env := NewEnvironmentForFile("blue/sys.blue")
	env.ParseNextWord()

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
	if env.Compiling {
		log.Fatal(": expects interpretation mode")
	}

	env.Compiling = true

	name := env.ReadNextWord()
	if len(name) == 0 {
		log.Fatal(": expects a name")
	}

	word := NewWord(name)

	fmt.Println("KERNEL_COLON", word.Name)
}
