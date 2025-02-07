package main

type DataFlow interface {
}

type LitFlow struct {
	Val uint64
	Size int
}

type RegisterFlow struct {
	Idx int
	Size int
}

type TrustFlow struct {
}

type DataFlowStack struct {
	Elems []DataFlow
	I     int
}

func NewDataFlowStack(len int) *DataFlowStack {
	return &DataFlowStack { Elems: make([]DataFlow, len) }
}

func (s *DataFlowStack) Push(val DataFlow) {
	s.Elems[s.I] = val
	s.I++
}

func (s *DataFlowStack) Pop() DataFlow {
	s.I--
	return s.Elems[s.I]
}
