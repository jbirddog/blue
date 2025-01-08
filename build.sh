#!/bin/bash

set -e

mkdir -p bin
mkdir -p obj

echo "* Building BlueVM x86_64/linux"

fasm bluevm.asm bin/bluevm

echo "* Building bs0 files"

./examples/blang/blang.pl < examples/blang/halt.bl > obj/halt.bs0

echo "* Testing bs0 files"

./bin/bluevm < obj/halt.bs0 > bin/halt

echo "* Done"
