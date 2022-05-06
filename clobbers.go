package main

func UpdateClobbers(clobberSet uint, registerSet uint, indirectRegisterSet uint) uint {
	clobberSet &= ^registerSet

	return clobberSet
}
