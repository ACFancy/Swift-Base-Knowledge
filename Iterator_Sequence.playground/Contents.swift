import UIKit

protocol IteratorProtocol2 {
    associatedtype Element
    mutating func next() -> Element?
}

struct ReverseIndexIterator: IteratorProtocol2, IteratorProtocol {
    typealias Element = Int
    var index: Int
    
    init<T>(array: [T]) {
        index = array.endIndex - 1
    }
    
    mutating func next() -> Int? {
        guard index >= 0 else {
            return nil
        }
        defer {
            index -= 1
        }
        return index
    }
}

let letters = ["A", "B", "C"]

var iterator = ReverseIndexIterator(array: letters)
while let i = iterator.next() {
    print("Element \(i) of thee array is \(letters[i])")
}

struct PowerIterator: IteratorProtocol2 {
    typealias Element = NSDecimalNumber
    var power: NSDecimalNumber = 1
    
    mutating func next() -> NSDecimalNumber? {
        power = power.multiplying(by: 2)
        return power
    }
}

extension PowerIterator {
    mutating func find(where predicate: (NSDecimalNumber) -> Bool) -> NSDecimalNumber? {
        while let x = next() {
            if predicate(x) {
                return x
            }
        }
        return nil
    }
}

var powerIterator = PowerIterator()
let findNumber = powerIterator.find { $0.intValue > 1000 }
print(findNumber)

struct FileLineIterator: IteratorProtocol2 {
    typealias Element = String
    let lines: [String]
    var currentLine: Int = 0
    
    init(filename: String) throws {
        let contents: String = try String(contentsOfFile: filename)
        lines = contents.components(separatedBy: .newlines)
    }
    
    mutating func next() -> String? {
        guard currentLine < lines.endIndex else {
            return nil
        }
        defer {
            currentLine += 1
        }
        return lines[currentLine]
    }
}


extension IteratorProtocol2 {
    mutating func find(predicate: (Element) -> Bool) -> Element? {
        while let x = next() {
            if predicate(x) {
                return x
            }
        }
        return nil
    }
}

struct LimitIterator<I: IteratorProtocol2>: IteratorProtocol2 {
    typealias Element = I.Element
    var limit = 0
    var iterator: I
    
    init(limit: Int, iterator: I) {
        self.limit = limit
        self.iterator = iterator
    }
    
    mutating func next() -> Element? {
        guard limit > 0 else {
            return nil
        }
        limit -= 1
        return iterator.next()
    }
}

extension Int {
    func countDown() -> AnyIterator<Int> {
        var i = self - 1
        return AnyIterator {
            guard i >= 0 else {
                return nil
            }
            defer {
                i -= 1
            }
            return i
        }
    }
}

func +<I: IteratorProtocol2, J: IteratorProtocol2>(first: I, second: J) -> AnyIterator<I.Element> where I.Element == J.Element {
    var i = first
    var j = second
    return AnyIterator { i.next() ?? j.next() }
}

func +<I: IteratorProtocol2, J: IteratorProtocol2>(first: I, second: @escaping @autoclosure () -> J) -> AnyIterator<I.Element> where I.Element == J.Element {
    var one = first
    var other: J? = nil
    return AnyIterator {
        if var other = other {
            return other.next()
        } else if let result = one.next() {
            return result
        } else {
            other = second()
            return other?.next()
        }
    }
}

func +<I: IteratorProtocol, J: IteratorProtocol>(first: I, second: @escaping @autoclosure () -> J) -> AnyIterator<I.Element> where I.Element == J.Element {
    var one = first
    var other: J? = nil
    return AnyIterator {
        if var other = other {
            return other.next()
        } else if let result = one.next() {
            return result
        } else {
            other = second()
            return other?.next()
        }
    }
}

// 序列
protocol Sequence2 {
    associatedtype Iterator: IteratorProtocol2
    func makeIterator() -> Iterator
}

struct ReverseArrayIndices<T>: Sequence2, Sequence {
    typealias Iterator = ReverseIndexIterator
    
    let array: [T]
    
    init(array: [T]) {
        self.array = array
    }
    
    func makeIterator() -> ReverseIndexIterator {
        return ReverseIndexIterator(array: array)
    }
}

var array = ["one", "two", "three"]
let reverseSequence = ReverseArrayIndices(array: array)
var reverseIterator = reverseSequence.makeIterator()

while let i = reverseIterator.next() {
    print("Index \(i) is \(array[i])")
}

for i in ReverseArrayIndices(array: array) {
    print("index \(i) is \(array[i])")
}

let reverseElements = ReverseArrayIndices(array: array).map { array[$0] }
for x in reverseElements {
    print("Elements is \(x)")
}

let results = (1...10).filter { $0 % 3 == 0 }.map { $0 * $0 }
print(results)

// “使用 lazy 来合并所有的循环”
let lazyResults = (1...10).lazy.filter { $0 % 3 == 0 }.map { $0 * $0 }
print(Array(lazyResults))

// 遍历二叉树
indirect enum BinarySearchTree<Element: Comparable> {
    case leaf
    case node(BinarySearchTree<Element>, Element, BinarySearchTree<Element>)
}

extension BinarySearchTree: Sequence {
    func makeIterator() -> AnyIterator<Element> {
        switch self {
        case .leaf:
            return AnyIterator { return nil }
        case let .node(l, element, r):
            return l.makeIterator() + CollectionOfOne(element).makeIterator() + r.makeIterator()
        }
    }
}

// 优化QuickCheck 范围收缩
public protocol Smaller {
    //    func smaller() -> Self?
    func smaller() -> AnyIterator<Self>
}

extension Array: Smaller {
    //    public func smaller() -> [Element]? {
    //        guard !self.isEmpty else {
    //            return nil
    //        }
    //        return Array(dropFirst())
    //    }
    
    public func smaller() -> AnyIterator<[Element]> {
        var i = 0
        return AnyIterator {
            guard i < self.endIndex else {
                return nil
            }
            var result = self
            result.remove(at: i)
            i += 1
            print(result)
            return result
        }
    }
}

Array([1, 2, 3].smaller())

/// 解析器组合算子
//typealias Parser<Result> = (String) -> (Result, String)?

//typealias Stream = String.UnicodeScalarView
//typealias Parser<Result> = (Stream) -> (Result, Stream)?

struct Parser<Result> {
    typealias Stream = String
    let parse: (Stream) -> (Result, Stream)?
}

func character(condition: @escaping(Character) -> Bool) -> Parser<Character> {
    return Parser { input in
        guard let char = input.first, condition(char) else {
            return nil
        }
        return (char, [Character](input).dropFirst().map { String($0) }.joined())
    }
}

let one  = character { $0 == "1" }
print(one.parse("123"))

extension Parser {
    func run(_ string: String) -> (Result, String)? {
        guard let (result, remainder) = parse(string) else {
            return nil
        }
        return (result, remainder)
    }
}

print(one.run("136"))

extension CharacterSet {
    func contains(_ c: Character) -> Bool {
        let scalars = String(c).unicodeScalars
        guard scalars.count == 1 else {
            return false
        }
        return contains(scalars.first!)
    }
}

let digit = character { CharacterSet.decimalDigits.contains($0) }
print(digit.run("456abc"))

// 组合解析器
extension Parser {
    var many: Parser<[Result]> {
        return Parser<[Result]> { input in
            var result: [Result] = []
            var remainder = input
            while let (element, newRemainder) = self.parse(remainder) {
                result.append(element)
                remainder = newRemainder
            }
            return (result, remainder)
        }
    }
}
print(digit.many.run("1234abc"))

// map
extension Parser {
    func map<T>(_ transform: @escaping (Result) -> T) -> Parser<T> {
        return Parser<T> { input in
            guard let (result, remainder) = self.parse(input) else { return nil }
            return (transform(result), remainder)
        }
    }
}

let integer = digit.many1.map { Int(String($0))! }
print(integer.run("212aa"))
//print(integer.run(""))

// 顺序解析
extension Parser {
    func followed<A>(by other: Parser<A>) -> Parser<(Result, A)> {
        return Parser<(Result, A)> { input in
            guard let (result1, remainder1) = self.parse(input) else {
                return nil
            }
            guard let (result2, remainder2) = other.parse(remainder1) else {
                return nil
            }
            return ((result1, result2), remainder2)
        }
    }
}

let multiplication = integer.followed(by: character(condition: { $0 == "*" }))
    .followed(by: integer)
print(multiplication.run("2*3"))

let multiplication2 = multiplication.map { ($0.0 ?? 0) * ($1 ?? 0) }
print(multiplication2.run("2*3"))

// 改进

func multiply(lhs: (Int, Character), rhs: Int) -> Int {
    return lhs.0 * rhs
}

func multipy(x: Int, _ op: Character, _  y: Int) -> Int {
    return x * y
}

func curriedMultiply(_ x: Int) -> (Character) -> (Int) -> Int {
    return { op in
        return { y in
            return x * y
        }
    }
}

print(curriedMultiply(2)("*")(3))

// 柯里化操作抽象定义
func curry<A, B, C>(_ f: @escaping(A, B) -> C) -> (A) -> (B) -> (C) {
    return { a in { b in f(a, b) }}
}

//TODO:需要好好理解下
let p1 = integer.map(curriedMultiply)
let p2 = p1.followed(by: character { $0 == "*"})

let p3 = p2.map { f, op in f(op) }
let p4 = p3.followed(by: integer)
let p5 = p4.map { f, y in f(y) }
print(p5.run("5*5"))

//let multiplication3 = integer.map(curriedMultiply)
//    .followed(by: character{ $0 == "*"}).map { f, op in f(op) }
//    .followed(by: integer).map { f, y in f(y) }
//
//func <*>(lhs: Parser<...>, rhs: Parser<...>) -> Parser<...> {
//return lhs.followed(by: rhs).map { f, x in f(x) }
//}
precedencegroup SequencePrecedence {
    associativity: left
    higherThan: AdditionPrecedence
}
infix operator <*> : SequencePrecedence
func <*><A, B>(lhs: Parser<(A) -> B>, rhs: Parser<A>) -> Parser<B> {
    return lhs.followed(by: rhs).map { f, x in f(x) }
}
let multiplication4 = integer.map(curriedMultiply) <*> character{ $0 == "*" } <*> integer


infix operator <^> : SequencePrecedence
func <^><A, B>(lhs:@escaping(A) -> B, rhs: Parser<A>) -> Parser<B> {
    return rhs.map(lhs)
}
let multiplication5 = curriedMultiply <^> integer <*> character{ $0 == "*" } <*> integer

infix operator ~> : SequencePrecedence
func ~><A, B>(lhs: Parser<A>, rhs: Parser<B>) -> Parser<B> {
    return curry({_, y in y}) <^> lhs <*> rhs
}

infix operator <~ : SequencePrecedence
func <~<A, B>(lhs: Parser<A>, rhs: Parser<B>) -> Parser<A> {
    return curry({x, _ in x}) <^> lhs <*> rhs
}

extension Parser {
    func or(_ other: Parser<Result>) -> Parser<Result> {
        return Parser<Result> { input in
            return self.parse(input) ?? other.parse(input)
        }
    }
}

let star = character(condition: { $0 == "*" })
let plus = character(condition: { $0 == "+" })
let starOrPlus = star.or(plus)
print(starOrPlus.run("+*"))

infix operator <|>: SequencePrecedence
func <|><A>(lhs: Parser<A>, rhs: Parser<A>) -> Parser<A> {
    return lhs.or(rhs)
}
let resOp = (star<|>plus).run("+*")
print(resOp ?? "")

// 一次或更多次解析
extension Parser {
    var many1: Parser<[Result]> {
        return { x in { manyX in [x] + manyX }}<^>self<*>self.many
    }
    
    var many2: Parser<[Result]> {
        return curry({ [$0] + $1 })<^>self<*>self.many
    }
}

// 可选
extension Parser {
    var optional: Parser<Result?> {
        return Parser<Result?> { input in
            guard let (result, remainder) = self.parse(input) else {
                return (nil, input)
            }
            return (result, remainder)
        }
    }
}

// 解析算式表达式
let tmultiplication = curry({ $0 * ($1 ?? 1) }) <^> integer <*> (character{ $0 == "*" } ~> integer).optional
// 研究下
let tdivision = curry({ $0 / ($1 ?? 1) }) <^> tmultiplication <*> (character{ $0 == "/" } ~> tmultiplication).optional
let taddition = curry({ $0 + ($1 ?? 0) }) <^> tdivision <*> (character{ $0 == "+" } ~> tdivision).optional
let tminus = curry({ $0 - ($1 ?? 0) }) <^> taddition <*> (character{ $0 == "-" } ~> taddition).optional
let texpression = tminus
print(texpression.run("2*3+4*6/2-10"))


// 更swift化的解析器类型
struct Parser2<Result> {
    typealias Stream = String
    let parse:(inout Stream) -> Result?
}

extension Parser2 {
    var many: Parser2<[Result]> {
        return Parser2<[Result]> { input in
            var result: [Result] = []
            while let element = self.parse(&input) {
                result.append(element)
            }
            return result
        }
    }
}

extension Parser2 {
    func or(_ other: Parser2<Result>) -> Parser2<Result> {
        return Parser2<Result> { input in
            let original = input
            if let result = self.parse(&input) {
                return result
            }
            input = original
            return other.parse(&input)
        }
    }
}

let multiplication6 = curry({ $0 * ($1 ?? 1) }) <^> integer <*> (character{ $0 == "*" } ~> integer).optional

indirect enum Expression {
    case int(Int)
    case reference(String, Int)
    case infix(Expression, String, Expression)
    case function(String, Expression)
}

extension Expression {
    static var intParser: Parser<Expression> {
        return {.int($0)} <^> integer
    }
}

let capitalLetter = character { CharacterSet.uppercaseLetters.contains($0) }

extension Expression {
    static var referenceParser: Parser<Expression> {
        return curry({ .reference(String($0), $1) }) <^> capitalLetter <*> integer
    }
}


func string(_ string: String) -> Parser<String> {
    return Parser<String> { input in
        var remainder = input
        let chars = [Character](input) // Array(arrayLiteral: input).map({ Character($0) })
        for c in chars {
            let parser = character { $0 == c }
            guard let (_, newRemainder) = parser.parse(remainder) else {
                return nil
            }
            remainder = newRemainder
        }
        return (string, remainder)
    }
}

print(string("SUM").run("SUM"))

extension Parser {
    var parenthesized: Parser<Result> {
        return string("(") ~> self <~ string(")")
    }
}

print(string("SUM").parenthesized.run("(SUM)"))

func curry<A, B, C, D>(_ f: @escaping(A, B, C) -> D) -> (A) -> (B) -> (C) -> D {
    return {a in { b in { c in f(a, b, c)} }}
}

extension Expression {
    static var functionParser: Parser<Expression> {
        let name = { String($0) } <^> capitalLetter.many1
        let argument = curry({ Expression.infix($0, String($1), $2) }) <^> referenceParser <*> string(":") <*> referenceParser
        return curry({ .function($0, $1) }) <^> name <*> argument.parenthesized
    }
}

func combineOperands(first: Expression, _ rest: [(String, Expression)]) -> Expression {
    return rest.reduce(first) { result, pair in
        return Expression.infix(result, pair.0, pair.1)
    }
}

extension Expression {
    //    static var productParser: Parser<Expression> {
    //        let multiplier = curry({ ($0, $1) }) <^> (string("*") <|> string("/")) <*> intParser
    //        return curry(combineOperands) <^> intParser <*> multiplier.many
    //    }
}

func lazy<A>(_ parser: @autoclosure @escaping () -> Parser<A>) -> Parser<A> {
    return Parser<A> { parser().parse($0) }
}

extension Expression {
    static var primitiveParser: Parser<Expression> {
        return intParser <|> referenceParser <|> functionParser <|> lazy(parser).parenthesized
    }
    
    static var productParser: Parser<Expression> {
        let multiplier = curry({ ($0, $1) }) <^> (string("*") <|> string("/")) <*> primitiveParser
        return curry(combineOperands) <^> primitiveParser <*> multiplier.many
    }
    
    static var sumParser: Parser<Expression> {
        let summand = curry({ ($0, $1) }) <^> (string("+") <|> string("-")) <*> productParser
        return curry(combineOperands) <^> productParser <*> summand.many
    }
    
    static var parser = sumParser
}
print(Expression.parser.run("2+4*SUM(A1:A2)")?.0)
