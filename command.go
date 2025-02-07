package main

import "encoding/binary"

type CommandCtx struct {
	CodeBuf *CodeBuf
	DataFlowStack *DataFlowStack
}

type Command interface {
	Execute(*CommandCtx)
}

type Comma struct {
	Size int
}

type Lit struct {
	Val uint64
	Size int
}

func (c *Comma) Execute(ctx *CommandCtx) {
	lit := ctx.DataFlowStack.Pop().(LitFlow)
	binary.LittleEndian.PutUint64(ctx.CodeBuf.Here(), lit.Val)
	ctx.CodeBuf.I += lit.Size
}

func (c *Lit) Execute(ctx *CommandCtx) {
	ctx.DataFlowStack.Push(LitFlow(*c))
}
