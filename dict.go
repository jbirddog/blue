package main

type Dictionary struct {
	Name   string
	Words  map[string]*Word
	Latest *Word
}

func DefaultDictionary() *Dictionary {
	d := &Dictionary{Name: "default", Words: map[string]*Word{}}

	d.appendWords([]*Word{
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
		NewCallGoWord("decd", KernelDecd).Immediate(),
		NewCallGoWord("decq", KernelDecq).Immediate(),
		NewCallGoWord("decb(", KernelDecbLParen).Immediate(),
		NewCallGoWord("decd(", KernelDecdLParen).Immediate(),
		NewCallGoWord("decq(", KernelDecqLParen).Immediate(),
		NewCallGoWord("litb", KernelLitb).Immediate(),
		NewCallGoWord("litd", KernelLitd).Immediate(),
		NewCallGoWord("litq", KernelLitq).Immediate(),
		NewCallGoWord("litb(", KernelLitbLParen).Immediate(),
		NewCallGoWord("litd(", KernelLitdLParen).Immediate(),
		NewCallGoWord("litq(", KernelLitqLParen).Immediate(),
		NewInlineWord("drop", &DropInstr{}),
		NewInlineWord("dup", &DupInstr{}),
		NewInlineWord("swap", &SwapInstr{}),
		NewCallGoWord("'", KernelTick).Immediate(),
		NewCallGoWord("xe", KernelXe).Immediate(),
		NewCallGoWord("xne", KernelXne).Immediate(),
		NewCallGoWord("xl", KernelXl).Immediate(),
		NewCallGoWord("xz", KernelXz).Immediate(),
		NewCallGoWord("xnz", KernelXnz).Immediate(),
		NewCallGoWord("xg", KernelXg).Immediate(),
		NewCallGoWord("loople", KernelLoople).Immediate(),
		NewCallGoWord("const", KernelConst),
		NewCallGoWord("hide", KernelHide),
		NewInlineWord("@", &DerefInstr{}),
		NewInlineWord("!", &SetInstr{}),
		NewInlineWord("rot", &RotInstr{}),
		NewCallGoWord(`s"`, KernelSQuote).Immediate(),
		NewCallGoWord(`c"`, KernelCQuote).Immediate(),
		NewInlineWord("call", &CallInstr{}),
		NewCallGoWord("::", KernelColonColon).Immediate(),
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
	word := d.Words[wordName]
	if word == nil {
		return nil
	}

	if word.IsHidden() {
		return nil
	}

	return word
}
