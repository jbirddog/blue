package main

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
}

func (c *Lit) Execute(ctx *CommandCtx) {
}
