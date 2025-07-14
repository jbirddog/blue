# TODOs

## Maybe

1. Add `bye`, remove BC_FIN
1. Top of stack always in rax?
1. Dict entry 0x00 can have not found handler
1. Likely go back to fasm for build time speed

## Keep in Mind

1. There is no ip - just compiling byte code top to bottom
1. Control flow happens via compiled machine code
1. Return stack is rsp
1. Data stack wraps

## Words

1. Interpret word at compile time (cyan)
1. Call word at compile time (yellow - done)
1. Call word at run time (green)
1. Push compile time addr of word (magenta - done)
1. Push run time addr of word (white - done)

## Next

1. Double size of dict, dst, src

## Future

1. Show `BC_FIN` in ed output (white?)
1. Try having `bc_tbl` be `dd`
1. Change xt to find
1. Factor Makefile a bit for multiple ouput binaries
1. Factor `$ elfhdrs - 0x400000 + entry !` into `entry!` defined in elf.1xo
1. Make onex.1x so onex can be written in onex and bootstrapped from fasm version

## rt

How many files to include as `rt`?

### asm.1xo

### kernel.1xo

1. `$ $$ !`
1. Move logic to read _src from stdin
   1. Words + exec `read`

### kernel.fin.1xo

1. `out bye`
