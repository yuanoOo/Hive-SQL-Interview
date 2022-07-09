package main

import (
	"fmt"
	"strconv"
	"unicode/utf8"

	"github.com/spaolacci/murmur3"
)

func main() {
	const domain = "https://poxiao.tk/"
	const domain1 = "https://poxiao.tk/"

	shortUrl := murmur3.Sum64([]byte(domain))
	shortUrl1 := murmur3.Sum32([]byte(domain1))

	nick := Person{
		Name:  "nick",
		Age:   28,
		Email: "nickli@xxx.com",
	}

	fmt.Println(shortUrl1)
	fmt.Printf("shortUr   is %d, length is %d\n", shortUrl, utf8.RuneCountInString(strconv.Itoa(int(shortUrl))))
	fmt.Printf("shortUrl  is %d, length is %d\n", shortUrl1, utf8.RuneCountInString(strconv.Itoa(int(shortUrl1))))

	fmt.Println(nick.Name)
	fmt.Println(LearnStruct())
}

func LearnStruct() int {
	fmt.Println("LearnStruct ==> ")
	return 1
}

type Person struct {
	Name  string
	Age   int
	Email string
}
