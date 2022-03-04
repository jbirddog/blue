package main

type Dictionary struct {
	Name  string
	Words []*Word
}

func DefaultDictionary() *Dictionary {
	return &Dictionary{
		Name: "default",
		Words: []*Word{
			NewCallGoWord(":", KernelColon),
			NewCallGoWord(":>", KernelColonGT).Immediate(),
			NewCallGoWord("latest", KernelLatest).Immediate(),
			NewCallGoWord(";", KernelSemi).Immediate(),
			NewCallGoWord("global", KernelGlobal),
		},
	}
}

func (d *Dictionary) Append(word *Word) {
	d.Words = append(d.Words, word)
}

func (d *Dictionary) Find(wordName string) *Word {
	wordsLen := len(d.Words)

	for i := wordsLen - 1; i >= 0; i-- {
		word := d.Words[i]

		if word.IsHidden() {
			continue
		}

		if word.Name == wordName {
			return d.Words[i]
		}
	}

	return nil
}

func (d *Dictionary) HideLocalWords() {
	wordsLen := len(d.Words)

	for i := wordsLen - 1; i >= 0; i-- {
		word := d.Words[i]

		if !word.IsLocal() {
			break
		}

		word.Hidden()
	}
}

func (d *Dictionary) Latest() *Word {
	return d.Words[len(d.Words)-1]
}

func (d *Dictionary) LatestNonLocal() *Word {
	wordsLen := len(d.Words)

	for i := wordsLen - 1; i >= 0; i-- {
		word := d.Words[i]

		if word.IsHidden() {
			continue
		}

		if !word.IsLocal() {
			return word
		}
	}

	return nil
}

func (d *Dictionary) AppendGlobalDecls(asmInstrs []AsmInstr) []AsmInstr {
	for _, word := range d.Words {
		if word.IsHiddenFromAsm() || !word.IsGlobal() {
			continue
		}

		asmInstrs = append(asmInstrs, &AsmGlobalInstr{Label: word.Name})
	}

	return asmInstrs
}

func (d *Dictionary) AppendWords(asmInstrs []AsmInstr) []AsmInstr {
	for _, word := range d.Words {
		if word.IsHiddenFromAsm() {
			continue
		}

		asmInstrs = append(asmInstrs, &AsmLabelInstr{Name: word.AsmLabel()})
		asmInstrs = word.AppendCode(asmInstrs)
	}

	return asmInstrs
}
