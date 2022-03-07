package main

type Dictionary struct {
	Name  string
	Words []*Word
}

func DefaultDictionary() *Dictionary {
	return &Dictionary{
		Name: "default",
		Words: []*Word{
			NewCallGoWord("extern", KernelExtern),
			NewCallGoWord("section", KernelSection),
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
