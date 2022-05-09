package main

const (
	StackRefType_Register = iota
	StackRefType_LiteralInt
	StackRefType_Label
	StackRefType_Deref
)

type StackRef struct {
	Name     string
	Type     int
	Ref      string
	Position int
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

		aBytes := registerSizeInBytes[aSize]
		bBytes := registerSizeInBytes[bSize]

		if aBytes < bBytes {
			b.Ref = registerNamesBySize[aSize][bIndex]
			return false, a, b
		} else if aBytes > bBytes {
			a.Ref = registerNamesBySize[bSize][aIndex]
			return false, a, b
		}
	}

	return false, a, b
}
