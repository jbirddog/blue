# Bake

`bake` is a simplistic and opinionated tool for building and running Blue programs on Linux/x86-64. Running `bake` with no parameters or invalid parameters will print its `usage`:

```
$ bake

usage: bake cmd somefile.blue [args]

cmd:
	build   - compile the specified blue file
	run     - compile and run the specified blue file

[args]:
	optional args can be passed to commands:

	build	- n/a
	run	- args to forward to the blue program to run
```

## Commands

### build

To build a Blue file with `bake`:

```
$ bake build bake.blue 
ok	bake.blue
```

`bake` will create a `.build` directory in the current directory which will contain object files as well as the final binary. The generated assembly file will be placed in the current directory as well, though this is likely to change once the language stabalizes more.

```
$ ls .build/bin/
bake
```

### run

To run a Blue file with `bake`:

```
$ bake run hello_world.blue 
ok	hello_world.blue
Hello world!
```

`bake` will first compile the Blue file then execute it. Extra command line arguments are passed on to the executable (note: currently only one argument is supported, see TODO.md)

## Building

To build `bake`, either run `./bootstrap.sh` in this directory, or `./build.sh` from the root of this repo. `bake` has the same dependencies as the Blue compiler itself. For more information see [INSTALL.md](../../INSTALL.md).

Once built using one of the methods above, `bake` will reside in `.build/bin` in this directory. Either add this location to your path or copy `bake` to a location already in your path.

## Questions

Q: Couldn't this just be a shell script/Makefile?

A: Naturally, yes. This was more of an exercise while developing the Blue language and compiler, during which several issues were resolved - most of which only happened after moving beyond Hello World type programs.

Q: Is this used?

A: Yes, to build all language examples, the tutorial and `bake` itself.
