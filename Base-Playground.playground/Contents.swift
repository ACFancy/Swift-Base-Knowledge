import UIKit

//let data = "test+/=".data(using: .utf8)
//let str = data?.base64EncodedString()
//print(str)
//
//let str1 = " ; ; ;"
//let array = str1.split(separator: ";")
//print(array)
//
//let str2 = Array(repeating: " ", count: 0).joined()
//
//let ttArray = ["1", "2", "3"]
//ttArray.enumerated().compactMap({ $0 })

//let decimal = NSDecimalNumber(string: "4.17", locale: Locale(identifier: "en-US"))
//let format = NumberFormatter()
//format.locale = Locale(identifier: "ar-iq")
////format.formatterBehavior = .behavior10_4
////format.minimumFractionDigits = 99
//format.minimumFractionDigits = 2
//format.maximumFractionDigits = 99
////format.numberStyle = .currency
//format.currencySymbol
//format.currencyCode
//let str = format.string(from: decimal)
////_ = format.minimum
////_ = format.maximum
//let d = decimal.doubleValue
//let tt = Int("0000000000000 ")
//print("tt: \(String(describing: tt))")
let ttp = String(format: "%.0lf%%", 22.5)
let cc: ContiguousArray<NSObject> = [NSNumber(value: 10)]

var a = [1, 2, 3]
var b = [3, 5, 6, 1]
var c = [4, 7, 0, 10, 111]
for i in 0...2 {
    c[i] = a[i] &+ b[i]
}
print(c)

let t = Int.max &+ 1
print(t, Int.min)
final class Ref<T> {
    var val: T
    init(_ v: T) {
        val = v
    }
}

struct Box<T> {
    var ref: Ref<T>
    init(_ x: T) {
        ref = Ref(x)
    }

    var value: T {
        get {
            return ref.val
        }
        set {
            if !isKnownUniquelyReferenced(&ref) {
                ref = Ref(newValue)
                return
            }
            ref.val = newValue
        }
    }
}

class Node {
    var next: Node?
    var value: Int
    init(_ value: Int) {
        self.value = value
    }
}

/// 自行管理引用计数（性能上的处理）
var next = Node(6)
var head = Node(7)
head.next = next
withExtendedLifetime(head) {
    var Ref: Unmanaged<Node> = Unmanaged.passUnretained(head)
    while let Next = Ref._withUnsafeGuaranteedRef({ $0.next }) {
        Ref = Unmanaged.passUnretained(Next)
    }
}

/// 仅仅用于class的协议
protocol SS: class {

}
protocol Pingable: AnyObject {

}

@propertyWrapper
struct Wrapper<T: SignedNumeric> {
    var wrappedValue: T

    var projectedValue: Wrapper<T> { return self }

    func foo() { print("Foo") }

    struct HasWrapper {
        @Wrapper var x = 0

        func foo() {
            print(x)
            print(_x)
            print($x)
        }

    }
}

Wrapper.HasWrapper(x: 0).foo()
//StringInterpolationProtocol
//ExpressibleByDictionaryLiteral
//ExpressibleByArrayLiteral
//ExpressibleByNilLiteral
//ExpressibleByFloatLiteral
//ExpressibleByStringLiteral
//ExpressibleByIntegerLiteral
//ExpressibleByBooleanLiteral
//ExpressibleByExtendedGraphemeClusterLiteral
//ExpressibleByStringInterpolation
//ExpressibleByUnicodeScalarLiteral

//ExpressibleByDictionaryLiteral
var countryCodes = Dictionary<String, Any>()
countryCodes["BR"] = "Brazil"
countryCodes["GH"] = "Ghana"

let countryCodes2 = ["BR": "Brazil", "GH": "Ghana"]

//Sequence for in
//IteratorProtocol
//Sequence 无限

let animals = ["Antelope", "Butterfly", "Camel", "Dolphin"]
for animal in animals {
    print(animal)
}
var animalIterator = animals.makeIterator()
while let animal = animalIterator.next() {
    print(animal)
}

//Collection 有限 下标访问，元素个数 Array Dictionary Set

//CustomStringConvertible
struct Point: CustomStringConvertible {
    let x, y: Int
    var description: String {
        return "(\(x), \(y))"
    }
}
let p = Point(x: 1, y: 2)
print(p)
let s = String(describing: p)
print(s)

// Hashable Dictionary Set
struct Color: Hashable {
    let red: UInt8
    let green: UInt8
    let blue: UInt8

    func hash(into hasher: inout Hasher) {
        hasher.combine(red)
        hasher.combine(green)
        hasher.combine(blue)
    }

    var hashValue: Int {
        var hasher = Hasher()
        hash(into: &hasher)
        return hasher.finalize()
    }
}

// Codable Ecodable Decodable
let json = """
{
"id": "123123",
"name": "Mik",
"age": 18
}
"""

struct Person: Codable {
    var id: String
    var name: String
    var age: Int
}
//JSONEncoder().encode(json)
let data = json.data(using: .utf8)!
do {
    let mike = try JSONDecoder().decode(Person.self, from: data)
    print(mike)
} catch {
    print("error: \(error)")
}

// Comparable

// RangeReplaceableCollection Array
var bugs = ["Aphid", "Damselfy"]
bugs.append("Earwig")
bugs.insert(contentsOf: ["Bumblebee", "Cicada"], at: 1)
let tempBugs = bugs[0...1]

// @propertyWrapper 属性包装
extension UserDefaults {
    enum Keys {
        static let isFirstLaunch = "isFirstLaunch"
    }
    //    var isFirstLaunch: Bool {
    //        get {
    //            return bool(forKey: Keys.isFirstLaunch)
    //        }
    //        set {
    //            set(newValue, forKey: Keys.isFirstLaunch)
    //        }
    //    }
}

@propertyWrapper
struct UserDefaultWrapper<T> {
    private let key: String
    private let defaultValue: T

    init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

extension UserDefaults {
    @UserDefaultWrapper(key: Keys.isFirstLaunch, defaultValue: false)
    static var isFirstLaunch: Bool
}

@propertyWrapper
struct Clamping<Value: Comparable> {
    var value: Value
    let range: ClosedRange<Value>

    init(wrappedValue: Value, _ range: ClosedRange<Value>) {
        precondition(range.contains(wrappedValue))
        self.value = wrappedValue
        self.range = range
    }

    var wrappedValue: Value {
        get { value }
        set {
            print("sss: \(newValue)")
            value = min(max(range.lowerBound, newValue), range.upperBound)
        }
    }
}

struct Solution {
    @Clamping(0...14) var pH: Double = 7.0
}
var carbonicAcid = Solution()
carbonicAcid.pH = -1
carbonicAcid.pH

@propertyWrapper
struct TwelveOrLess<T> {
    private var number: T
    init(wrappedValue: T) {
        self.number = wrappedValue
    }
    var wrappedValue: T {
        get { return number }
        set { number = newValue }
    }
}


struct SmallRectangle {
    @TwelveOrLess public var height: Int = 0
    @TwelveOrLess public var width: Int = 0
}

var rectangle = SmallRectangle()
print(rectangle.height)
// Prints "0"

rectangle.height = 10
print(rectangle.height)
// Prints "10"

rectangle.height = 24
print(rectangle.height)
// Prints "12"

UserDefaults.isFirstLaunch
let price = 168.0 / 365.0
let numberFormatter = NumberFormatter()
numberFormatter.minimumFractionDigits = 1
numberFormatter.maximumFractionDigits = 1
numberFormatter.numberStyle = .decimal
numberFormatter.roundingMode = .floor
numberFormatter.formatterBehavior = .default
numberFormatter.locale = Locale(identifier: "zh_CN")
let dailyPriceStr = numberFormatter.string(from: NSNumber(value: price))


// public open

// static class final
final class Manager {
    // 单例的声明
    static let shared = Manager()
    // 实例属性，override
    var name: String = "x"
    // instance property, unoverride
    final var lastName: String = "s"
    // 类属性，unoverride
    static var address: String = "d"
    // 类属性， override only for calculated property
    class var code: String {
        return "xxx"
    }

    // 实例函数 override
    func download() {

    }

    // 实例函数，unoverride
    final func download1() {

    }

    // 类函数，override
    class func removeCache() {

    }

    // 类函数，unoverride
    static func download() {

    }
}

//struct和enum因为不能被继承，所以也就无法使用class和final关键词，仅能通过static关键词进行限定

//mutating inout
struct Point2 {
    var x: CGFloat
    var y: CGFloat
    //
    mutating func moveRight(offset: CGFloat) {
        x += offset
    }

    //    func normalSwap(a: CGFloat, b: CGFloat) {
    //        let temp = a
    //        a = b
    //        b = temp
    //    }

    func inoutSwap(a: inout CGFloat, b: inout CGFloat) {
        let temp = a
        a = b
        b = temp
    }
}

var location1: CGFloat = 10
var location2: CGFloat = -10

var point2 = Point2(x: 0, y: 0)
point2.moveRight(offset: location1)
print(point2)

point2.inoutSwap(a: &location1, b: &location2)
print(location1)
print(location2)

// 使用inout 改变传入变量的值

// infix operator

// 定义中缀操作符
infix operator **

func **(left: Double, right: Double) -> Double {
    return pow(left, right)
}

let number = 2 ** 3
print(number)

// 定义阶乘操作，后缀操作符
postfix operator -!
postfix func -!(value: Int) -> Int {
    var res = value
    var value = value
    while value >= 2 {
        res *= (value - 1)
        value -= 1
    }
    return res
}

let number2 = 4-!

// 定义输出操作，前缀操作符
prefix operator <<

prefix func <<(value: Any) {
    print(value)
}
<<"res: \(number2)"

//@dynamicMemberLookup @dynamicCallable

/***
 Swift 面世时就大谈自己的安全特性，现在来了这么一个无限制访问的成员万一返回的是nil不就闪退了？是的，出于安全的原因，如果实现了这个特性，你就不能返回可选值。必须处理好意料外的情况，一定要有值返回。不像常规的subscript方法可以返回可空的值。
 这个方法可以被重载。和泛型的逻辑类似，会根据你要的返回值而通过类型推断来选择对应的subscript方法。
 需要注意的是如果声明在类上，那么他的子类也会具有动态查找成员的能力。
 */
@dynamicMemberLookup
struct Person3 {
    subscript(dynamicMember dynamicMember: String) -> String {
        let properties = ["ss": "ss", "dd": "ff", "gg": "aa"]
        return properties[dynamicMember, default: "undefined"]
    }
}

let p3 = Person3()
print(p3.ss)
print(p3.dd)
print(p3.gg)
print(p3.fff)

@dynamicCallable
struct Person4 {
    func dynamicallyCall(withArguments arguments: [String]) {
        arguments.forEach {
            print("\(#function) - \($0)")
        }
    }

    func dynamicallyCall(withKeywordArguments keywordArguments: KeyValuePairs<String, String>) {
        for (key, value) in keywordArguments {
            print("\(#function) \(key) --- \(value)")
        }
    }
}
let p4 = Person4()
p4("sds")
p4("sda", "12", "male")
p4(name: "name")
p4(name: "name", age: "20", sex: "male")
/*
 @dynamicCallable可以理解成动态调用，当为某一类型做此声明时，需要实现dynamicallyCall(withArguments:)或者dynamicallyCall(withKeywordArguments:)。编译器将允许你调用并为定义的方法。

 一个动态查找成员变量，一个动态方法调用，带上这两个特性Swift就可以变成彻头彻尾的动态语言了。所以作为静态语言的Swift也是可以具有动态特性的。
 */

/*
 原来你需要显式声明字符串参数的地方，可以不用是字符串的形式，可以直接用点语法访问。官方举的例子是 JSON 的使用。
 常规的写法是这样的：
 */
@dynamicMemberLookup
enum JSON {
    case intValue(Int)
    case stringValue(String)
    case arrayValue(Array<JSON>)
    case dictionaryValue(Dictionary<String, JSON>)

    var stringValue: String? {
        if case .stringValue(let str) = self {
            return str
        }
        return nil
    }

    subscript(index: Int) -> JSON? {
        if case .arrayValue(let array) = self {
            return index < array.count ? array[index] : nil
        }
        return nil
    }

    subscript(dynamicMember key: String) -> JSON? {
        if case .dictionaryValue(let dict) = self {
            return dict[key]
        }
        return nil
    }

    //    subscript(dynamicMember: String) -> JSON {
    //        if let case .dictionaryValue(dict) = self {
    //            return dict[dynamicMember]
    //        }
    //        return nil
    //    }
}
let json2: JSON = .arrayValue([.dictionaryValue(["name": .arrayValue([.stringValue("fafafa")])])])
let jsonValue = json2[0]?.name?[0]?.stringValue
print(jsonValue)

@dynamicCallable @dynamicMemberLookup
class AnyThing {

    func dynamicallyCall(withArguments arguments: [String]) {
        arguments.forEach {
            print("Anything \(#function) - \($0)")
        }
    }

    func dynamicallyCall<T>(withKeywordArguments keywordArguments: KeyValuePairs<String, T>) {
        keywordArguments.forEach {
            print("Anything \(#function) -\($0.key) - \($0.value)")
        }
    }

    subscript(dynamicMember dynamicMember: String) -> Self {
        return self
    }
}
let anyThing = AnyThing()
anyThing.someMethod.dynamicallyCall(withKeywordArguments: ["Anything": true])

//where 它可以用在for-in、swith、do-catch中
let numbers2 = [1, 2, 3, 4, 5, 6, 8]
for item in numbers2 where item % 2 == 1 {
    print("odd \(item)")
}

numbers2.forEach {
    switch $0 {
    case let x where x % 2 == 0:
        print("even \(x)")
    default:
        break
    }
}

// where也可以用于类型限定。
extension Dictionary where Key == String , Value == String {
    func merge(other: Dictionary) -> Dictionary {
        return merging(other, uniquingKeysWith: {_, new in new})
    }
}

// @autoclosure 是使用在闭包类型之前，做的事情就是把一句表达式自动地封装成一个闭包 (closure)。
func logIfTrueNormal(predicate: () -> Bool) {
    if predicate() {
        print("\(#function) - True")
    }
}

func logIfTrueAutoclosure(predicate: @autoclosure () -> Bool) {
    if predicate() {
        print("\(#function) - True")
    }
}

logIfTrueNormal(predicate: { 2 > 1 })
logIfTrueAutoclosure(predicate: true)

// @autoclosure好处 ?? 的实现细节如下
infix operator -??
func -?? <T>(optional: T?, defaultValue: @autoclosure () throws -> T) rethrows -> T {
    switch optional {
    case .some(let value):
        return value
    case .none:
        return try defaultValue()
    }
}

var name3: String? = nil
let currentName = name3 -?? getDefaultName()

func getDefaultName() -> String {
    return "sss"
}

//@escaping @escaping也是闭包修饰词，用它标记的闭包被称为逃逸闭包，还有一个关键词是@noescape，用它修饰的闭包叫做非逃逸闭包。在Swift3及之后的版本，闭包默认为非逃逸闭包，在这之前默认闭包为逃逸闭包。
// 这两者的区别主要在于生命周期的不同，当闭包作为参数时，如果其声明周期与函数一致就是非逃逸闭包，如果生命周期大于函数就是逃逸闭包
func logIfTrueNoEscaping(predicate: () -> Bool) {
    if predicate() {
        print("\(#function) - True")
    }
}

func logIfTrueEscaping(predicate:@escaping () -> Bool) {
    DispatchQueue.main.async {
        if predicate() {
            print("\(#function) - True")
        }
    }
}

logIfTrueNoEscaping(predicate: { true })
logIfTrueEscaping(predicate: { true })

// Filter, Map, Reduce, flatmap, compactMap
// 注意到flatMap有两种用法，一种是展开数组，将二维数组降为一维数组，一种是过滤数组中的nil。在Swift4.1版本已经将flatMap过滤数组中nil的函数标位deprecated，所以我们过滤数组中nil的操作应该使用compactMap函数。
let numbers4 = [1, 2, 3, 4, 5, 6, 7 ,8 , 9, 190]

let odd4 = numbers4.filter { $0 % 2 == 1 }
print(odd4)

let maps4 = odd4.map { "\($0 + 2)"}
print(maps4)

let result4 = odd4.reduce(0, +)
print(result4)

let numerList4 = [[1, 3, 5, 100], [55, 44], [222]]
// 数组展开，降维操作
let flatMapNumbers = numerList4.flatMap { $0 }
print(flatMapNumbers)

let countrys = ["cn", "us", nil, nil, "en"]
// 过滤nil(已经废弃)
let flatMapCountrys = countrys.flatMap { $0 }
print(flatMapCountrys)

// 过滤nil
let compactMapCountrys = countrys.compactMap { $0 }
print(compactMapCountrys)


// 柯里化指的是从一个多参数函数变成一连串单参数函数的变换，这是实现函数式编程的重要手段,
// 所以柯里化也可以理解为批量生成一系列相似的函数
func greateThan(_ compare: Int) -> (Int) -> Bool {
    return { number in
        return number > compare
    }
}
let greaterThan10 = greateThan(10)
greaterThan10(13)
greaterThan10(9)

/**
 Any 与AnyObject 区别
 AnyObject：是一个协议，所有class都遵守该协议，常用语跟OC对象的数据转换。

 Any：它可以代表任何型別的类(class)、结构体 (struct)、枚举 (enum)，包括函式和可选型，基本上可以说是任何东西。
 */


/**
 rethrows 和 throws 有什么区别呢？
 throws是处理错误用的，可以看一个往沙盒写入文件的例子
 // 调用
 do {
     let data = Data()
     try data.write(to: localUrl)
 } catch let error {
     print(error.localizedDescription)
 }
 将一个会有错误抛出的函数末尾加上throws，则该方法调用时需要使用try语句进行调用，用于提示当前函数是有抛错风险的，其中catch句柄是可以忽略的。

 rethrows与throws并没有太多不同，它们都是标记了一个方法应该抛出错误。但是 rethrows 一般用在参数中含有可以 throws 的方法的高阶函数中

 @inlinable public func map<T>(_ transform: (Element) throws -> T) rethrows -> [T]
 transform是需要我们定义的闭包，它有可能抛出异常，也可能不抛出异常。Swift作为类型安全的语言就需要保证在有异常的时候需要使用try去调用，在没有异常的时候要正常调用，那怎么兼容这两种情况呢，这就是rethrows的作用了。
 */
enum CalculationError: Error {
    case DivideByZero
}

func squareOf(x: Int) -> Int { x * x }
func divideTenBy(x: Int) throws -> Double {
    guard x != 0 else {
        throw CalculationError.DivideByZero
    }
    return 10.0 / Double(x)
}

let theNumbers2 = [10, 20, 30]
let squareResult = theNumbers2.map { squareOf(x: $0) }

do {
    let divideResult2 = try theNumbers2.map(divideTenBy(x:))
//    let divideResult2 = try theNumbers2.map { try divideTenBy(x: $0 ) }
    print(divideResult2)
} catch {
    print(error)
}

/**
 break return continue fallthough 在语句中的含义（switch、while、for）
 在Swift的switch语句，会在每个case结束的时候自动退出该switch判断，如果我们想不退出，继续进行下一个case的判断，可以加上fallthough
 */
