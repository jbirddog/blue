#!/usr/bin/sh

BAKE=../../../tools/bake/.build/bin/bake

command -v "${BAKE}" > /dev/null 2>&1 || {
	cd ../../../tools/bake
	./bootstrap.sh
	cd -
}

rm -f output.txt
rm -rf docs

$BAKE build clear_the_screen.blue
$BAKE build commandline_args.blue
$BAKE build create_file.blue
$BAKE build environment.blue
$BAKE build hello_world.blue
$BAKE build program_name.blue
$BAKE build read_entire_file.blue

# TODO support this via bake
blue fibonacci.blue
nasm -f elf64 -o .build/obj/fibonacci.o fibonacci.asm
