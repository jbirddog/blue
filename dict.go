package main

type Dictionary struct {
	Name  string
	Words []*Word
}

func DefaultDictionary() *Dictionary {
	return &Dictionary{
		Name: "default",
		Words: []*Word{
			NewCallGoWord(":", kernel_colon),
			NewCallGoWord("(", kernel_lparen).Immediate(),
			NewCallGoWord(";", kernel_semi).Immediate(),
		},
	}
}

func (d *Dictionary) Append(word *Word) {
	d.Words = append(d.Words, word)
}

func (d *Dictionary) Find(wordName string) *Word {
	wordsLen := len(d.Words)

	for i := wordsLen - 1; i >= 0; i-- {
		if d.Words[i].Name == wordName {
			return d.Words[i]
		}
	}

	return nil
}

func (d *Dictionary) Latest() *Word {
	return d.Words[len(d.Words)-1]
}

func (d *Dictionary) AppendGlobalDecls(asmInstrs []AsmInstr) []AsmInstr {
	for _, word := range d.Words {
		if word.IsHiddenFromAsm() {
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

		asmInstrs = append(asmInstrs, &AsmLabelInstr{Name: word.Name})
		asmInstrs = word.AppendCode(asmInstrs)
	}

	return asmInstrs
}

