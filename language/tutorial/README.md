# Blue

Compiler for the Blue Language

_Please note the language and compiler are in an early stage of development. Working programs can be compiled but rough spots, TODOs and deficiencies can easily be encountered._

Blue is a compiled low level Forth-like language that is designed for building programs without a standard library. Currently the x86-64 instruction set is supported. Example programs utilize Linux system calls but nothing in the language requires or assumes an operating system. A familarity with the x86-64 instruction set is advised and some knowledge of Forth or a similar stack based language will help.

The Blue Language is very Forth-like in appearance, but instead of a traditional data/return stack, stack comments and manipulation words are used to describe the flow of data into registers. Stack manipulation words run at compile time and are not included in the resulting binary. When using the Blue Language you are in direct control of memory layout/allocation and register usage. As you develop a vocabulary to describe the program at hand, Blue quickly starts to look like a traditional Forth.

## A quick tutorial

To begin you will need the Blue compiler (unless you just want to read along). Please see the [installation instructions](../../INSTALL.md).

_Note: to build the tutorials in the repo from `./build.sh` from this directory. Binaries will be in `.build/bin`_

### Tutorial 1: `bye` executable for Linux

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
$ blue tutorial1.blue
$ nasm -f elf64 -o tutorial1.o tutorial1.asm
$ ld -o tutorial1 tutorial1.o
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
	xor edi, edi
	jmp __blue_3454868101_0

; : _start ( -- noret )

_start:
	jmp __blue_1911791459_0
```

That's it. The assembly is currently unoptimized but the basic idea is it is very close to a 1:1 mapping of the words and data flow described in the Blue program. Non `global` label names are mangled to support redefining words and words whose names are not valid nasm labels. 

### Tutorial 2: `Hello World!` executable for Linux

Now it is time to unlock one of the greatest programming achievements - printing `Hello World!` to the screen. As you recall from tutorial 1 Blue is not linked against a standard library and has no traditional `main` function. For this program we will need to define some system calls to interact with the Linux kernel, namely `exit` and `write`. Let's start with a quick program that simply exits to get started:

```
global _start

: syscall ( num:eax -- result:eax ) syscall ;
: exit ( status:edi -- noret ) 60 syscall ;
: bye ( -- noret ) 0 exit ;

: _start ( -- noret ) bye ;
```

Now we need to define a word to perform the `write` system call. The Linux kernel expects a file descriptor to write to along with a buffer of data and the number of bytes to write. The result from the kernel will be a negative value describing an error or the number of bytes written. For this program we will discard the result value and visually test the presence of characters in the terminal. For other programs this may not suffice.

```
global _start

: syscall ( num:eax -- result:eax ) syscall ;
: exit ( status:edi -- noret ) 60 syscall ;
: bye ( -- noret ) 0 exit ;

: write ( buf:esi len:edx fd:edi -- ) 1 syscall drop ;

: _start ( -- noret ) bye ;
```

`1` is the system call number for `write`, `esi`, `edx` and `edi` are the registers that the Linux kernel expects to hold the relevant data. `drop` removes the value in `eax` from the compile time data flow. It does not actually alter the value of the register at run time.

Next we need something to write:

```
global _start

: syscall ( num:eax -- result:eax ) syscall ;
: exit ( status:edi -- noret ) 60 syscall ;
: bye ( -- noret ) 0 exit ;

: write ( buf:esi len:edx fd:edi -- ) 1 syscall drop ;

: _start ( -- noret ) s" Hello world!\n" 1 write bye ;
```

`s"` reads until the next `"` and adds a byte array and length to the compile time data flow stack. `1` is the global file descriptor for `stdout`. These three parameters are then flowed into `esi`, `edx` and `edi` as needed by our `write` word. We then call `write` and exit with `bye`.

Compile and Run:

```
$ blue tutorial2.blue
$ nasm -f elf64 -o tutorial2.o tutorial2.asm
$ ld -o tutorial2 tutorial2.o
$ ./tutorial2
Hello world!
```

Working but once again not quite ideal from a readability standpoint. There are a couple hardcoded `1`s that mean different things. Let's factor some:

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

Here we define a constant for the stdout file descriptor and create a new word `print` that is a partial application of `write` - it is a call to write where the file descriptor is always `stdout`. We then defined `greet` that builds the string and prints it. `_start` simply calls the high level words. You might notice that `print` does not need to specify registers for its parameters. This is because they can be inferred since write already fully specified its registers. This is what was alluded to earlier - once you start building up a vocabulary your program starts to look more like a traditional Forth.

### Tutorial 3: `clear` executable for Linux and reuse some code

To write a `clear` clone we will need `exit` and `write` system calls so we can write a terminal escape sequence to clear the screen and return the cursor to the home position. Our `print` and `bye` higher level words will also be useful. To begin:

```
global _start

: syscall ( num:eax -- result:eax ) syscall ;
: exit ( status:edi -- noret ) 60 syscall ;
: bye ( -- noret ) 0 exit ;

: write ( buf:esi len:edx fd:edi -- ) 1 syscall drop ;

1 const stdout

: print ( buf len -- ) stdout write ;
: clear-screen ( -- ) s" \033[2J\033[H" print ;

: _start ( -- noret ) clear-screen bye ;
```

Compile and Run:

```
$ blue tutorial3.blue
$ nasm -f elf64 -o tutorial3.o tutorial3.asm
$ ld -o tutorial3 tutorial3.o
$ ./tutorial3
```

The console should be cleared. 

While Blue has no standard library that does not mean that you cannot build your own reusable vocabulary that is used in your programs. In fact you are encouraged to. Instead of creating abstractions for abstraction sake, work out the scope of your problem and factor out words. Simplify both the design and implementation and factor again. When a pattern emerges move common words into a shared location in your project.

If you have been following along the three tutorials so far we ended up having some shared words which have proven to have utility for us. We can move `syscall`, `exit`, `bye`, `write`, `stdout` and `print` to a common location and include them in our program.

Create a new file called `vocab.blue` and copy over the words we want to reuse:

```
: syscall ( num:eax -- result:eax ) syscall ;
: exit ( status:edi -- noret ) 60 syscall ;
: bye ( -- noret ) 0 exit ;

: write ( buf:esi len:edx fd:edi -- ) 1 syscall drop ;

1 const stdout

: print ( buf len -- ) stdout write ;
```

Our `clear` clone can now include `vocab` instead of redefining the words:

```
import vocab

global _start

: clear-screen ( -- ) s" \033[2J\033[H" print ;

: _start ( -- noret ) clear-screen bye ;
```

Similarly, our example from `tutorial2` could now become:

```
import vocab

global _start

: greet ( -- ) s" Hello world!\n" print ;

: _start ( -- noret ) greet bye ;
```

## From here

Feel free to play around with the language. Happy hacking.
