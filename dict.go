package main

type Dictionary struct {
	Name   string
	Words  map[string]interface{}
	Latest *Word
}

func DefaultDictionary() *Dictionary {
	d := &Dictionary{Name: "default", Words: map[string]interface{}{}}

	d.appendWords([]*Word{
		NewCallGoWord("import", KernelImport),
		NewCallGoWord("import", KernelImport),
		NewCallGoWord("extern", KernelExtern),
		NewCallGoWord("section", KernelSection),
		NewCallGoWord(":", KernelColon).Immediate(),
		NewCallGoWord("latest", KernelLatest).Immediate(),
		NewCallGoWord(";", KernelSemi).Immediate(),
		NewCallGoWord("global", KernelGlobal),
		NewCallGoWord("global(", KernelGlobalLParen),
		NewCallGoWord("inline", KernelInline),
		NewCallGoWord("\\", KernelCommentToEol).Immediate(),
		NewCallGoWord("resb", KernelResb),
		NewCallGoWord("resd", KernelResd),
		NewCallGoWord("resq", KernelResq),
		NewCallGoWord("decb", KernelDecb).Immediate(),
		NewCallGoWord("decb(", KernelDecbLParen).Immediate(),
		NewInlineWord("drop", &DropInstr{}),
		NewInlineWord("dup", &DupInstr{}),
		NewInlineWord("swap", &SwapInstr{}),
		NewCallGoWord("'", KernelTick).Immediate(),
		NewCallGoWord("xl", KernelXl).Immediate(),
		NewCallGoWord("xne", KernelXne).Immediate(),
		NewCallGoWord("loople", KernelLoople).Immediate(),
		NewCallGoWord("const", KernelConst),
		NewCallGoWord("hide", KernelHide),
		NewInlineWord("@", &BracketInstr{}),
		NewInlineWord("!", &SetInstr{}),
		NewCallGoWord(`s"`, KernelSQuote).Immediate(),
		NewCallGoWord(`c"`, KernelCQuote).Immediate(),
	})

	return d
}

func (d *Dictionary) Append(word *Word) {
	d.Words[word.Name] = word
	d.Latest = word
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
