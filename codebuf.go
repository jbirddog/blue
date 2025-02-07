package main

import "encoding/binary"

type CodeBuf struct {
	Mem []byte
	i int
	buf  []byte
}

func NewCodeBuf(rwx_mem []byte) *CodeBuf {
	return &CodeBuf{
		Mem: rwx_mem,
		buf: make([]byte, 8),
	}
}

func (c *CodeBuf) Append(val byte) {
	c.Mem[c.i] = val
	c.i++
}

func (c *CodeBuf) AppendUint32(val uint32) {
	binary.LittleEndian.PutUint32(c.buf, val)
	copy(c.Mem[c.i:], c.buf[:4])
	c.i += 4
}

