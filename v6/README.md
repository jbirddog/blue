# Blue

Blue is a single-pass bytecode interpreter for a [colorForth](https://colorforth.github.io/index.html) dialect. It is a single shot application with an intentionally limited scope that focuses on generating output. Like any Forth, an emphasis is placed on building user defined vocabularies to describe the problem at hand.

Blue aims to:

1. Have a reasonably small, simplistic and hackable codebase that can be completely understood by a single human
1. Help create minimalistic handcrafted applications
1. Bring some fun back into the world

This is the reference implementation for x86_64 Linux.

## Why a colorForth?

Because this is how I like to code.

For many years I been interested in Forth and have dabbled in existing systems as well as written several of my own. When I first saw screenshots of `colorForth` I remembering thinking "cool but looks a little gimmicky." Once I dug into what it really was though, I realized how brutally simple this type of system is compared to a traditional Forth. The fact that this extreme simplification comes without sacrificing power is amazing. This is the genius of Chuck Moore.

To me `colorForth` is not about the colors that are shown on your screen. Those colors are strictly some visual representation of the bytecode - the same bytecode that can be shown in any number of ways. While one may display word definitions in red, others could choose to render a more traditional `: wordname`. Some viewers may render an svg, others ansi terminal escape sequences. Even a hex editor is in play. Currently I `fasm2` to generate flat binaries as a means to edit my bytecode. None of that truly matters. The real focus should be on how simple the underlying interpreter is.

## Comparison with colorForth

It is important to note that I have not used or seen the source for an actual `colorForth` system. I do believe I have digested all the (limited) material that is available online. When I say `colorForth` I am likely also describing `arrayForth` or `etherforth`. With that being said, this comparison is in good faith but may not end up being 100% correct:

### Similarities

1. Concatenative/stack-based
9. No stack effect declarations
2. Use of binary bytecode files instead of the more traditional text file as input
3. Data stack is implemented as a circular buffer
4. Dictionary is implemented as an array
5. The use of each word describes its execution semantics (compile/interpret/inline)
   1. Defining a word does not enter compile mode, `;` does not leave compile mode, there is no `]`, `[`, `immediate`, `postpone`, etc
6. Word definitions do not require a `;` - they can fallthrough to the next word
7. Defined words are available immediately - words can call themselves with no trickery
8. `;` will perform tail-call optimization when preceeded by a call
9. Any previously defined word can be called or used as a macro

### Differences

1. Blue is a single shot application (used like `gcc`) instead of a living application (like an `os`/`emacs`)
2. Does not have a custom keyboard mapping
3. The bytecode format is not the same
4. There are no comments or shadow blocks
5. Block files are not used
6. Has more opcodes and less pre-defined words
7. There is no dedicated dictionary for macros
8. The colors used are different and bold/italics are used

## The Structural Dynamics of Flow
