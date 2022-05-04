package main

const (
	StackRefType_Register = iota
	StackRefType_LiteralInt
	StackRefType_Label
	StackRefType_Deref
)

type StackRef struct {
	Name string
	Type int
	Ref  string
}

func NormalizeRefs(a *StackRef, b *StackRef) (bool, *StackRef, *StackRef) {
	if a.Type == b.Type && a.Ref == b.Ref {
		return true, a, b
	}

	if a.Type == StackRefType_Register && a.Type == b.Type {
		aIndex := registers[a.Ref]
		bIndex := registers[b.Ref]
		if aIndex == bIndex {
			return true, a, b
		}

		aSize := registerSize[a.Ref]
		bSize := registerSize[b.Ref]

		// TODO will need some more work to support all combos
		// add lookup in x8664.go map[size][index] to get names
		if aSize == "dword" && bSize == "qword" {
			b.Ref = reg32Names[bIndex]
			return false, a, b
		} else if aSize == "qword" && bSize == "dword" {
			a.Ref = reg32Names[aIndex]
			return false, a, b
		}
	}

	return false, a, b
}
