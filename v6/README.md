# Blue

Blue is a single-pass bytecode interpreter for a [colorForth](https://colorforth.github.io/index.html) dialect. Unlike the traditional `colorForth` system, Blue is a single shot application with a sole focus on generating output. Like any Forth, an emphasis is placed on building user defined vocabularies to describe and solve the problem at hand.

Blue aims to:

1. Have a reasonably small, simplistic and hackable codebase that a single human can completely understand
1. Help create minimalistic handcrafted applications
1. Bring some fun back into the world

This is the reference implementation for x86_64 Linux.

## Reading

Some links that may help fill in some back story/knowledge in no particular order:

1. [1x Forth](https://www.ultratechnology.com/1xforth.htm)
2. [POL](https://colorforth.github.io/POL.htm)
3. [x86 Instruction Reference](https://www.felixcloutier.com/x86/)

## Building

Blue is built using `fasm2` which is included in this repo as a submodule. To build run `make` or `make -s -j 8`. Once finished `./bin/blue` will be available along with bytecode files in `./obj`.

## Opcodes

Opcodes are described in `b.inc` and are subject to change.

## Working With Blue Bytecode

By convention Blue bytecode files have a `.b` extension. A `.bo` file indicates partial bytecode that is meant to be joined into a complete `.b` file. This "linking" step is typically done with `cat`. Breaking code out into separate `.bo` files can facilitate code reuse as well as speed up build times when `make -j 8` or similar is run.

Currently there is no bytecode editor like you would see in a traditional `colorForth` system. I am using `fasm2` to build `.bo` files from `.bo.asm` files. This is likely to change at some point, or I may just write some macros to make this less tedious. 

Running `./ed.pl file.b` or `./ed.pl file.bo` will print the bytecode in a format that is closer to what one would expect when working with a `colorForth` code file.

Running `make` will also build `./bin/btv` the Blue Terminal Viewer. Running `./bin/btv < file.b` or `./bin/btv < file.bo` will print the bytecode much like `ed.pl`. There are some TODOs for `btv` but once finished `ed.pl` will be removed. `btv` is a complete binary written in Blue.

## Running

Blue will read up to 4096 bytes of bytecode from stdin and when finished write its output to stdout.

## The Structural Dynamics of Flow

Coming Soon...

## TODOs

1. Hex display in btv
2. Add BC_SAVE, BC_RESTORE
3. Remove BC_NUM_COMP
