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
| 0x83 | cret | ( -- ) | Compile ret |
| 0x84 | cstosd | ( -- ) | Compile stosd |
| 0x85 | csys | ( -- ) | Compile syscall |
| 0x86 | cxord | ( b -- ) | Compile xor b, b |
| 0x87 | tfd | ( -- d ) | Push fd of test input file |
| 0x88 | oblk | ( -- a ) | Push addr of TAP output's start |
| 0x89 | thr | ( -- a ) | Push addr of TAP output's here |
| 0x8A | setthr | ( a -- ) | Set addr of TAP output's here |
| 0x8B | cdstarg | ( -- ) | Compile movabs rdi, _addr of argv[1]_ |
| 0x8C | cflgsro | ( -- ) | Compile xor esi, esi (flags = READ_ONLY) |
| 0x8D | csopen | ( -- ) | Compile mov eax, 0x02 (sys_open); syscall |
| 0x8E | cdsttfd | ( -- ) | Compile movabs rdi, _addr of tfd's litd_ |
| 0x8F | cfrmtfd | ( -- ) | Compile mov edi, _tfd_ |
| 0x90 | csrctib | ( -- ) | Compile mov rsi, _addr of _test input block_ |
| 0x91 | cblklen | ( -- ) | Compile mov edx, 0x0400 |
| 0x92 | csread | ( -- ) | Compile xor eax, eax; syscall |
| 0x93 | opentst | ( -- ) | Open argv[1] and set tfd |
| 0x94 | readtst | ( -- ) | Read block from tfd into the test input block |
| 0x95 | endl | ( a -- ) | End line of output and set TAP output's here |
| 0x96 | woka | ( a -- ) | Write ok line to addr |
| 0x97 | wprep | ( -- ) | Preps the write system call |
| 0x98 | wlen | ( -- ) | Buffer length for the write system call |
| 0x99 | waddr | ( -- ) | Addr of the buffer for the write system call |
| 0x9A | test | ( w -- ) | Initialize a test suite |
| 0x9B | plan | ( w -- ) | Plan w tests where w is two ascii characters such as '03' |
| 0x9C | ok | ( -- ) | Write ok line to TAP output's here |
| 0x9D | notok | ( -- ) | Write not ok line to TAP output's here |
| 0x9E | okif | ( t/f -- ) | Ok if top of stack is true |
| 0x9F | okeq | ( a b -- ) | Ok if a and b are eq |
| 0xA0 | okne | ( a b -- ) | Ok if a and b are not eq |
| 0xA1 | ok0 | ( n -- ) | Ok if top of stack is 0 |
| 0xA2 | okn0 | ( n -- ) | Ok if top of stack is not 0 |
| 0xA3 | done | ( -- ) | Writes TAP output to stdout and exits with depth as status |

## TODOs

1. Print "TAP version 14" when testing begins
1. Split ops_low.bla into ops_pri.bla and ops_pub.bla
   1. Separate ops tables in README, etc
   1. Separate includes
1. Redo wprep, wlen, waddr to use cxord, cmovd, etc
