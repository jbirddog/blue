package main

/*

: syscall (( num eax -- res eax )) 0F b, 05 b, ;
: exit (( status edi -- noret )) 3C syscall ;
: bye (( -- noret )) 00 exit ;

bye

*/

type Flag uint

const (
	Anonymous Flag = 1 << iota
	Immediate
)

type Flow interface {
}

type Instruction interface {
}

type WordDecl struct {
	Flags Flag
	Ins []Flow
	Outs []Flow
	Instrs []Instruction
}
