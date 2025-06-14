_This file is generated from README.md.tmpl_

# BlueVM Test Harness

Standalone executable to run BlueVM bytecode test files and produce [TAP](https://testanything.org/) output.

## Building

Run `make` at the root of this repository to build `bth` and its dependencies (`BlueVM` and `blasm`). Once that has
been done, running `make` in this directory will build just `bth`.

## Running

`./bin/bth path/to/test/file.bs0` will execute a test file and print its TAP output.

`prove -e ./bin/bth --ext bs0 path/to/tosts` will use `prove` to run test file(s).

## BlueVM Block Usage

`bth` uses `BlueVM` block 9 for test input and block 10 for test ouput.

## Opcodes

Public opcodes that can be used in tests to produce TAP output. Test files written in `blasm` can include `tap.inc`
from this directory. For an example test file see `test/bth.bla`. The BlueVM test suite uses `bth` and contains
test files in `../../test`.

| Opcode | Name | Stack Effect | Description |
|----|----|----|----|
| 0xC0 | test | ( w -- ) | Initialize a test suite |
| 0xC1 | plan | ( w -- ) | Plan w tests where w is two ascii characters such as '03' |
| 0xC2 | ok | ( -- ) | Write ok line to TAP output's here |
| 0xC3 | notok | ( -- ) | Write not ok line to TAP output's here |
| 0xC4 | okif | ( t/f -- ) | Ok if top of stack is true |
| 0xC5 | okeq | ( a b -- ) | Ok if a and b are eq |
| 0xC6 | okne | ( a b -- ) | Ok if a and b are not eq |
| 0xC7 | ok0 | ( n -- ) | Ok if top of stack is 0 |
| 0xC8 | okn0 | ( n -- ) | Ok if top of stack is not 0 |
| 0xC9 | done | ( -- ) | Writes TAP output to stdout and exits with depth as status |

### Internal Opcodes

These internal opcodes are used by `bth` itself and should not be considered stable for external use.

| Opcode | Name | Stack Effect | Description |
|----|----|----|----|
| 0x80 | atq | ( a -- q ) | Push qword value found at addr |
| 0x81 | ifnot | ( t/f fa -- ? ) | Call fa if t/f is false |
| 0x82 | chkargc | ( -- ) | Exit with error unless argc is 2 |
| 0x83 | tfd | ( -- d ) | Push fd of test input file |
| 0x84 | oblk | ( -- a ) | Push addr of TAP output's start |
| 0x85 | thr | ( -- a ) | Push addr of TAP output's here |
| 0x86 | setthr | ( a -- ) | Set addr of TAP output's here |
| 0x87 | argv1 | ( -- a ) | Push _argv[1]_ |
| 0x88 | opentst | ( -- ) | Open argv[1] and set tfd |
| 0x89 | readtst | ( -- ) | Read block from tfd into the test input block |
| 0x8A | runtst | ( -- ) | Run the test in the test input block |
| 0x8B | endl | ( a -- ) | End line of output and set TAP output's here |
| 0x8C | woka | ( a -- ) | Write ok line to addr |
| 0x8D | tapout | ( -- ) | Write TAP output to stdout |

## TODOs

1. Print "TAP version 14" when testing begins
1. See about getting listed as a TAP producer
1. Factor out some words related to the `scall`s
