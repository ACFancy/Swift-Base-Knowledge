import UIKit

// 构造器
struct Fahrenheit {
    var temperature: Double
    init() {
        temperature = 32.0
    }
}

var f = Fahrenheit()
debugPrint(f.temperature)

struct Fahrenheit2 {
    var temperature: Double = 32.0
}

var f2 = Fahrenheit2()
debugPrint(f2.temperature)


struct Celsius {
    var temperatureInCelsius: Double
    
    init(fromFahrenheit fahrenheit: Double) {
        temperatureInCelsius = (fahrenheit - 32.0) / 1.8
    }
    
    init(fromKelvin kelvin: Double) {
        temperatureInCelsius = kelvin - 273.15
    }
    
    init(_ celsius: Double) {
        temperatureInCelsius = celsius
    }
}

let boilingPointOfWater = Celsius(fromFahrenheit: 212.0)
debugPrint(boilingPointOfWater.temperatureInCelsius)
let freezingPointOfWater = Celsius(fromKelvin: 273.15)
debugPrint(freezingPointOfWater.temperatureInCelsius)

struct Color {
    let red, green, blue: Double
    init(red: Double, green: Double, blue: Double) {
        self.red = red
        self.green = green
        self.blue = blue
    }
    
    init(white: Double) {
        red = white
        green = white
        blue = white
    }
}
let magenta = Color(red: 1.0, green: 0, blue: 1)
let halfGray = Color(white: 0.5)

class SurveyQuestion {
    var text: String
    let gg: String
    var response: String?
    init(text: String) {
        self.text = text
        gg = "GG"
    }
    func ask() {
        debugPrint(text)
    }
}

let cheeseQuestion = SurveyQuestion(text: "Like Cheese?")
cheeseQuestion.ask()
cheeseQuestion.response = "NO."

class ShoppingListItem {
    var name: String?
    var quantity = 1
    var purchased = false
}
var item = ShoppingListItem()


struct Size {
    var width = 0.0, height = 0.0
}

// 逐一成员构造器 memberwise initializer
var twoByTwo = Size(width: 2.0, height: 2.0)

struct Point {
    var x = 0.0, y = 0.0
}

struct Rect {
    var origin = Point()
    var size = Size()
    init() {}
    
    init(origin: Point, size: Size) {
        self.origin = origin
        self.size = size
    }
    
    init(center: Point, size: Size) {
        let originX = center.x - (size.width / 2)
        let originY = center.y - (size.height / 2)
        self.init(origin: Point(x: originX, y: originY), size: size)
    }
}
let basicRect = Rect()
let originRect = Rect(origin: Point(x: 2, y: 2), size: Size(width: 5, height: 5))
let centerRect = Rect(center: Point(x: 4, y: 4), size: Size(width: 3, height: 3))

struct Rect2 {
    var origin = Point()
    var size = Size()
}

extension Rect2 {
    init(center: Point, size: Size) {
        let originX = center.x - (size.width / 2)
        let originY = center.y - (size.height / 2)
        self.init(origin: Point(x: originX, y: originY), size: size)
    }
}
let centerRect2 = Rect2(center: Point(x: 4, y: 4), size: Size(width: 3, height: 3))

//类的构造器（指定构造器和遍历构造器）
//init(parameters) {}
//convenience init(parameters) {}
/**
 类类型的构造器代理
 为了简化指定构造器和便利构造器之间的调用关系，Swift 构造器之间的代理调用遵循以下三条规则
 1.指定构造器必须调用其直接父类的的指定构造器。
 2.便利构造器必须调用同类中定义的其它构造器。
 3.便利构造器最后必须调用指定构造器。
 
 指定构造器必须总是向上代理
 便利构造器必须总是横向代理
 
 两段式构造过程
 Swift 的两段式构造过程跟 Objective-C 中的构造过程类似。最主要的区别在于阶段 1，Objective-C 给每一个属性赋值 0 或空值（比如说 0 或 nil）。Swift 的构造流程则更加灵活，它允许你设置定制的初始值，并自如应对某些属性不能以 0 或 nil 作为合法默认值的情况
 Swift 编译器将执行 4 种有效的安全检查
 1、指定构造器必须保证它所在类的所有属性都必须先初始化完成，之后才能将其它构造任务向上代理给父类中的构造器。
 如上所述，一个对象的内存只有在其所有存储型属性确定之后才能完全初始化。为了满足这一规则，指定构造器必须保证它所在类的属性在它往上代理之前先完成初始化。
 2、指定构造器必须在为继承的属性设置新值之前向上代理调用父类构造器。如果没这么做，指定构造器赋予的新值将被父类中的构造器所覆盖。
 3、便利构造器必须为任意属性（包括所有同类中定义的）赋新值之前代理调用其它构造器。如果没这么做，便利构造器赋予的新值将被该类的指定构造器所覆盖。
 4、构造器在第一阶段构造完成之前，不能调用任何实例方法，不能读取任何实例属性的值，不能引用 self 作为一个值。
 
 类的实例在第一阶段结束以前并不是完全有效的。只有第一阶段完成后，类的实例才是有效的，才能访问属性和调用方法。
 
 阶段一
 1.类的某个指定构造器或便利构造器被调用
 2.完成类的新实例内存的分配，但此时内存还没有被初始化
 3.指定构造器确保其所在类引入的所有存储型属性都已赋初值。存储型属性所属的内存完成初始化
 4.指定构造器切换到父类的构造器，对其存储属性完成相同的任务
 5.这个过程沿着类的继承链一直往上执行，直到到达继承链的最顶部
 6.当到达了继承链最顶部，而且继承链的最后一个类已确保所有的存储型属性都已经赋值，这个实例的内存被认为已经完全初始化。此时阶段 1 完成。
 
 阶段二
 1.从继承链顶部往下，继承链中每个类的指定构造器都有机会进一步自定义实例。构造器此时可以访问 self、修改它的属性并调用实例方法等等。
 2.最终，继承链中任意的便利构造器有机会自定义实例和使用 self
 
 
 
 跟 Objective-C 中的子类不同，Swift 中的子类默认情况下不会继承父类的构造器。Swift 的这种机制可以防止一个父类的简单构造器被一个更精细的子类继承，而在用来创建子类时的新实例时没有完全或错误被初始化。
 父类的构造器仅会在安全和适当的某些情况下被继承
 
 正如重写属性，方法或者是下标，override 修饰符会让编译器去检查父类中是否有相匹配的指定构造器，并验证构造器参数是否被按预想中被指定
 当你重写一个父类的指定构造器时，你总是需要写 override 修饰符，即使是为了实现子类的便利构造器
 */

class Vehicle : CustomStringConvertible {
    var numberOfWheels = 0
    
    var description: String {
        return "\(numberOfWheels) wheel(s)"
    }
}
let vehicle = Vehicle()
debugPrint(vehicle.description)

class Bicycle : Vehicle {
    override init() {
        super.init()
        numberOfWheels = 2
    }
}
let bicycle = Bicycle()
debugPrint(bicycle.description)

class Hoverboard : Vehicle {
    var color: String
    init(color: String) {
        self.color = color
        //        super.init() //会被隐式调用可以省略
    }
    
    override var description: String {
        return "\(super.description) in a beaultiful \(color)"
    }
}

let hoverboard = Hoverboard(color: "Silver")
debugPrint(hoverboard.description)
// 子类可以在构造过程修改继承来的变量属性，但是不能修改继承来的常量属性
/**
 构造器的自动继承
 如上所述，子类在默认情况下不会继承父类的构造器。但是如果满足特定条件，父类构造器是可以被自动继承的。事实上，这意味着对于许多常见场景你不必重写父类的构造器，并且可以在安全的情况下以最小的代价继承父类的构造器
 假设你为子类中引入的所有新属性都提供了默认值，以下 2 个规则将适用
 规则1
 如果子类没有定义任何指定构造器，它将自动继承父类所有的指定构造器
 规则2
  如果子类提供了所有父类指定构造器的实现
  ——无论是通过规则1继承过来的，还是提供了自定义实现——它将自动继承父类所有的便利构造器
 
  即使你在子类中添加了更多的便利构造器，这两条规则仍然适用
  子类可以将父类的指定构造器实现为便利构造器来满足规则2
 */

// 指定构造器和便利构造器实践
class Food {
    var name: String
    init(name: String) {
        self.name = name
    }
    
    convenience init() {
        debugPrint("XXXXFFF")
        self.init(name: "[Unknown]")
        debugPrint("FFood")
    }
}

let namedMeat = Food(name: "Bacon")
debugPrint(namedMeat.name)
let mysteryMeat = Food()
debugPrint(mysteryMeat.name)

class RecipeIngredient : Food {
    var quantity: Int
    init(name: String, quantity: Int) {
        self.quantity = quantity
        super.init(name: name)
    }
    
    override convenience init(name: String) {
        debugPrint("RRCe")
        self.init(name: name, quantity: 1)
        debugPrint("XXXXRRR")
    }
}
let oneMysteryItem = RecipeIngredient()
debugPrint(oneMysteryItem.quantity)
let oneBacon = RecipeIngredient(name: "Bacon")
let sixEggs = RecipeIngredient(name: "Eggs", quantity: 6)

class ShoppingListItem2 : RecipeIngredient, CustomStringConvertible {
    var purchased = false
    
    var description: String {
        var output = "\(quantity) x \(name)"
        output += purchased ? " ✔" : " ✘"
        return output
    }
}

var breakfastList = [
    ShoppingListItem2(),
    ShoppingListItem2(name: "Bacon"),
    ShoppingListItem2(name: "Eggs", quantity: 6)
]
breakfastList[0].name = "Orange juice"
breakfastList[0].purchased = true
breakfastList.forEach {
    debugPrint($0.description)
}

/**
 可失败构造器
 定义一个构造器可失败的类，结构体或者枚举是很有用的。这里所指的“失败” 指的是，如给构造器传入无效的形参，或缺少某种所需的外部资源，又或是不满足某种必要的条件等
 init?
 可失败构造器的参数名和参数类型，不能与其它非可失败构造器的参数名，及其参数类型相同
 可失败构造器会创建一个类型为自身类型的可选类型的对象。你通过 return nil 语句来表明可失败构造器在何种情况下应该 “失败”
 
 严格来说，构造器都不支持返回值。因为构造器本身的作用，只是为了确保对象能被正确构造。因此你只是用 return nil 表明可失败构造器构造失败，而不要用关键字 return 来表明构造成功
 */
let wholeNumber: Double = 12345.0
let pi = 3.14159
//let tt = Int("12334")
//let xx = Int(exactly: 22.9)
if let valueMaintained = Int(exactly: wholeNumber) {
    debugPrint("\(wholeNumber) conversion to \(valueMaintained)")
}
let valueChanged = Int(exactly: pi)
if valueChanged == nil {
    debugPrint("\(pi) conversion to Int doesn't maintain value")
}

struct Animal {
    let species: String
    init?(species: String) {
        guard !species.isEmpty else {
            return nil
        }
        self.species = species
    }
}

let someCreateure = Animal(species: "Giraffe")

if let giraffe = someCreateure {
    debugPrint("Initalized with \(giraffe.species)")
}

let anonymousCreature = Animal(species: "")
if anonymousCreature == nil {
    debugPrint("Anonymous created could not be initilized")
}

// 枚举类型的可失败构造器
enum TemperatureUnit {
    case Kelvin, Celsius, Fahrenheit
    init?(symbol: Character) {
        switch symbol {
        case "K":
            self = .Kelvin
        case "C":
            self = .Celsius
        case "F":
            self = .Fahrenheit
        default:
            return nil
        }
    }
}

let fahrenheitUnit = TemperatureUnit(symbol: "F")
debugPrint(fahrenheitUnit)
let unknowUnit = TemperatureUnit(symbol: "x")
debugPrint(unknowUnit)

/**
 带原始值的枚举类型的可失败构造器
 带原始值的枚举类型会自带一个可失败构造器 init?(rawValue:)，该可失败构造器有一个合适的原始值类型的 rawValue 形参，选择找到的相匹配的枚举成员，找不到则构造失败
 */

enum TemperatureUnit2 : Character {
    case Kelvin = "K", Celsius = "C", Fahrenheit = "F"
}

let fahrenheitUnit2 = TemperatureUnit2(rawValue: "F")
debugPrint(fahrenheitUnit2)
let unkonwnUnit2 = TemperatureUnit2(rawValue: "X")
debugPrint(unkonwnUnit2)

/**
 构造失败的传递
 类、结构体、枚举的可失败构造器可以横向代理到它们自己其他的可失败构造器
 子类的可失败构造器也能向上代理到父类的可失败构造器
 无论是向上代理还是横向代理，如果你代理到的其他可失败构造器触发构造失败，整个构造过程将立即终止，接下来的任何构造代码不会再被执行
 
 可失败构造器也可以代理到其它的不可失败构造器。通过这种方式，你可以增加一个可能的失败状态到现有的构造过程中。
 */
class Product {
    let name: String
    init?(name: String) {
        guard !name.isEmpty else {
            return nil
        }
        self.name = name
    }
}

class CartItem : Product {
    let quantity: Int
    init?(name: String, quantity: Int) {
        guard quantity >= 1 else {
            return nil
        }
        self.quantity = quantity
        super.init(name: name)
    }
}

let twoSocks = CartItem(name: "Sock", quantity: 2)
debugPrint(twoSocks)
let zeroShirts = CartItem(name: "shirt", quantity: 0)
debugPrint(zeroShirts)
let oneUnnamed = CartItem(name: "", quantity: 1)
debugPrint(oneUnnamed)

/**
 重写一个可失败构造器
 如同其它的构造器，你可以在子类中重写父类的可失败构造器。或者你也可以用子类的非可失败构造器重写一个父类的可失败构造器。这使你可以定义一个不会构造失败的子类，即使父类的构造器允许构造失败。
 注意，当你用子类的非可失败构造器重写父类的可失败构造器时，向上代理到父类的可失败构造器的唯一方式是对父类的可失败构造器的返回值进行强制解包。
 你可以用非可失败构造器重写可失败构造器，但反过来却不行
 
 */
class Document {
    var name: String?
    init() {}
    init?(name: String) {
        guard !name.isEmpty else {
            return nil
        }
        self.name = name
    }
    init!(test: String){
        guard !test.isEmpty else {
            return nil
        }
        self.name = test
    }
}

class AutomaticallyNamedDocument : Document {
    override init() {
        super.init()
        name = "[Untitled]"
    }
    
    // 不可失败构造器 init(name:) 重写了父类的可失败构造器 init?(name:)
    override init(name: String) {
        super.init()
        if name.isEmpty {
            self.name = "[Untitled]"
        } else {
            self.name = name
        }
    }
}

class UntitledDocument : Document {
    override init() {
        /**
         子类的不可失败构造器中使用强制解包来调用父类的可失败构造器
         如果在调用父类的可失败构造器 init?(name:) 时传入的是空字符串，那么强制解包操作会引发运行时错误。不过，因为这里是通过字符串常量来调用它，构造器不会失败，所以并不会发生运行时错误。
         */
        super.init(name: "[Untitled]")!
    }
}

/**
 init! 可失败构造器
 通常来说我们通过在 init 关键字后添加问号的方式（init?）来定义一个可失败构造器，但你也可以通过在 init 后面添加感叹号的方式来定义一个可失败构造器（init!），该可失败构造器将会构建一个对应类型的隐式解包可选类型的对象
 你可以在 init? 中代理到 init!，反之亦然。你也可以用 init? 重写 init!，反之亦然。你还可以用 init 代理到 init!，不过，一旦 init! 构造失败，则会触发一个断言(如果不进行强制解包不会crash)
 */
let test1 = Document(test: "")
debugPrint(test1)
let test2 = Document(test: "xx")
debugPrint(test2)

// 必要构造器(在类的构造器前添加 required 修饰符表明所有该类的子类都必须实现该构造器)
class SomeClass {
    required init() {}
}

// 在子类重写父类的必要构造器时，必须在子类的构造器前也添加 required 修饰符，表明该构造器要求也应用于继承链后面的子类。在重写父类中必要的指定构造器时，不需要添加 override 修饰符
// 如果子类继承的构造器能满足必要构造器的要求，则无须在子类中显式提供必要构造器的实现
class SomeSubClass : SomeClass {
    required init() {
        
    }
}

/**
 通过闭包或函数设置属性的默认值
 如果某个存储型属性的默认值需要一些自定义或设置，你可以使用闭包或全局函数为其提供定制的默认值
 每当某个属性所在类型的新实例被构造时，对应的闭包或函数会被调用，而它们的返回值会当做默认值赋值给这个属性
 这种类型的闭包或函数通常会创建一个跟属性类型相同的临时变量，然后修改它的值以满足预期的初始状态，最后返回这个临时变量，作为属性的默认值
 注意闭包结尾的花括号后面接了一对空的小括号。这用来告诉 Swift 立即执行此闭包。如果你忽略了这对括号，相当于将闭包本身作为值赋值给了属性，而不是将闭包的返回值赋值给属性
 
 注意
 如果你使用闭包来初始化属性，请记住在闭包执行时，实例的其它部分都还没有初始化。这意味着你不能在闭包里访问其它属性，即使这些属性有默认值。同样，你也不能使用隐式的 self 属性，或者调用任何实例方法。
 */

//class SomeClass2 {
//    let someProperty: SomeType = {
//        return someTypeValue
//    }()
//}

struct Chessboard {
    let boardColors: [Bool] = {
        var temporaryBoard: [Bool] = []
        var isBlack = false
        for i in 1...8 {
            for j in 1...8 {
                temporaryBoard.append(isBlack)
                isBlack = !isBlack
            }
            isBlack = !isBlack
        }
        return temporaryBoard
    }()
    
    func squareIsBlackAt(row: Int, column: Int) -> Bool {
        return boardColors[(row * 8) + column]
    }
}

// 每当一个新的 Chessboard 实例被创建时，赋值闭包则会被执行，boardColors 的默认值会被计算出来并返回。
let board = Chessboard()
debugPrint(board.squareIsBlackAt(row: 0, column: 1))
debugPrint(board.squareIsBlackAt(row: 7, column: 7))
