#!/usr/bin/sh

rm -rf .bootstrap
rm -rf .build
mkdir -p .bootstrap/bin
mkdir -p .bootstrap/obj

blue bake.blue
nasm bake.asm -f elf64 -o .bootstrap/obj/bake.o
ld .bootstrap/obj/bake.o -o .bootstrap/bin/bake

.bootstrap/bin/bake build bake.blue
