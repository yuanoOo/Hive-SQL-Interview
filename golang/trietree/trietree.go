package main

import "fmt"

// Trie 树节点
type trieNode struct {
	char     string             // Unicode 字符
	isEnding bool               // 是否是单词结尾
	children map[rune]*trieNode // 该节点的子节点
}

// 初始化 Trie 树节点
func NewTrieNode(char string) *trieNode {
	return &trieNode{
		char:     char,
		isEnding: false,
		children: make(map[rune]*trieNode),
	}
}

// Trie 树结构
type Trie struct {
	root *trieNode // 根节点指针
}

// 初始化 Trie 树
func NewTrie() *Trie {
	// 初始化根节点
	trieNode := NewTrieNode("/")
	return &Trie{trieNode}
}

// 往 Trie 树中插入一个单词
func (t *Trie) Insert(word string) {
	node := t.root              // 获取根节点
	for _, code := range word { // 以 Unicode 字符遍历该单词
		value, ok := node.children[code] // 获取 code 编码对应子节点
		if !ok {
			// 不存在则初始化该节点
			value = NewTrieNode(string(code))
			// 然后将其添加到子节点字典
			node.children[code] = value
		}
		// 当前节点指针指向当前子节点
		node = value
		// fmt.Println(node.char)
	}
	node.isEnding = true // 一个单词遍历完所有字符后将结尾字符打上标记
}

// 在 Trie 树中查找一个单词
func (t *Trie) Find(word string) bool {
	node := t.root
	for _, code := range word {
		value, ok := node.children[code] // 获取对应子节点
		if !ok {
			// 不存在则直接返回
			return false
		}
		// 否则继续往后遍历
		node = value
	}

	return node.isEnding

	// if node.isEnding == false {
	// 	return false // 不能完全匹配，只是前缀
	// }
	// return true // 找到对应单词
}

func main() {
	fmt.Println(int('0'))
	trie := NewTrie()
	words := []string{"Golang", "学院君", "Language", "Trie", "Go"}
	for _, word := range words {
		trie.Insert(word)
	}
	term := "学院君"
	if trie.Find(term) {
		fmt.Printf("包含单词\"%s\"\n", term)
	} else {
		fmt.Printf("不包含单词\"%s\"\n", term)
	}
}
