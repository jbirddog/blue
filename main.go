package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"strings"
)

type Instr interface {
	Compile(*Environment)
	Interpret(*Environment)
}

type GoCaller func(*Environment)

type CallGoInstr struct {
	F GoCaller
}

func (i *CallGoInstr) Compile(env *Environment) {
	log.Fatal("TODO: compile call go instr")
}

func (i *CallGoInstr) Interpret(env *Environment) {
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

type Environment struct {
	Compiling  bool
	Dictionary *Dictionary
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

func main() {
	env := NewEnvironmentForFile("blue/sys.blue")

	fmt.Println(env.ReadNextWord())
	fmt.Println(env.ReadNextWord())
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
	fmt.Println("KERNEL_COLON")
}
