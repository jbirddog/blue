# Blue

Compiler for the Blue Language

_Please note the language and compiler are in an early stage of development. Working programs can be compiled but rough spots can easily be encountered._

Blue is a compiled low level Forth-like language that is designed for building minimal programs without a standard library. Currently the x86-64 instruction set is supported. Example programs utilize Linux system calls but nothing in the language requires or assumes an operating system. A familarity with the x86-64 instruction set is advised and some knowledge of Forth or a similar stack based language will help.

## Language

The Blue Language is very Forth-like in appearance, but instead of a traditional data/return stack, stack comments and manipulation words are used to describe the flow of data into registers. Stack manipulation words run at compile time and are not included in the resulting binary. When using the Blue Language you are in direct control of memory layout/allocation and register usage. As you develop a vocabulary to describe the program at hand, Blue quickly starts to look like a traditional Forth.

## Compiler

The Blue compiler requires `go`, `nasm` and `ld`. Version used for development are:

```
$ go version
go version go1.18 linux/amd64
$ nasm --version
NASM version 2.15.05
$ ld --version
GNU ld (GNU Binutils for Ubuntu) 2.37
```
