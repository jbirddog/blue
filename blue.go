package main

import (
	"fmt"
	"os"
	"unsafe"
)

var filename = "a.out"

const (
	ELFHDR_IDX_ENT = 3
	ELFHDR_IDX_BSZ = 12
	ELFHDR_IDX_MSZ = 13

	ELFHDR_ELEMS = 15
	ELFHDR_BSZ   = ELFHDR_ELEMS * 8
)

var elfhdr = [ELFHDR_ELEMS]uint64{
	0x0301_0102_464C_457F,
	0x00,
	0x0000_0001_003E_0002,
	0x0000_0000_0040_0078,
	0x0000_0000_0000_0040,
	0x00,
	0x0038_0040_0000_0000,
	0x0000_0000_0040_0001,
	0x0000_0007_0000_0001,
	0x00,
	0x0000_0000_0040_0000,
	0x0000_0000_0040_0000,
	0x00,
	0x00,
	0x0000_0000_0000_1000,
}
var elfhdrb = unsafe.Slice((*byte)(unsafe.Pointer(&elfhdr[0])), ELFHDR_BSZ)

type MachineCode []byte

var mc MachineCode

const (
	OP_COMP1 = iota
	OP_COMP2
	OP_COMP4
	OP_COMP8

	OP_ELEMS
)

var opelemsz = [OP_ELEMS]int{
	1,
	2,
	4,
	8,
}

type ByteCode []byte

var bc = ByteCode{
	OP_COMP2, 0x31, 0xFF,
	OP_COMP1, 0xB8, OP_COMP4, 0x3C, 0x00, 0x00, 0x00,
	OP_COMP2, 0x0F, 0x05,
}

const (
	MAGIC_IDX_MAGIC = 0
	MAGIC_IDX_MCSZ  = 1

	MAGIC_ELEMS = 2
	MAGIC_BSZ   = MAGIC_ELEMS * 8
)

var magic = [MAGIC_ELEMS]uint64{
	0x0000_0006_6575_6C62,
	0x00,
}
var magicb = unsafe.Slice((*byte)(unsafe.Pointer(&magic[0])), MAGIC_BSZ)

func save() error {
	f, err := os.OpenFile(filename, os.O_CREATE|os.O_WRONLY, 0755)
	if err != nil {
		return err
	}
	defer f.Close()

	mcsz := len(mc)
	sz := uint64(ELFHDR_BSZ + mcsz + len(bc) + MAGIC_BSZ)

	elfhdr[ELFHDR_IDX_BSZ] = sz
	elfhdr[ELFHDR_IDX_MSZ] = sz

	magic[MAGIC_IDX_MCSZ] = uint64(mcsz)

	for _, o := range [][]byte{elfhdrb, mc, bc, magicb} {
		_, err = f.Write(o)
		if err != nil {
			return err
		}
	}

	return nil
}

func compN(i *int, n int) {
	mc = append(mc, bc[*i:*i+n]...)
	*i += n
}

func comp1(i *int) {
	compN(i, 1)
}

func comp2(i *int) {
	compN(i, 2)
}

func comp4(i *int) {
	compN(i, 4)
}

func comp8(i *int) {
	compN(i, 8)
}

type OpHandler func(*int)

var codeops = [OP_ELEMS]OpHandler{
	comp1,
	comp2,
	comp4,
	comp8,
}

var ophandler = codeops

func main() {
	if len(os.Args) > 1 {
		filename = os.Args[1]
	}

	for i := 0; i < len(bc); {
		op := bc[i]
		i += 1

		ophandler[op](&i)
	}

	if err := save(); err != nil {
		panic(err)
	}

	fmt.Printf("ok: %d\n", len(mc))
}
