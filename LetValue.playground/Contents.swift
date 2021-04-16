import UIKit

// 值类型和引用类型
/**
 “这就是值类型与引用类型之间的关键区别：当被赋以一个新值或是作为参数传递给函数时，值类型会被复制”

 */
struct PointStruct {
    var x: Int
    var y: Int
}

var structPoint = PointStruct(x: 1, y: 2)
var sameStructPoint = structPoint
sameStructPoint.x = 3
print(structPoint, sameStructPoint)


class PointClass: CustomStringConvertible {
    var x: Int
    var y: Int

    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    var description: String {
        return "x: \(x), y: \(y)"
    }
}

var classPoint = PointClass(x: 1, y: 2)
var sameClassPoint = classPoint
sameClassPoint.x = 3
print(classPoint, sameClassPoint)


func setStructToOrigin(point: PointStruct) -> PointStruct {
    var newPoint = point
    newPoint.x = 0
    newPoint.y = 0
    return newPoint
}

/**
 “结构体这样的值类型，在作为函数的参数被传递时将会被复制后使用。因此，在这个例子中，调用 setStructToOrigin 之后，原来的 structPoint 并没有被修改。”
 */
var structOrigin = setStructToOrigin(point: structPoint)

func setClassToOrigin(point: PointClass) -> PointClass {
    point.x = 0
    point.y = 0
    return point
}

/**
 “当把一个值类型赋值给新的变量，或者传递给函数时，值类型总是会被复制，而引用类型并不会被复制。对引用类型的对象来说，只有对于对象的引用会被复制，而不是对象本身。对于对象本身的任何修改都会在通过另一个引用访问相同对象时被反映出来”
 */
var classOrigin = setClassToOrigin(point: classPoint)

/**
 “相较于对类进行操作的对应方法，结构体的 mutating 方法有其优势，它们不存在类似的副作用。一个 mutating 方法只作用于单一变量，完全不影响其它变量”
 */
extension PointStruct {
    mutating func setStructToOrigin() {
        x = 0
        y = 0
    }
}

var myPoint = PointStruct(x: 100, y: 100)
let otherPoint = myPoint
myPoint.setStructToOrigin()
print(otherPoint, myPoint)

let immutablePoint = PointStruct(x: 0, y: 0)
//// error operation
//immutablePoint = PointStruct(x: 1, y: 1)
//immutablePoint.x = 2

var mutablePoint = PointStruct(x: 1, y: 1)
mutablePoint.x = 3

// 结构体中的属性let声明
struct ImmutablePointStruct {
    let x: Int
    let y: Int
}

var immutablePoint2 = ImmutablePointStruct(x: 1, y: 1)
//// error operation
//immutablePoint2.x = 3
// enable operation
immutablePoint2 = ImmutablePointStruct(x: 2, y: 2)

/**
 “像这样只要输入值相同则得到的输出值一定相同的函数有时被称为引用透明函数。根据定义，引用透明函数在它所存在环境中是松耦合的：除了函数的参数，不存在任何隐式依赖的状态或变量。因此，引用透明函数更容易单独测试和理解”
 */

///“可变变量的良性使用方式”
func sum(interges: [Int]) -> Int {
    var result = 0
    interges.forEach {
        result += $0
    }
    return result
}

func qsort(_ intput: [Int]) -> [Int] {
    if intput.isEmpty {
        return []
    }
    var array = intput
    let pivot = array.removeFirst()
    let lesser = array.filter { $0 < pivot }
    let greater = array.filter { $0 >= pivot }
    return qsort(lesser) + [pivot] + qsort(greater)
}
