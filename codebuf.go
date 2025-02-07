package main

import "encoding/binary"

type CodeBuf struct {
	Mem []byte
	i   int
	tmp []byte
}

func NewCodeBuf(rwx_mem []byte) *CodeBuf {
	return &CodeBuf{
		Mem: rwx_mem,
		tmp: make([]byte, 8),
	}
}

func (c *CodeBuf) Append(val ...byte) {
	copy(c.Mem[c.i:], val)
	c.i += len(val)
}

func (c *CodeBuf) AppendUint32(val uint32) {
	binary.LittleEndian.PutUint32(c.tmp, val)
	c.Append(c.tmp[:4]...)
}
