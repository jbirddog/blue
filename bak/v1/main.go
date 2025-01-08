package main

import (
	"fmt"
	"log"
	"os"
)

func main() {
	if len(os.Args) != 2 {
		log.Fatal("Usage: blue [blueFile]")
	}

	blueFile := os.Args[1]
	asmFile := blueFile[:len(blueFile)-5] + ".asm"
	env := ParseFileInNewEnvironment(blueFile)

	env.WriteAsm(asmFile)

	fmt.Printf("ok\t%s\n", blueFile)
}
