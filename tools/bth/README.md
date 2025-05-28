_This file is generated from README.md.tmpl_

# BlueVM Test Harness

Patched version of the BlueVM with extended opcodes to facilitate testing.

## Building

To build `bth` run `make` after `make` has been run in the root of the repo.

## Opcodes

Opcodes are subject to change and can be used in `.bla` files by including `bth.inc`.

### Internal Opcodes

| Opcode | Name | Stack Effect | Description |
|----|----|----|----|
| 0x80 | atq | ( a -- q ) | Push qword value found at addr |
| 0x81 | ifnot | ( t/f fa -- ? ) | Call fa if t/f is false |
| 0x82 | chkargc | ( -- ) | Exit with error unless argc is 2 |
| 0x83 | cmovd | ( d b -- ) | Compile mov b, dword |
| 0x84 | cmovq | ( q b -- ) | Compile mov b, qword |
| 0x85 | cret | ( -- ) | Compile ret |
| 0x86 | cstosd | ( -- ) | Compile stosd |
| 0x87 | csys | ( -- ) | Compile syscall |
| 0x88 | cxord | ( b -- ) | Compile xor b, b |
| 0x89 | tfd | ( -- d ) | Push fd of test input file |
| 0x8A | oblk | ( -- a ) | Push addr of TAP output's start |
| 0x8B | thr | ( -- a ) | Push addr of TAP output's here |
| 0x8C | setthr | ( a -- ) | Set addr of TAP output's here |
| 0x8D | argv1 | ( -- a ) | Push argv[1]_ |
| 0x8E | cdstarg | ( -- ) | Compile movabs rdi, _addr of argv[1]_ |
| 0x8F | cflgsro | ( -- ) | Compile xor esi, esi (flags = READ_ONLY) |
| 0x90 | csopen | ( -- ) | Compile mov eax, 0x02 (sys_open); syscall |
| 0x91 | cdsttfd | ( -- ) | Compile movabs rdi, _addr of tfd's litd_ |
| 0x92 | cfrmtfd | ( -- ) | Compile mov edi, _tfd_ |
| 0x93 | csrctib | ( -- ) | Compile mov rsi, _addr of _test input block_ |
| 0x94 | cblklen | ( -- ) | Compile mov edx, 0x0400 |
| 0x95 | csread | ( -- ) | Compile xor eax, eax; syscall |
| 0x96 | opentst | ( -- ) | Open argv[1] and set tfd |
| 0x97 | readtst | ( -- ) | Read block from tfd into the test input block |
| 0x98 | runtst | ( -- ) | Run the test in the test input block |
| 0x99 | endl | ( a -- ) | End line of output and set TAP output's here |
| 0x9A | woka | ( a -- ) | Write ok line to addr |
| 0x9B | wprep | ( -- ) | Preps the write system call |
| 0x9C | wlen | ( -- ) | Buffer length for the write system call |
| 0x9D | waddr | ( -- ) | Addr of the buffer for the write system call |
| 0x9E | test | ( w -- ) | Initialize a test suite |
| 0x9F | plan | ( w -- ) | Plan w tests where w is two ascii characters such as '03' |
| 0xA0 | ok | ( -- ) | Write ok line to TAP output's here |
| 0xA1 | notok | ( -- ) | Write not ok line to TAP output's here |
| 0xA2 | okif | ( t/f -- ) | Ok if top of stack is true |
| 0xA3 | okeq | ( a b -- ) | Ok if a and b are eq |
| 0xA4 | okne | ( a b -- ) | Ok if a and b are not eq |
| 0xA5 | ok0 | ( n -- ) | Ok if top of stack is 0 |
| 0xA6 | okn0 | ( n -- ) | Ok if top of stack is not 0 |
| 0xA7 | done | ( -- ) | Writes TAP output to stdout and exits with depth as status |

## TODOs

1. Print "TAP version 14" when testing begins
1. Split ops_low.bla into ops_pri.bla and ops_pub.bla
   1. Separate ops tables in README, etc
   1. Separate includes
1. Redo wprep, wlen, waddr to use cxord, cmovd, etc
