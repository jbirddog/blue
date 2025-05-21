_This file is generated from README.md.tmpl_

# BlueVM Test Harness

Patched version of the BlueVM with extended opcodes to facilitate testing.

## Building

To build `bth` run `make` after `make` has been run in the root of the repo.

## Opcodes

Opcodes are subject to change and can be used in `.bla` files by including `bth.inc`.

| Opcode | Name | Stack Effect | Description |
|----|----|----|----|
| 0x80 | asrt | ( t/f -- ) | Assert top of stack is true |
| 0x81 | asrteq | ( a b -- ) | Assert a and b are eq |
| 0x82 | asrtne | ( a b -- ) | Assert a and b are not eq |

## TODOs

1. TAP?
