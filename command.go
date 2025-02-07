package main

import "encoding/binary"

type Command interface {
	Execute(*CompileCtx)
}

type Comma struct {
	Size int
}

type Lit struct {
	Val  uint64
	Size int
}

func (c *Comma) Execute(ctx *CompileCtx) {
	lit := ctx.DataFlowStack.Pop().(LitFlow)
	binary.LittleEndian.PutUint64(ctx.CodeBuf.Here(), lit.Val)
	ctx.CodeBuf.I += lit.Size
}

func (c *Lit) Execute(ctx *CompileCtx) {
	ctx.DataFlowStack.Push(LitFlow(*c))
}
