package main

import (
	"strings"
)

func buildRegisterRef(rawRef string, parentRefs []*RegisterRef) *RegisterRef {
	parts := strings.SplitN(rawRef, ":", 2)
	partsLen := len(parts)

	if partsLen == 1 {
		reg := parts[0]

		for _, parentRef := range parentRefs {
			if parentRef.Name == parts[0] {
				reg = parentRef.Reg
				break
			}
		}

		return &RegisterRef{Name: parts[0], Reg: reg}
	}

	return &RegisterRef{Name: parts[0], Reg: parts[1]}
}
