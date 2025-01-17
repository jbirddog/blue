# Blue

Compiler for the Blue Language

_Please note the language and compiler are in an early stage of development. Working programs can be compiled but rough spots, TODOs and deficiencies can easily be encountered._

The Blue compiler requires `go`, `nasm` and `ld`. Versions used for development are:

```
$ go version
go version go1.18 linux/amd64
$ nasm --version
NASM version 2.15.05
$ ld --version
GNU ld (GNU Binutils for Ubuntu) 2.37
```

To build run `./build` in the repo root. The build script will compile, test and install the Blue compiler then build all language examples.
