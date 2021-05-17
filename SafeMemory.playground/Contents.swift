import UIKit

/**
 理解内存访问冲突
 1、如果你写过并发和多线程的代码，内存访问冲突也许是同样的问题。然而，这里访问冲突的讨论是在单线程的情境下讨论的，并没有使用并发或者多线程
 2、如果你曾经在单线程代码里有访问冲突，Swift 可以保证你在编译或者运行时会得到错误。对于多线程的代码，可以使用 Thread Sanitizer 去帮助检测多线程的冲突
 */

/**
 内存访问性质
 内存访问冲突时，要考虑内存访问上下文中的这三个性质：访问是读还是写，访问的时长，以及被访问的存储地址
 冲突会发生在当你有两个访问符合下列的情况
 1.至少有一个是写访问
 2.它们访问的是同一个存储地址
 3.它们的访问在时间线上部分重叠
 如果一个访问不可能在其访问期间被其它代码访问，那么就是一个瞬时访问。正常来说，两个瞬时访问是不可能同时发生的。大多数内存访问都是瞬时的。例如，下面列举的所有读和写访问都是瞬时的
 */
func onMore(than number: Int) -> Int {
    return number + 1
}

var myNumber = 1
myNumber = onMore(than: myNumber)
debugPrint(myNumber)
/**
 有几种被称为长期访问的内存访问方式，会在别的代码执行时持续进行。瞬时访问和长期访问的区别在于别的代码有没有可能在访问期间同时访问，也就是在时间线上的重叠。一个长期访问可以被别的长期访问或瞬时访问重叠
 重叠的访问主要出现在使用 in-out 参数的函数和方法或者结构体的 mutating 方法里
 */

/**
 In-Out 参数的访问冲突
 一个函数会对它所有的 in-out 参数进行长期写访问。in-out 参数的写访问会在所有非 in-out 参数处理完之后开始，直到函数执行完毕为止。如果有多个 in-out 参数，则写访问开始的顺序与参数的顺序一致。
 长期访问的存在会造成一个结果，你不能在访问以 in-out 形式传入后的原变量，即使作用域原则和访问权限允许——任何访问原变量的行为都会造成冲突。例如
 */
var stepSize = 1
func increment(_ number: inout Int) {
    number += stepSize
}
func testIncreament() {
    var test = 1
    func increment2(_ number: inout Int) {
        number += test
    }
    increment2(&test)
    test
}
//testIncreament()
//increment(&stepSize)
/**
 在上面的代码里，stepSize 是一个全局变量，并且它可以在 increment(_:) 里正常访问
 然而，对于 stepSize 的读访问与 number 的写访问重叠了
 */
var copyOfStepSize = stepSize
increment(&copyOfStepSize)
stepSize = copyOfStepSize

/**
 长期写访问的存在还会造成另一种结果，往同一个函数的多个 in-out 参数里传入同一个变量也会产生冲突，例如：
 */
func balance(_ x: inout Int, _ y: inout Int) {
    let sum = x + y
    x = sum / 2
    y = sum - x
}

var playerOneScore = 42
var playerTwoScore = 30
//func testPlayer() {
//    var playerOneScore = 52
//    balance(&playerOneScore, &playerOneScore)
//    playerOneScore
//}

balance(&playerOneScore, &playerTwoScore)
// 报错
//balance(&playerOneScore, &playerOneScore)
/**
 上面的 balance(_:_:) 函数会将传入的两个参数平均化。将 playerOneScore 和 playerTwoScore 作为参数传入不会产生错误 —— 有两个访问重叠了，但它们访问的是不同的内存位置。相反，将 playerOneScore 作为参数同时传入就会产生冲突，因为它会发起两个写访问，同时访问同一个的存储地址。
 注意:
 因为操作符也是函数，它们也会对 in-out 参数进行长期访问。例如，假设 balance(_:_:) 是一个名为 <^> 的操作符函数，那么 playerOneScore <^> playerOneScore 也会造成像 balance(&playerOneScore, &playerOneScore) 一样的冲突
 */

/**
 方法里 self 的访问冲突
 一个结构体的 mutating 方法会在调用期间对 self 进行写访问
 */

struct Player {
    var name: String
    var health: Int
    var energy: Int
    
    static let maxHealth = 10
    mutating func restoreHealth() {
        health = Self.maxHealth
    }
}
/**
 在上面的 restoreHealth() 方法里，一个对于 self 的写访问会从方法开始直到方法 return。在这种情况下，restoreHealth() 里的其它代码不可以对 Player 实例的属性发起重叠的访问。下面的 shareHealth(with:) 方法接受另一个 Player 的实例作为 in-out 参数，产生了访问重叠的可能性
 */

extension Player {
    mutating func shareHealth(with tempmate: inout Player) {
        balance(&tempmate.health, &health)
    }
}

var oscar = Player(name: "Oscar", health: 10, energy: 10)
var maria = Player(name: "Maria", health: 5, energy: 10)
oscar.shareHealth(with: &maria)

//当然，如果你将 oscar 作为参数传入 shareHealth(with:) 里，就会产生冲突
//oscar.shareHealth(with: &oscar)

/**
 属性的访问冲突(作用域相关)
 如结构体，元组和枚举的类型都是由多个独立的值组成的，例如结构体的属性或元组的元素。因为它们都是值类型，修改值的任何一部分都是对于整个值的修改，意味着其中一个属性的读或写访问都需要访问整一个值。例如，元组元素的写访问重叠会产生冲突
 */
var playerInfomation = (health: 10, energy: 20)
// 报错
//balance(&playerInfomation.health, &playerInfomation.energy)
/**
 上面的例子里，传入同一元组的元素对 balance(_:_:) 进行调用，产生了冲突，因为 playerInformation 的访问产生了写访问重叠。playerInformation.health 和 playerInformation.energy 都被作为 in-out 参数传入，意味着 balance(_:_:) 需要在函数调用期间对它们发起写访问。任何情况下，对于元组元素的写访问都需要对整个元组发起写访问。这意味着对于 playerInfomation 发起的两个写访问重叠了，造成冲突
 
 下面的代码展示了一样的错误，对于一个存储在全局变量里的结构体属性的写访问重叠了
 */
var holly = Player(name: "Holly", health: 10, energy: 10)
//报错
//balance(&holly.health, &holly.energy)

/**
 在实践中，大多数对于结构体属性的访问都会安全的重叠。例如，将上面例子里的变量 holly 改为本地变量而非全局变量，编译器就会可以保证这个重叠访问是安全的
 */
func someFunction() {
    var oscar = Player(name: "Oscar", health: 10, energy: 60)
    balance(&oscar.health, &oscar.energy)
    oscar.energy
    var playerInfomation = (health: 10, energy: 40)
    balance(&playerInfomation.health, &playerInfomation.energy)
    playerInfomation.health
}
someFunction()
/**
 上面的例子里，oscar 的 health 和 energy 都作为 in-out 参数传入了 balance(_:_:) 里。编译器可以保证内存安全，因为两个存储属性任何情况下都不会相互影响
 */

/**
 限制结构体属性的重叠访问对于保证内存安全不是必要的
 保证内存安全是必要的，但因为访问独占权的要求比内存安全还要更严格——意味着即使有些代码违反了访问独占权的原则，也是内存安全的，所以如果编译器可以保证这种非专属的访问是安全的，那 Swift 就会允许这种行为的代码运行。
 特别是当你遵循下面的原则时，它可以保证结构体属性的重叠访问是安全的
 1.你访问的是实例的存储属性，而不是计算属性或类的属性
 2.结构体是本地变量的值，而非全局变量
 3.结构体要么没有被闭包捕获，要么只被非逃逸闭包捕获了
 
 如果编译器无法保证访问的安全性，它就不会允许那次访问
 */
