# Blue

Blue is a single-pass bytecode interpreter for a [colorForth](https://colorforth.github.io/index.html) dialect. Unlike the traditional `colorForth` system, Blue is a single shot application with a sole focus on generating output. Like any Forth, an emphasis is placed on building user defined vocabularies to describe and solve the problem at hand.

Blue aims to:

1. Have a reasonably small, simplistic and hackable codebase that a single human can completely understand
1. Help create minimalistic handcrafted applications
1. Bring some fun back into the world

This is the reference implementation for x86_64 Linux.

## Comparison with colorForth

It is important to note that I have not used or seen the source for an actual `colorForth` system. I do believe I have digested all the (limited) material that is available online. When I say `colorForth` I am likely also describing `arrayForth` or `etherforth`. With that being said, this comparison is in good faith but may not end up being 100% correct:

### Similarities

1. Concatenative/stack-based
2. No stack effect declarations
2. Use of binary bytecode files instead of the more traditional text file as input
3. Data stack is implemented as a circular buffer
4. Dictionary is implemented as an array
5. The use of each word describes its execution semantics (compile/interpret/inline)
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
