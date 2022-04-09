# Blue

Compiler for the Blue Language

_Please note the language and compiler are in an early stage of development. Working programs can be compiled but rough spots can easily be encountered._

Blue is a compiled low level Forth-like language that is designed for building minimal programs without a standard library. Currently the x86-64 instruction set is supported. Example programs utilize Linux system calls but nothing in the language requires or assumes an operating system. A familarity with the x86-64 instruction set is advised and some knowledge of Forth or a similar stack based language will help.

## Language

The Blue Language is very Forth-like in appearance, but instead of a traditional data/return stack, stack comments and manipulation words are used to describe the flow of data into registers. Stack manipulation words run at compile time and are not included in the resulting binary. When using the Blue Language you are in direct control of memory layout/allocation and register usage. As you develop a vocabulary to describe the program at hand, Blue quickly starts to look like a traditional Forth.

### Code examples via a quick tutorial

_Note: code can be found in `languages/tutorial`._

#### Tutorial 1: `bye` executable for Linux

For an introduction to Blue we will start by creating an executable to run on Linux which will simply exit. Since this program does not link against a standard library there is no main. A global `_start` word needs to be defined which will be the entry point to your program:

```
global _start

: _start ( -- ) ;
```
We will get into the syntax more throughout the tutorial but if you are familar with Forth this works as expected. `:` begins compilation of a new word (think function if not familar), in this case named `_start`. `(` begins a stack comment which describes the expected inputs. `--` begins the description of the outputs. `;` ends compilation and makes the word visible in the dictionary.

By itself this is not a useful program - in fact it won't even execute properly. On Linux an executable needs to call the `exit` system call to properly exit the process. To do this first we create a word that describes how to tell the Linux kernel which system call we want to execute. This is done by placing a known number in `eax` and issuing a `x86-64` `syscall` instruction. When complete the kernel will set the result in `eax`. We will redefine `syscall` to have this behavior:

```
: syscall ( num:eax -- result:eax ) syscall ;
```

_Here we see our first real departure from a traditional Forth. The stack comments are required and specify the register that is expected to hold the data. More on this as the tutorial progresses._

Next we can call our new version of `syscall` to tell the Linux kernel we are ready to exit (via system call #60):

```
global _start

: syscall ( num:eax -- result:eax ) syscall ;

: _start ( -- noret ) 60 syscall ;
```

Compile:

```
blue tutorial1.blue
nasm -f elf64 -o tutorial1.o tutorial1.asm
ld -o tutorial1 tutorial1.o
```

Run and check the exit code:

```
$ ./tutorial1 
$ echo $?
0
```

This works but is not ideal. It relies on the fact that the `edi` register is zeroed out when the process starts. The `exit` system call takes an argument to specify the return code which we should be setting explicitly. Also from a readability standpoint, one month/year later, wtf does `60 syscall` mean? Let's factor some:

```
global _start

: syscall ( num:eax -- result:eax ) syscall ;
: exit ( status:edi -- noret ) 60 syscall ;

: _start ( -- noret ) 0 exit ;
```

`0 exit` reads better. `exit` self documents what `60 syscall` means. `noret` specifies that `exit` does not return when called. For a nod to Forth we can add one more word:

```
global _start

: syscall ( num:eax -- result:eax ) syscall ;
: exit ( status:edi -- noret ) 60 syscall ;
: bye ( -- noret ) 0 exit ;

: _start ( -- noret ) bye ;
```

Compile, run and verify the exit code if desired.

To wrap up the first tutorial let's take a look at the assembly generated by the Blue compiler:

```
global _start

; : syscall ( num:eax -- result:eax )
__blue_4057121178_0: 
        syscall
        ret

; : exit ( status:edi -- noret )
__blue_3454868101_0:
        mov eax, 60
        call __blue_4057121178_0

; : bye ( -- noret )
__blue_1911791459_0:
        mov edi, 0
        call __blue_3454868101_0

; : _start ( -- noret )
_start:
        call __blue_1911791459_0
```

That's it. The assembly is currently unoptimized but the basic idea is it is very close to a 1:1 mapping of the words and data flow described in the Blue program. Non `global` label names are mangled to support redefining words and words whose names are not valid nasm labels. 

#### Tutorial 2: `Hello World!` executable for Linux

Now it is time to unlock one of the greatest programming achievements - printing `Hello World!` to the screen. As you recall from tutorial 1 Blue is not linked against a standard library and has no traditional `main` function. For this program we will need to define some system calls to interact with the Linux kernel, namely `exit` and `write`. Let's start with a quick program that simply exits to get started:

```
global _start

: syscall ( num:eax -- result:eax ) syscall ;
: exit ( status:edi -- noret ) 60 syscall ;
: bye ( -- noret ) 0 exit ;

: _start ( -- noret ) bye ;
```

Compile:

```
blue tutorial2.blue
nasm -f elf64 -o tutorial2.o tutorial2.asm
ld -o tutorial2 tutorial2.o
```

Run:

```
$ ./tutorial2
```

Now we need to define a word to perform the `write` system call. The Linux kernel expects a file descriptor to write to along with a buffer of data and the number of bytes to write. Upon completion the result will be a negative values describing an error or the number of bytes written. For this program will we discard the result value and manually test the presence of characters in the terminal. For other programs this may not suffice.

```
: write ( buf:esi len:edx fd:edi -- ) 1 syscall drop ;
```

`1` is the system call number for `write`, `esi`, `edx` and `edi` are the registers that the Linux kernel expects to hold the relevant data. `drop` removes the value in `eax` from the compile time data flow. It does not actually alter the value of the register at run time.

While Blue has no standard library that does not mean that you cannot build your own reusable vocabulary that is used in your programs. In fact you are encouraged to. Instead of creating abstractions for abstraction sake, work out the scope of your problem and factor out words. When a pattern emerges move them into a shared location in your project.

## Compiler

To build run `./build` in the repo root. The build script will compile, test and install the Blue compiler then build all language examples.

The Blue compiler requires `go`, `nasm` and `ld`. Versions used for development are:

```
$ go version
go version go1.18 linux/amd64
$ nasm --version
NASM version 2.15.05
$ ld --version
GNU ld (GNU Binutils for Ubuntu) 2.37
```
