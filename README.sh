#!/bin/sh

awk -v OPCODE_TABLE="$(cat ops.md)" '{gsub(/^_OPCODE_TABLE_$/, OPCODE_TABLE); print}' README.md.tmpl
