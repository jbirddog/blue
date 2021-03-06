# Blue

Compiler for the Blue Language

_Please note the language and compiler are in an early stage of development. Working programs can be compiled but rough spots, TODOs and deficiencies can easily be encountered._

Blue is a compiled low level Forth-like language that is designed for building programs without a standard library. Currently the x86-64 instruction set is supported. Example programs utilize Linux system calls but nothing in the language requires or assumes an operating system. A familarity with the x86-64 instruction set is advised and some knowledge of Forth or a similar stack based language will help.

If you are unfamilar with any of the above, some useful links:

1. [Starting Forth](https://www.forth.com/starting-forth/1-forth-stacks-dictionary)
1. [x86 Instruction Reference](https://www.felixcloutier.com/x86/index.html)
1. [x86-64 Linux System Call Table](https://filippo.io/linux-syscall-table/)
   1. [Chromium Docs x86-64 Linux System Call Table](https://chromium.googlesource.com/chromiumos/docs/+/HEAD/constants/syscalls.md#x86_64-64_bit)

## Language

The Blue Language is very Forth-like in appearance, but instead of a traditional data/return stack, stack comments and manipulation words are used to describe the flow of data into registers. Stack manipulation words run at compile time and are not included in the resulting binary. When using the Blue Language you are in direct control of memory layout/allocation and register usage. As you develop a vocabulary to describe the program at hand, Blue quickly starts to look like a traditional Forth.

The instructions and registers of the instruction set being used are exposed as words in the dictionary allowing them to be referenced like any other defined word. These instructions combined with a small number of words predefined by the compiler form the first building blocks for your program. From there the abstractions and vocabularies defined are up to the programmer. As an example, here is a short defintion for a word `fib` that computes the nth number in the Fibonacci Sequence:

```
: fib ( nth:ecx -- result:edi ) 1 0 
: compute ( times:ecx accum:eax scratch:edi -- result:edi ) xadd latest loop ;

: example ( -- ) 11 fib ;
```

In this example `fib` expects one parameter, the nth number to compute. It returns one value, the result. One main difference from Forth is these values are defined to be stored in registers instead of on the data stack. The compilation of `fib` then falls through to `compute` which makes use of the `xadd` and `loop` instructions. The stack comments are used to describe the compile time data flow stack and are used to move data into the appropriate registers for the word you are defining. The counter variables are placed in `ecx` for the use by `loop` instruction for instance. The assembly generated by the compiler for this snippet:

```
; : fib ( nth:ecx -- result:edi )

__blue_3169096246_0:
        xor edi, edi
        xor eax, eax
        inc eax

; : compute ( times:ecx accum:eax scratch:edi -- result:edi )

__blue_1147400058_0:
        xadd eax, edi
        loop __blue_1147400058_0
        ret

; : example ( -- )

__blue_2347908769_0:
        mov ecx, 11
        jmp __blue_3169096246_0
```

A more complete example is `Hello World!` for Linux x86-64. As detailed in the tutorial Blue does not link to a standard library:

```
global _start

: syscall ( num:eax -- result:eax ) syscall ;
: exit ( status:edi -- noret ) 60 syscall ;
: bye ( -- noret ) 0 exit ;

: write ( buf:esi len:edx fd:edi -- ) 1 syscall drop ;

1 const stdout

: print ( buf len -- ) stdout write ;
: greet ( -- ) s" Hello world!\n" print ;

: _start ( -- noret ) greet bye ;
```

### Code examples via a quick tutorial

A brief [tutorial is available](language/tutorial/README.md) with examples of creating simple programs that leverage Linux system calls.

## Compiler

The Blue compiler requires `go`, `nasm` and `ld`. To install read the [installation instructions](INSTALL.md)
