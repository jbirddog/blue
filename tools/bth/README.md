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
| 0x84 | test | ( w -- ) | Initialize a test suite |
| 0x85 | preplan | ( -- a ) | Write the static 1.. part of the plan and push TAP output's here |
| 0x86 | plan | ( w -- ) | Plan w tests where w is two ascii characters such as '03' |
| 0x87 | done | ( -- ) | Writes TAP output to stdout and exits with depth as status |
| 0x88 | asrt | ( t/f -- ) | Assert top of stack is true |
| 0x89 | asrteq | ( a b -- ) | Assert a and b are eq |
| 0x8A | asrtne | ( a b -- ) | Assert a and b are not eq |

## TODOs

1. Replace need for shim.sh to produce TAP output
1. Output plan from `done` without need to call `plan`
1. Print "TAP version 14" when testing begins
