package main

type CodeBuf struct {
	Mem []byte
	I   int
}

func (c *CodeBuf) Here() []byte {
	return c.Mem[c.I:]
}

/*
func (c *CodeBuf) Append(val ...byte) {
	copy(c.Mem[c.I:], val)
	c.I += len(val)
}

func (c *CodeBuf) AppendUint32(val uint32) {
	binary.LittleEndian.PutUint32(c.tmp, val)
	c.Append(c.tmp[:4]...)
}
*/
