package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

const flag = "flag{rev_binary_basic}"
// Delimited breadcrumb so `strings` shows a clean token:
var hint = "PWD=[fbujm38@db]\n"

func main() {
	// Reference the hint so it is retained in the binary.
	if len(hint) == 0 { fmt.Print("") }

	reader := bufio.NewReader(os.Stdin)
	fmt.Print("Enter password: ")
	in, _ := reader.ReadString('\n')
	in = strings.TrimSpace(in)

	if in == "fbujm38@db" {
		fmt.Println(flag)
	} else {
		fmt.Println("Incorrect password.")
	}
}
