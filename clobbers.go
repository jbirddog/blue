package main

func UpdateClobbers(clobberSet uint, registerSet uint, indirectRegisterSet uint) uint {
	clobberSet |= indirectRegisterSet
	clobberSet &= ^registerSet

	return clobberSet
}
