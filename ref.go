package main

const (
	StackRefType_Register = iota
)

type StackRef struct {
	Name string
	Type int
	Ref  string
}

// TODO need to refactor so that by the time this is called a and b are StackRefs
func NormalizeRefs(a string, b string) (bool, string, string) {
	if a == b {
		return true, a, b
	}

	if aIndex, found := registers[a]; found {
		if bIndex, found := registers[b]; found {
			if aIndex == bIndex {
				return true, a, b
			}

			aSize := registerSize[a]
			bSize := registerSize[b]

			// TODO will need some more work to support all combos
			// add lookup in x8664.go map[size][index] to get names
			if aSize == "dword" && bSize == "qword" {
				return false, a, reg32Names[bIndex]
			} else if aSize == "qword" && bSize == "dword" {
				return false, reg32Names[aIndex], b
			}
		}
	}

	return false, a, b
}
