_This file is generated from README.md.tmpl_

# BlueVM Test Harness

Patched version of the BlueVM with extended opcodes to facilitate testing.

## Building

To build `bth` run `make` after `make` has been run in the root of the repo.

## Opcodes

Opcodes are subject to change and can be used in `.bla` files by including `bth.inc`.

| Opcode | Name | Stack Effect | Description |
|----|----|----|----|
| 0x80 | tst | ( -- q ) | Push addr of TAP output's start |
| 0x81 | thr | ( -- q ) | Push addr of TAP output's here |
| 0x82 | thrM | ( -- q ) | Push addr of TAP output's here modification point |
| 0x83 | setthr | ( q -- ) | Set addr of TAP output's here |
| 0x84 | plan | ( w -- ) | Plan w tests where w is two ascii characters such as '03' |
| 0x85 | done | ( -- ) | Writes TAP output to stdout and exits with depth as status |
| 0x86 | asrt | ( t/f -- ) | Assert top of stack is true |
| 0x87 | asrteq | ( a b -- ) | Assert a and b are eq |
| 0x88 | asrtne | ( a b -- ) | Assert a and b are not eq |

## TODOs

1. Replace need for shim.sh to produce TAP output
1. Output plan from `done` without need to call `plan`
1. Print "TAP version 14" when testing begins
