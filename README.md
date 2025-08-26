# Blue

Blue is a single-pass bytecode interpreter for a [colorForth](https://colorforth.github.io/index.html) dialect.
Unlike the traditional `colorForth` system, Blue is a single shot application with a sole focus on generating
output, which is typically an artisanal binary. Its simplistic nature makes it hard to describe, but think of an
assembler with no target architecture, output format or separate macro syntax where any label can be called at
assemble time or used as a macro. This is why I think of Blue as a
`colorForth`/[fasmg](https://flatassembler.net/docs.php?article=fasmg) love child.

Blue aims to:

1. Have a reasonably small, simplistic and hackable codebase
1. Be something that a single human can completely understand
1. Help create minimalistic handcrafted applications
1. Bring some fun back into the world

This is the reference implementation for x86_64 GNU/Linux.

## Fair Warning

It is important to realize that using Blue is agreeing to step into a world of brutal simplicity and minimalism.
There are zero guardrails. You will not get an error message let alone a helpful one. Segfaults will happen and
debugging often means taking a walk to think about what you've done wrong. Hand jitting some machine code will be
required to do anything non trivial. You will be responsible for and will understand the role of every byte that
lands in the output.

## Fair Warning, Illustrated

When using Blue you will start with virtually nothing and craft exactly what you need, brick by brick. With a 
small number of definitions your code quickly goes from low to high level. As an example:

<img src="./fairwarning.svg">

> The astute reader will realize that the red `eax` is not used and the red `eax!` can be factored out to
> something like `mov/ri4` that is `B8 + b, d, ;`. Then `eax!` becomes `eax mov/ri4`. This is how factoring
> works. Building up a vocabulary to desribe and solve the problem at hand is a common theme with Blue and
> other [concatenative languages](https://en.wikipedia.org/wiki/Concatenative_programming_language).

This example is essentially the same as when you assemble:

```
bye:
	xor	edi, edi
exit:
	mov	eax, 60
	syscall

call	bye	; except this is run at assemble time
```

## Color Tags and Opcodes

One of the core parts of the `colorForth` bytecode structure is the color tag. This shifts state that used to be 
managed by the interpreter into the bytecode itself. Words like `immediate`, `postpone`, `]` and `[` are no 
longer needed. Instead each number and word has an associated color tag that tells the bytecode interpreter 
how to proceed. This results in a massive simplification of both application and interpreter code. Because of 
this, it is important to realize that the colors are more than just visual.

### Color Tags

| Color Tag | Type | Description |
|----|----|----|
| Red | Word | Creates a new word in the dictionary using the next 8 bytes as the name |
| Green | Word | Compile a call to the word named in the next 8 bytes into the output |
| Green | Number | Copy the next 8 bytes into the output |
| Yellow | Word | At assemble time, call the word named in the next 8 bytes |
| Yellow | Number | Push the next 8 bytes on the data stack |
| Cyan | Word | Macro expand the word named in the next 8 bytes |
| Magenta | Word | Push the assemble time address of the word named in the next 8 bytes on the data stack |
| White | Word | Push the run time address of the word named in the next 8 bytes on the data stack |

### Opcodes

In addition to color tags, `Blue` also has a small set of opcodes to instruct the bytecode interpreter. These 
opcodes have a visual representation but are not words defined in the dictionary and therefore have no color tag.

Opcode numbers are defined in `bc.inc` and are subject to change.

| Visual | Description |
|----|----|
| `fin` | Signals that bytecode is finished and output should be written to stdout |
| `;` | Mark the end of a word definition, compiles a `ret` or performs tail call optimization if following a green word |
| `dup` | Duplicate the top item on the data stack |
| `+` | Pop two data stack items, add them and push the result |
| `-` | Pop two data stack items, subtract them and push the result |
| `\|` | Pop two data stack items, logical or them and push the result |
| `<<` | Pop two data stack items, shift the second left the number of times in the first and push the result |
| `$` | Push assemble time address of the current location in the output buffer |
| `$*` | Push run time address of the current location in the output buffer |
| `$>` | Push assemble time address of the output buffer's start |
| `$>!` | Set assemble time address of the output buffer's start |
| `!` | Pop two data stack items, store the first in the address specified by the second |
| `@` | Replace the top of stack with the value stored at the specified address |
| `b,` | Pop the top of the data stack and compile a byte into the output |
| `w,` | Pop the top of the data stack and compile a word into the output |
| `d,` | Pop the top of the data stack and compile a dword into the output |
| `,` | Pop the top of the data stack and compile a qword into the output |
| `\n` | Ignored by the interpreter, display a newline when printing bytecode |

## On Colors

By default Blue bytecode is visualized using colors (like `colorForth`) and styles, adding another dimension by
which information can be relayed to the reader. There is no requirement to use these colors or any colors at all.

You can easily write a bytecode viewer that uses any means desired to display the bytecode. In the example
above, the yellow `bye` means that word is to be called at assemble time. If yellow is not agreeable, make it pink
or underlined, or display it as `@bye`. If you like reading verbose code, display it as `callAtAssembleTime(bye)`.
In the same vein, the visual representation of the opcodes can also be changed. if `@` is too terse, simply have 
your bytecode viewer display `fetch`.

Thanks to [input from a kind reddit user](https://www.reddit.com/r/Forth/comments/1mwsgga/comment/na80bqc/)
Blue also ships with a non color based viewer (./bin/bnc) that uses prefixes instead. Using this viewer the example
above looks like:

```
:eax #00 ; :edi #07 ; 
:/0 #C0 or ; :/r #03 << | ~/0 ; 
:xor #31 b, ~/r b, ; :syscall #050F w, ; 

:!0 dup ~xor ; :eax! #B8 b, d, ; 
:bye ~edi ~!0 :exit #3C ~eax! ~syscall ; 

#bye
```

The color tag to prefix mapping used by `./bin/bnc` is:

| Color Tag | Prefix |
|----|----|
| Red | `:` |
| Green | No prefix |
| Yellow | `#` |
| Cyan | `~` |
| Magenta | `@` |
| White | `&` |

Opcodes have no prefix and show their default visual representation.

## Forth Data Structures

Blue has a `dictionary` that can hold up to 256 entries. Each entry associates the address of the current location 
for the input and output buffers at the time the word is defined. If the word is used as a macro its location in 
the input buffer is used, if the word is called its location in the output buffer is used. The dictionary only 
exists at assemble time.

The `data stack` used by Blue is a circular buffer with a capacity for 16 elements. If this is limiting I would
argue that you are doing something wrong. I have yet to use more than 3 elements in concert at a given time. The
wrapping stack is very freeing, you don't have to worry about `drop`s as much or over/underflows. This is
especially relevant when defining macros.

The `return stack` is `rsp`. Like the dictionary the stacks only exist at assemble time.

## Building

Install [fasm v1](https://flatassembler.net/) then run `make` or `make -s -j 8`. Once finished `./bin/blue` will be
available along with bytecode files in `./obj`. `./bin/btv` can be used to view any file in `./obj` that is passed
via stdin. `./bin/examples` contains example binaries built with Blue.

It is worth poking around in the `bin` directories and noting the size of the binaries.

## Running

Blue will interpret up to 8192 bytes of bytecode from stdin. When finished it will write up to 8192 bytes of your
output to stdout.

## Working With Blue Bytecode

By convention Blue bytecode files have a `.b` extension. A `.bo` file indicates partial bytecode that is meant to
be joined into a complete `.b` file. This "linking" step is typically done with `cat`. Breaking code out into
separate `.bo` files aids in code reuse and can speed up build times when `make -j 8` or similar is run. The
`Makefile` shows how bytecode is built/combined and intepreted to build standalone binaries.

Currently there is no bytecode editor like you would see in a traditional `colorForth` system. I am using `fasm`
to build `.bo` files from `.bo.asm` files. This is likely to change at some point, or I may just write some macros
to make this less tedious. 

`make` will also build two bytecode viewers:

`./bin/btv`: Blue Terminal Vieiwer prints the bytecode using colors.

`./bin/bnc`: Blue No Color will print the bytecode using prefixes instead of colors.

`btv` and `bnc` are complete binaries written in Blue.

To view byteocde pass a file via stdin. For example to see the words that are called when a given opcode needs to
be displayed: `./bin/btv < obj/lib/bc/view/ops.bo`. Looking at the various bytecode files in `obj` and how they
are pieced together in the `Makefile` to create executables should be a good place to start exploring.

To use the non colorized version replace `./bin/btv` with `./bin/bnc`.

## Reading

Some links that may help fill in some back story/knowledge in no particular order:

1. [1x Forth](https://www.ultratechnology.com/1xforth.htm)
1. [POL](https://colorforth.github.io/POL.htm)
1. [x86 Instruction Reference](https://www.felixcloutier.com/x86/)
1. [x86-64 Registers](https://wiki.osdev.org/CPU_Registers_x86-64)

## TODOs

1. Make `$>` just push its addr, use `! @` to read/write
1. Add BC_TOR, BC_FROMR

## Blue in Blue (bib)

1. When all done
   1. Rename blue.asm to bootstrap.asm
   1. Rename bib.b to blue.b
   1. Use bin/bootstrap to build bin/blue from blue.b

### bib - After Merge

1. Factor macros (keep, set, fetch)
1. ifeq needs to r> addr of byte to set, then needs to set byte (needs b!)
   
### viewer

1. Factor hexnum more
1. That trailing space that looks like a leading space issue
