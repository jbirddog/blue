_This file is generated from README.md.tmpl_

# BlueVM Test Harness

Patched version of the BlueVM with extended opcodes to facilitate testing.

## Building

To build `bth` run `make` after `make` has been run in the root of the repo.

## Opcodes

Opcodes are subject to change and can be used in `.bla` files by including `bth.inc`.

| Opcode | Name | Stack Effect | Description |
|----|----|----|----|
| 0x80 | oblk | ( -- a ) | Push addr of TAP output's start |
| 0x81 | tfd | ( -- d ) | Push fd of test input file |
| 0x82 | thr | ( -- a ) | Push addr of TAP output's here |
| 0x83 | setthr | ( a -- ) | Set addr of TAP output's here |
| 0x84 | endl | ( a -- ) | End line of output and set TAP output's here |
| 0x85 | woka | ( a -- ) | Write ok line to addr |
| 0x86 | wprep | ( -- ) | Preps the write system call |
| 0x87 | wlen | ( -- ) | Buffer length for the write system call |
| 0x88 | waddr | ( -- ) | Addr of the buffer for the write system call |
| 0x89 | sysret | ( -- ) | System call and return for mccall |
| 0x8A | test | ( w -- ) | Initialize a test suite |
| 0x8B | plan | ( w -- ) | Plan w tests where w is two ascii characters such as '03' |
| 0x8C | ok | ( -- ) | Write ok line to TAP output's here |
| 0x8D | notok | ( -- ) | Write not ok line to TAP output's here |
| 0x8E | okif | ( t/f -- ) | Ok if top of stack is true |
| 0x8F | okeq | ( a b -- ) | Ok if a and b are eq |
| 0x90 | okne | ( a b -- ) | Ok if a and b are not eq |
| 0x91 | ok0 | ( n -- ) | Ok if top of stack is 0 |
| 0x92 | okn0 | ( n -- ) | Ok if top of stack is not 0 |
| 0x93 | done | ( -- ) | Writes TAP output to stdout and exits with depth as status |

## TODOs

1. Output plan from `done` without need to call `plan`
1. Print "TAP version 14" when testing begins
