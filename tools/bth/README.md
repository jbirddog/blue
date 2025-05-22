_This file is generated from README.md.tmpl_

# BlueVM Test Harness

Patched version of the BlueVM with extended opcodes to facilitate testing.

## Building

To build `bth` run `make` after `make` has been run in the root of the repo.

## Opcodes

Opcodes are subject to change and can be used in `.bla` files by including `bth.inc`.

| Opcode | Name | Stack Effect | Description |
|----|----|----|----|
| 0x80 | tst | ( -- a ) | Push addr of TAP output's start |
| 0x81 | thr | ( -- a ) | Push addr of TAP output's here |
| 0x82 | thrM | ( -- a ) | Push addr of TAP output's here modification point |
| 0x83 | setthr | ( a -- ) | Set addr of TAP output's here |
| 0x84 | endl | ( a -- ) | End line of output and set TAP output's here |
| 0x85 | test | ( w -- ) | Initialize a test suite |
| 0x86 | plan | ( w -- ) | Plan w tests where w is two ascii characters such as '03' |
| 0x87 | wokA | ( a -- ) | Write ok line to addr |
| 0x88 | wok | ( -- ) | Write ok line to TAP output's here |
| 0x89 | notok | ( -- ) | Write not ok line to TAP output's here |
| 0x8A | ok | ( t/f -- ) | Ok if top of stack is true |
| 0x8B | okeq | ( a b -- ) | Ok if a and b are eq |
| 0x8C | okne | ( a b -- ) | Ok if a and b are not eq |
| 0x8D | wprep | ( -- ) | Preps the write system call |
| 0x8E | wlen | ( -- ) | Buffer length for the write system call |
| 0x8F | waddr | ( -- ) | Addr of the buffer for the write system call |
| 0x90 | sysret | ( -- ) | System call and return for mccall |
| 0x91 | done | ( -- ) | Writes TAP output to stdout and exits with depth as status |

## TODOs

1. Replace need for shim.sh to produce TAP output
1. Output plan from `done` without need to call `plan`
1. Print "TAP version 14" when testing begins
