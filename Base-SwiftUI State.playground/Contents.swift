import SwiftUI
import PlaygroundSupport

/**
 @State 基础
 */

struct ContentView: View {
    @State private var value = 2
    var body: some View {
        VStack(alignment: .leading) {
            Text("Number\(value)")
            Button("+") { value += 1 }
        }
    }
}
PlaygroundPage.current.liveView = UIHostingController(rootView: ContentView())

struct DetailView: View {
    let number: Int
    var body: some View {
        Text("Number\(number)")
    }
}

struct ContentView2: View {
    @State private var value = 2
    var body: some View {
        VStack(alignment: .leading) {
            DetailView(number: value)
            Button("+") { value += 2 }
        }
    }
}
/*
 在 ContentView 中的 @State value 发生改变时，ContentView.body 被重新求值，DetailView 将被重新创建，包含新数字的 Text 被重新渲染。
 */
PlaygroundPage.current.liveView = UIHostingController(rootView: ContentView2())

// 子 View 中自己的 @State
/**
 如果我们希望的不完全是这种被动的传递，而是希望 DetailView 也拥有这个传入的状态值，并且可以自己对这个值进行管理的话，一种方法是在让 DetailView 持有自己的 @State，然后通过初始化方法把值传递进去
 */
struct DetailView2: View {
    // declare your state properties as private, to prevent clients of your view from accessing them
    @State var number: Int
    var body: some View {
        HStack {
            Text("2:\(number)")
            Button("+") { number += 1 }
        }
    }
}

struct ContentView3: View {
    @State private var value = 1
    var body: some View {
        DetailView2(number: value)
    }
}

PlaygroundPage.current.liveView = UIHostingController(rootView: ContentView3())

/**
 如果一个 @State 无法被标记为 private 的话，一定是哪里出了问题。一种很朴素的想法是，将 @State 声明为 private，然后使用合适的 init 方法来设置它。更多的时候，我们可能需要初始化方法来解决另一个更“现实”的问题：那就是使用合适的初始化方法，来对传递进来的 value 进行一些处理。比如，如果我们想要实现一个可以对任何传进来的数据在显示前就进行 +1 处理的 View
 */
struct DetailView3: View {
    @State private var number: Int?

    // tip: @State private var number: Int. Variable ‘self.number’ used before being initialized
    // 虽然我们在 init 中设置了 self.number = 1，但在 body 被第一次求值时，number 的值是 nil，因此 0 会被显示在屏幕上
    init(number: Int) {
        self.number = number
    }

    var body: some View {
        HStack {
            Text("2:\(number ?? 0)")
            Button("+") { number = (number ?? 0) + 1 }
        }
    }
}

struct ContentView4: View {
    @State private var value = 1
    var body: some View {
        DetailView3(number: value)
    }
}
PlaygroundPage.current.liveView = UIHostingController(rootView: ContentView4())

// @State内部
/**
 问题出在 @State 上：SwiftUI 通过 property wrapper 简化并模拟了普通的变量读写，但是我们必须始终牢记，@State Int 并不等同于 Int，它根本就不是一个传统意义的存储属性。这个property wrapper做的事情大体上说有三件：

 1.为底层的存储变量 State<Int> 这个struct 提供了一组 getter 和 setter，这个 State struct 中保存了 Int 的具体数字。
 2.在 body 首次求值前，将 State<Int>关联到当前View上，为它在堆中对应当前 View 分配一个存储位置。
 3.为 @State 修饰的变量设置观察，当值改变时，触发新一次的 body 求值，并刷新屏幕。
 @frozen @propertyWrapper public struct State<Value> : DynamicProperty {
     public init(wrappedValue value: Value)
     public init(initialValue value: Value)
     public var wrappedValue: Value { get nonmutating set }
     public var projectedValue: Binding<Value> { get }
 }
 打印和 dump State 的值
 struct State<Value> : DynamicProperty {
     var _value: Value
     var _location: StoredLocation<Value>?

     var _graph: ViewGraph?

     var wrappedValue: Value {
         get { _value }
         set {
             updateValue(newValue)
         }
     }

     // 发生在 init 后，body 求值前。
     func _linkToGraph(graph: ViewGraph) {
         if _location == nil {
             _location = graph.getLocation(self)
         }
         if _location == nil {
             _location = graph.createAndStore(self)
         }
         _graph = graph
     }

     func _renderView(_ value: Value) {
         if let graph = _graph {
             // 有效的 State 值
             _value = value
             graph.triggerRender(self)
         }
     }
 }
 SwiftUI 使用 meta data 来在 View 中寻找 State 变量，并将用来渲染的 ViewGraph 注入到 State 中。当 State 发生改变时，调用这个 Graph 来刷新界面。
 对于 @State 的声明，会在当前 View 中带来一个自动生成的私有存储属性，来存储真实的 State struct 值
 struct DetailView1: View {
     @State private var number: Int?
     private var _number: State<Int?> // 自动生成
     // ...
 }

 这为我们解释了为什么刚才直接声明 @State var number: Int 无法编译
 struct DetailView1: View {
     @State private var number: Int

     init(number: Int) {
         self.number = number + 1
     }
     //
 }
 Int? 的声明在初始化时会默认赋值为 nil，让 _number 完成初始化 (它的值为 State<Optional<Int>>(_value: nil, _location: nil))；而非 Optional 的 number 则需要明确的初始化值，否则在调用 self.number 的时候，底层 _number 是没有完成初始化的
 于是“为什么 init 中的设置无效”的问题也迎刃而解了。对于 @State 的设置，只有在 View 被添加到 graph 中以后 (也就是首次 body 被求值前) 才有效

 当前 SwiftUI 的版本中，自动生成的存储变量使用的是在 State 变量名前加下划线的方式。这也是一个代码风格的提示：我们在自己选择变量名时，虽然部分语言使用下划线来表示类型中的私有变量，但在 SwiftUI 中，最好是避免使用 _name 这样的名字，因为它有可能会被系统生成的代码占用 (类似的情况也发生在其他一些 property wrapper 中，比如 Binding 等)。
 */

// 几种可选方案
/**
 在知道了 State struct 的工作原理后，为了达到最初的“在 init 中对传入数据进行一些操作”这个目的，会有几种选择。
 */
// 首先是直接操作 _number
/**
 因为现在我们直接插手介入了 _number 的初始化，所以它在被添加到 View 之前，就有了正确的初始值 100。不过，因为 _number 显然并不存在于任何文档中，这么做带来的风险是这个行为今后随时可能失效。
 */
struct DetailView4: View {
    @State private var number: Int

    init(number: Int) {
        _number = State(wrappedValue: number + 1)
    }

    var body: some View {
        return HStack {
            Text("4: \(number)")
            Button("+") { number += 1 }
        }
    }
}

struct ContentView5: View {
    @State private var value = 0

    var body: some View {
        DetailView4(number: value)
    }
}

PlaygroundPage.current.liveView = UIHostingController(rootView: ContentView5())

// 另一种可行方案是，将 init 中获取的 number 值先暂存，然后在 @State number 可用时 (也就是在 body ) 中，再进行赋值
/**
 不过，这样的做法也并不是很合理。State 文档中明确指出:
 You should only access a state property from inside the view’s body, or from methods called by it
 通过 DispatchQueue.main.async 中来访问和更改 state，是不是推荐的做法，还是存疑的。另外，由于实际上 body 有可能被多次求值，所以这部分代码会多次运行，你必须考虑它在 body 被重新求值时的正确性 (比如我们需要加入 number == nil 判断，才能避免重复设值)。在造成浪费的同时，这也增加了维护的难度。
 */
struct DetailView5: View {
    @State private var number: Int?
    private var tempNumber: Int

    init(number: Int) {
        self.tempNumber = number
    }

    var body: some View {
        DispatchQueue.main.async {
            if number == nil {
                number = tempNumber
            }
        }
        return HStack {
            Text("5:\(number ?? 0)")
            Button("+") { number = (number ?? 0) + 1 }
        }
    }
}

struct ContentView6: View {
    @State private var value = 1
    var body: some View {
        DetailView5(number: value)
    }
}

PlaygroundPage.current.liveView = UIHostingController(rootView: ContentView6())

// 对于这种方法，一个更好的设置初值的地方是在 onAppear 中
/**
 被验证后，这个方法已经没有用了
 */
struct DetailView6: View {
    @State private var number: Int = 0
    private var tempNumber: Int

    init(number: Int) {
        self.tempNumber = number
    }

    var body: some View {
        HStack {
            Text("6:\(number)")
            Button("+") { number += 1 }
        }.onAppear {
            number = tempNumber
        }
    }
}

struct ContentView7: View {
    @State private var value = -2
    var body: some View {
        DetailView6(number: value)
    }
}

PlaygroundPage.current.liveView = UIHostingController(rootView: ContentView7())

// State Binding StateObject ObservedObject
/**
 @StateObject 的情况和 @State 很类似：View 都拥有对这个状态的所有权，它们不会随着新的 View init 而重新初始化。
 这个行为和 Binding 以及 ObservedObject 是正好相反的：使用 Binding 和 ObservedObject 的话，意味着 View 不会负责底层的存储，开发者需要自行决定和维护“非所有”状态的声明周期
 */
// 当然，如果 DetailView 不需要自己拥有且独立管理的状态，而是想要直接使用 ContentView 中的值，且将这个值的更改反馈回去的话，使用标准的 @Bining 是毫无疑问的
struct DetailView7: View {
    @Binding var number: Int

    var body: some View {
        HStack {
            Text("7:\(number)")
            Button("+") { number += 1 }
        }
    }
}

struct ContentView8: View {
    @State private var value = 6

    var body: some View {
        DetailView7(number: $value)
        DetailView(number: value)
    }
}

PlaygroundPage.current.liveView = UIHostingController(rootView: ContentView8())

// 状态重设
/**
 对于文中的情景，想要对本地的 State (或者 StateObject) 在初始化时进行操作，最合适的方式还是通过在 (.onAppear 验证后没有用途) 里赋值来完成。如果想要在初次设置后，再次将父 view 的值“同步”到子 view 中去，可以选择使用 id modifier 来将子 view 上的已有状态清除掉。在一些场景下，这也会非常有用
 被 id modifier 修饰后，每次 body 求值时，DetailView4 将会检查是否具有相同的 identifier。如果出现不一致，在 graph 中的原来的 DetailView5 将被废弃，所有状态将被清除，并被重新创建。这样一来，最新的 value 值将被重新通过初始化方法设置到 DetailView5.tempNumber。而这个新 View 的 （onAppear 也会被触发，最终把处理后的输入值再次显示出来 有待验证）。
 */
struct ContentView9: View {
    @State private var value = 99

    var identifier: String {
        value < 105 ? "id1" : "id2"
    }

    var body: some View {
        VStack(alignment: .leading) {
            DetailView(number: value)
            Button("+") { value += 1 }
            Divider()
            DetailView6(number: value)
        } //.id(identifier)
    }
}

// .id(identifier) 这个会导致 error: Execution was interrupted, reason: EXC_BAD_INSTRUCTION (code=EXC_I386_INVOP, subcode=0x0).
PlaygroundPage.current.liveView = UIHostingController(rootView: ContentView9())
// 对于 @State 来说，严格遵循文档所预想的使用方式，避免在 body 以外的地方获取和设置它的值，会避免不少麻烦。正确理解 @State 的工作方式和各个变化发生的时机，能让我们在迷茫时找到正确的分析方向
