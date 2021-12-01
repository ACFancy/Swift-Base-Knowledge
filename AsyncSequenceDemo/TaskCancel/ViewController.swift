//
//  ViewController.swift
//  TaskCancel
//
//  Created by Lee Danatech on 2021/11/29.
//

import UIKit
import Combine

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        //        testCancel()

        //        testReturnCancel()

        //        testErrorThrowCancel()

        //        testTaskTreeOtherBranch()

        //        testSystemAPICancel()

//        testCancelClean()

        testCancellationHandler()
    }
}

// MARK: - 协作式任务取消
extension ViewController {
    /**
     1.“并发任务往往是一些耗费时间和资源的操作，如果并发任务中途被取消了，我们会希望这些耗时耗力的操作也能及时中止”
     2.“在基于回调的派发式并发模型中，取消任务是一件非常困难的事情。并发任务可能会逃逸出当前作用范围，而且并发任务之间缺乏关联，我们往往需要自行维护各个任务之间的关系，持有那些可能被取消的任务 (或者说 DispatchWorkItem)，并在适当的情况下将它们停止。这其中涉及的复杂度，其实只在理论上可行，而且必然充满了各种 bug”
     3.“Operation 类型 通过封装 GCD，提供了一层任务抽象。我们可以为任务之间设定依赖关系，虽然它并不完全等价于结构化并发的任务层级，但是我们可以用任务依赖来“模拟”父任务和子任务。不过，对某个 Operation 值进行取消，并不会使取消操作在这个模拟的任务层级间自动传递，我们需要很多额外代码，才能做到正确地取消相关任务。这为在并发编程中正确处理取消，带来了巨大的难度”
     4.“对于结构化并发，事情就简单得多了。由于子任务的作用域和生命周期被完全限制，结构化的父任务和子任务之间有着天然的层级联系。父任务取消可以非常容易地传递到子任务中，这样子任务可以在不持有任务关于父任务的引用的情况下，对取消作出响应 (比如清理资源等)”
     5.“需要注意的是，结构化并发中取消的传递，并不意味着在任务取消时那些需要手动释放的资源可以被“自动”回收，任务本身在被取消后也并不会自动停止”
     6.“Swift 并发和任务的取消，是一种基于协作式 (cooperative) 的取消：换句话说，组成任务层级的各个部分，包括父任务和子任务，往往需要通力合作，才能达到我们最终想要的效果。而结构化并发中取消的传递，仅仅只是协作式取消中的一个部分”
     */

    func testCancel() {
        @Sendable func work() async -> String {
            var s = ""
            for c in "Hello" {
                await Task.sleep(NSEC_PER_SEC)
                debugPrint("Append: \(c) \(Task.isCancelled)")
                s.append(c)
            }
            return s
        }

        Task {
            let t = Task {
                let value = await work()
                debugPrint("Value: \(value)")
            }
            await Task.sleep(UInt64(2.5 * Double(NSEC_PER_SEC)))
            t.cancel()
        }
    }

    /**
     “实际上，Swift 并发中对某个任务调用 cancel，做的事情只有两件”
     1.“将自身任务的 isCancelled 标识置为 true”
     2.“在结构化并发中，如果该任务有子任务，那么取消子任务”

     “子任务在被取消时，同样做这两件事。在结构化并发中，取消会被传递给任务树中当前任务节点下方的所有子节点”
     1.“SubTask 1 和 SubTask 2 都是 Root 任务的子任务。如果对 SubTask 1 调用 cancel()，SubTask 1 的 isCancelled 被标记为 true”
     2.“接下来取消被传递给 SubTask 1 的所有子任务，它们的 isCancelled 也被标记为 true”
     3.“取消操作在结构化任务树中一直向下传递，直到最末端的叶子节点”

     “cancel() 调用只负责维护一个布尔变量，仅此而已。它不会涉及其他任何事情：任务不会因为被取消而强制停止，也不会让自己提早返回”
     1.“各个任务需要合作，才能达到最终停止执行的目标。父任务要做的工作就是向子任务传递 isCancelled，并将自身的 isCancelled 状态设置为 true。”
     2.“当父任务已经完成它自己的工作后，接下来的事情就要交给各个子任务的实现，它们要负责检查 isCancelled 并作出合适的响应”
     3.“换言之，如果谁都没有检查 isCancelled 的话，协作式的取消就不成立了，整个任务层级向外将呈现出根本不支持取消操作的状态”
     */

    /// 处理任务取消
    /**
     “在任务中要如何实际利用 isCancelled 来停止异步任务。结构化并发要求异步函数的执行不超过任务作用域，因此在遇到任务取消时，如果我们想要进行处理并提前结束任务，大致只有两类选择”
     1.“提前返回一个空值或者部分已经计算出来的值，让当前任务正常结束”
     2.“通过抛出错误并汇报给父层级任务，让当前任务异常结束”
     */

    /// 返回空值或部分值
    /// “当任务的取消不影响流程，或者异步任务只能获取部分结果的情况也被考虑为正常的时候，我们可以通过提前返回空值或者部分值，来完成当前任务”
    func testReturnCancel() {
        /// “策略是，每次进行耗时操作之前，先对 isCancelled 进行检查。只有在 isCancelled 为 false 时，才进行操作，否则立即将当前的部分结果返回”
        @Sendable func work() async -> String {
            var s = ""
            for c in "Hello" {
                guard !Task.isCancelled else { return s }
                await Task.sleep(NSEC_PER_SEC)
                debugPrint("Append: \(c) \(Task.isCancelled)")
                s.append(c)
            }
            return s
        }

        /// 返回空值
        @Sendable func work2() async -> String? {
            var s = ""
            for c in "Hello" {
                guard !Task.isCancelled else { return nil }
                await Task.sleep(NSEC_PER_SEC)
                debugPrint("Append: \(c) \(Task.isCancelled)")
                s.append(c)
            }
            return s
        }

        Task {
            let t = Task {
                let value = await work2()
                debugPrint("Value: \(value)")
            }
            await Task.sleep(UInt64(2.5 * Double(NSEC_PER_SEC)))
            t.cancel()
        }
    }

    /// 抛出错误
    /**
     “如果某个任务的完成情况 (或者说，返回值)     在并发操作中具有关键作用，其他任务必须依赖该任务确实完成才能继续进行的话，返回空值或者部分值就不再是一个可行的选项了”
     1. “下载数据、缓存数据以及提供图片，其重要程度并非对等。缓存任务和提供图片的任务是依赖于下载任务的：只有当下载数据确实完整，缓存和提供图片才有意义。但是提供图片的任务并不依赖于缓存任务：即使缓存失败了，也可以从下载的数据中生成图片”
     2. “在设计这些任务时，当缓存任务被取消时，我们可以选择返回部分结果或者 nil；但是当下载任务被取消时，我们只能抛出错误，告诉框架调用者任务无法完成”
     */
    /// “约定错误和自定义错误”
    /**
     “Swift 并发中为取消处理规定了一些约定俗成的通用方法”
     “CancellationError 是定义在标准库内的一个特殊的错误类型”
     “区分任务取消和其他类型的错误，在最终进行错误处理的时候是很有意义的”
     “Result 唯一的优势在于，可以对错误类型进行限定：比如如果一个任务除了被取消外，不会以任何其他错误方式抛出，那么我们可以把返回值写为 Result<String, CancellationError>，来在编译期间提供更好的静态提示。这确实比单纯的 throws 表达了更精确的信息，但是考虑到 Task 相关的 API 和整个既有生态，都在使用 throws 来处理错误的现实，单纯为了这一点优势而放弃整个体系，似乎有点得不偿失。”
     */
    func testErrorThrowCancel() {
        @Sendable func work() async throws -> String {
            var s = ""
            for c in "Hello" {
                guard !Task.isCancelled else {
                    throw CancellationError()
                }
                await Task.sleep(NSEC_PER_SEC)
                debugPrint("Append: \(c) \(Task.isCancelled)")
                s.append(c)
            }
            return s
        }

        /// “抛出 CancellationError 错误”的模式十分常用，Swift 甚至把它们封装成了一个单独的方法，并放到了标准库中”
        @Sendable func work2() async throws -> String {
            var s = ""
            for c in "Hello" {
                try Task.checkCancellation()
                await Task.sleep(NSEC_PER_SEC)
                debugPrint("Append: \(c) \(Task.isCancelled)")
                s.append(c)
            }
            return s
        }

        Task {
            let t = Task {
                do {
                    let value = try await work2()
                    debugPrint("Value: \(value)")
                } catch is CancellationError {
                    debugPrint("Task Cancelled")
                } catch {
                    debugPrint("Other Error \(error)")
                }
            }
            await Task.sleep(UInt64(2.5 * Double(NSEC_PER_SEC)))
            t.cancel()
        }
    }

    /// 对任务树上其他分支的影响
    /**
     “上面都只涉及了单个任务，接下来让我们来考虑一个复杂一点的结构化并发例子”
     “结构化并发里一个任务接受到子任务抛出的错误后，会先将其他子任务取消掉，然后再等待所有子任务结束后，把首先接到的错误抛出到更外层”
     1.“在 work 的实现中，我们使用了 try Task.checkCancellation() 检测任务的取消情况，并抛出 CancellationError 错误。
     Task 1.1 或 Task   1.2 中的这部分代码将被触发，并将错误抛给 inner”
     2.“这个错误并没有在 inner.addTask 中被处理，于是它将被进一步抛出到上层，也就是 group 中”
     3.“作为父任务，外层 group 在接受到 Task 1 的错误后，会主动取消掉任务树中所有的子任务，等待子任务们全部执行完毕 (不论是正常返回还是抛出错误) 后，再进行错误处理。在这里，group 中除了 Task 1 外，只有一个其他子任务 Task 2。于是，Task 2 的 isCancelled 也被置为 true，并触发 work 中的相关检查抛出取消错误”

     “这是一个运行良好的协作式取消的例子：在任务树的某个部分被取消时，树上所有的耗时操作都及时停止了”
     - “我们总是应该尽可能快地对任务取消作出响应，避免额外的非必要工作，并迅速通过抛出来完成任务，将结构化并发的控制权交回给调用者”
     “遵守规范”其实需要精确的设计才能实现。在设计并发系统时，即使我们没有处理取消操作，编译器也不会报错或警告。但是一旦我们没有能正确处理取消，比如忘了检查 isCancelled 或没有抛出错误，任务的执行可能会超出我们的想定”
     */
    func testTaskTreeOtherBranch() {

        @Sendable func work(_ text: String) async throws -> String {
            var s = ""
            for c in text {
                if Task.isCancelled {
                    debugPrint("Task Cancelled: \(s)")
                }
                try Task.checkCancellation()
                await Task.sleep(NSEC_PER_SEC)
                s.append(c)
                debugPrint("Append \(c)")
            }
            debugPrint("\(s)")
            return s
        }

        Task {
            do {
                let value: String = try await withThrowingTaskGroup(of: String.self, body: { group in
                    group.addTask {
                        try await withThrowingTaskGroup(of: String.self, body: { inner in
                            inner.addTask { try await work("Hello") }
                            inner.addTask { try await work("World!") }

                            // cancel
                            await Task.sleep(UInt64(2.5 * Double(NSEC_PER_SEC)))
                            inner.cancelAll()
                            return try await inner.reduce([]) {
                                $0 + [$1]
                            }.joined(separator: " ")
                        })
                    }
                    group.addTask {
                        try await work("Swift Concurrency")
                    }
                    return try await group.reduce([]) {
                        $0 + [$1]
                    }.joined(separator: " ")
                })
                debugPrint("Value : \(value)")
            } catch {
                debugPrint("error \(error)")
            }
        }
    }

    /// “内建 API 的取消”
    /**
     “因为在设计并发系统时，如果我们想要尽快地响应取消，则需要在每个 await 前后添加 try Task.checkCancellation()。虽然这并不困难，但是显然是一种重复劳动和模板代码”
     “在上例中，Task.sleep(_:) 本身并不支持取消：它会忠实地计数到设定的时间后再将控制流交还。不过，Swift 并发在 Task 的 API 中还提供了一个可以取消的 sleep 版本，它接受一个命名参数 nanoseconds，并被标记为 throws，以示区别”
     extension Task where Success == Never, Failure == Never {
     static func sleep(nanoseconds duration: UInt64) async throws
     }
     “在遇到取消时，sleep(nanoseconds:) 会直接中断，并抛出 CancellationError。如果我们使用这个版本的 sleep 来改写 work，则可以不再手动进行 checkCancellation”
     “对比 sleep(_:) 中每次在 await 前进行检查的版本，sleep(nanoseconds:) 在抛出错误时更加及时，它不需要等到当前的 await 结束后再进行抛出。相比于原来的处理取消的方式，sleep(nanoseconds:) 是更优秀的实现”
     “在我们实际构建一个真正的并发系统时 (而不是使用 Task.sleep 来模拟工作时)，也有类似的选择”
     1.“在大多数情况下，实际的异步操作是通过使用一些系统层级提供的异步 API 来完成的”
     2.“相比于自己书写代码来检查任务的取消状态，我们首先要做的应该是确认我们所使用的异步 API 是否已经支持了协作式取消”
     3.“在标准库和 Foundation 中，有很多这样的例子，比如 URLSession 新加入的几个异步方法，都是默认支持任务取消的，使用它们时我们并不需要自己去检查 isCancelled，不过它们抛出的错误类型可能会根据 API 的差异也有所不同”
     */
    func testSystemAPICancel() {
        @Sendable func work(_ text: String) async throws -> String {
            var s = ""
            for c in text {
                if Task.isCancelled {
                    debugPrint("Cancelled: \(text)")
                }

                try await Task.sleep(nanoseconds: NSEC_PER_SEC)
                s.append(c)
                debugPrint("Append \(c)")
            }
            return s
        }
        Task {
            do {
                let value: String = try await withThrowingTaskGroup(of: String.self) { group in
                    group.addTask {
                        try await withThrowingTaskGroup(of: String.self) { inner in
                            inner.addTask { try await work("Hello") }
                            inner.addTask { try await work("World!") }
                            try await Task.sleep(nanoseconds: UInt64(2.5 * Double(NSEC_PER_SEC)))
                            inner.cancelAll()
                            return try await inner.reduce([]) { $0 + [$1] }.joined(separator: " ")
                        }
                    }
                    group.addTask { try await work("Swift Concurrency") }
                    return try await group.reduce([]) { $0 + [$1] }.joined(separator: " ")
                }
                debugPrint("Value: \(value)")
            } catch {
                debugPrint("Error \(error)")
            }
        }

        Task {
            let t2 = Task {
                do {
                    let (data, _) = try await URLSession.shared.data(from: URL(string: "https://www.baidu.com")!, delegate: nil)
                    debugPrint("data count: \(data.count)")
                } catch {
                    debugPrint("error \(error)")
                }
            }
            await Task.sleep(1)
            t2.cancel()
        }
    }

    /// “取消的清理工作”
    /// defer
    /**
     “某些操作可能会占用资源，需要在使用完毕后及时进行清理”
     1.“比如在访问沙盒外的安全作用域的 URL (security-scoped URL) 时，我们需要先调用 startAccessingSecurityScopedResource 来向系统请求对这个 URL 的访问权限。在使用结束后，我们需要及时调用停止方法 stopAccessingSecurityScopedResource 来放弃访问权限，否则将造成内核资源的泄漏”
     2.“一般情况下，工作流程是首先进行申请，然后使用 URL，最后在做完事情后，放弃权限”

     “在同步的世界中，为了避免在各个退出路径上重复写清理代码，我们往往使用 defer 来确保代码在离开作用域后进行调用”
     “这个技巧在异步操作中也是适用的”
     1.“在结构化并发中的 defer，会等到子任务 await 全部完成后再调用”
     2.“在某些情况下并不明显。比如在使用 async let 创建子任务，然后没有使用这些子任务，导致自动取消的情况”
     3. “这种情况下，结构化并发在离开 Task 作用域前，会补全对 v 的取消和 await v 的调用。即使在这种情况下，defer 也会在最后的隐式 await 之后，再进行调用，所以无论如何，你总是能够安全地在 defer 中进行清理工作”

     “defer 的意义是“当退出当前代码块 { } 的作用域范围时执行 defer 中的代码”
     “而不是“退出当前函数时，执行代码”

     */

    func testCancelClean() {
        // 任务取消则会导致泄漏
        @Sendable func load(url: URL) async {
            let started = url.startAccessingSecurityScopedResource()
            if started {
                await doSomeThing(url)
                url.stopAccessingSecurityScopedResource()
            }
        }

        @Sendable func load2(url: URL) async throws {
            let started = url.startAccessingSecurityScopedResource()
            if started {
                try Task.checkCancellation()
                await doSomeThing(url)
                try Task.checkCancellation()
                await doAnotherThing(url)
                // 调用可能没有被执行到
                url.stopAccessingSecurityScopedResource()
            }
        }

        @Sendable func load3(url: URL) async throws {
            let started = url.startAccessingSecurityScopedResource()
            if started {
                defer {
                    url.stopAccessingSecurityScopedResource()
                    debugPrint("load3 Closed")
                }
                try Task.checkCancellation()
                await doSomeThing(url)
                try Task.checkCancellation()
                await doAnotherThing(url)
                debugPrint("load3 Finished")
            }
        }

        @Sendable func doSomeThing(_ url: URL) async {
            await Task.sleep(NSEC_PER_SEC)
        }

        @Sendable func doAnotherThing(_ url: URL) async {
            await Task.sleep(NSEC_PER_SEC)
        }

        @Sendable func work() async {
            await Task.sleep(NSEC_PER_SEC)
            debugPrint("Work Done")
        }

        Task {
            do {
                try await load3(url: URL(string: "https://www.baidu.com")!)
            } catch {
                debugPrint("error : \(error)")
            }
        }
        Task {
            defer {
                debugPrint("Defer")
            }
            async let v = work()
        }
    }

    /// Cancellation Handler
    /**
     “在使用 defer 时，只有在异步操作返回或者抛出时，defer 才会被触发。如果我们使用 checkCancellation 在每次 await 时检查取消的话，实际上抛出错误的时机会比任务被取消的时机要晚一些：在异步函数执行暂停期间的取消，并不会立即导致抛出，只有在下一次调用 checkCancellation 进行检查时，才进行抛出并触发 defer 进行资源清理。虽然在大部分情况下，这一点时间差应该不会带来问题，但是对于下面两种情况，我们可能会希望有一种更加“实时”的方法来处理取消”
     1. “需要在取消发生的时刻，立即作出一些响应：比如关键资源的清理，或者想要获取精确的取消时间。”
     2.“在某些情况下，无法通过 checkCancellation 抛出错误时。假如使用的是外部的非 Swift 并发的异步实现 (例如包装了传统的 GCD 实现等)，这种时候原来的异步实现往往不支持抛出错误，或者抛出的错误无法传递到 Swift 并发中，也无法用来取消任务。”

     “这些情况下，我们可以考虑使用 withTaskCancellationHandler。它接受两个闭包：一个是待执行的异步任务 operation，另一个是当取消发生时会被立即调用的闭包 onCancel”
     func withTaskCancellationHandler<T>(operation: () async throws -> T, onCancel handler:@Sendable () -> Void) async rethrows -> T

     1.“这个方法并不会创建任何新的任务上下文，它只负责为当前任务提供一个在取消时被调用的闭包”
     2.“因为对 onCancel 的调用会在任务被取消时立即发生，它可能会在任何时间任意线程上下文被调用，所以 onCancel 接受的函数被标记为了 @Sendable”
     3.“@Sendable 是一个纯编译期间的标记，它作为提示，是对开发者的一种警示，表示被标记的函数可以在并发域之间进行传递，因此该函数只能持有那些跨并发域也安全的数据类型”
     4.“这个标记只作为编译检查，它在运行时并不会有什么作用，
     5.但是如果我们的函数体没有能真的满足 @Sendable,但却被标记为 @Sendable 的话，我们很可能会引入潜在的并发危险”
     6.“有时候 withTaskCancellationHandler 会与 withUnsafeThrowingContinuation 配合使用。后者在将闭包回调的异步操作封装成异步函数时，为了能在任务取消时正确释放某些资源，会用到 onCancel”
     7.“如果没有 withTaskCancellationHandler，我们在封装这种带有“取消”功能的异步操作时，将不得不以轮询的方式，在 continuation.resume 之前去不断检查 Task.isCancelled，这会让取消变得不及时，甚至导致如果新的事件不发生的话，持有的资源就永远无法释放。相比起来，onCancel 给了我们更加正确和优雅的解决方式”
     */

    func testCancellationHandler() {
        class Observer {
            func start() {
                debugPrint("\(#function)")
            }

            func stop() {
                debugPrint("\(#function)")
            }

            func waitForNextValue(completion:@escaping (Result<String, Error>) -> Void) {
                completion(.success("Gogo"))
            }
        }

        @Sendable func asyncObserve() async throws -> String {
            let observer = Observer()
            return try await withTaskCancellationHandler(operation: {
                observer.start()
                return try await withUnsafeThrowingContinuation({ continuation in
                    observer.waitForNextValue { result in
                        switch result {
                        case .success(let value):
                            continuation.resume(returning: value)
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                    }
                })
            }, onCancel: {
                observer.stop()
            })
        }

        Task {
            do {
                let value: String = try await asyncObserve()
                debugPrint("value: \(value)")
            } catch {
                debugPrint("error \(error)")
            }
        }
    }

    /// 异步序列的取消
    /**
     “异步序列协议最重要的部分，就是 AsyncIterator 所定义的 next() async throws 函数。这个函数已经被标记为 throws 了，因此和其他的异步操作一样，我们可以选择在实现 next() 时检查任务是否已经取消，并抛出相应的错误”
     mutating func next() async throws -> Int? {
        try Task.checkCancellation()
        return try await getNextNumber()
     }
     “这样，当通过 for try await 运行的异步序列的 Task 被取消时，在序列中计算下一个元素时，序列将会抛出并终结”
     1.“和普通的异步函数取消相同，对异步序列也还有另一种选择：让 next 返回 nil 使序列正常终结”
     2.“异步序列本身的目的就是产生一系列值，所以相对于抛出错误，这种“正常返回”的处理方式，有时候可能更切合于异步序列的初衷”
     3.“这在无穷序列中更加常见：当任务取消时，序列也随之取消，不再产生新值。这个序列在取消时可能已经产生了部分值，并处理了我们所需要的逻辑。而取消时，如果我们不太关心后续的值，那么选择不抛出错误，代码就可以按照正常路径退出”
      - “异步的 NotificationCenter 方法所给出的异步序列就是典型的例子，它们不会在取消时抛出错误，而只是默默结束序列”
     */
}

// MARK: - “隐式等待和任务暂停”

extension ViewController {
    /// “结构化并发的潜在暂停点”
    /**
     1.“await 代表潜在暂停点。我们需要特别注意在 await 前后，异步函数的执行上下文可能发生变化，这包括任务的取消状态”
     2.“因此，如果我们选择使用 isCancelled 或 checkCancellation 检查任务取消的话，await“会是一个很好的标志”
     3.“在 await 前后对任务的取消状态进行检查，是一种省心省力的做法”
     4.“在结构化并发中，会存在隐式 await 的情况。我们在前面已经说过，在 TaskGroup 中，如果我们没有明确地等待 group 中的任务，它们将会在离开 group 作用域前被隐式等待”
     let t = Task {
        try await withThrowingTaskGroup(of: Int.self) { group in
            group.addTask { try await work() }
            group.addTask { try await work() }
        }
     } catch {
        debugPrint("Error \(error)")
     }
     await Task.sleep(NSEC_PER_SEC)
     t.cancel()

     func work() async throws -> Int {
        try await Task.sleep(nanoseconds: 3 * NSEC_PER_SEC)
        debugPrint("Done")
        return 1
     }
     “运行上面的代码，你既看不到 work 中的 “Done” 输出，也看不到 catch 块中 “Error” 的输出”
     1. “这是因为我们没有明确对 group 进行 try await 操作”
     2.“try await work 只生存在 addTask 内，它的抛出会向上传递到 group 中，但由于我们没有明确地 try await group，这个错误并不会继续传递到 withThrowingTaskGroup 的外层”
     3.“在离开作用域时的隐式等待，会选择自行消化这个错误，而不是进行抛出，这一点并不是特别明显”
     4.“没有完整 await 的 group 所面临的假设和情况，要比完整写出 await 的时候复杂得多”
     5.“不论我们最终需不需要子任务的返回值，都应该保持明确写出对 group 等待操作的好习惯”
     6.“比如，在离开作用域时补上 try await，就可以让 catch 代码块在接收到取消时正确工作”
     do {
        try await withThrowingTaskGroup(of: Int.self) { group in
            group.addTask { try await work() }
            group.addTask { try await work() }
            try await group.waitForAll()
        }
     } catch {
        debugPrint("Error \(error)")
     }
     7.“对于没有使用的 async let 异步绑定值，情况有些类似”
     8.“不过要注意 async let 会直接先取消，再进行隐式等待，这和 group 子任务的行为不同。如果我们确实需要不加取消地执行某个子任务，用样明确地 await 它会是最好的选择”
     9.“不论任务是否已经被取消，在 group 通过 addTask 追加子任务后，子任务将立即开始执行。如果我们不希望在任务已经结束时还创建新的子任务，可以使用 addTaskUnlessCancelled 来在相应的情况下跳过子任务的追加”
      let added = group.addTaskUnlessCancelled { try await work() }
      if !Task.isCancelled {
         group.addTask { try await work() }
      }
     - 9.1 “当子任务是一个非常消耗资源，且不能中途取消的时候，使用 addTaskUnlessCancelled 在很多情况下可以减少资源使用的足迹。”
     - 9.2 “需要特别注意，如果你的代码逻辑依赖于子任务的成功时，相比于使用 addTask，addTaskUnlessCancelled 可能会带来不同的结果”
       - 9.2.1 “使用 addTask，子任务一定会被添加”
       - 9.2.2 “不过，被添加后，由于父任务已经取消这一事实，子任务中如果有 checkCancellation 调用的话，它会被立即抛出，并让整个 group 执行抛出错误”
     - 9.3 “但是，如果在任务已经取消的情况下使用 addTaskUnlessCancelled 的话，任务根本就不会被加入到 group 里，也就不存在任务取消的错误”
       - 9.3.1 “对这样的 group (空的任务组) 进行 await，会得到“正确完成”的结果”
     */

}

