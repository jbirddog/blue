#!/usr/bin/sh

mkdir -p .build/bin
mkdir -p .build/obj

blue tutorial1.blue
nasm -f elf64 -o .build/obj/tutorial1.o tutorial1.asm
ld -o .build/bin/tutorial1 .build/obj/tutorial1.o

blue tutorial2.blue
nasm -f elf64 -o .build/obj/tutorial2.o tutorial2.asm
ld -o .build/bin/tutorial2 .build/obj/tutorial2.o

blue tutorial3.blue
nasm -f elf64 -o .build/obj/tutorial3.o tutorial3.asm
ld -o .build/bin/tutorial3 .build/obj/tutorial3.o
