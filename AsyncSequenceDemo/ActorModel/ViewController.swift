//
//  ViewController.swift
//  ActorModel
//
//  Created by Lee Danatech on 2021/11/29.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //        testAsyncProtocol()
        
        //        testClassAsync()
        
        //        testInstanceAsync()
        
        //        testisolatedMulti()
        
        //        testMainDispatch()
        
        //        testMainActor()
        
        //        testAnaylze()
        
        //        testSendable()

        //        testSilentSendable()

        //        testSendableSomeErrorCase()

        testMigrateSendable()
    }
}

// MARK: - “actor 模型和数据隔离”
// MARK: - Actor隔离
extension ViewController {
    /// 具体化的actor
    /**
     “现在把所有的安全设施都撤掉，只在它的门口设置一个信箱，并在房间内配置一个专员。来访者不再被允许亲自进入房间进行操作，他们只能携带一封信，并将这封信投递到信箱里，表明自己到访过。房间里的专员会负责检查信箱，每次拿出一封信进行处理。在获取信后，专员在房间里的“正”字纸上添加一笔，然后把结果封好作为回信寄回给来访者的地址。这样一来我们“轻易”地解决了上面的问题”
     1.“因为只有一个操作专员，且他每次只处理一封信，所以同一时间只会有一个人在纸上写字。内存状态不会遭到破坏”
     2.“因为来访者现在只需要进行信件投递，这不需要任何等待。投递完成后来访者 (调用线程) 就可以去做其他事情了，直到房间回信到达才需要回头处理结果。对锁的完全去除，也从根本上消除了死锁的可能性”
     
     “这样一个房间的模型，我们就把它称作 actor”
     “Actor 能够运作的关键在于，“信件投递”这件事情是线程安全的”
     */
}

// MARK: - “Swift 中的 actor 和隔离检查”
extension ViewController {
    /**
     1.“actor 类型和 class 类型在结构上十分相似，它可以拥有初始化方法、普通的方法、属性以及下标”
     2.“它们能够被扩展并满足协议，可以支持泛型等”
     3.“和 class 的主要不同在于，actor 将保护其中的内部状态 (或者说存储属性)，让自身免受数据竞争带来的困扰”
     4.“这种保护通过 Swift 编译器的一系列限制来达成，这主要包括对 actor 中成员 (包括实例方法和属性) 的访问限制”
     5.“在 actor 中，对属性的直接访问只允许发生在 self 里，像是上例中的 visit，可以直接操作 visitorCount 并返回它”
     */
    actor Room {
        let roomNumber = "101"
        var visitorCount: Int = 0
        init() {}
        
        func visit() -> Int {
            visitorCount += 1
            return visitorCount
        }
    }
    //    // “在 Room 外进行这些操作，编译器会给出错误”
    //    class Op {
    //        func foo() {
    //            let room = Room()
    //            // Actor-isolated property 'visitorCount' can not be mutated from a non-isolated context
    //            room.visitorCount += 1
    //            // Actor-isolated property 'visitorCount' can not be referenced from a non-isolated context
    //            debugPrint(room.visitorCount)
    //        }
    //    }
    /**
     “从外部直接操作和访问内部状态 visitorCount 的行为是被限制的，我们把这种限制称作 actor 隔离：Room 的成员被隔离在了 actor 自身所定义的隔离域 (actor isolated scope) 中”
     “不能直接调用 visit 方法，它也是在隔离域中的”
     */
    //    class Op {
    //        func foo() {
    //            let room = Room()
    //            // Actor-isolated instance method 'visit()' can not be referenced from a non-isolated context
    //            room.visit()
    //        }
    //    }
    /**
     “上面这些代码，如果在 Room 是 class 的情况下，都是被允许的。但是在 class 中它们并不安全，如果不加锁，任何线程都可以任意访问它们，这会面临数据竞争的风险。和 class 不同，在 actor 实例上所有的声明，包括那些存储和计算属性 (比如 visitorCount)、实例方法 (比如 visit())、实例的下标等，默认情况下都是 actor 隔离的。隔离域对于自身来说是透明的：被同一个域隔离的成员可以自由地互相访问，比如 visit() 中可以自由操作 visitorCount”
     
     “从 actor 外部持有对这个 actor 的引用，并对某个具有 actor 隔离特性的声明的访问，叫做跨 actor 调用。这种调用只有在异步时可以使用”
     “具体来说，像是 visit() 和 visitorCount 这样的异步访问将被转换为消息，来请求 actor 在安全的时候执行对应的任务”
     “这些消息就是投递到 actor 信箱中的“信件”，调用者开始一个异步函数调用，直到 actor 处理完信箱中的对应的消息之前，这个调用都会被置于暂停状态”
     “在此期间，负责的线程可以去处理其他任务。”
     “虽然 Room.visit 并没有被标记为 async 函数，但是编译期间 Swift 会对 actor Room 进行隔离检查，它会决定哪些调用是跨 actor 隔离域的调用”
     “因为 actor 要保证隔离状态不被意外改变，因此对于这些调用，必须等待到合适的时间才能处理”
     “编译器会应用上面的规则，要求调用方引入潜在暂停点 await”
     “Swift 中 actor 模型的特点，要求了对隔离域上的调用，必须发生在异步任务执行上下文中”
     */
    func bar() async {
        let room = Room()
        let visitCount = await room.visitorCount
        debugPrint(visitCount)
        debugPrint(await room.visitorCount)
    }
    
    /**
     “要注意，actor 隔离域是按照 actor 实例进行隔离的：也就是说，不同的 Room 实例拥有不同的隔离域。如果要进行消息的“转发”，我们必须明确使用 await”
     */
    actor Room2 {
        var visitorCount: Int = 0
        func forwardVisit(_ anotherRoom: Room) async -> Int {
            await anotherRoom.visit()
        }
        
        //        func testError(_ anotherRoom: Room) -> Int {
        //            // await' in a function that does not support cawait' in a function that does not support concurrencyoncurrency
        //            // Add 'async' to function 'test' to make it asynchronous
        //            // Actor-isolated instance method 'visit()' can not be referenced on a non-isolated actor instance
        //            await anotherRoom.visit()
        //        }
    }
    
    /**
     1.“在底层，每一个 actor 对信箱中的消息处理是顺序进行的，这确保了在 actor 隔离的代码中，不会有两个同时运行的任务”
     2.“也就确保了 actor 隔离的状态，不存在数据竞争”
     3.“从实现角度来看：消息是一个异步调用的局部任务，每个 actor 实例都包含了它自己的串行执行器，这个执行器实际对作用域进行了限制”
     4.“串行执行器负责在某个线程内循序执行这些局部任务 (包括处理消息，实际访问实例上的状态等)”
     5.“从概念上，这和串行派发的 DispatchQueue 类似，但是 actor 在实际运行时，是基于协作式的线程派发和 Swift 异步函数续体的，相比于传统的线程调度，它是一个更轻量级的实现”
     
     “Swift 中的 actor 模型，最重要的就是理解隔离域”
     1.“某个隔离域中的声明，可以无缝访问相同隔离域中的其他成员”
     2.“某个隔离域外的声明，不论它位于传统的非隔离中，还是位于其他 actor 的隔离域中，都无法直接访问这个隔离域的成员。只有通过异步消息的方法，才能跨越隔离域进行访问”
     */
}

// MARK: - Actor协议
protocol Popular {
    var popular: Bool { get }
}

extension ViewController {
    /**
     “所有的 actor 类型都隐式地遵守 Actor 协议，它的定义是”
     protocol Actor: AnyObject, Sendable {
     nonisolated var unownedExecutor: UnownedSerialExecutor { get }
     }
     “直接声明 actor 类型就可以了，编译器将在 actor 的初始化方法中“注入”创建执行器的调用，为 actor 绑定一个串行的执行器”
     */
    
    /// 隔离声明
    /**
     “actor 类型默认的声明都是被隔离在 actor 域中的”
     “让这个 actor 类型满足某个一般性质的协议时，会有一些困难”
     protocol Popular {
     var popular: Bool { get }
     }
     “使用 actor 类型定义的隔离域是一个非常强的假设”
     “对于某个 actor 实例所形成的隔离域，任何一个函数声明，要么在隔离域中，要么在隔离域外”
     “Popular 中定义的 var popular 不在任何 actor 隔离域中，它是一个普通的同步协议方法。当我们尝试像普通 class 那样去让 Room 实现 Popular 时，会遇到编译错误：”
     */
}

//// 报错代码
//extension ViewController.Room: Popular {
//     // Actor-isolated property 'popular' cannot be used to satisfy a protocol requirement
//    // Add 'nonisolated' to 'popular' to make this property not isolated to the actor
//    var popular: Bool {
//        visitorCount > 10
//    }
//}
/**
 “这里的 popular 是定义在 actor Room 中的，它是在 actor 隔离域中的声明。Room.popular 和 Popular.popular 产生了隔离域上的冲突，必须有一方进行妥协”
 */

// MARK: - Actor协议细分
extension ViewController {
}
/**
 “第一种方式是让 Popular 也能在某个隔离域中。这里可以让 PopularActor 作为 Actor 协议的细分存在”
 */
protocol PopulatorActor: Actor {
    var popularActor: Bool { get}
}

/**
 “这样，在当 Room 实现 PopularActor 时，其中的 popularActor 也将作为隔离域中的一部分存在，于是 Room 将可以在同一个隔离域中访问到 visitorCount”
 “当然，因为 popularActor 现在是 actor 的一部分了，从隔离域外对它的访问，都需要经过 await 进行。这一点和 actor 上的其他成员的默认行为是一致的。PopularActor 现在是 Actor 的细分协议，因此也只有 actor 类型能满足这个协议了”
 */
extension ViewController.Room: PopulatorActor {
    var popularActor: Bool {
        visitorCount > 10
    }
}

// MARK: - 定义异步协议方法
/**
 “让 Popular 协议对 actor 适用的第二种方法，是将涉及到的成员设计为异步方法或属性；也就是说，让它在语法上明确满足“可暂停”的特点”
 “这样的实现没有影响 Room.popularAsync 处于 actor 隔离域中的事实”
 “因此，在隔离域外我们可以用类似于访问其他成员的方式，通过 await 的方式访问到 popularAsync (实际上 get async 也要求我们使用 await)”
 */
protocol PopularAsync {
    var popularAsync: Bool { get async }
}

extension ViewController.Room: PopularAsync {
    var popularAsync: Bool {
        get async {
            visitorCount > 10
        }
    }
}

extension ViewController {
    func testAsyncProtocol() {
        Task {
            let room = Room()
            ///“await 纯粹就是一个编译期间的标记，它的作用是辅助开发者，提示我们这里代码可能发生暂停。选择将 await 写在整个表达式的开头，还是选择让它紧接实际可能暂停的代码，只要风格统一，都是可行的。不过，让 await 的位置尽可能靠近实际可暂停的表达式，可能会让代码的意思更加清楚。”
            debugPrint("is Popular \(await room.popularAsync)")
        }
    }
}

/**
 “虽然 popularAsync 的声明是处于 Room 的 actor 隔离域内的，但是它本身是一个异步 getter，域内的其他方法要访问它时，依然需要 await。这有时候很不方便，而且具有传染性：当某个域内方法本身是同步方法时，是不允许调用这个异步 getter 的”
 */
extension ViewController.Room {
    //    func reportPopular() {
    //        // async' property access in a function that does not support concurrency
    //        // Add 'async' to function 'reportPopular()' to make it asynchronous
    //        if popularAsync {
    //            debugPrint("Popular")
    //        }
    //    }
}
/**
 “为了避免重复逻辑，同时保持 popularAsync 以满足异步协议，也许我们可以添加一个内部使用的同步的 getter，然后在 popularAsync 中把它简单地转换为异步”
 */

extension ViewController.Room {
    private var internalPoular: Bool {
        visitorCount > 10
    }
    
    var popularAsync2: Bool {
        get async {
            internalPoular
        }
    }
}

/**
 “这样，刚才的 reportPopular 就可以直接使用隔离域内的同步方法了”
 */
extension ViewController.Room {
    func reportPopular2() {
        if internalPoular {
            debugPrint("Popular")
        }
    }
}

/**
 “如果我们需要一个协议既能被 class 或 struct 这样的“传统”类型满足，又能以安全的方式工作在 actor 里，可以考虑将协议的成员声明为上面这样的异步成员”
 “因为同步函数其实是异步函数的子集和“特例”，所以普通类型是可以用同步函数来实现这个协议的异步定义的”
 */
class RoomClass: PopularAsync {
    var popularAsync: Bool { return true }
}

extension ViewController {
    func testClassAsync() {
        let room = RoomClass()
        debugPrint(room.popularAsync)
    }
}
/**
 “我们要使用 PopularAsync 作为实例类型 (或者类型约束) 的话，由于类型信息不足以判断 popularAsync 的具体实现是否是同步，我们必须加上 await 才能进行调用”
 */
extension ViewController {
    func testInstanceAsync() {
        Task {
            let room = RoomClass()
            await foo2()
            await bar(value: room)
        }
    }
    func foo2() async {
        let room: PopularAsync = RoomClass()
        debugPrint("x \(await room.popularAsync)")
    }
    
    func bar<T: PopularAsync>(value: T) async {
        debugPrint("b \(await value.popularAsync)")
    }
}

// MARK: -  nonisolated
/**
 “在上面 PopularActor 和 PopularAsync 的例子中，我们都更改了协议本身的定义。但是当这个协议是外部定义的或者早已存在于现有同步系统中的话，改变协议本身是很困难、甚至不可能的事情。比如，如果我们想为 Room 加上一段描述，想办法让它满足 Swift 的 CustomStringConvertible”
 public protocol CustomStringConvertiable {
 var description: String { get }
 }
 “这是一个同步协议，不可能纳入到 actor 隔离域内。想要在 Room 中满足这样一个协议，唯一的方法是明确将 Room.description 声明放到隔离域外，使用 nonisolated 标记可以让编译器做到这一点”
 */
extension ViewController.Room: CustomStringConvertible {
    nonisolated var description: String {
        "A room"
    }
}

// “隔离域外的成员 description 是不能同步访问隔离域内的内容的。比如下面的代码会给出编译错误”
//extension ViewController.Room2: CustomStringConvertible {
//    nonisolated var description: String {
//        // Actor-isolated property 'visitorCount' can not be referenced from a non-isolated context
//        "Room Visited: \(visitorCount)"
//    }
//}

/**
 “Room 中用 let 声明的存储变量，是一个例外。这类 let 成员的值不会在并发模型中改变，因此它们天然是线程安全的”
 “在同一个模块内，从域外访问这样的值是透明的”
 1.“需要强调的是，这个“安全例外”只发生在同一模块内。从别的模块访问 let 定义的 roomNumber 时，依然需要加上 await”
 2.“这样的安排是刻意为之的：根据版本原则，将 public let 替换为 public var，应该是一个仅添加了特性 (setter)，可以后向兼容的变化，它不应该引起原有使用者的编译错误”
 3.“但是，如果我们将 public let 也作为例外，让模块外的代码可以直接使用的话，在未来我们将它换为 public var 时，原有的域外代码将会失效 (此时需要 await 才能跨域访问)”
 4.“因此，一开始就由编译器作出规定，必须使用 await 来进行跨模块跨域访问，是更合理的选择”
 5.“nonisolated 标记的成员，无法访问那些隔离域内的成员，否则将违反基本的并发安全假设，让 actor 类型变得不安全”
 6.“另外，actor 中的存储属性的成员安全保证，只针对具体的值和引用”
 7.“对于那些被引用的实际对象，如果它们的类型不是 actor，而是普通的 class 的话，在域外对这些对象上成员的访问依然是不安全的”
 */
actor Room3 {
    let roomNumber = "1"
}
extension Room3: CustomStringConvertible {
    nonisolated var description: String {
        "Room Number: \(roomNumber)"
    }
}

class Person: CustomStringConvertible {
    var name: String
    var age: Int
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
    
    var description: String {
        "Name:\(name) age:\(age)"
    }
}

actor Room4 {
    private let person: Person
    
    init() {
        person = Person(name: "Goo", age: 11)
    }
}

extension Room4 {
    func changePersonName() {
        person.name = "Boo"
        debugPrint("Person:\(person)")
    }
}
/**
 “这里，可以确信 changePersonName 的执行是在域内，它是安全的，因此 person.name 的修改在此时也是安全的。但是，我们也可以在 Room 的一个 nonisolated 域外方法中修改这个属性，编译器并没有阻止我们这么做”
 
 “由于 unsafeChangePersonName 在隔离域外，它可能在多个线程中以并行的方式被调用，此时对 name 的修改将造成内存的数据竞争。因此这段代码是不安全的”
 “当然，这并没有违反 actor 关于“保护成员”的目标：因为 person 这个引用确实是完全受到保护的，问题在于 Person 类型没有能够保护它的 name 成员，这是由于 Person 是 class 这一特质所造成的，和 Room 是 actor 这一事实并无关系”
 1.“想要增加安全性，我们可以选择把 Person 也声明为 actor，或者让它满足一个稍微弱化的假设，让 Person 满足 Sendable”
 2.“在未来，编译器会添加这类问题的静态检查，并彻底防止此类数据竞争的问题”
 */
extension Room4 {
    nonisolated func unsafeChangePersonName() {
        person.name = "TOO"
        debugPrint("Person:\(person)")
    }
}

// MARK: - isolated
/**
 1.“在 actor 中的声明，默认处于 actor 的隔离域中”
 2.“在 actor 中的声明，如果加上 nonisolated，那么它将被置于隔离域外”
 3.“在 actor 外的声明，默认处于 actor 隔离域外”
 “对于 actor 外的声明，我们有没有办法让它处于某个隔离域中呢”
 “答案是肯定的，我们可以使用 isolated 关键字来修饰函数的某个 actor 类型的参数，这会明确表示函数体应该运行在该 actor 的隔离域中”
 
 “通常在一些需要隔离的全局的函数中，可以见到这样的用法：”
 1.“在函数参数的类型前，加上 isolated，将把这个函数放到该参数 actor (这里是 room) 的隔离域中”
 2.“在函数体内部调用隔离域内的成员，就可以使用同步的方式了”
 */
func reportRoom(room: isolated ViewController.Room) {
    debugPrint("Room: \(room.visitorCount)")
}

/**
 “根据调用者和参数的不同，在调用这个全局函数时，编译器会要求我们添加 await”
 “规则和一般对 actor 的成员调用完全一致：当从隔离域内部使用时，可以以同步方式直接访问；但当从隔离域外使用时，则需要 await”
 */
extension ViewController.Room {
    func doSomething() async {
        // self在自身的隔离域中
        reportRoom(room: self)
        
        let room = ViewController.Room()
        // room 不在self隔离域中，需要切换隔离域
        // Expression is 'async' but is not marked with 'await'
        await reportRoom(room: room)
    }
}

// MARK: - 隔离域切换
/**
 “提到了隔离域切换的概念，使用一个更“正规”一些的名称，我们把它叫做 actor 跳跃 (actor hopping)”
 1.“对于隔离域中的成员，比如方法调用，actor 跳跃是隐式发生的”
 2.“编译器在生成最终代码时，会在需要的位置插入 actor 跳跃的指令”
 “典型的地方是方法开头时跳到 self，以及显式 await 调用其他 actor 成员时跳到对应的 actor。比如，上例中 doSomething 在编译后，等效于”
 actor Room {
 func doSomthing() async {
 hop_to_executor(self)
 // self在自身隔离域中
 reportRoom(room: self)
 
 let room = Room()
 
 // room不在self隔离域中。需要切换隔离域
 hop_to_executor(room)
 reportRoom(room: room)
 
 // room隔离域执行完毕，跳回self
 hop_to_executor(self)
 }
 }
 
 “actor 跳跃是轻量级的操作，大部分情况下它们会在同一个线程中完成，但我们不应该对实际的执行线程进行假设”
 “通过理解 actor 跳跃，以及异步函数和任务执行时的堆栈情况,对 Swift 并发程序的性能有基本的判断”
 */

// MARK: - 隔离域冲突
/**
 “通过 isolated 设定函数的隔离域，天然地面临着一个问题：那就是在设定的多个 isolated 参数时，会发生什么。比如说，某个全局函数接受两个不同的 isolated actor”
 “这时的隔离域应该是 room1 呢，还是 room2 呢，又或者是其他某种行为？”
 1.“如果我们在 Room 中为 room1 和 room2 都传入 self 的话，隔离域的表述是清晰的，就是 self 自身的隔离域”
 2.“同时传入 self 和其他某个新的 Room 对象”,“这种情况下，当前编译器会选择使用第一个非 self 的 actor 隔离域作为调用时的隔离域”
 */
// @note 危险代码
func addCount(room1: isolated ViewController.Room, room2: isolated ViewController.Room) -> Int {
    let count = room1.visitorCount + room2.visitorCount
    return count
}

extension ViewController.Room {
    func addSelf() {
        debugPrint("\(#function) \(visitorCount)")
        _ = addCount(room1: self, room2: self)
    }
    
    // @note “在由 isolated 标记参数的 addCount 中，运行环境的隔离域是 another actor 值。在其中以同步的方式访问第一个参数 self 上的成员，是不安全的行为”
    func add(_  another: ViewController.Room) async {
        debugPrint("\(#function) \(visitorCount)")
        _ = await addCount(room1: self, room2: another)
    }
    
    //    // 等效于
    //    func add(_  another: ViewController.Room) async {
    //        hop_to_executor(self)
    //        debugPrint(visitorCount)
    //
    //        hop_to_executor(another)
    //        _ = await addCount(room1: self, room2: another)
    //        hop_to_executor()
    //    }
}

extension ViewController {
    func testisolatedMulti() {
        Task {
            let room = Room()
            await room.addSelf()
            let another = Room()
            await room.add(another)
        }
    }
}
/**
 “这种行为理论上应该被编译器禁止，但是 Swift 并发路线图中指出，actor 的完全隔离将作为第二阶段的目标，而 Swift 5.5 中的第一阶段，只提供部分的 actor 隔离。我们在上一节里谈到的不安全的 unsafeChangePersonName，也属于暂时没有确保安全的操作”
 1.“虽然在静态上不安全，但是 Swift 并发底层所依赖的 GCD 的新实现，可以通过合理的调度，让 self 隔离域和 another 2.隔离域处在同一个并发域中“交替”执行，以此避免内存问题。”
 3.“不过，这并没有文档说明,也不是一个很强的保证，我们最好不要依赖这个实现细节来进行假设”
 
 “和上面的使用两个 isolated 隔离参数造成冲突类似，如果我们在某个 actor 中声明了接受 isolated 参数的方法，即使它只接受一个这种参数，其隔离域依然存在冲突：方法本身在 actor 中，是按照 self 进行 actor 隔离的，同时它又被声明了参数隔离，我们将无法确定最终这个函数的隔离状态”
 */
// @note危险代码
extension ViewController.Room {
    func baz(_ another: isolated ViewController.Room) {
        debugPrint(visitorCount)
        debugPrint(another.visitorCount)
    }
}

/**
 1. “要解决这个隔离上的模糊，我们可以选择去除 isolated，这样就能明确地选择使用 self 隔离”
 2. “或者为方法添加 nonisolated 来去掉 self 的隔离，从而选择 another 的隔离域”
 3. “在跨越隔离域访问成员时，按照规则使用 await，会是更加明确的做法”
 */

extension ViewController.Room {
    // 使用self隔离
    func baz1(_ another: ViewController.Room) async {
        debugPrint(visitorCount)
        debugPrint(await another.visitorCount)
    }
    
    // 使用another隔离
    nonisolated func baz2(_ another: isolated ViewController.Room) async {
        debugPrint(await visitorCount)
        debugPrint(another.visitorCount)
    }
}

/**
 “乍看起来，为 Room.baz2 添加 nonisolated，并指定 isolated 的方式似乎很蠢，但是它确实有实际的使用途径。考虑下面这种情况，我们在方法内需要多次访问 another actor 隔离域中的成员”
 “在默认的 self 隔离中，每次对 another 上成员的访问都会产生两次 actor 跳跃”
 “从 self 域切换到 another 域，然后在 await 结束后再切回 self。这种情况下，使用 nonisolated，可以减少 actor 跳越的次数，在某些特定情况下对性能提升会有一定帮助”
 
 “尽可能避免隔离域的冲突，让一个成员拥有单一而明确的隔离域，往往可以帮助我们避开很多潜在的问题”
 */
extension ViewController.Room {
    func baz3(_ another: ViewController.Room) async {
        for _ in 0..<100 {
            debugPrint(await another.visitorCount)
            _ = await another.visit()
            debugPrint(await another.visitorCount)
        }
    }
    
    nonisolated func baz4(_ another: isolated ViewController.Room) async {
        for _ in 0..<100 {
            debugPrint(another.visitorCount)
            _ = another.visit()
            debugPrint(another.visitorCount)
        }
    }
}

// MARK: - 全局Actor，可重入，Sendable
// MARK: - 全局 Actor
/**
 “actor 类型作为局部的数据隔离手段，是非常有效的”,“编译器可以保证定义在 actor 上的成员的安全”
 “使用 isolated 把函数的隔离域设定为某个参数隔离域的方式，来让 actor 隔离域在一定程度上得到扩展”
 “如果需要保护的状态存在于 actor 外部，或者这些代码不可能汇集到一个单一的 actor 实例中时，我们可能会需要一种作用域更加宽广的隔离手段。
 “我们可以声明并使用global actor”
 “作为属性包装，它可以被任意地使用在某个属性或方法前，对这个属性或方法进行标注，把它限定在该全局 actor 的隔离域中”
 “Swift 标准库中的 MainActor 就是这样一个全局 actor”
 */

// MARK: - MainActor
extension ViewController {
    /// “主线程队列派发”
    /**
     “UIKit 或 AppKit 中，对 UI 的操作必须在主线程上进行；一些重要的由框架调用的方法 (比如 viewDidLoad 等)，也会被保证在主线程上运行”
     “假设代码在某个后台线程中获取了数据 (这在使用 URLSession 进行网络请求的时候是很常见的情况)，我们想用这些数据设置 UI 的话，传统 GCD 中，会需要使用 DispatchQueue.main 将操作派发到 UI 队列，并由 UI 队列把工作分配给它所绑定的主线程，来进行实际的工作”
     */
    func testMainDispatch() {
        let url = URL(string: "https://www.baidu.com")!
        let task  = URLSession.shared.dataTask(with: url) { data, response, erro in
            debugPrint(Thread.isMainThread)
            DispatchQueue.main.async {
                debugPrint(Thread.isMainThread)
                //Do UI thing
            }
        }
        task.resume()
    }
    
    /**
     “这个方法在 Apple 平台的 app 开发中可以称得上是被广泛使用的，以至于很多时候开发者会“无脑”在任何时候都使用这个方式，或者甚至将它滥用，作为“黑魔法”来解决一些比如布局等 UI 时序上的问题。将操作派发到 DispatchQueue.main 上，特别是如果原来就在主线程上，但依然进行这样的派发的话，往往会改变原本应有的执行顺序，为今后埋下巨大的隐患。在使用 DispatchQueue.main 时，有一种做法是先判断当前是否是主线程，如果是的话，则直接执行需要的操作；如果当前不是主线程，那么再进行派发。这样，我们就可以避免不必要的派发，并在一定程度上减轻派发对主线程操作执行顺序的改变，就像下面这样”
     extension DispatchQueue {
     static func mainAsyncOrExecute(_ work: @escaping() -> Void) {
     if Thread.isMainThread {
     work()
     } else {
     main.async { work() }
     }
     }
     }
     
     “这个模式其实和 actor 高度相似：当方法在 actor 隔离域时，我们就可以用同步方式直接访问 actor 成员，在隔离域外时，则需要异步访问。”
     “我们完全可以为把主线程看作是一个特殊的 actor 隔离域：这个隔离域绑定的执行线程就是主线程，任何来自其他隔离域的调用，需要通过 await 来进行 actor 跳跃。在 Swift 中，这个特殊的 actor 就是 MainActor”
     
     */
    
    /// MainActor 隔离域
    /**
     “MainActor 是标准库中定义的一个特殊 actor 类型”
     @globalActor final public actor MainActor: GlobalActor {
     public static let shared: MainActor
     }
     “整个程序只有一个主线程，因此 MainActor 类型也只应该提供唯一一个对应主线程的 actor 隔离域。它通过 shared 来提供一个全局实例，以满足这个要求”
     “所有被限制在 MainActor 隔离域中的代码，事实上都被隔离在 MainActor.shared 的 actor 隔离域中。”
     */
    
    /// @MainActor属性包装
    /**
     “如果我们看 GlobalActor，会发现这个 shared 成员正是 GlobalActor 协议的要求。通过满足 GlobalActor 并且在类型前添加 @globalActor 标记，我们就可以将这个 MainActor 类型作为属性包装 (property wrapper)，用来注记其他的类型或者方法：”
     “按照添加的地方，@MainActor 有不同的作用”
     1.“对于 C1，整个类型都被标记为 @MainActor：这意味着其中所有的方法和属性都会被限定在 MainActor 规定的隔离域中”
     2.“C2 的话，只有部分方法被标记为 @MainActor”
     3.“另外，对于定义在全局范围的变量或者函数，也可以用 @MainActor 限定它的作用返回，上面代码中的 globalValue 就是一个例子”
     4.“在使用它们时，需要切换到 MainActor 隔离域”
     5.“和其他一般的 actor 一样，可以通过 await 来完成这个 actor 跳跃”
     6.“也可以通过将 Task 闭包标记为 @MainActor 来将整个闭包“切换”到与 C1 同样的隔离域，这样就可以使用同步的方式访问 C1 的成员了”
     */
    @MainActor class C1 {
        func method() {}
    }
    
    class C2 {
        @MainActor var value: Int?
        @MainActor func method() {}
        func nonisolatedMethod() {}
    }
    
    class Sample {
        func foo() {
            Task { await C1().method() }
            Task { @MainActor in C1().method() }
            Task { @MainActor in globalValue = "Hello" }
        }
        
        func bar2() async {
            await C1().method()
        }
    }
    
    /**
     “我们提到过，每个 actor 实际都有一个串行的执行器，来保证同一时间对成员访问是唯一的”
     “MainActor 的执行器在内部所做的事情，其实就是调用 DispatchQueue.main 的 async，在需要的时候把操作派发到主队列中”
     “事实上，这样的派发所接受的闭包，在 Swift 并发中也是被隐式标记为 @MainActor 的，所以下面的代码，虽然看起来 foo 在 MainActor 的隔离域外，但在闭包中对隔离域内的成员可以同步访问”
     “混用在 MainActor 这个特例中执行时不会有太大问题，但是却引入了不同的并发风格，可能造成理解上的困难”
     1.“在 Swift 并发中，其实线程和通过 GCD 进行线程调度的概念，更多时候是被隐藏起来的”
     2.“如果没有绝对的必要，我们最好让并发的底层机制为我们进行调度，以保证并发性能”
     */
    class Sample2 {
        func foo() {
            DispatchQueue.main.async {
                C1().method()
                globalValue = "World"
            }
        }
    }
}

@MainActor var globalValue: String = ""

// MARK: - UIKit中的 @MainActor
/**
 “UIKit 中一些非常常用的类，都被 @MainActor 修饰了”
 “比如 UIViewController 或者 UIView，甚至是它们的所有子类”
 @MainActor class UIViewControll: UIResponder
 @MainActor class UIView: UIResponder
 @MainActor class UIButton: UIControl
 “在 Swift 并发的时代之前，虽然在文档中规定了这些 UI 相关的类型比如在主线程上操作，但这些规则并没有编译器保证，只能在运行时通过调试手段 (比如打开 Main Thread Checker) 检测到。@MainActor 的出现，将这些类型上的成员明确地圈入隔离域中。从 UIViewController 自身内部的调用，可以直接使用同”
 “步方式。在以前，切换到后台队列的线程去执行某项任务 (比如加载网络资源)，然后再切回主线程设置 UI，是非常常见的做法。这类操作现在用 Task.init 书写的话，可以更简单”
 
 */

extension ViewController {
    func testMainActor() {
        let url = URL(string: "https://www.baidu.com")!
        Task {
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            updateUI(data)
        }
        Task.detached {
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            // Expression is 'async' but is not marked with 'await'
            //self.updateUI(data)
            await self.updateUI(data)
        }
    }
    
    private func updateUI(_ data: Data?) {
        debugPrint("\(data?.count ?? 0)")
    }
}

/**
 “上例中，继承自 UIViewController 的 ViewController 在 @MainActor 域中，因此 viewDidLoad 的运行环境也在同一隔离域里。通过 Task 新建的任务，将继承 actor 的运行环境，也就是说，它的闭包也运行在 MainActor 隔离域中的，这也是可以同步调用 updateUI 的原因。”
 “如果我们将这里的 Task.init 换为 Task.detached 的话，闭包的运行将无视原有隔离域。此时，想要调用 updateUI，我们需要添加 await 以确保 actor 跳跃能够发生”
 “所以，在 UIViewController 的环境中，如果我们希望开始某个异步操作，然后在主线程中调用自身成员的话，Task.init 一般会是更好的选择：它能保证 await 后，后续代码能通过 actor 跳跃回到 MainActor 中执行。”
 */

/**
 “对于 UIViewController 外发生的调用，在 Swift 并发上下文中 (比如 async 函数或者某个一般 actor 内)，由于无法确定调用域，因此必须使用 await 的方式进行 actor 跳跃，来保证它们运行在主线程上”
 */
class Sample3 {
    func bar() async {
        let button = UIButton()
        // Expression is 'async' but is not marked with 'await'
        await button.setTitle("Click", for: .normal)
        // Expression is 'async' but is not marked with 'await'
        await ViewController().view.addSubview(button)
    }
}

/**
 “严格来说，这对旧的代码会是一个破坏性的变化：在引入 Swift 并发之前，ViewController 之外 (或者说是 MainActor 隔离域外) 的代码，如果操作和使用了 ViewController 的话，由于无法确定原来的隔离域，理论上都应该编译报错”
 “但是事实上，编译器却“容忍”了这类问题。比如下面的代码可能会在任意隔离域，甚至是非隔离域中被调用，但它并不会产生错误”
 “如果编译器对所有像是 UIViewController 或者 UIView 这些类型进行严格的隔离域检查，那么可以想见已有的代码将几乎不可能完成隔离域的迁移”
 “因此，Swift 现在选择了只在明确的存在任务上下文的环境中，对 @MainActor 进行隔离域检查”
 “也就是说，检查只发生在异步方法里、actor 中、以及 Task 相关 API 等地方”
 “对于引入 Swift 并发之前就存在的纯同步的代码，这个检查被关闭了”
 1.“在原有的同步代码中忽略掉 @MainActor，是一种工程上的妥协。在编译器内部，这依靠 @_unsafeMainActor 内部标注完成”
 2.“通过逐步递进的方式提供可行的迁移方案，一直是 Swift 并发路线图上重要的目标之一。在未来我们也许会看到更加严格和绝对安全的 UI 代码，但是那并不是一个近期目标”
 */
extension Sample3 {
    // @note “注意，和 `bar` 不同，foo 不是异步函数”
    func foo() {
        let button = UIButton()
        button.setTitle("Click", for: .normal)
        ViewController().view.addSubview(button)
    }
}

/**
 “不过如果我们明确地将某些成员标记为 @MainActor 的话，可以用这个“本地”的声明覆盖编译器的针对全体的默认行为。在为已有项目进行迁移时，我们也可以利用这一点重新“激活”编译器的检查，让我们得到更加安全的代码”
 “通过标注 @MainActor，Swift 编译器实际上已经具备了提供完全的主线程安全的能力”
 “尽可能多地明确设定这类注解，不仅可以在当下立即增加代码的安全性；在未来某天 (也许是 Swift 6)，如果 Swift 编译器决定不再容忍非主线程的 UI 代码时，我们迁移起来也能轻松一些”
 */
extension ViewController {
    @MainActor func explicitUIMethod() { }
}

extension Sample3 {
    func foo2() {
        // Call to main actor-isolated instance method 'explicitUIMethod()' in a synchronous nonisolated context
        // ViewController().explicitUIMethod()
        Task {
            // Expression is 'async' but is not marked with 'await'await
            await ViewController().explicitUIMethod()
        }
    }
}

// MARK: - 自定义全局actor
/**
 “@MainActor 可以帮助将散落在代码各处的需要在主线程进行的操作统一隔离起来”
 “对于其他的隔离域，通常直接使用 actor 类型就能胜任。”
 “但是有一些情况，我们可能会需要和 @MainActor 类似的手段，来创建自己的全局隔离域”
 1.“若干个可以成组的状态：它们散落在各个类型里，但是需要以串行的方式避免写入时的数据竞争”
 2.“存在需要被某个 actor 隔离的全局变量，此时单纯的 actor 类型无法做到将其纳入隔离域”
 3.“需要隔离的状态是跨越模块的：提供隔离域的人希望某些由其他开发者生成的状态被纳入该隔离域以保证执行时的安全。开发者在编译自己的模块时，可以向外部提供一个全局 actor，这样别人就能使用定义在模块内部的隔离域了”
 
 “对于这些需求，可以像 MainActor 那样，使用 @globalActor 来把一个 actor 类型声明为全局 actor，这会把它转换为一个属性包装”
 “和 MainActor 类似，该类型需要提供一个单例，所有被属性包装标注的内容，都会被限制在这个 actor 单例的隔离域中”
 */
@globalActor actor MyActor {
    static let shared = MyActor()
}

@MyActor var foo = "sss"

/**
 “虽然被标记为全局 actor，但 MyActor 自身也确实还是一个 actor 类型，所以这并不妨碍它被作为普通的 actor 来使用”
 “比如持有一些成员变量或者方法时，这些 actor 内的声明会拥有自己的隔离域。有时候这会造成一些困惑。比如下面这样的代码”
 */

@globalActor actor MyActor2 {
    static let shared = MyActor2()
    var value: Int = 0
}

@MyActor2 func bar(actor: MyActor2) async {
    debugPrint(await actor.value)
    debugPrint(await MyActor2.shared.value)
}
/**
 1. “bar 方法被 @MyActor 标记，因此它运行在 MyActor.shared 的隔离域中”
 2. “对于 bar 方法里作为参数的 actor，我们无法判断它是否和 MyActor.shared 属于同一隔离域，因此必须使用 await”
 3. “即便访问的就是 MyActor.shared 上的属性 value，编译器现在也还无法指出它和 @MyActor 其实是在相同的隔离域中，所以这里也需要明确的 await 才能访问”
 4. “为了从根本上避免这类困扰，我们通常会选择不在 @globalActor 里持有变量和实例方法，并且为它声明一个私有的初始化方法。”
 5. “将这个 actor 类型作为纯粹的标记来使用，减少一些迷惑”
 */
@globalActor actor MyActor3 {
    static let shared = MyActor3()
    private init() {}
}

// MARK: - 可重入
/**
 “在 actor 的话题下，另一个很容易让人掉坑里的问题是 actor 方法的可重入特性 (reentrancy)”
 */

// MARK: - actor中的异步方法和交织
/**
 1. “和其他类型一样，actor 中的方法里也可以使用异步函数”
 2. “在对异步函数调用时，当前的方法有可能因为要处理其他任务而处于暂停状态”
 3.“依靠串行调度来保证数据安全的 actor 在这种情况下将面临一个选择：是否要在一个方法暂停时，允许 actor 上的其他成员被访问”
 “Swift 的选择是允许这样的访问，我们把这个特性称为可重入”
 “在被暂停的 actor 隔离函数继续之前，可重入特性允许其他工作”“在这个 actor 上执行 (也包括被暂停的函数被其他人再次调用)”
 “当 actor 上的一个函数还在等待，但另一个函数占用了隔离域并可能修改 actor 上的属性时，我们就说这些访问之间就发生了“交织” (interleaving)”
 “这样一来，就算是访问的是同一个变量，我们也不能轻易作出假设，认为在 await 前后它们的值会相同”
 */

// MARK: - 可重入的风险
struct Report {
    let reason: String
    let visitCount: Int
}

func analyze(room: ViewController.Room) async -> String {
    try? await Task.sleep(nanoseconds: NSEC_PER_SEC)
    return "da da da"
}

extension ViewController.Room {
    var isPopular: Bool {
        visitorCount > 10
    }
    
    func generateReport() async -> Report? {
        if !isPopular {
            debugPrint(visitorCount)
            let reason = await analyze(room: self)
            debugPrint(visitorCount)
            return Report(reason: reason, visitCount: visitorCount)
        }
        return nil
    }
}

extension ViewController {
    func testAnaylze() {
        let room = Room()
        Task {
            _ = await room.visit()
            let r = await room.generateReport()
            debugPrint(String(describing: r))
        }
        /// “但是，因为可重入的存在，在 generateReport 中 analyze 执行期间，其他并发代码也可以使用 room，比如多次调用 visit 进行访问”
        /// "Optional(ActorModel.Report(reason: \"da da da\", visitCount: 101))"
        Task {
            for _ in 0..<100 {
                _ = await room.visit()
            }
        }
    }
}

/**
 1. “要指出的是，在 actor 中，即使交织发生，await 后的实例成员状态和我们“预想”的有所不同”
 2. “但是 actor 隔离域本身依然是有效的：两次函数调用在 actor 隔离域中依旧是串行执行的，它们并不会造成对某个状态的同时读写和内存危险”
 3. “不过，这些交织是否发生还是取决于调用的时间，所以从外部看起来，它的部分行为会表现得和数据竞争有些相似”
 “在暂停点发生交织的可能性，是编译器要求在每个暂停点标记 await 的主要原因之一”
 “在 actor 中，面对每次 await，我们都需要格外小心：await 前后的执行环境可能完全不同，实例上的状态也可能发生改变”
 “在 await 前后依赖某些状态和假设时，必须时刻清晰认识到这一点。我们可以通过在 await 之前就复制一份需要的值，并依赖这个不变量，来解决 generateReport 的问题”
 */

extension ViewController.Room {
    func generateReport2() async -> Report? {
        if !isPopular {
            let count = visitorCount
            let reason = await analyze(room: self)
            return Report(reason: reason, visitCount: count)
        }
        return nil
    }
}

/**
 “不过，要注意只有值语义的类型适合这种做法，引用类型依然有被改变的风险。另外，根据具体的逻辑，也许我们也会有其他的解决方式，比如在 await 后再次检查并判断我们所依赖的状态”
 1.“在处理可重入时，往往需要具体问题具体分析，并没有所谓的万灵丹”
 2.“首要任务是认识到可重入可能发生的条件，在 actor 方法中看到 await 关键字时，我们就需要提高警惕了”
 */
extension ViewController.Room {
    func generateReport3() async -> Report? {
        if !isPopular {
            let reason = await analyze(room: self)
            return isPopular ? nil : Report(reason: reason, visitCount: visitorCount)
        }
        return nil
    }
}

// MARK: - 不可重入的设计
/**
 “既然可重入和 actor 中的异步函数会造成执行上的交织，并带来这种编译器无法侦测的危险，那么为什么 Swift 并发依旧选择支持 actor 可重入呢？”
 1.“如果让 actor 成为不可重入的实例，那么就意味着当 actor 在处理一条消息时 (希望你还记得 actor 的信箱机制)，它将不再查看邮箱和处理其他内容”
 2.“这其实就回到了类似锁的世界中，在任务运行时，我们将 actor 锁上，以此避免交织和内部状态在交织中的改变”
 3.“回到使用锁来避免交织的话，同时也会把锁的问题带回来，那就是大幅退化的性能以及出现死锁的风险”
 4.“这两者恰恰是我们引入 actor 想要解决的重要问题”
 5.“有一些其他语言和框架选择在禁止可重入的同时，为 actor 调用加上超时检测”
 6.“不过这要求所有的异步函数都可以 throw，而且超时检测本身也会带来性能开销，这与 Swift 并发的初衷并不相符”
 */

// MARK: - Sendable
// MARK: - 在隔离域间传递数据
/**
 “和 Hashable 表示类型可以求取哈希值，Equatable 表示支持判等类似，Sendable 协议也表达了类型的一种能力，那就是该类型可以安全地在不同并发域之间传递”
 1.“以 actor 的执行环境为例：actor 隔离域提供了一个串行的执行环境，通过在域外使用 await 调用 actor 上的方法，我们可以跳跃到隔离域内”
 2.“不过，这种跳跃往往伴随着一些数据的转移：比如 actor 上的方法接受某个参数，或者这些方法所返回的值，都会随着调用和返回一同跨越隔离域”
 */
actor Room5 {
    let roomName: String
    init(roomName: String) {
        self.roomName = roomName
    }
}
// “它定义了自己的隔离域，我们可以为它声明一些有用的方法”
extension Room5 {
    func visit(_ visitor: PersonStruct) -> PersonStruct {
        var result = visitor
        result.message = "Hello, \(visitor.name). From\(roomName)"
        return result
    }
}


struct PersonStruct {
    let name: String
    var message: String = ""
    
    init(name: String) {
        self.name = name
    }
}
/**
 “不过，当我们使用一个具有引用语义的类型 (比如 class 类型) 时，情况就不一样了。在 Swift 5.5 (Xcode 13) 中，如果换成 PersonClass，它将高概率因为内存错误产生崩溃”(没有验证到crash)
 “对于 PersonClass，在传递给不同 Room 隔离域时，它们指向的是同一个内存引用。因此，调用 visit 和 p.message 期间，存在从多个线程同时访问共享内存的风险。actor Room 虽然能保证自己的成员免于数据竞争，但是它并不能确保跨越隔离域的参数或返回值的安全”
 */
class PersonClass {
    let name: String
    var message: String = ""
    
    init(name: String) {
        self.name = name
    }
}

extension Room5 {
    func visit(_ visitor: PersonClass) -> PersonClass {
        visitor.message = "Hello, \(visitor.name). From\(roomName)"
        return visitor
    }
}

extension ViewController {
    func testSendable() {
        // 值类型
        let person = PersonStruct(name: "xxx")
        for i in 0..<10000 {
            Task {
                let room = Room5(roomName: "room\(i)")
                let p = await room.visit(person)
                debugPrint(p.message)
            }
        }
        
        // 引用类型
        let personCls = PersonClass(name: "zzz")
        for i in 0..<10000 {
            Task {
                let room = Room5(roomName: "room\(i)")
                let p = await room.visit(personCls)
                debugPrint(p.message)
            }
        }
    }
}

/**
 “除了 actor 以外，在使用 Task 相关的 API 创建和运行新的任务时，我们也面临着类似的问题。一些数据可能会在创建 Task 时从非任务的运行环境传递到任务运行环境中，同时它也可能在其他并发运行的环境中被访问”
 */
class Sample6 {
    var value: String = ""
    func foo() {
        Task { value += "ee" }
        Task { value += "fff" }
        debugPrint(value)
    }
}
/**
 “为了保证数据安全，我们需要一种方法来对此进行检查，核心问题是：“我们应该在什么时候，以什么方式允许数据在不同的并发域中传递？”
 “这个问题的答案是相当明确的：只有那些不会在并发访问时发生竞争和危险的类型，可以在并发域之间自由传递。不过即使答案明确，它所涵盖的具体类型也是多种多样的”
 1.“像是 PersonStruct 这样的所有成员都具有值语义，它自身也具有值语义的类型是安全的”
 2.“即使是 class 这样的引用类型，只要它的成员都是不可变量并满足 Sendable 的话，它也是安全的”
 3.“在内部存在数据保护机制的引用类型，比如 actor 类型或是成员访问时通过加锁来进行状态安全保证的类型”
 4.“可以通过深拷贝 (deep copy) 来把内存结构完全复制的情况”
 等等
 
 “在 Swift 并发在设计针对跨越并发域的数据安全时，想要做到的事情有三件”
 1. “对于那些跨越并发域时可能不受保护的可变状态，编译器则应该给出错误，以保证数据安全”
 2.“Swift 的并发设计，是鼓励使用值类型的。但是有些情况下引用类型确实可以带来更优秀的性能。对于 1 中的限制，应该为资深程序员留有余地，让他们可以可以自由设计 API，同时保证数据安全和性能”
 3.“Swift 5.5 之前已经存在大量的代码，如果强制开始 1 的话，可能会造成大量的编译错误。我们需要平滑和渐进式的迁移过程。”
 - tip:
 1. “对于 1，我们使用 Sendable 来标记那些安全的类型”
 2. “对于 2，Swift 留有 @unchecked Sendable 让开发者可以在需要时绕过编译器的检查”.
 3.“对于 3，Swift 5.5 中大部分关于 Sendable 的检查默认都是关闭的”
 */

// MARK: - Sendable协议
/**
 “Sendable 和现存在 Swift 中的所有协议都不同，它是一个标志协议 (marker protocol)，没有任何具体的要求”
 @_marker
 public protocol Sendable {}
 1.“Sendable 所定义的“能在并发域之间被安全传递”的能力，并不像 Hashable 的 hash(into:) 或者 Equatable 的 == 方法那样，可以用若干个明确的方法进行要求”
 2.“Sendable 这样的标志协议具有的是语义上的属性，它完全是一个编译期间的辅助标记，只会由编译器使用，不会在运行期间产生任何影响”
 3.“意味着，像是 x is Sendable 或者 x as? Sendable 这样的运行时判定是无法编译的”
 4.“虽然 Sendable 协议里没有任何要求，但是如果我们明确声明某个类型满足 Sendable 的话，编译器会对它的进行检查，来确认是否确实满足要求”
 */

/// 值类型
/**
 “Swift 标准库中的大部分基本类型，都是满足 Sendable 协议的”
 extension Int: Sendable {}
 extension Bool: Sendable {}
 extension String: Sendable {}
 ...
 “它们构成了其他标准库中的“容器”类型的基石。只要容器内的元素满足 Sendable，那么容器本身也满足 Sendable。这类容器包括可选值、数组、字典等”
 extension Optional: Sendable where Wrapped: Senable {}
 extension Array: Sendable where Element: Sendable {}
 extension Dictionary: Sendable where Key: Sendable, Value: Sendable {}
 
 “这些类型在边界传递时，将发生复制或者稍后的写时复制 (Copy-on-write)，在新的并发域中，它们和原来的值不相关，“因此它们是安全的。”
 “类似地，如果我们自己的 struct 类型中只包含 Sendable 的变量，那么这个类型本身也是 Sendable 的，PersonStruct 就是一个例子，我们可以明确地把它标记为 Sendable：”
 */
extension PersonStruct: Sendable {}

/**
 “当 struct 上有非 Sendable 成员时 (比如 class 这样的引用类型)，该成员可能会被多个并发域同时修改。”
 “类型不能再满足 Sendable。这种时候为该类型添加 Sendable 协议，编译器将会给出错误”
 */
class A {}
struct PersonStruct2: Sendable {
    let name: String
    var message: String = ""
    /// Stored property 'a' of 'Sendable'-conforming struct 'PersonStruct2' has non-sendable type 'A'
    //    let a: A = A()
    init(name: String) {
        self.name = name
    }
}

/**
 “实际上，在同一模块中，如果一个 struct 满足它的所有成员都是 Sendable，我们甚至不需要明确地为它标记 Sendable。编译器将会帮助我们推断出这件事情，并自动让该类型满足协议”
 */

///PersonStruct3 被推断为Sendable
struct PersonStruct3 {
    let name: String
    var message: String = ""
    init(name: String) {
        self.name = name
    }

    func foo<T:Sendable>(value: T) {
        debugPrint(value)
    }
}

extension ViewController {
    func testSilentSendable() {
        let p = PersonStruct3(name: "xx")
        p.foo(value: PersonStruct2(name: "www"))
    }
}
/**
 “这一点和我们熟知的 Hashable 或者 Equatable 有所不同。就算一个类型上的所有成员都满足 Hashable，我们也还是需要明确地声明这个类型满足 Hashable，编译器才能帮助我们自动生成所需要的实现。不过由于 Sendable 的使用会更加广泛，而且不像其他协议，为某个类型添加一个 Sendable 标志协议不会带来任何运行时的影响，所以尽可能地自动为合适的类型添加 Sendable，有助于保持简洁和避免开发者的重复劳动”

 “在上面我们强调了“同一模块”这个条件。当我们要把该类型声明为 public 时，这个前提就不再存在了，在模块外，这样的类型不会被自动视为 Sendable”
 “因为可能存在只有在模块内部才可见的 internal 或 private 成员。”
 “从模块外部，编译器将无法确定类型中所有的成员是否都是 Sendable”

 “在把某个类型标记为 public 时，如果有条件，我们应该把它也明确标记为 Sendable，并作为公开 API 保证的一部分。这样有利于使用者将它在并发域之间进行传递”
 “如果我们能够确定某个 struct 不会再改变，我们可以使用 @frozen 进行声明。对于这样的 struct，它的成员不会再被修改改，编译器也将有机会直接“窥视”并确定它的内部结构，从而隐式添加 Sendable，而不必担心在未来这个假设失效。不过要注意，在开发框架时这意味着对该 struct 的成员进行修改的话，将引入对 ABI 的破坏”
 */

public struct PersonModuleA {
    let name: String
    var message: String = ""
    /**
     编译器无法确定非 public 成员
     可能存在非 Sendable 成员，无法为 `PersonModuleA` 推断 `Sendable`
     let a = A()”
     */
    public init(name: String) {
        self.name = name
    }
}

/// class 类型
/**
 “要让 class 类型满足 Sendable，条件要严苛得多”
 1.“这个 class 必须是 final 的，不允许继承，否则任何它的子类都有可能添加破坏数据安全的成员”
 2.“该 class 类型的成员必须都是 Sendable 的”
 3.“所有的成员都必须使用 let 声明为不变量”

 “这些条件可以确保 class 类型在不同并发域中的安全。不过，即使如此，编译器也不会像对待 struct 那样，为它自动添加 Sendable。想要让 class 类型满足 Sendable，我们必须明确进行声明”
 */
final class PersonClass2: Sendable {
    let name: String
    //    // Stored property 'message' of 'Sendable'-conforming class 'PersonClass2' is mutable
    //    var message: String = ""

    init(name: String) {
        self.name = name
    }
}

/// actor类型
/**
 “虽然和 class 一样，actor 也是引用类型，不过 actor 内部的隔离机制保证了内部状态的安全”
 “在不同并发域中对 actor 成员进行访问，最终都会在该 actor 的隔离域中发生”
 “因此所有的 actor 类型都可以随意地在并发域之间传递”
 “它们都满足 Sendable：不论在哪个模块中，也不论 actor 拥有什么类型的存储成员，编译器都会为它们加上 Sendable”
 */

// MARK: - “函数类型和 @Sendable 标注”
/**
 1.“除了像是 struct、enum、class 或者 actor 这样具体类型的值，函数也是会经常在并发域之间传递的类型之一”
 2.“在 Swift 中，函数类型的值可能会有各种形式：比如全局函数、getter/setter 或者匿名闭包等等”
 3.“在 Swift 中，函数类型也是引用类型，它会在函数体内部持有对外部值的引用。”
 4.“在跨越并发域时，在函数体内的这些被引用的值可能会发生变化”
 5.“想要保证数据安全的话，我们必须规定函数闭包所持有的值都满足 Sendable 且它们都为不变量”
 7.“不过在 Swift 语法中，函数类型本身并不能满足任何协议。为了表示某个函数参数必须满足 Sendable”,使用 @Sendable“对这个函数进行标注。这种模式和在处理闭包逃逸时所使用的 @escaping 有些相似”
 func bar(value: Int, block: @Sendable() -> Void) { block() }

 “我们也可以在 Task 或者 AsyncStream 等相关 API 的设计中看到这个标注，它们广泛存在于 Swift 异步 API 中”
 extension Task where Failure == Never {
 init(priority: TaskPriority? = nil, operation: @escaping @Sendable() async -> Success)
 }

 struct TaskGroup<ChildTaskResult> {
 mutating func addTask(priority: TaskPriority? = nil, operation: @escaping @Sendable() async -> ChildTaskResult)
 }

 struct AsyncStream<Element> {
 struct Continuation: Sendable {
 var onTermination:(@Sendable(Termination) -> Void)? { get nonmutating set }
 }
 }

 “在使用这些函数时，编译器会对传入的函数进行检查”
 1.“被函数体持有的变量，必须都是 Sendable 的”
 2.“所有被持有的值，都必须是使用 let 声明的不变量”

 “虽然 String 是 Sendable，但是在 Task.init 的闭包中，对它的捕获将导致编译错误：name 有可能在多个不同任务上下文中被更改。如果我们只需要读取 name 的内容，可以将它明确地写在闭包的捕获列表中，或者使用 let 来声明这个变量 (这样它会被作为值隐式地复制到闭包中)：”
 “因为函数类型实际上是引用类型，你可以把它想象成一个 class 类型，其成员就是它所持有的所有捕获值。这样一来，让一个函数类型满足 Sendable 所需要的条件，就可以和 class 类型所需要的条件进行类比了”
 “在当前 Swift 5.5 中，只有本地声明 (像是上面的 name) 的 var 或者 let 会在 @Sendable 中被检查。对于被声明在其他代码域中的变量，还并不在默认的检查列表中”

 */
extension ViewController {
    func testSendableSomeErrorCase() {
        var name = "Hello"
        Task {
            // Reference to captured var 'name' in concurrently-executing code
            //let validName = "xxx" == name
        }

        Task { [name] in
            let validName = "xxx" == name
        }

        let tname = "sss"
        Task {
            let validName = "dd" == tname
        }
    }
}

/// 错误
/**
 “另一类重要的会在并发域中传递的类型是各种错误：当异步函数出错时，我们会使用 throws 抛出错误，这在语义上其实相当于从并发域中返回了一个错误给调用者”
 “基于安全要求，Error 类型应该始终是 Sendable 的。其实现在 Swift 中 Error 协议也确实被这么标记了：”
 protocol Error: Sendable {}
 “更改 protocol 的需求，显然是一个破坏性的修改。试想如果在 Swift 5.5 之前，我们已经有一个满足 Error 但是存在可变状态的类型，那么在编译器要求 Error 强制满足 Sendable 后，之前的代码将无法继续编译，例如这样一个类型”
 class Detail {
 var text: String
 }
 struct SomeError: Error {
 var detail: Detail
 }
 “将会因为 detail.text 无法被保护，而无法满足 Sendable。这是一个源码级别的不兼容。为了平滑迁移，编译器在 Swift 6 之前都会“网开一面”，暂时允许这样的 Error 类型存在。但是我们必须提早进行准备并进行迁移，以免在 Swift 6 中实现完全的数据安全时，被无尽的编译错误包围”
 */

/// @unchecked Sendable
/**
 “actor 并不是引用类型保证数据安全的唯一手段，在 Swift 并发之前，为了 class 成员的数据安全，我们就已经有诸如加锁或者设定内部串行派发队列的方案了”
 “这种在自身内部具有数据安全保证、原本就线程安全的类型，自然是可以在不同并发域之间安全传递的”
 “但是 Sendable 的检查并没有办法在编译期间确定它的安全性，这种类型也无法直接被声明满足 Sendable”
 “如果我们确信该类型是安全的，可以在 Sendable 前面加上 @unchecked 标记，这样编译器就会跳过类型的成员检查，相信开发者的判断，直接把这个类型认为是满足 Sendable 的”
 “不仅仅是在将旧有代码进行迁移时有用，在我们确实需要使用引用类型实现一些高效的数据结构，同时又需要和 Swift 并发的其他部分协作时，有时 @unchecked Sendable 也是唯一的可行选择。”
 “通过 @unchecked 你可以让任意类型都满足 Sendable，但是错误的实现将会引入 bug，让你在并发运行时面临数据安全的问题”
 */
class MyClass: @unchecked Sendable {
    private var value: Int = 0
    private let lock = NSLock()
    func update(_ value: Int) {
        lock.lock()
        self.value = value
        lock.unlock()
    }
}

/// “渐进式迁移和 @_unsafeSendable”
/**
 1.“Swift 并发的理想状态，是在静态环境下 (也就是编译时) 避免所有的由于共享可变状态所带来的数据安全问题。”
 2.“这其中很大一部分，可以依靠 Sendable 的检查来进行。但是我们已经看到了，在 Swift 5.5 中，编译器并没有对 Sendable 进行完整的检查”
 3.“不像异步函数、结构化任务和 actor 这些新加入的概念，Sendable 的存在和 Swift 5.5 以前的代码可能发生关联，比如我们可能会在并发域边界传递一个之前已有的 class。我们当然可以通过把这个 class 改为 actor 来让它满足 Sendable，但这同时这也意味着项目中其他使用了这个类型的部分，必须有异步运行环境来继续调用这个新的 actor”
 4.“这种迁移的“扩散性”和它所伴随的难度，往往出乎预料，迁移本身也会需要花费更多时间才能完成”
 5.“在这种情况下，强行开始完整的 Sendable 检查，可能带来非常多的错误，无限期地拖长迁移所需要的时间，甚至让新的 API 也变得无法使用。因此作为第一阶段，Swift 选择了延后静态检查的时间点，让 Swift 5.5 的迁移相对容易一些。”
 6.“对迁移来说，另一个重要的问题是不同模块之间的关系。假设你在开发一个模块，并尝试将它迁移到 Swift 并发，并用 Sendable 来保证数据安全，你将同时面临来自上游和下游的压力。和你关联的各个模块不太可能同时完成 Sendable 迁移，当你正在开发的模块打算迁移时，这个模块所依赖的模块，以及依赖这么模块的其他使用者，有可能还没有进行迁移”
 8.“Swift 并发数据安全的迁移不会是一蹴而就的，Swift 也需要避免这种“大面积传染”的迁移需求，尽可能让模块的迁移能够独立进行。为了达到这个目的，Swift 需要能区分已经完成了迁移的模块和尚未进行迁移的模块，并在编译时区别对待它们”
 */

/// 迁移的模块先于依赖的模块
/**
 “如果你所依赖的模块还没有迁移到 Sendable，但你需要在并发域间使用某些其中的类型，那么这些类型有可能无法安全访问”
 */
// Module A
public class Cube {
    public let edge: CGFloat
    public init(edge: CGFloat) {
        self.edge = edge
    }
}
/**
 “它虽然在语义上满足 Sendable，但是由于 Module A 还没有完成迁移，因此在我们自己的模块中，如果有某个类型使用了 Cube，那么理论上它将不能被推断为 Sendable”
 import ModuleA
 // 无法对 CubeOwner进行 Sendable推断
 // 因为 Module A还没有迁移，不能知道Cube是否满足 Sendable
 struct CubeOwner {
 let name: String
 let cube: Cube
 }
 “因为 Cube 来源于其他人的模块，所以在这种情况下，想让 CubeOwner 满足 Sendable，只有两种方式”
 1.“在自己的模块中为 Cube 添加 @unchecked Sendable 的假设，这样编译器就可以推断出 CubeOwner 满足 Sendable 了”
 extension Cube: @unchecked Sendable {}
 2. “或者直接将 CubeOwner 声明为 @unchecked Sendable，无视掉 Cube 的真实状况”
 struct CubeOwner: @unchecked Sendable {
 let name: String
 let cube: Cube
 }

 “对于未迁移模块中的 Cube，因为没有更多信息，为它做 @unchecked Sendable 的假设无可厚非，这是我们能做到的最好的方式，但是它在未来终将成为隐患。如果在 Module A 完成迁移后，事实上 Cube 无法满足 Sendable，但由于 Cube 存在 @unchecked Sendable 的假设，编译器不会对 Cube 并非 Sendable 的事实作出任何反应。你的模块依然处于危险之中”
 // Module A
 class A {}
 // 由于class A的存在， Cube并非 Sendable
 public class Cube {
 public let edge: CGFloat
 private var a = A()
 public init(edge: CGFloat) {
 self.edge = edge
 }
 }

 // 自己的模块
 import ModuleA
 // 危险，隐藏的bug，编译器不会有任何警告或者错误
 extension Cube: @uncheckedd Sendable {}

 1.“为了避免这个问题，并保证在未来启用完整的数据安全时，编译器能正确地发现此类问题，Swift 会启用渐进式的迁移策略，在导入依赖模块时进行判定：如果导入的模块还没有完成并发适配，那么先假设 Cube 这样的类型可以进行隐式 Sendable 推断”
 2.“这样，就算没有明确为 Cube 标记 @unchecked Sendable，我们的模块也可以让 CubeOwner 满足 Sendable”
 // Module A
 public class Cube {
 public let edge: CGFloat
 public init(edge: CGFloat) {
 self.edge = edge
 }
 }

 // 自己的模块
 import ModuleA
 // Module A还未完成迁移， Cube可被认为是Sendable
 // 从而 CubeOwner可被判定为Sendable
 struct CubeOwner {
 let name: String
 let cube: Cube
 }
 let owner = CubeOwner(name: "xx", cube: .init(edge: 1))
 Task {
 // owner可以在并发域之间传递
 debugPrint(owner.cube)
 }
 */
struct CubeOwner {
    let name: String
    let cube: Cube
}

extension ViewController {
    func testMigrateSendable() {
        let owner = CubeOwner(name: "xx", cube: .init(edge: 1))
        Task {
            // owner可以在并发域之间传递
            debugPrint(owner.cube)
        }
    }
}

/**
 “虽然可以进行隐式推断，但这里的 Cube 依然是有风险的。不过在当下，它所提供的安全性，和 @unchecked Sendable 是同等的。”
 “这让我们可以避免在我们自己的模块中强行添加我们无法确定的 @unchecked 标记”
 “在未来，当 Module A 完成并发迁移后，Cube 会有两种可能性”
 1. “如果 Cube 确实满足 Sendable，那么它会在 public API 中被标记为 Sendable。这种情况下，CubeOwner 的 Sendable 推断依然有效，而且现在可以保证这些代码是安全的了”
 2. “如果 Cube 最终不能满足 Sendable，那么在完全数据安全被启用时，编译器将会检测出 CubeOwner 不满足 Sendable 的错误。你至少可以确认代码并不安全，并再进一步考虑处理的方式”

 “无论 Module A 中最后是哪种结果，我们自己的模块都有机会避免由于 @unchecked 带来的错误假设和危险”
 */

/// 开发的模块优先于模块的用户
/**
 1.“模块迁移的另一个方向，是你的模块的用户还没有完成迁移，但他们需要依赖并使用你的已经完成迁移的模块”
 2.“如果你的模块的使用者还没有迁移到 Sendable，但你已经声明了某些函数只能接受 Sendable 的参数 (比如某个方法只接受 @Sendable)，那么这个方法将无法由使用者进行安全地调用。比如你的模块中原来有这样的代码”
 // You Module
 public func bar<T>(value: T, block:() -> Void) {}
 “在完成迁移后，bar 可能会需要参数 value 和 block 都满足数据安全，这要求 value 的泛型类型从 T 变为 T: Sendable，且 block 应该被 @Sendable 修饰。所以在适配后，它的签名应该是：”
 public func bar<T: Sendable>(value: T, block: @Sendable() -> Void) {}
 
 “如果进行严格的检查，那么在你的模块迁移后，这个模块的用户将无法再进行编译：因为在他们的模块还没有迁移，参数类型不可能满足 Sendable”
 import YourModule
 class A {}
 let a = A()
 //在YourModule迁移前可以编译，迁移后无法编译
 // 迁移后，a不满足Sendable, block 捕获了 Sendable的值，不满足 @Sendable
 bar(value: a, block: { debugPrint(a) })

 “为了避免这种情况的发生，在用户完全适配 Sendable 之前，编译器会选择忽略掉这些错误，最多给出一些警告”
 1.“对于泛型类型参数 value 的 Sendable 需求，和上一小节中的例子一样，编译器会默认 A 是 Sendable 的。虽然这可能带来潜在的数据安全问题，但是这在 YourModule 迁移之前也是一直存在的，它并没有让事情变糟”
 2.“对于 @Sendable，则在迁移前直接忽略掉这个检查”

 “你可以使用 @_unsafeSendable 来替代函数的 @Sendable 标记，明确表明让编译器忽略检查行为。这样即使在未来 Swift 开启全面检查后，你的函数依然可以提供最大的兼容性，被“不安全”地调用。这个标记现在还只是 Swift 内部的私有标记，在未来它将被公开”

 “除了内部状态外，标志协议 Sendable 可以用来保护在并发域间传递的值的安全性。在 Swift 5.5 中，Sendable 并不会对写出异步和并发代码有太大影响。但是，想要写出正确的异步和并发代码，我们必须关注任何可能发生的数据竞争。即使编译器默认还不会给出错误，但为合适的类型添加 Sendable，不仅能够大幅提升代码安全性，也会帮助我们在之后 Swift 6 发布时轻松一些。”
 */
