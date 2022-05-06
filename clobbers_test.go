package main

import (
	"testing"
)

func TestIsOkWithNoClobbersOrRegisters(t *testing.T) {
	expected := uint(0)
	clobbers := UpdateClobbers(expected, 0, 0)

	if clobbers != expected {
		t.Fatal("Expected clobbers to be empty")
	}
}

func TestDoesNotChangeClobbersIfNoRegisters(t *testing.T) {
	expected := uint(1 << rax)
	clobbers := UpdateClobbers(expected, 0, 0)

	if clobbers != expected {
		t.Fatal("Expected clobbers not to change")
	}
}

func TestClobbersDoesNotIncludeSpecifiedRegisters(t *testing.T) {
	expected := uint(0)
	specifiedRegisters := uint(1 << rax)
	clobbers := UpdateClobbers(specifiedRegisters, specifiedRegisters, 0)

	if clobbers != expected {
		t.Fatal("Expected clobbers not to include specified registers")
	}
}

func TestClobbersIncludeNonSpecifiedRegisters(t *testing.T) {
	expected := uint(1 << rcx)
	specifiedRegisters := uint(1 << rax)
	clobbers := UpdateClobbers(expected|specifiedRegisters, specifiedRegisters, 0)

	if clobbers != expected {
		t.Fatal("Expected clobbers not to include specified registers")
	}
}

func TestClobbersIncludeIndirectRegisters(t *testing.T) {
	expected := uint(1 << rcx)
	specifiedRegisters := uint(1 << rax)
	indirectRegisters := uint(1 << rcx)
	clobbers := UpdateClobbers(0, specifiedRegisters, indirectRegisters)

	if clobbers != expected {
		t.Fatal("Expected clobbers to include indirect registers")
	}
}

func TestClobbersDoesNotIncludeIndirectRegistersThatAreAlsoSpecified(t *testing.T) {
	expected := uint(0)
	specifiedRegisters := uint(1<<rax | 1<<rcx)
	indirectRegisters := uint(1 << rcx)
	clobbers := UpdateClobbers(0, specifiedRegisters, indirectRegisters)

	if clobbers != expected {
		t.Fatal("Expected clobbers not to include indirect registers that are also specified")
	}
}
