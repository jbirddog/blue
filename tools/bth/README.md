_This file is generated from README.md.tmpl_

# BlueVM Test Harness

Patched version of the BlueVM with extended opcodes to facilitate testing.

## Building

To build `bth` run `make` after `make` has been run in the root of the repo.

## Opcodes

Opcodes are subject to change and can be used in `.bla` files by including `bth.inc`.

| Opcode | Name | Stack Effect | Description |
|----|----|----|----|
| 0x80 | ifnot | ( t/f fa -- ? ) | Call fa if t/f is false |
| 0x81 | chkargc | ( -- ) | Exit with error unless argc is 2 |
| 0x82 | cmovd | ( d b -- ) | Compile mov b, dword |
| 0x83 | cmovq | ( q b -- ) | Compile mov b, qword |
| 0x84 | cret | ( -- ) | Compile ret |
| 0x85 | cstosd | ( -- ) | Compile stosd |
| 0x86 | csys | ( -- ) | Compile syscall |
| 0x87 | cxord | ( b -- ) | Compile xor b, b |
| 0x88 | tfd | ( -- d ) | Push fd of test input file |
| 0x89 | oblk | ( -- a ) | Push addr of TAP output's start |
| 0x8A | thr | ( -- a ) | Push addr of TAP output's here |
| 0x8B | setthr | ( a -- ) | Set addr of TAP output's here |
| 0x8C | cdstarg | ( -- ) | Compile movabs rdi, _addr of argv[1]_ |
| 0x8D | cflgsro | ( -- ) | Compile xor esi, esi (flags = READ_ONLY) |
| 0x8E | csopen | ( -- ) | Compile mov eax, 0x02 (sys_open); syscall |
| 0x8F | cdsttfd | ( -- ) | Compile movabs rdi, _addr of tfd's litd_ |
| 0x90 | cfrmtfd | ( -- ) | Compile mov edi, _tfd_ |
| 0x91 | csrctib | ( -- ) | Compile mov rsi, _addr of _test input block_ |
| 0x92 | cblklen | ( -- ) | Compile mov edx, 0x0400 |
| 0x93 | csread | ( -- ) | Compile xor eax, eax; syscall |
| 0x94 | opentst | ( -- ) | Open argv[1] and set tfd |
| 0x95 | readtst | ( -- ) | Read block from tfd into the test input block |
| 0x96 | runtst | ( -- ) | Run the test in the test input block |
| 0x97 | endl | ( a -- ) | End line of output and set TAP output's here |
| 0x98 | woka | ( a -- ) | Write ok line to addr |
| 0x99 | wprep | ( -- ) | Preps the write system call |
| 0x9A | wlen | ( -- ) | Buffer length for the write system call |
| 0x9B | waddr | ( -- ) | Addr of the buffer for the write system call |
| 0x9C | test | ( w -- ) | Initialize a test suite |
| 0x9D | plan | ( w -- ) | Plan w tests where w is two ascii characters such as '03' |
| 0x9E | ok | ( -- ) | Write ok line to TAP output's here |
| 0x9F | notok | ( -- ) | Write not ok line to TAP output's here |
| 0xA0 | okif | ( t/f -- ) | Ok if top of stack is true |
| 0xA1 | okeq | ( a b -- ) | Ok if a and b are eq |
| 0xA2 | okne | ( a b -- ) | Ok if a and b are not eq |
| 0xA3 | ok0 | ( n -- ) | Ok if top of stack is 0 |
| 0xA4 | okn0 | ( n -- ) | Ok if top of stack is not 0 |
| 0xA5 | done | ( -- ) | Writes TAP output to stdout and exits with depth as status |

## TODOs

1. Print "TAP version 14" when testing begins
1. Split ops_low.bla into ops_pri.bla and ops_pub.bla
   1. Separate ops tables in README, etc
   1. Separate includes
1. Redo wprep, wlen, waddr to use cxord, cmovd, etc
