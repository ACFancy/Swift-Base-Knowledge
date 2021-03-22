import UIKit

// rethrows
/**
 A function or method can be declared with the rethrows keyword to indicate that it throws an error only if one of its function parameters throws an error. These functions and methods are known as rethrowing functions and rethrowing methods. Rethrowing functions and methods must have at least one throwing function parameter.
 返回rethrows的函数要求至少有一个可抛出异常的函数式参数，而有以函数作为参数的函数就叫做高阶函数。
 */

// 特性修饰词

//@available
/**
 可用来标识计算属性、函数、类、协议、结构体、枚举等类型的生命周期。（依赖于特定的平台版本 或 Swift 版本）。它的后面一般跟至少两个参数，参数之间以逗号隔开。其中第一个参数是固定的，代表着平台和语言，可选值有以下这几个
 iOS
 iOSApplicationExtension
 macOS
 macOSApplicationExtension
 watchOS
 watchOSApplicationExtension
 tvOS
 tvOSApplicationExtension
 swift
 */
let scrollView = UIScrollView()
if #available(iOS 11.0, *) {
    scrollView.contentInsetAdjustmentBehavior = .never
}

@available(iOS 12.0, *)
func adjustDarkMode() {

}

@available(iOS 12.0, *)
struct DarkModeConfig {}

@available(iOS 12.0, *)
protocol DarkModeTheme {}

@available(OSX 10.15, iOS 13, watchOS 6, *)
func DarkModeCall() {}

/**
 注意：作为条件语句的available前面是#，作为标记位时是@
 刚才说了，available后面参数至少要有两个，后面的可选参数这些：

 deprecated：从指定平台标记为过期，可以指定版本号


 obsoleted=版本号：从指定平台某个版本开始废弃（注意弃用的区别，deprecated是还可以继续使用，只不过是不推荐了，obsoleted是调用就会编译错误）该声明
 message=信息内容：给出一些附加信息
 unavailable：指定平台上是无效的
 renamed=新名字：重命名声明
 */
@available(*, unavailable, renamed: "testInvidateFunction")
func testUnavailableFunction() {}

// @discardableResult
/*
 带返回的函数如果没有处理返回值会被编译器警告⚠️。但有时我们就是不需要返回值的，这个时候我们可以让编译器忽略警告，就是在方法名前用@discardableResult声明一下
 */

// @inlinable
/*
 这个关键词是可内联的声明，它来源于C语言中的inline。C中一般用于函数前，做内联函数，它的目的是防止当某一函数多次调用造成函数栈溢出的情况。因为声明为内联函数，会在编译时将该段函数调用用具体实现代替，这么做可以省去函数调用的时间
 Swift中的@inlinable和C中的inline基本相同，它在标准库的定义中也广泛出现，可用于方法，计算属性，下标，便利构造方法或者deinit方法中

 需要注意内联声明不能用于标记为private或者fileprivate的地方。
 这很好理解，对私有方法的内联是没有意义的。内联的好处是运行时更快，因为它省略了从标准库调用map实现的步骤。但这个快也是有代价的，因为是编译时做替换，这增加了编译的开销，会相应的延长编译时间
 */

// @warn_unqualified_access
/*
 通过命名我们可以推断出其大概含义：对“不合规”的访问进行警告。这是为了解决对于相同名称的函数，不同访问对象可能产生歧义的问题
 比如说，Swift 标准库中Array和Sequence均实现了min()方法，而系统库中也定义了min(::)，对于可能存在的二义性问题，我们可以借助于@warn_unqualified_access。

 我们会收到编译器的警告：Use of 'min' treated as a reference to instance method in protocol 'Sequence', Use 'self.' to silence this warning。它告诉我们编译器推断我们当前使用的是Sequence中的min()，这与我们的想法是违背的。因为有这个@warn_unqualified_access限定，我们能及时的发现问题，并解决问题：self.min()。
 */
extension Array where Element: Comparable {
    func minValue() -> Element? {
        return self.min()
    }
}

// @objc
/*
 把这个特性用到任何可以在 Objective-C 中表示的声明上——例如，非内嵌类，协议，非泛型枚举（原始值类型只能是整数），类和协议的属性、方法（包括 setter 和 getter ），初始化器，反初始化器，下标。 objc 特性告诉编译器，这个声明在 Objective-C 代码中是可用的。
 用 objc 特性标记的类必须继承自一个 Objective-C 中定义的类。如果你把 objc 用到类或协议中，它会隐式地应用于该类或协议中 Objective-C 兼容的成员上。如果一个类继承自另一个带 objc 特性标记或 Objective-C 中定义的类，编译器也会隐式地给这个类添加 objc 特性。标记为 objc 特性的协议不能继承自非 objc 特性的协议

 @objc还有一个用处是当你想在OC的代码中暴露一个不同的名字时，可以用这个特性，它可以用于类，函数，枚举，枚举成员，协议，getter，setter等。
 这一特性还可以用于解决潜在的命名冲突问题，因为Swift有命名空间，常常不带前缀声明，而OC没有命名空间是需要带的，当在OC代码中引用Swift库，为了防止潜在的命名冲突，可以选择一个带前缀的名字供OC代码使用。
 */

class ExampleClass: NSObject {
    @objc var enabled: Bool {
        @objc(isEnabled) get {
            return true
        }
    }
}

@objc(ChartAnimator)
open class Animator: NSObject {}

@objc(ChartComponentBase)
open class ComponentBase: NSObject {}

// @objcMembers
/*
 因为Swift中定义的方法默认是不能被OC调用的，除非我们手动添加@objc标识。但如果一个类的方法属性较多，这样会很麻烦，于是有了这样一个标识符@objcMembers，它可以让整个类的属性方法都隐式添加@objc，不光如此对于类的子类、扩展、子类的扩展都也隐式的添加@objc，当然对于OC不支持的类型，仍然无法被OC调用：
 */
@objcMembers
class ObjcMemeberClass: NSObject {

    /// implicitly @objc
    func foo() {}


    /// not @objcm becase tuple  returns
    /// - Returns: <#description#>
    func bar() -> (Int, Int) {
        return (1, 1)
    }
}

extension ObjcMemeberClass {

    /// implicitly @objc
    func baz() {}
}

class SubObjcMemberClass: ObjcMemeberClass {

    /// implicitly @objc
    func wibble() {}
}

extension SubObjcMemberClass {

    /// implicitly @objc
    func wobble() {}
}

// @testable
/*
 @testable是用于测试模块访问主target的一个关键词
 因为测试模块和主工程是两个不同的target，在swift中，每个target代表着不同的module，不同module之间访问代码需要public和open级别的关键词支撑。但是主工程并不是对外模块，为了测试修改访问权限是不应该的，所以有了@testable关键词。
 这时测试模块就可以访问那些标记为internal或者public级别的类和成员了
 import XCTest
 @testable import Project
 class ProjectTest: XCTestCase {
 }
 */

//@frozen @unknown default
/*
 frozen意为冻结，是为Swift5的ABI稳定准备的一个字段，意味向编译器保证之后不会做出改变。
 ComparisonResult这个枚举值被标记为@frozen即使保证之后该枚举值不会再变。注意到String作为结构体也被标记为@frozen，意为String结构体的属性及属性顺序将不再变化。其实我们常用的类型像Int、Float、Array、Dictionary、Set等都已被“冻结”。需要说明的是冻结仅针对struct和enum这种值类型，因为他们在编译器就确定好了内存布局。对于class类型
 对于没有标记为frozen的枚举AVPlayerItem.Status，则认为该枚举值在之后的系统版本中可能变化
 对于可能变化的枚举，我们在列出所有case的时候还需要加上对@unknown default的判断，这一步会有编译器检查：
 */
@frozen public enum ComparisonResult: Int {
    case orderedAscending = -1
    case orderedSame = 0
    case orderedDescending = 1
}

@frozen public struct String {}

import AVFoundation
extension AVPlayerItem {
    public enum Status2: Int {
        case unknown = 0
        case readyToPlay = 1
        case failed = 2
    }
}

let item = AVPlayerItem(asset: AVAsset(url: URL(string: "https://www.baidu.com")!))
switch item.status {
case .failed: break
case .readyToPlay: break
case .unknown: break
@unknown default:
    fatalError("not supported")
}
//let status = AVPlayerItem.Status2.readyToPlay
//switch status {
//case .unknown: break
//case .readyToPlay: break
//case .failed: break
//@unknown default:
//    fatalError("not supported")
//}

// @State @Binding @ObservedObject @EnvironmentObject
/*
 这几个是SwiftUI中出现的特性修饰词
 */
//import SwiftUI


// lazy
/*
 lazy是懒加载的关键词，当我们仅需要在使用时进行初始化操作就可以选用该关键词。
 lazy很好的避免的不必要的计算
 这里使用的是一个闭包，当调用该属性时，执行闭包里面的内容，返回具体的label，完成初始化。
 使用lazy你可能会发现它只能通过var初始而不能通过let，这是由 lazy 的具体实现细节决定的：它在没有值的情况下以某种方式被初始化，然后在被访问时改变自己的值，这就要求该属性是可变的。
 */
func increment(x: Int) -> Int {
    print("Computing next value of \(x)")
    return x + 1
}

let array = Array(0..<1000)
let incArray = array.map(increment)
print("Result: \(incArray[0]) \(incArray[4])")

/*
 在执行print("Result:")之前，Computing next value of ...会被执行1000次，但实际上我们只需要0和4这两个index对应的值。
 上面说了序列也可以使用lazy，使用的方式是
 就是说这里的lazy可以延迟到我们取值时才去计算map里的结果
 */

let incLazyArray = array.lazy.map(increment)
print("Result: \(incLazyArray[0]) \(incLazyArray[4])")
//array.filter(<#T##isIncluded: (Int) throws -> Bool##(Int) throws -> Bool#>)
/*
 我们看下这个lazy的定义：
 @inlinable public var lazy: LazySequence<Array<Element>> { get }

 它返回一个LazySequence的结构体，这个结构体里面包含了Array<Element>，而map的计算在LazySequence里又重新定义了一下

 /// Returns a `LazyMapSequence` over this `Sequence`.  The elements of
 /// the result are computed lazily, each time they are read, by
 /// calling `transform` function on a base element.
 @inlinable public func map<U>(_ transform: @escaping (Base.Element) -> U) -> LazyMapSequence<Base, U>

 这里完成了lazy序列的实现。LazySequence类型的lazy只能被用于map、flatMap、compactMap这样的高阶函数中。
 */


// unowned weak
/*
 闭包打交道，而用到闭包就不可避免的遇到循环引用问题
 在Swift处理循环引用可以使用unowned和weak这两个关键词
 */

class Dog {
    var name: Swift.String
    init(name: Swift.String) {
        self.name = name
    }

    deinit {
        print("\(name) is deinitialized")
    }
}

class Bone {
    weak var owner: Dog?
    init(owner: Dog?) {
        self.owner = owner
    }

    deinit {
        print("bone is deinitialized")
    }
}

var lucky: Dog? = Dog(name: "Lucky")
var bone: Bone = Bone(owner: lucky!)

lucky = nil
/**
 这里Dog和Bone是相互引用的关系，如果没有weak var owner: Dog?这里的weak声明，将不会打印Lucky is deinitialized。还有一种解决循环应用的方式是把weak替换为unowned关键词。
 weak相当于oc里面的weak，弱引用，不会增加循环计数。主体对象释放时被weak修饰的属性也会被释放，所以weak修饰对象就是optional。
 unowned相当于oc里面的unsafe_unretained，它不会增加引用计数，即使它的引用对象释放了，它仍然会保持对被已经释放了的对象的一个 "无效的" 引用，它不能是 Optional 值，也不会被指向 nil。如果此时为无效引用，再去尝试访问它就会crash

 当闭包和它捕获的实例总是相互引用，并且总是同时释放时，即相同的生命周期，我们应该用unowned，除此之外的场景就用weak
 */

// KeyPath
/**
 KeyPath是键值路径，最开始是用于处理KVC和KVO问题，后来又做了更广泛的扩展
 WritableKeyPath
 */
struct User {
    var name: Swift.String?
    var age: Int?
    var address: Address?
}

var user1 = User()
user1.name = "xxx"
user1.age = 18
// KVC
let path = \User.name
// WritableKeyPath
user1[keyPath: path] = "yyyy"
let name = user1[keyPath: path]
print(name ?? "")

// KVO
item.observe(\.status) { (_, change) in
}

struct Address {
    var country: String?
}

let tpath = \User.address?.country

//这里根类型为User，次级类型是Address，结果类型是String。所以path的类型依然是KeyPath<User, String?>
extension Sequence {
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        return sorted { (a, b) -> Bool in
            return a[keyPath: keyPath] < b[keyPath: keyPath]
        }
    }

    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T?>) -> [Element] {
        return sorted { (a, b) -> Bool in
            guard let valueA = a[keyPath: keyPath],
                  let valueB = b[keyPath: keyPath] else {
                return false
            }
            return valueA < valueB
        }
    }
}

let tt = \User.age
let users = [User(name: "x", age: 19, address: nil),
             User(name: "y", age: 22, address: nil),
             User(name: "z", age: 16, address: nil)]
let newUsers = users.sorted(by: \.age)

// some
/**
 some是Swift5.1新增的特性。它的用法就是修饰在一个 protocol 前面，默认场景下 protocol 是没有具体类型信息的，但是用 some 修饰后，编译器会让 protocol 的实例类型对外透明。


 var value1: Equatable {
 return 1
 }

 var value2: Int {
 return 1
 }

 编译器提示我们Equatable只能被用来做泛型的约束，它不是一个具体的类型，这里我们需要使用一个遵循Equatable的具体类型（Int）进行定义。但有时我们并不想指定具体的类型，这时就可以在协议名前加上some，让编译器自己去推断value的类型：
 var value1: some Equatable {
 return 1
 }
 在SwiftUI里some随处可见：
 struct ContentView: View {
 var body: some View {
    Text("Hello World")
    }
 }

 这里使用some就是因为View是一个协议，而不是具体类型。

 var value1: some Equatable {
    if Bool.random() {
        return 1
    } else {
        return "1"
    }
 }
 编译器是会发现并警告我们Function declares an opaque return type, but the return statements in its body do not have matching underlying types
 */
