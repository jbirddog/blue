#!/bin/bash

set -e

error_handler() {
  echo "Error on line $1, exit status: $2"
}

trap 'error_handler $LINENO $?' ERR

mkdir -p bin
mkdir -p obj

echo "* Building BlueVM v5 x86_64/linux"

fasm v5.asm bin/driver
fasm opcode_tbl.asm bin/opcode_tbl

echo "7FF: 00" | xxd -r > bin/xtd_opcode_tbl
echo "7FF: 00" | xxd -r > bin/code_buffer
echo "3FF: 00" | xxd -r > bin/return_stack
echo "3FF: 00" | xxd -r > bin/data_stack
echo "3FF: 00" | xxd -r > bin/input_buffer

cat \
  bin/driver \
  bin/opcode_tbl \
  bin/xtd_opcode_tbl \
  bin/return_stack \
  bin/data_stack \
  bin/code_buffer \
  bin/input_buffer \
> bin/v5

chmod +x bin/v5
./bin/v5
