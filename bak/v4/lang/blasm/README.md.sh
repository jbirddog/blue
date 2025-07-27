#!/bin/sh

awk 'BEGIN {print "_This file is generated from README.md.tmpl_\n"} {print}' README.md.tmpl
