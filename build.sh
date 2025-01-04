#!/bin/bash

set -e

mkdir -p bin
mkdir -p obj

echo "* Building Blue x86_64/linux"

fasm blue.asm bin/blue

echo "* Building s120 x86_64/linux"

fasm s120.asm bin/s120

echo "* Creating bs1 files"

cat \
  x86_64/elf/pre.bs1 \
  examples/x86_64/linux/hello_world.bs1 \
  x86_64/elf/post.bs1 > obj/hello_world.bs1

echo "* Confirming s120 output"

grep -v "#" test_data/000.bs1 | xxd -p -r > obj/000_xxd.bs0
./bin/s120 < test_data/000.bs1 > obj/000.bs0

cmp obj/000_xxd.bs0 obj/000.bs0

grep -v "#" obj/hello_world.bs1 | xxd -p -r > obj/hello_world_xxd.bs0
./bin/s120 < obj/hello_world.bs1 > obj/hello_world.bs0

cmp obj/hello_world_xxd.bs0 obj/hello_world.bs0

echo "* Building example hello_world"

./bin/blue < obj/hello_world.bs0 > bin/hello_world
chmod +x bin/hello_world

./bin/hello_world
