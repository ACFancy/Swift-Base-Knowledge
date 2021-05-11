import UIKit

let cities = ["Paris": 2241,
              "Madrid": 3165,
              "Amsterdam": 827,
              "Berlin": 3562]

// Error Operation
//let madridPopulation: Int = cities["Madrid"]

let madridPopulation: Int? = cities["Madrid"]

if let madridPopulation = cities["Madrid"] {
    print("\(madridPopulation)")
}

infix operator ??
func ??<T>(optional: T?, defaultValue: @autoclosure () throws -> T) rethrows -> T {
    if let x = optional {
        return x
    } else {
        return try defaultValue()
    }
}

let madridPopulation2 = cities["Madrid"] ?? 88

// 可选链
struct Order {
    let orderNumber: Int
    let person: Person?
}

struct Person {
    let name: String
    let address: Address?
}

struct Address {
    let streetName: String
    let city: String
    let state: String?
}

let order = Order(orderNumber: 42, person: nil)

// crash operation
//order.person!.address!.state!
if let person = order.person,
   let address = person.address,
   let state = address.state {
    print(state)
}
/**
 “我们使用了问号运算符来尝试对可选类型进行解包，而不是强制将它们解包。访问任意属性失败时，都将会导致整条语句链返回 ni”
 */
if let myState = order.person?.address?.state {
    print(myState)
}
// 可选分支 switch guard
switch madridPopulation {
case 0?: print("xxx")
case (1..<1000)?: print("ssss")
case let x?: print(x)
case nil: print("Nil")
}

func populationDescription(for city: String) -> String? {
    guard let population = cities[city] else {
        return nil
    }
    return "\(population)"
}

// 可选映射
func increment(optional: Int?) -> Int? {
    guard let x = optional else { return nil }
    return x + 1
}

extension Optional {
    func map<U>(_ transform: (Wrapped) -> U) -> U? {
        guard let x = self else { return nil }
        return transform(x)
    }
}

func increment2(optional: Int?) -> Int? {
    return optional.map { $0 + 1 }
}

//可选绑定
func add(_ optionalX: Int?, _ optionalY: Int?) -> Int? {
    //    if let x = optionalX, let y = optionalY {
    //        return x + y
    //    }
    //    return nil
    guard let x = optionalX, let y = optionalY else {
        return nil
    }
    return x + y
}

let capitals = [
    "France": "Paris",
    "Spain": "Madrid",
    "The Netherlands": "Amsterdam",
    "Belgium": "Brussels"
]

func populationOfCapital(country: String) -> Int? {
    guard let capital = capitals[country], let population = cities[capital] else {
        return nil
    }
    return population * 1000
}

/**
 “可选链和 if let (或 guard let) 都是语言中让可选值能够更易于使用的特殊构造。不过，Swift 还提供了另一条途径来解决上述问题：那就是借力于标准库中的 flatMap 函数。多种类型中都定义了flatMap 函数，在可选值类型的情况下，它的定义是这样的”
 */
extension Optional {
    func flatMap2<U>(_ transform: (Wrapped) -> U?) -> U? {
        guard let x = self else {
            return nil
        }
        return transform(x)
    }
}

func add2(_ optionalX: Int?, _ optionalY: Int?) -> Int? {
    return optionalX.flatMap2 { x in
        optionalY.flatMap2 { y in
            return x + y
        }
    }
}

func populationOfCapital3(country: String) -> Int? {
    return capitals[country].flatMap2 { capital in
        cities[capital].flatMap2 { population in
            return population * 1000
        }
    }
}

// 也可以链式调用
func populationOfCapital4(country: String) -> Int? {
    return capitals[country].flatMap2 { capital in
        cities[capital]
    }.flatMap2 { population in
        population * 1000
    }
}

/**
 “选择显式的可选类型更符合 Swift 增强静态安全的特性。强大的类型系统能在代码执行前捕获到错误，而且显式可选类型有助于避免由缺失值导致的意外崩溃。”
 “类型系统将有助于你捕捉难以察觉的细微错误。其中一些错误很容易在开发过程中被发现，但是其余的可能会一直留存到生产代码中去。坚持使用可选值能够从根本上杜绝这类错误。”
 */

func plusIsCommmutative(x: Int, y: Int) -> Bool {
    return x + y == y + x
}

//check("Plus should be commutative", plusIsCommmutative)

func minusIsCommutative(x: Int, y: Int) -> Bool {
    return x - y == y - x
}

//check("Minus should be commutative", minusIsCommutative)

//尾随闭包特性
//check("Additive identity") {(x: Int) in  x + 0 == x }

// QuickCheck
let numberOfIterations = 10
public protocol Arbitrary {
    static func arbitrary() -> Self
}

extension Int: Arbitrary {
    public static func arbitrary() -> Int {
        return Int(arc4random())
    }
}

Int.arbitrary()

extension Int {
    static func arbitrary(in range: CountableRange<Int>) -> Int {
        let diff = range.upperBound - range.lowerBound
        return range.lowerBound + (Int.arbitrary() % diff)
    }
}

extension UnicodeScalar: Arbitrary {
    public static func arbitrary() -> Unicode.Scalar {
        return UnicodeScalar(Int.arbitrary(in: 65..<90))!
    }
}

extension String: Arbitrary {
    public static func arbitrary() -> String {
        let randomLength = Int.arbitrary(in: 0..<40)
        let randomScalars = (0..<randomLength).map { _ in
            UnicodeScalar.arbitrary()
        }
        return String(UnicodeScalarView(randomScalars))
    }
}

String.arbitrary()

func check1<A: Arbitrary>(_ message: String, _ property: (A) -> Bool) {
    for _ in 0..<numberOfIterations {
        let value = A.arbitrary()
        guard property(value) else {
            print("\(message) doesn't hold: \(value)")
            return
        }
    }
    print("\(message) passed \(numberOfIterations) tests.")
}

extension CGSize {
    var area: CGFloat {
        return width * height
    }
}

extension CGSize: Arbitrary {
    public static func arbitrary() -> CGSize {
        return CGSize(width: .arbitrary(), height: .arbitrary())
    }
}

check1("Area should be at least 0") { (size: CGSize) in size.area >= 0 }

//缩小范围
check1("Every string starts with Hello") {(s: String) in s.hasPrefix("Hello") }

public protocol Smaller {
    func smaller() -> Self?
}

extension Int: Smaller {
    public func smaller() -> Int? {
        return self == 0 ? nil : self / 2
    }
}
100.smaller()

extension String: Smaller {
    var characters: [Character] {
        return Array(self)
    }

    public func smaller() -> String? {
        return isEmpty ? nil : String(characters.dropFirst())
    }
}

public protocol Arbitrary2: Smaller {
    static func arbitrary() -> Self
}

// 反复缩小范围
func iterate<A>(while condition: (A) -> Bool, inital: A, next:(A) ->A?) -> A {
    guard let x = next(inital), condition(x) else {
        return inital
    }
    return iterate(while: condition, inital: x, next: next)
}

func check2<A: Arbitrary2>(_ message: String, _ property:(A) -> Bool) {
    for _ in 0..<numberOfIterations {
        let value = A.arbitrary()
        guard property(value) else {
            let smallerValue = iterate(while: { !property($0) }, inital: value) {
                $0.smaller()
            }
            print("\(message) doesn't hold: \(smallerValue)")
            return
        }
    }
    print("\(message) passed \(numberOfIterations) tests.")
}

func qsort(_ input: [Int]) -> [Int] {
    var array = input
    if array.isEmpty {
        return []
    }
    let pivot = array.removeFirst()
    let lesser = array.filter({ $0 < pivot })
    let greater = array.filter({ $0 >= pivot })
    let intermediate = qsort(lesser) + [pivot]
    return intermediate + qsort(greater)
}

extension Array: Smaller {
    public func smaller() -> Array<Element>? {
        guard !isEmpty else {
            return nil
        }
        return Array(dropLast())
    }
}

extension Array: Arbitrary2 where Element: Arbitrary2 {
    public static func arbitrary() -> [Element] {
        let randomLength = Int.arbitrary(in: 0..<50)
        return (0..<randomLength).map { _ in
            .arbitrary()
        }
    }
}

extension Int: Arbitrary2 {}

check2("qsort should behave like sort") { (x: [Int]) -> Bool in
    return qsort(x) == x.sorted()
}


struct ArbitraryInstance<T> {
    let arbitrary: () -> T
    let smaller: (T) -> T?
}

func checkHelper<A>(_ arbitraryInstance: ArbitraryInstance<A>, _ property: (A) -> Bool, _ message: String) {
    for _ in 0..<numberOfIterations {
        let value = arbitraryInstance.arbitrary()
        guard property(value) else {
            let smallerValue = iterate(while: { !property($0) }, inital: value, next: arbitraryInstance.smaller)
            print("\(message) doesn't hold: \(smallerValue)")
            return
        }
    }
    print("\(message) passed \(numberOfIterations) tests.")
}

func check3<X: Arbitrary2>(_ message: String, property:(X) -> Bool) {
    let instance = ArbitraryInstance(arbitrary: X.arbitrary, smaller: { $0.smaller() })
    checkHelper(instance, property, message)
}

func check4<X: Arbitrary2>(_ message: String, _ property: ([X]) -> Bool) {
    let instance = ArbitraryInstance(arbitrary: Array.arbitrary, smaller: { (x: [X]) in x.smaller()})
    checkHelper(instance, property, message)
}

check4("qsort should behave like sort") { (x: [Int]) -> Bool in
    return qsort(x) == x.sorted()
}




