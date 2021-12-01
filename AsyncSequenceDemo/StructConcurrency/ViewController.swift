//
//  ViewController.swift
//  StructConcurrency
//
//  Created by Lee Danatech on 2021/11/26.
//

import UIKit

// MARK: - 结构化并发
class ViewController: UIViewController {
    /**
     “async/await 所引入的异步函数的简单写法，可以在暂停点时放弃线程，这是构建高并发系统所不可或缺的。但是异步函数本身，其实并没有解决并发编程的问题。结构化并发 (structured concurrency) 将用一个高效可预测的模型，来实现优雅的异步代码的并发。”
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //       debugPrint(foo())
        
        //        testCurrentTaskState()
        
        //        testSyncCurrentTaskState()
        
        //        testCheckTaskCancelState()
        
        //        testTaskGroupStructConcurrency()
        
        //        testTaskGroupWaitSilent()
        
        //        testResultCount()
        
        //        testAccessValue()
        
        //        testComplileSuccessButErrorOperation()
        
        //        testAsyncLet()
        
        //        testAsyncLetWait()
        
        //        testItemsTaskGroup()
        
        //        testNestTaskGroup()
        
        testAsyncLetSample3()
        
    }
}

// MARK: - 非结构化的并发
extension ViewController {
    /**
     “由于和调用者拥有不同的调用栈，因此它们并不知道调用者是谁，所以无法以抛出的方式向上传递错误。”
     “结构化并发理论认为，这种通过派发所进行的并行，藉由时间或者线程上的错位，实际上实现了任意的跳转。它只是 goto 语句的“高级”一些的形式，在本质上并没有不同，回调和闭包语法只是让它丑陋的面貌得到了一定程度遮掩”
     “非结构化的并发面临类似的问题”
     1.“这个函数会不会产生一个后台任务”
     2.“这个函数虽然返回了，但是它所产生的后台任务可能还在运行，它什么时候会结束，它结束后会产生怎么样的行为”
     3.“作为调用者，我应该在哪里、以怎样的方式处理回调”
     4.“我需要保持这个函数用到的资源吗？后台任务会自动去持有这些资源吗？我需要自己去释放它们吗？”
     5.“后台任务是否可以被管理，比如想要取消的话应该怎么做”
     6.“派发出去的任务会不会再去派发别的任务？别的这些任务会被正确管理吗？如果取消了这个派发出去的任务，那些被二次派发的任务也会被正确取消吗”
     */
    func foo() -> Bool {
        bar(completion: { debugPrint($0) })
        baz(completion: { debugPrint($0) })
        return true
    }
    
    func bar(completion: @escaping(Int) -> Void) {
        DispatchQueue.global().async {
            completion(1)
        }
    }
    
    func baz(completion: @escaping(Int) -> Void) {
        DispatchQueue.global().async {
            completion(2)
        }
    }
}

// MARK: - 结构化并发
extension ViewController {
    /**
     “即使进行并发操作，也要保证控制流路径的单一入口和单一出口。程序可以产生多个控制流来实现并发，但是所有的并发路径在出口时都应该处于完成 (或取消) 状态，并合并到一起”
     “为了将并发路径合并，程序需要具有暂停等待其他部分的能力。异步函数恰恰满足了这个条件：使用异步函数来获取暂停主控制流的能力，函数可以执行其他的异步并发操作并等待它们完成，最后主控制流和并发控制流统合后，从单一出口返回给调用者。这也是我们在之前就将异步函数称为结构化并发基础的原因”
     */
}

// MARK: - 基于Task的结构化并发模型
extension ViewController {
    /**
     “在 Swift 并发编程中，结构化并发需要依赖异步函数，而异步函数又必须运行在某个任务上下文中，因此可以说，想要进行结构化并发，必须具有任务上下文。实际上，Swift 结构化并发就是以任务为基本要素进行组织的。”
     */
    
    /// 当前任务状态
    func testCurrentTaskState() {
        /**
         1.“withUnsafeCurrentTask 本身不是异步函数，你也可以在普通的同步函数中使用它。如果当前的函数并没有运行在任何任务上下文环境中，也就是说，到 withUnsafeCurrentTask 为止的调用链中如果没有异步函数的话，这里得到的 task 会是 nil”
         2.“使用 Task 的初始化方法，可以得到一个新的任务环境”
         3.“对于 foo2 的调用，发生在上一步的 Task 闭包作用范围中，它的运行环境就是这个新创建的 Task”
         4.“对于获取到的 task，可以访问它的 isCancelled 和 priority 属性检查它是否已经被取消以及当前的优先级。我们甚至可以调用 cancel() 来取消这个任务”
         
         */
        
        withUnsafeCurrentTask { task in
            debugPrint(task as Any)
        }
        Task {
            await foo2()
        }
    }
    
    func foo2() async {
        withUnsafeCurrentTask { task in
            if let task = task {
                debugPrint("Cancelled:\(task.isCancelled)")
                debugPrint(task.priority)
            } else {
                debugPrint("No task")
            }
            
        }
    }
    
    /**
     “要注意任务的存在与否和函数本身是不是异步函数并没有必然关系，这是显然的：同步函数也可以在任务上下文中被调用。比如下面的 syncFunc 中，withUnsafeCurrentTask 也会给回一个有效任务”
     */
    
    func testSyncCurrentTaskState() {
        Task {
            await foo3()
        }
    }
    
    func foo3() async {
        withUnsafeCurrentTask { task in
            debugPrint(task as Any)
        }
        syncFunc()
    }
    
    func syncFunc() {
        withUnsafeCurrentTask { task in
            debugPrint("Sync \(task as Any)")
        }
    }
    
    /**
     1.“使用 withUnsafeCurrentTask 获取到的任务实际上是一个 UnsafeCurrentTask 值。和 Swift 中其他的 Unsafe 系 API 类似，Swift 仅保证它在 withUnsafeCurrentTask 的闭包中有效。你不能存储这个值，也不能在闭包之外调用或访问它的属性和方法，那会导致未定义的行为”
     2.“因为检查当前任务的状态相对是比较常用的操作，Swift 为此准备了一个“简便方法”：使用 Task 的静态属性来获取当前状态”
     
     extension Task where Success == Never, Failure == Never {
     static var isCancelled: Bool { get }
     static var currentPriority: TaskPriority{ get }
     }
     3. “虽然被定义为 static var，但是它们并不表示针对所有 Task 类型通用的某个全局属性，而是表示当前任务的情况”
     4.“因为一个异步函数的运行环境必须有且仅会有一个任务上下文，所以使用 static 变量来表示这唯一一个任务的特性”
     5.“相比于每次去获取 UnsafeCurrentTask，这种写法更加简单。比如，我们可以在不同的任务上下文中使用 Task.isCancelled 检查任务的取消情况”
     
     “虽然 t1 和 t2 是在外层 Task 中再新生成并进行并发的，但是它们之间没有从属关系，并不是结构化的。这一点从 t: false 先于其他输出就可以看出，t1 和 t2 的执行都是在外层 Task 闭包结束后才进行的，它们逃逸出去了，这和结构化并发的收束规定不符”
     */
    func testCheckTaskCancelState() {
        Task {
            let t1 = Task {
                debugPrint("t1: \(Task.isCancelled)")
            }
            
            let t2 = Task {
                debugPrint("t2: \(Task.isCancelled)")
            }
            
            t1.cancel()
            debugPrint("t: \(Task.isCancelled)")
            
        }
    }
}

// MARK: - 任务层级
extension ViewController {
    /**
     “想要创建结构化的并发任务，就需要让内层的 t1 和 t2 与外层 Task 具有某种从属关系。你可以已经猜到了，外层任务作为根节点，内层任务作为叶子节点，就可以使用树的数据结构”
     “描述各个任务的从属关系，并进而构建结构化的并发了”
     
     “通过用树的方式组织任务层级，我们可以获取下面这些有用特性”
     1.“一个任务具有它自己的优先级和取消标识，它可以拥有若干个子任务 (叶子节点) 并在其中执行异步函数”
     2.“当一个父任务被取消时，这个父任务的取消标识将被设置，并向下传递到所有的子任务中去”
     3.“无论是正常完成还是抛出错误，子任务会将结果向上报告给父任务，在所有子任务正常完成或者抛出之前，父任务是不会被完成的”
     
     “当任务的根节点退出时，我们通过等待所有的子节点，来保证并发任务都已经退出”
     “树形结构允许我们在某个子节点扩展出更多的二层子节点，来组织更复杂的任务”
     “这个子节点也许要遵守同样的规则，等待它的二层子节点们完成后，它自身才能完成”
     “在这棵树上的所有任务就都结构化了”
     “在 Swift 并发中，在任务树上创建一个叶子节点，有两种方法：
     通过任务组 (task group) 或是通过 async let 的异步绑定语法。我们来看看两者的一些异同。”
     */
    
    /// 任务组
    /**
     “在任务运行上下文中，或者更具体来说，在某个异步函数中，我们可以通过 withTaskGroup 为当前的任务添加一组结构化的并发子任务”
     
     func withTaskGroup<ChildTaskResult, GroupResult>(of childTaskResultType: ChildTaskResult.Type, returning returnType: GroupResult.Type = GroupResult.self, body:(inout TaskGroup<ChildTaskResult>) async -> GroupResult) async -> GroupResult {}
     1. “childTaskResultType 正如其名，我们需要指定子任务们的返回类型。同一个任务组中的子任务只能拥有同样的返回类型，这是为了让 TaskGroup 的 API 更加易用，让它可以满足带有强类型的 AsyncSequence 协议所需要的假设。returning 定义了整个任务组的返回值类型，它拥有默认值，通过推断就可以得到，我们一般不需要理会。在 body 的参数中能得到一个 inout 修饰的 TaskGroup，我们可以通过使用它来向当前任务上下文添加结构化并发子任务。”
     2. “addTask API 把新的任务添加到当前任务中。被添加的任务会在调度器获取到可用资源后立即开始执行。在这里的例子里，for...in 循环中的三个任务会被立即添加到任务组里，并开始执行。”
     3.“在实际工作开始时，我们进行了一次 debugPrint 输出，这让我们可以更容易地观测到事件的顺序”
     4.“group 满足 AsyncSequence，因此我们可以使用 for await 的语法来获取子任务的执行结果。group 中的某个任务完成时，它的结果将被放到异步序列的缓冲区中。每当 group 的 next 会被调用时，如果缓冲区里有值，异步序列就将它作为下一个值给出；如果缓冲区为空，那么就等待下一个任务完成，这是异步序列的标准行为”
     5.“for await 的结束意味着异步序列的 next 方法返回了 nil，此时group 中的子任务已经全部执行完毕了，withTaskGroup 的闭包也来到最后。接下来，外层的 “End” 也会被输出。整个结构化并发结束执行”
     */
    struct TaskGroupSample {
        func start() async {
            debugPrint("Start")
            await withTaskGroup(of: Int.self) { group in
                for i in 0..<3 {
                    group.addTask {
                        await work(i)
                    }
                }
                debugPrint("Task Added")
                
                for await result in group {
                    debugPrint("Get result: \(result)")
                }
                
                debugPrint("Task Ended")
            }
            debugPrint("End")
        }
        
        func startSilent() async {
            debugPrint("Start")
            await withTaskGroup(of: Int.self) { group in
                for i in 0..<3 {
                    group.addTask {
                        await work(i)
                    }
                }
                debugPrint("Task Added")
                // Silent added await
                
                debugPrint("Task Ended")
            }
            debugPrint("End")
        }
        
        func startResult() async {
            debugPrint("Start")
            let value: Int = await withTaskGroup(of: Int.self) { group in
                var value = 0
                for i in 0..<3 {
                    group.addTask {
                        await work(i)
                    }
                }
                debugPrint("Task Added")
                for await result in group {
                    value += result
                }
                debugPrint("Task Ended")
                return value
            }
            debugPrint("End \(value)")
        }
        
        func startError() async {
            debugPrint("Start")
            await withTaskGroup(of: Int.self) { group in
                var value = 0
                for i in 0..<3 {
                    group.addTask {
                        let result = await work(i)
                        //                        // Mutation of captured var 'value' in concurrently-executing code
                        //                        value += result
                        return result
                    }
                }
                debugPrint("Task Added")
                
                debugPrint("Task Ended")
            }
            debugPrint("End")
        }
        
        func startAccessValue() async {
            debugPrint("Start")
            await withTaskGroup(of: Int.self) { group in
                var value = 0
                for i in 0..<3 {
                    group.addTask { [value] in
                        let result = await work(i)
                        debugPrint("Value \(value)")
                        return result
                    }
                }
                value = 100
                debugPrint("Task Added")
                
                debugPrint("Task Ended")
            }
            debugPrint("End")
        }
        
        private func work(_ value: Int) async -> Int {
            debugPrint("Start Work \(value)")
            await Task.sleep(UInt64(value) * NSEC_PER_SEC)
            debugPrint("Work\(value) Done")
            return value
        }
    }
    
    func testTaskGroupStructConcurrency() {
        Task {
            let sample = TaskGroupSample()
            await sample.start()
        }
    }
    
    /// 隐式等待
    /**
     “为了获取子任务的结果，我们在上例中使用 for await 明确地等待 group 完成”
     “这从语义上明确地满足结构化并发的要求：子任务会在控制流到达底部前结束”
     “其实编译器并没有强制我们书写 for await 代码”
     “即使我们没有明确 await 任务组，编译器在检测到结构化并发作用域结束时，会为我们自动添加上 await 并在等待所有任务结束后再继续控制流”
     “虽然 “Task ended” 的输出似乎提早了，但代表整个任务组完成的 “End” 的输出依然处于最后，它一定会在子任务全部完成之后才发生。对于结构化的任务组，编译器会为在离开作用域时我们自动生成 await group 的代码，上面的代码其实相当于”
     
     await withTaskGroup(of: Int.self) { group in
     for i in 0..<3 {
     group.addTask {
     await work(i)
     }
     }
     debugPrint("Task Added")
     debugPrint("Task Ended")
     // 编译器自动生成的代码
     fir await _ in group {}
     }
     debugPrint("End")
     
     “它满足结构化并发控制流的单入单出，将子任务的生命周期控制在任务组的作用域内，这也是结构化并发的最主要目的”
     “即使我们手动 await 了 group 中的部分结果，然后退出了这个异步序列，结构化并发依然会保证在整个闭包退出前，让所有的子任务得以完成”
     
     await withTaskGroup(of: Int.self) { group in
     for i in 0..<3 {
     group.addTask {
     await work(i)
     }
     }
     debugPrint("Task Added")
     for await result in group {
     debugPrint("Get result: \(result)")
     break
     }
     debugPrint("Task Ended")
     // 编译器自动生成
     await group.waitForAll()
     }
     */
    
    func testTaskGroupWaitSilent() {
        Task {
            await TaskGroupSample().startSilent()
            
        }
    }
    
    /// 任务组的值的捕获
    /**
     1.“任务组中的每个子任务都拥有返回值，上面例子中 work 返回的 Int 就是子任务的返回值”
     2.“当 for await 一个任务组时，就可以获取到每个子任务的返回值。任务组必须在所有子任务完成后才能完成，因此我们有机会“整理”所有子任务的返回结果，并为整个任务组设定一个返回值”
     let v: Int = await withTaskGroup(of: Int.self) { group in
     var value = 0
     for i in 0..<3 {
     group.addTask {
     return await work(i)
     }
     }
     for await result in group {
     value += result
     }
     return value
     }
     debugPrint(End: result \(v))
     
     “一种很常见的错误，是把 value += result 的逻辑写到 addTask 中”
     let v: Int = withTaskGroup(of: Int.self) { group in
     var value = 0
     for i in 0..<3 {
     group.addTask {
     let result = await work(i)
     /// “Mutation of captured var ‘value’ in concurrently-executing code”
     value += result
     return result
     }
     }
     await group.waitForAll()
     }
     
     1.“在将代码通过 addTask 添加到任务组时，我们必须有清醒的认识：这些代码有可能以并发方式同时运行”
     2.“编译器可以检测到这里我们在一个明显的并发上下文中改变了某个共享状态”
     3.“不加限制地从并发环境中访问是危险操作，可能造成崩溃”
     4.“得益于结构化并发，现在编译器可以理解任务上下文的区别，在静态检查时就发现这一点，从而从根本上避免了这里的内存风险”
     
     可使用的改进
     1. var value -> let value
     2. block中 [value]“使用 [value] 的语法，来捕获当前的 value 值。由于 value 是值类型的值，因此它将会遵循值语义，被复制到 addTask 闭包内使用”“子任务闭包内的访问将不再使用闭包外的内存，从而保证安全”
     await withTaskGroup(of: Int.self) { group in
     // var value = 0
     let value = 0
     }
     or
     await withTaskGroup(of: Int.self) { group in
     var value = 0
     for i in 0..<3 {
     group.addTask { [value] in
     let result = await work(i)
     debugPrint("Value: \(value)")
     return result
     }
     }
     value = 100
     }
     
     */
    
    func testResultCount() {
        Task {
            await TaskGroupSample().startResult()
        }
    }
    
    func testAccessValue() {
        Task {
            await TaskGroupSample().startAccessValue()
        }
    }
    
    /**
     “不过，如果我们把 value 再向上提到类的成员一级的话，这个静态检查将失去作用”(数据不安全的访问在多线程的case下)
     1.“在 Swift 5.5 中，虽然它可以编译 (而且使用起来，特别是在本地调试时也几乎不会有问题)，但这样的行为是错误的。和 Rust 不同，Swift 的堆内存所有权模型还无法完全区分内存的借用 (borrow) 和移动 (move)，因此这种数据竞争和内存错误，还需要开发者自行注意”
     2.“Swift 编译器并非无法检出上述错误，它只是暂时“容忍”了这种情况。包括静态检测上述错误在内的完全的编译器级别并发数据安全，是未来 Swift 版本中的目标”
     3.“现在，在并发上下文中访问共享数据时，Swift 设计了 actor 类型来确保数据安全”
     */
    /// 错误的代码，不要这么写
    class TaskGroupSampleCls {
        var value = 0
        func start() async {
            await withTaskGroup(of: Int.self) { group in
                for i in 0..<3 {
                    group.addTask {
                        // 可以访问value
                        debugPrint("Value \(self.value)")
                        let result = await self.work(i)
                        // 可以操作value
                        self.value += result
                        return result
                    }
                }
            }
        }
        
        private func work(_ value: Int) async -> Int {
            await Task.sleep(NSEC_PER_SEC)
            return value
        }
    }
    
    func testComplileSuccessButErrorOperation() {
        Task {
            await TaskGroupSampleCls().start()
        }
    }
    
    /// 任务组逃逸
    /**
     “和 withUnsafeCurrentTask 中的 task 类似，withTaskGroup 闭包中的 group 也不应该被外部持有并在作用范围之外使用”
     “虽然 Swift 编译器现在没有阻止我们这样做，但是在 withTaskGroup 闭包外使用 group 的话，将完全破坏结构化并发的假设”
     
     // 错误的代码
     func start() async {
     var g: TaskGroup<Int>? = nil
     await withTaskGroup(of: Int.self) { group in
     g = group
     }
     g?.addTask {
     await work(1)
     }
     debugPrint("End")
     }
     1.“通过 g?.addTask 添加的任务有可能在 start 完成后继续运行，这回到了非结构并发的老路”
     2.“也可能让整个任务组进入到难以预测的状态，这将摧毁程序的执行假设”
     3.“TaskGroup 实际上并不是用来存储 Task 的容器，它也不提供组织任务时需要的树形数据结构，这个类型仅仅只是作为对底层接口的包装，提供了创建任务节点的方法”
     4.“要注意，在闭包作用范围外添加任务的行为是未定义的，随着 Swift 的升级，今后有可能直接产生运行时的崩溃”
     5.“虽然现在并没有提供任何语言特性来确保 group 不被复制出去，但是我们绝对应该避免这种反模式的做法”
     
     */
}

// MARK: - async let 异步绑定
extension ViewController {
    /**
     1.“除了任务组以外，async let 是另一种创建结构化并发子任务的方式”
     2.“withTaskGroup 提供了一种非常“正规”的创建结构化并发的方式：它明确地描绘了结构化任务的作用返回，确保在闭包内部生成的每个子任务都在 group 结束时被 await”“通过对 group 这个异步序列进行迭代，我们可以按照异步任务完成的顺序对结果进行处理。只要遵守一定的使用约定，就可以保证并发结构化的正确工作并从中受益”
     3.“withTaskGroup 不足：每次我们想要使用 withTaskGroup 时，往往都需要遵循同样的模板，包括创建任务组、定义和添加子任务、使用 await 等待完成等，这些都是模板代码”
     4.withTaskGroup“对于所有子任务的返回值必须是同样类型的要求，也让灵活性下降或者要求更多的额外实现 (比如将各个任务的返回值用新类型封装等)”
     5.“withTaskGroup 的核心在于，生成子任务并将它的返回值 (或者错误) 向上汇报给父任务，然后父任务将各个子任务的结果汇总起来，最终结束当前的结构化并发作用域”
     6.“这种数据流模式十分常见，如果能让它简单一些，会大幅简化我们使用结构化并发的难度。async let 的语法正是为了简化结构化并发的使用而诞生的”
     */
    
    struct AsyncLetStructSample {
        func start() async {
            debugPrint("Start")
            async let v0 = work(0)
            async let v1 = work(1)
            async let v2 = work(2)
            debugPrint("Task Added")
            let result = await v0 + v1 + v2
            debugPrint("Task Ended")
            debugPrint("End \(result)")
        }
        func startWait() async {
            debugPrint("Start")
            async let v0 = work(0)
            async let v1 = work(1)
            async let v2 = work(2)
            debugPrint("Task Added")
            let result0 = await v0
            let reuslt1 = await v1
            let result2 = await v2
            let result = result0 + reuslt1 + result2
            debugPrint("Task Ended")
            debugPrint("End \(result)")
        }
        
        private func work(_ value: Int) async -> Int {
            await Task.sleep(NSEC_PER_SEC)
            return value
        }
    }
    
    func testAsyncLet() {
        Task {
            await AsyncLetStructSample().start()
        }
    }
    
    /**
     1. “async let 和 let 类似，它定义一个本地常量，并通过等号右侧的表达式来初始化这个常量”
     2. “区别在于，这个初始化表达式必须是一个异步函数的调用，通过将这个异步函数“绑定”到常量值上，Swift 会创建一个并发执行的子任务，并在其中执行该异步函数”
     3.“async let 赋值后，子任务会立即开始执行”
     4.“如果想要获取执行的结果 (也就是子任务的返回值)，可以对赋值的常量使用 await 等待它的完成”
     */
    
    /**
     “需要特别强调，虽然这里我们顺次进行了 await，看起来好像是在等 v0 求值完毕后，再开始 v1 的暂停；然后在 v1 求值后再开始 v2。但是实际上，在 async let 时，这些子任务就一同开始以并发的方式进行了。在例子中，完成 work(n) 的耗时为 n 秒，所以上面的写法将在第 0 秒，第 1 秒和第 2 秒分别得出 v0，v1 和 v2 的值，而不是在第 0 秒，第 1 秒和第 3 秒 (1 秒 + 2 秒) 后才得到对应值”
     
     “如果我们修改 await 的顺序，“每个子任务实际完成的时序是没有变化
     “在 async let 创建子任务时，这个任务就开始执行了”
     
     */
    func testAsyncLetWait() {
        Task {
            await AsyncLetStructSample().startWait()
        }
    }
    
    /// 隐式取消
    /**
     1.“在使用 async let 时，编译器也没有强制我们书写类似 await v0 这样的等待语句”
     2.“如果没有 await，那么 Swift 并发会在被绑定的常量离开作用域时，隐式地将绑定的子任务取消掉，然后进行 await。也就是说，对于这样的代码”
     func start() async {
     async let v0 = work(0)
     debugPrint("End")
     }
     等效于：
     func start() async {
     async let v0 = worl(0)
     debugPrint("End")
     // 下面是编译器自动生成的伪代码”“注意和 Task group 的不同”“ v0 绑定的任务被取消”“伪代码，实际上绑定中并没有 `task` 这个属性”
     v0.task.cancel()
     // “隐式 await，满足结构化并发”
     _ = await v0
     }
     3. “和 TaskGroup API 的不同之处在于，被绑定的任务将先被取消，然后才进行 await”
     4.“这给了我们额外的机会去清理或者中止那些没有被使用的任务”
     5.“这种“隐藏行为”在异步函数可以抛出的时候，可能会造成很多的困惑”
     6.“和 TaskGroup 一样，就算没有 await，async let 依然满足结构化并发要求”
     */
    
    /// 对比任务组
    /**
     1.“在语义上，两者所表达的范式是很类似的”,“会有人认为 async let 只是任务组 API 的语法糖：因为任务组 API 的使用太过于繁琐了，而异步绑定毕竟在语法上要简洁很多”
     2.“async let 不能动态地表达任务的数量，能够生成的子任务数量在编译时必须是已经确定好的”
     “比如，对于一个输入的数组，我们可以通过 TaskGroup 开始对应数量的子任务，但是我们却无法用 async let 改写这段代码”
     3. “除了下面那些只能使用某一种方式创建的结构化并发任务外，对于可以互换的情况，任务组 API 和异步绑定 API 的区别在于提供了两种不同风格的编程方式”
     4.“一个大致的使用原则是，如果我们需要比较“严肃”地界定结构化并发的起始，那么用任务组的闭包将它限制起来，并发的结构会显得更加清晰”
     5.“如果我们只是想要快速地并发开始少数几个任务，并减少其他模板代码的干扰，那么使用 async let 进行异步绑定，会让代码更简洁易读”
     */
    struct StructSample2 {
        func startAll(_ items: [Int]) async {
            await withTaskGroup(of: Int.self) { group in
                for item in items {
                    group.addTask {
                        return await work(item)
                    }
                }
                
                for await value in group {
                    debugPrint("Value: \(value)")
                }
            }
        }
        
        func startAll2(_ items: [Int]) async {
            //// Cannot pass function of type '(Int) async -> Void' to parameter expecting synchronous function type
            //            items.forEach {
            //                async let v = work($0)
            //            }
        }
        
        private func work(_ value: Int) async -> Int {
            await Task.sleep(NSEC_PER_SEC)
            return value
        }
    }
    
    func testItemsTaskGroup() {
        Task {
            await StructSample2().startAll([5, 2, 1])
        }
    }
}

// MARK: - 结构化并发的组合
extension ViewController {
    /**
     1.“在只使用一次 withTaskGroup 或者一组 async let 的单一层级的维度上，我们可能很难看出结构化并发的优势”
     2.“因为这时对于任务的调度还处于可控状态：我们完全可以使用传统的技术，通过添加一些信号量，来“手动”控制保证并发任务最终可以合并到一起”
     3.“随着系统逐渐复杂，可能会面临在一些并发的子任务中再次进行任务并发的需求。也就是，形成多个层级的子任务系统。在这种情况下，想依靠原始的信号量来进行任务管理会变得异常复杂。这也是结构化并发这一抽象真正能发挥全部功效的情况。”
     4.“通过嵌套使用 withTaskGroup 或者 async let，可以在一般人能够轻易理解的范围内，灵活地构建出这种多层级的并发任务”
     5.“最简单的方式，是在 withTaskGroup 中为 group 添加 task 时再开启一个 withTaskGroup”
     */
    struct TaskGroupSample2 {
        
        func start() async {
            // 第一层任务组
            debugPrint("Start")
            let value: Int = await withTaskGroup(of: Int.self) { group in
                group.addTask {
                    // 第二层任务组
                    await withTaskGroup(of: Int.self) { innerGroup in
                        innerGroup.addTask {
                            await work(0)
                        }
                        innerGroup.addTask {
                            await work(2)
                        }
                        return await innerGroup.reduce(0) { result, value in
                            result + value
                        }
                    }
                }
                group.addTask {
                    await work(1)
                }
                return await group.reduce(0) { result, value in
                    result + value
                }
            }
            debugPrint("End \(value)")
        }
        
        private func work(_ value: Int) async -> Int {
            await Task.sleep(NSEC_PER_SEC)
            return value
        }
    }
    
    func testNestTaskGroup() {
        Task {
            await TaskGroupSample2().start()
        }
    }
    /**
     “对于上面使用 work 函数的例子来说，多加的一层 innerGroup 在执行时并不会造成太大区别”
     1.“三个任务依然是按照结构化并发执行”
     2.“不过，这种层级的划分，给了我们更精确控制并发行为的机会”
     3.“在结构化并发的任务模型中，子任务会从其父任务中继承任务优先级以及任务的本地值 (task local value)”
     4.“在处理任务取消时，除了父任务会将取消传递给子任务外，在子任务中的抛出也会将取消向上传递”
     5.“不论是当我们需要精确地在某一组任务中设置这些行为，或者只是单纯地为了更好的可读性，这种通过嵌套得到更加细分的任务层级的方法，都会对我们的目标有所帮助”
     6.“任务本地值指的是那些仅存在于当前任务上下文中的，由外界注入的值”
     7. “相对于 withTaskGroup 的嵌套，使用 async let 会更有技巧性一些”
     8.“async let 赋值等号右边，接受的是一个对异步函数的调用
     9.“这个异步函数可以是像 work 这样的具体具名的函数，也可“以是一个匿名函数”
     */
    struct AsyncLetSample3 {
        func start() async {
            // “这里在 v02 等号右侧的是一个匿名的异步函数闭包调用”
            // “，其中通过两个新的 async let 开始了嵌套的子任务”
            // “特别注意，上例中的写法和下面这样的 await 有本质不同：”
            /**
             async let v02: Int = {
             return await work(0) + work(2)
             }()
             “await work(0) + work(2) 将会顺次执行 work(0) 和 work(2)，并把它们的结果相加。这时两个操作不是并发执行的，也不涉及新的子任务”
             
             */
            async let v02: Int = {
                async let v0 = work(0)
                async let v2 = work(2)
                return await v0 + v2
            }()
            
            async let v1 = work(1)
            let value = await v1 + v02
            debugPrint("End \(value)")
        }
        
        func start2() async {
            // “我们也可以把两个嵌套的 async let 提取到一个署名的函数中，这样调用就会回到我们所熟悉的方式”
            async let v02 = work02()
            async let v1 = work(1)
            let value = await v1 + v02
            debugPrint("End \(value)")
        }
        
        private func work02() async -> Int {
            async let v0 = work(0)
            async let v2 = work(2)
            return await v0 + v2
        }
        
        private func work(_ value: Int) async -> Int {
            await Task.sleep(NSEC_PER_SEC)
            return value
        }
    }
    
    func testAsyncLetSample3() {
        Task {
            await AsyncLetSample3().start()
            await AsyncLetSample3().start2()
        }
    }
    /**
     1.“大部分时候，把子任务的部分提取成具名的函数会更好。不过对于这个简单的例子，直接使用匿名函数，让 work(0)、work(2) 与另一个子任务中的 work(1) 并列起来，可能结构会更清楚”
     2.“因为 withTaskGroup 和 async let 都产生结构性并发任务，因此有时候我们也可以将它们混合起来使用”
     3.“比如在 async let 的右侧写一个 withTaskGroup”
     4.“或者在 group.addTask 中用 async let 绑定新的任务”
     5.“这种“静态”的任务生成方式，理解起来都是相对容易的：只要我们能将生成的任务层级和我们想要的任务层级对应起来，两者混用也不会有什么问题”
     */
}
