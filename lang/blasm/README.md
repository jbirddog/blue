_This file is generated from README.md.tmpl_

# BlueVM Assembler

Block file assembler for the BlueVM powered by `fasmg`.

By convention, files processed by `blasm` have a `.bla` extension. These files are assembled into BlueVM block
files `.bs0`. Once assembled a block file can either be sent to the BlueVM via stdin or spliced into its input
buffer block.

A `fasmg`/`fasm2` include file `blasm.inc` is generated based on the BlueVM opcode table. An example of extending
`blasm` for use with custom opcodes can be found in `tools/bth` from the root of the repo.

The `examples` directory contains example `.bla` files. The core BlueVM test files are also written in `blasm`.

## Building

To build `blasm` run `make` after `make` has been run in the root of the repo.

## TODOs

1. Add `blasm2` for `.bla2` files that uses `fasm2` for mixed x8664 and blasm
