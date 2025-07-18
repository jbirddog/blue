# TODOs

## Maybe

1. Consider magenta + italics for runtime addr (like fin/; are yellow + italics if that holds)
1. Top of stack always in rax?
1. Dict entry 0x00 can have not found handler
1. Likely go back to fasm for build time speed

## Words

1. Interpret word at compile time (cyan - done)
1. Call word at compile time (yellow - done)
1. Call word at run time (green - done)
1. Push compile time addr of word (magenta - done)
1. Push run time addr of word (white - done)

## Next

1. btv - terminal output (port of ed.pl)

## Future

1. Add BC_TOR, BC_FROMR
1. Add BC_SAVE, BC_RESTORE - or BC_SYSCALL
1. bsv - svg output
1. bhv - html output
1. Release as blue after btv
   1. Tag main as v5
   1. Move to root, remove all old code (include bak)
   1. Update CI job
1. Start getting the README.md together
1. Factor Makefile a bit for multiple ouput binaries
1. Make onex.1x, onex written in onex and bootstrapped from fasm version
