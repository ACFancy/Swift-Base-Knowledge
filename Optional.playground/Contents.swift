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


