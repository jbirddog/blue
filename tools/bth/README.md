_This file is generated from README.md.tmpl_

# BlueVM Test Harness

Patched version of the BlueVM with extended opcodes to facilitate testing.

## Building

To build `bth` run `make` after `make` has been run in the root of the repo.

## Opcodes

Opcodes are subject to change and can be used in `.bla` files by including `bth.inc`.

| Opcode | Name | Stack Effect | Description |
|----|----|----|----|
| 0x80 | chkargc | ( -- ) | Exit with error unless argc is 2 |
| 0x81 | cmovd | ( d b -- ) | Compile mov b, dword |
| 0x82 | cmovq | ( q b -- ) | Compile mov b, qword |
| 0x83 | cxord | ( b -- ) | Compile xor b, b |
| 0x84 | tfd | ( -- d ) | Push fd of test input file |
| 0x85 | oblk | ( -- a ) | Push addr of TAP output's start |
| 0x86 | thr | ( -- a ) | Push addr of TAP output's here |
| 0x87 | setthr | ( a -- ) | Set addr of TAP output's here |
| 0x88 | endl | ( a -- ) | End line of output and set TAP output's here |
| 0x89 | woka | ( a -- ) | Write ok line to addr |
| 0x8A | wprep | ( -- ) | Preps the write system call |
| 0x8B | wlen | ( -- ) | Buffer length for the write system call |
| 0x8C | waddr | ( -- ) | Addr of the buffer for the write system call |
| 0x8D | sysret | ( -- ) | System call and return for mccall |
| 0x8E | test | ( w -- ) | Initialize a test suite |
| 0x8F | plan | ( w -- ) | Plan w tests where w is two ascii characters such as '03' |
| 0x90 | ok | ( -- ) | Write ok line to TAP output's here |
| 0x91 | notok | ( -- ) | Write not ok line to TAP output's here |
| 0x92 | okif | ( t/f -- ) | Ok if top of stack is true |
| 0x93 | okeq | ( a b -- ) | Ok if a and b are eq |
| 0x94 | okne | ( a b -- ) | Ok if a and b are not eq |
| 0x95 | ok0 | ( n -- ) | Ok if top of stack is 0 |
| 0x96 | okn0 | ( n -- ) | Ok if top of stack is not 0 |
| 0x97 | done | ( -- ) | Writes TAP output to stdout and exits with depth as status |

## TODOs

1. Print "TAP version 14" when testing begins
1. Split ops_low.bla into ops_pri.bla and ops_pub.bla
   1. Separate ops tables in README, etc
   1. Separate includes
