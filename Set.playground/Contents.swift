import Foundation

struct MySet<Element: Equatable> {
    var storage: [Element] = []
    
    var isEmpty: Bool {
        return storage.isEmpty
    }
    
    func contains(_ element: Element) -> Bool {
        return storage.contains(element)
    }
    
    func inserting(_ x: Element) -> MySet {
        return contains(x) ? self : MySet(storage: storage + [x])
    }
}

indirect enum BinarySearchTree<Element: Comparable> {
    case leaf
    case node(BinarySearchTree<Element>, Element, BinarySearchTree<Element>)
}

let leaf: BinarySearchTree<Int> = .leaf
let five: BinarySearchTree<Int> = .node(leaf, 5, leaf)

extension BinarySearchTree {
    init() {
        self = .leaf
    }
    
    init(_ value: Element) {
        self = .node(.leaf, value, .leaf)
    }
}

extension BinarySearchTree {
    var count: Int {
        switch self {
        case .leaf:
            return 0
        case let .node(left, _, right):
            return 1 + left.count + right.count
        }
    }
}

extension BinarySearchTree {
    var elements: [Element] {
        switch self {
        case .leaf:
            return []
        case let .node(left, value, right):
            return left.elements + [value] + right.elements
        }
    }
}

extension BinarySearchTree {
    func reduce<A>(leaf leafF: A, node nodeF:(A, Element, A) -> A) -> A {
        switch self {
        case .leaf:
            return leafF
        case let .node(left, value, right):
            return nodeF(left.reduce(leaf: leafF, node: nodeF), value, right.reduce(leaf: leafF, node: nodeF))
        }
    }
}

extension BinarySearchTree {
    var elemetsR: [Element] {
        return reduce(leaf: []) { $0 + [$1] + $2 }
    }
    
    var countR: Int {
        return reduce(leaf: 0) { 1 + $0 + $2 }
    }
}

extension BinarySearchTree {
    var isEmpty: Bool {
        if case .leaf = self {
            return true
        }
        return false
    }
}

extension Sequence {
    func all(predicate: (Iterator.Element) -> Bool) -> Bool {
        for x in self where !predicate(x) {
            return false
        }
        return true
    }
}

extension BinarySearchTree {
    var isBST: Bool {
        switch self {
        case .leaf:
            return true
        case let .node(left, value, right):
            return left.elements.all { $0 < value } &&
                right.elements.all { $0 > value } &&
                left.isBST &&
                right.isBST
        }
    }
}

extension BinarySearchTree {
    func contains(_ x: Element) -> Bool {
        switch self {
        case .leaf:
            return false
        case let .node(_, y, _) where x == y:
            return true
        case let .node(left, y, _) where x < y:
            return left.contains(x)
        case let .node(_, y, right) where y > x:
            return right.contains(x)
        default:
            fatalError("The impossible occurred")
        }
    }
}

extension BinarySearchTree {
    mutating func insert(_ x: Element) {
        switch self {
        case .leaf:
            self = BinarySearchTree(x)
        case .node(var left, let value, var right):
            if x < value {
                left.insert(x)
            } else if x > value {
                right.insert(x)
            }
            self = .node(left, value, right)
        }
    }
}

let myTree: BinarySearchTree<Int> = BinarySearchTree()
var copied = myTree
copied.insert(5)
myTree.elements

let formatter = NumberFormatter()
formatter.locale = Locale(identifier: "zh-Hant")
formatter.roundingMode = .halfDown
formatter.numberStyle = .spellOut
formatter.string(from: 10)

extension String {
    func complete(history: [String]) -> [String] {
        return history.filter { $0.hasPrefix(self) }
    }
}

struct Trie<Element: Hashable> {
    var isElement: Bool
    var children: [Element: Trie<Element>]
}

extension Trie {
    init() {
        isElement = false
        children = [:]
    }
}

extension Trie {
    var elements: [[Element]] {
        var result:[[Element]] = isElement ? [[]] : []
        for (key, value) in children {
            result += value.elements.map { [key] + $0 }
        }
        print(result)
        return result
    }
}

extension Array {
    var slice: ArraySlice<Element> {
        return ArraySlice(self)
    }
}

extension ArraySlice {
    var decomposed: (Element, ArraySlice<Element>)? {
        return isEmpty ? nil : (self[startIndex], self.dropFirst())
    }
}

func sum(_ integers: ArraySlice<Int>) -> Int {
    guard let (head, tail) = integers.decomposed else {
        return 0
    }
    return head + sum(tail)
}

sum([1, 2, 3, 4, 5].slice)

extension Trie {
    func lookup(key: ArraySlice<Element>) -> Bool {
        guard let (head, tail) = key.decomposed else {
            return isElement
        }
        guard let subtrie = children[head] else {
            return false
        }
        return subtrie.lookup(key: tail)
    }

    func lookup(key: ArraySlice<Element>) -> Trie<Element>? {
        guard let (head, tail) = key.decomposed else {
            return self
        }
        guard let remainder = children[head] else {
            return nil
        }
        return remainder.lookup(key: tail)
    }
}

extension Trie {
    func complete(key: ArraySlice<Element>)-> [[Element]] {
        return lookup(key: key)?.elements ?? []
    }
}

extension Trie {
    init(_ key: ArraySlice<Element>) {
        if let (head, tail) = key.decomposed {
            let children = [head: Trie(tail)]
            self = Trie(isElement: false, children: children)
        } else {
            self = Trie(isElement: true, children: [:])
        }
    }
}

extension Trie {
    func inserting(_ key: ArraySlice<Element>) -> Trie<Element> {
        guard let (head, tail) = key.decomposed else {
            return Trie(isElement: true, children: children)
        }
        var newChildren = children
        if let nextTrie = children[head] {
            newChildren[head] = nextTrie.inserting(tail)
        } else {
            newChildren[head] = Trie(tail)
        }
        return Trie(isElement: isElement, children: newChildren)
    }

    mutating func insert(_ key: ArraySlice<Element>) {
        guard let (head, tail) = key.decomposed else {
            return
        }
        if var nextTrie = children[head] {
            nextTrie.insert(tail)
            children[head] = nextTrie
        } else {
            children[head] = Trie(tail)
        }
    }
}

extension Trie {
    static func build(words: [String]) -> Trie<Character> {
        let emptyTrie = Trie<Character>()
        return words.reduce(emptyTrie) {
            $0.inserting(Array($1).slice)
        }
    }
}

extension String {
    func complete(_ knownWords: Trie<Character>) -> [String] {
        let chars = Array(self).slice
        let completed = knownWords.complete(key: chars)
        return completed.map { self + String($0) }
    }
}

let contents = ["cat", "car", "cart", "dog"]
let trieOfWords = Trie<Character>.build(words: contents)
"car".complete(trieOfWords)
