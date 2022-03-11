package main

type Dictionary struct {
	Name           string
	Words          map[string]interface{}
	VisibleLocals  []*Word
	Latest         *Word
	LatestNonLocal *Word
}

func DefaultDictionary() *Dictionary {
	d := &Dictionary{Name: "default", Words: map[string]interface{}{}}

	d.appendWords([]*Word{
		NewCallGoWord("import", KernelImport),
		NewCallGoWord("import", KernelImport),
		NewCallGoWord("extern", KernelExtern),
		NewCallGoWord("section", KernelSection),
		NewCallGoWord(":", KernelColon),
		NewCallGoWord(":>", KernelColonGT).Immediate(),
		NewCallGoWord("latest", KernelLatest).Immediate(),
		NewCallGoWord(";", KernelSemi).Immediate(),
		NewCallGoWord("global", KernelGlobal),
		NewCallGoWord("inline", KernelInline),
		NewCallGoWord("\\", KernelCommentToEol),
		NewCallGoWord("resb", KernelResb),
		NewInlineWord("drop", &DropInstr{}),
		NewInlineWord("dup", &DupInstr{}),
		NewCallGoWord("'", KernelTick).Immediate(),
		NewCallGoWord("xl", KernelXl).Immediate(),
	})

	return d
}

func (d *Dictionary) Append(word *Word) {
	d.Words[word.Name] = word
	d.Latest = word

	if word.IsLocal() {
		d.VisibleLocals = append(d.VisibleLocals, word)
	} else {
		d.LatestNonLocal = word
	}
}

func (d *Dictionary) appendWords(words []*Word) {
	for _, word := range words {
		d.Append(word)
	}
}

func (d *Dictionary) Find(wordName string) *Word {
	val := d.Words[wordName]
	if val == nil {
		return nil
	}

	word := val.(*Word)

	if word.IsHidden() {
		return nil
	}

	return word
}

func (d *Dictionary) HideLocalWords() {
	for _, word := range d.VisibleLocals {
		word.Hidden()
	}

	d.VisibleLocals = nil
}
