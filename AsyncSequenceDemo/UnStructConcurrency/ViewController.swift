//
//  ViewController.swift
//  UnStructConcurrency
//
//  Created by Lee Danatech on 2021/11/29.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        testUnStructConcurrency()
    }
}

// MARK: - 非结构化任务
extension ViewController {
    /**
     1.“TaskGroup.addTask 和 async let 是 Swift 并发中“唯二”的创建结构化并发任务的 API”
     2.“它们从当前的任务运行环境中继承任务优先级等属性，为即将开始的异步操作创建新的任务环境，然后将新的任务作为子任务添加到当前任务环境中”
     3.“我们也看到过使用 Task.init 和 Task.detached 来创建新任务，并在其中执行异步函数的方式”
     func start() {
     Task {
     await work(1)
     }
     Task.detached {
     await work(2)
     }
     }
     4.“这类任务具有最高的灵活性，它们可以在任何地方被创建。它们生成一棵新的任务树，并位于顶层，不属于任何其他任务的子任务，生命周期不和其他作用域绑定，当然也没有结构化并发的特性”
     
     “对比三者，可以看出它们之间明显的不同”
     1.“TaskGroup.addTask 和 async let - 创建结构化的子任务，继承优先级和本地值”
     2.“Task.init - 创建非结构化的任务根节点，从当前任务中继承运行环境：比如 actor 隔离域，优先级和本地值等”
     3.“Task.detached - 创建非结构化的任务根节点，不从当前任务中继承优先级和本地值等运行环境，完全新的游离任务环境”
     
     “@main 标记的异步程序入口和 SwiftUI task 修饰符，都使用的是 Task.detached”
     “创建非结构化任务时，我们可以得到一个具体的 Task 值，它充当了这个新建任务的标识。从 Task.init 或 Task.detached 的闭包中返回的值，将作为整个 Task 运行结束后的值。使用 Task.value 这个异步只读属性，我们可以获取到整个 Task 的返回值”
     extension Task {
     var value: Success { get async throws }
     }
     // 或者当task不会失败时，value也不会throw
     extension Task where Failure == Never {
     var value: Success { get async }
     }
     “想要访问这个值，和其他任意异步属性一样，需要使用 await”
     func start() async {
     let t1 = Task { await work(1) }
     let t2 = Task.detached { await work(2) }
     let v1 = await t1.value
     let v2 = await t2.value
     }
     “一旦创建任务，其中的异步任务就会被马上提交并执行。所以上面的代码依然是并发的”
     “t1 和 t2 之间没有暂停，将同时执行，t1 任务在 1 秒后完成，而 t2 在两秒后完成。await t1.value 和 await t2.value 的顺序并不影响最终的执行耗时，即使是我们先 await 了 t2，t1 的预先计算的结果也会被暂存起来，并在它被 await 的时候给出。”
     
     “用 Task.init 或 Task.detached 明确创建的 Task，是没有结构化并发特性的。Task 值超过作用域并不会导致自动取消或是 await 行为。想要取消一个这样的 Task，必须持有返回的 Task 值并明确调用 cancel”
     let t1 = Task { await work(1) }
     t1.cancel()
     
     “这种非结构化并发中，外层的 Task 的取消，并不会传递到内层 Task。或者，更准确来说，这样的两个 Task 并没有任何从属关系，它们都是顶层任务”
     let outer = Task {
     let inner = Task { await work(1)}
     await work(2)
     }
     outer.cancel
     outer.isCancelled // true
     inner.isCancelled // false
     “Task.value 其实也是一种异步函数，如果我们将结构化并发和非结构化的任务组合起来使用的话，事情马上就会变得复杂起来”
     
     “除非有特别的理由，我们希望某个任务独立于结构化并发的生命周期，否则我们应该尽量避免在结构化并发的上下文中使用非结构化任务。这可以让结构化的任务树保持简单，而不是随意地产生不受管理的新树”
     
     */
    struct UnStructSample {
        
        func start() async {
            // “t1 和 t2 确实是结构化的，但是它们开启的新任务，却并非如此：虽然 t1 和 t2 在超出 start 作用域时，由于没有 await，这两个绑定都将被取消，但这个取消并不能传递到非结构化的 Task 中，所以两个 isCancelled 都将输出 false”
            async let t1 = Task {
                await  work(1)
                debugPrint("Cancelled1: \(Task.isCancelled)")
            }.value
            async let t2 = Task.detached {
                await work(2)
                debugPrint("Cancelled2: \(Task.isCancelled)")
            }.value
        }
        
        func start2() async {
            let t1 = Task { await work(1) }
            let t2 = Task.detached { await work(2) }
            debugPrint("go \(CACurrentMediaTime())")
            let v1 = await t1.value
            debugPrint("done t1 \(CACurrentMediaTime())")
            let v2 = await t2.value
            debugPrint("done t2 \(CACurrentMediaTime())")
            debugPrint("value1: \(v1)  value2: \(v2)")
        }
        
        private func work(_ value: Int) async -> Int {
            await Task.sleep(UInt64(value) * NSEC_PER_SEC)
            return value
        }
    }
    
    
    func testUnStructConcurrency() {
        Task {
            await UnStructSample().start()
            await UnStructSample().start2()
        }
    }
}

