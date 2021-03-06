package main

import (
	"testing"
)

func TestCanFindDefaultWord(t *testing.T) {
	d := DefaultDictionary()
	if d.Find(":") == nil {
		t.Fatal("Could not find :")
	}
}

func TestDoesFindNonExistentWord(t *testing.T) {
	d := DefaultDictionary()
	if d.Find("@WTF#!") != nil {
		t.Fatal("Did not expect to find non existent word")
	}
}

func TestCanAppendNewWords(t *testing.T) {
	d := DefaultDictionary()
	d.Append(&Word{Name: "test__bob"})

	if d.Find("test__bob") == nil {
		t.Fatal("Could not find word after append")
	}
}

func TestCanReturnTheLastestWord(t *testing.T) {
	d := DefaultDictionary()
	d.Append(&Word{Name: "test__bob"})

	if d.Latest.Name != "test__bob" {
		t.Fatal("Unexpected latest word")
	}
}

func TestDoesNotFindHiddenWords(t *testing.T) {
	d := DefaultDictionary()
	w := &Word{Name: "hidden"}
	d.Append(w.Hidden())

	if d.Find("hidden") != nil {
		t.Fatal("Did not expect to find hidden word")
	}
}
