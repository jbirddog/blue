package main

type Stack struct {
	Elems []uint64
	I int
}

func NewStack(len int) *Stack {
	return &Stack {
		Elems: make([]uint64, len),
	}
}

func (s *Stack) Push(val uint64) {
	s.Elems[s.I] = val
	s.I++
}

func (s *Stack) Pop() uint64 {
	s.I--
	return s.Elems[s.I]
}

func (s *Stack) Top() *uint64 {
	return &s.Elems[s.I]
}

