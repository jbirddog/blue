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

func (s *StackRef) FlowTarget() string {
	if s.Ref != "" {
		return s.Ref
	}

	return s.Name
}

func RefsAreComplete(refs []*StackRef) bool {
	for _, r := range refs {
		if len(r.Ref) == 0 {
			return false
		}
	}

	return true
}

func NormalizeRefs(a *StackRef, b *StackRef) (bool, *StackRef, *StackRef) {
	if a.Type == b.Type && a.Ref == b.Ref {
		return true, a, b
	}

	if a.Type == StackRefType_Register && a.Type == b.Type {
		aIndex, aFound := registers[a.Ref]
		bIndex, bFound := registers[b.Ref]

		if !aFound || !bFound {
			return false, a, b
		}

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
