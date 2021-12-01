//
//  ViewController.swift
//  AsyncSequenceDemo
//
//  Created by Lee Danatech on 2021/11/15.
//

import UIKit
import Combine

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //        var iterator = SyncFibSequence().makeIterator()
        //        while let value = iterator.next() {
        //            debugPrint("Fabni \(value)")
        //        }
        
        //        Task {
        //            let asyncFib = AsyncFibnSequence()
        //            for try await v in asyncFib {
        //                if v < 20 {
        //                    debugPrint("Async Fib \(v)")
        //                } else {
        //                    break
        //                }
        //            }
        //            for try await v in asyncFib {
        //                if v < 20 {
        //                    debugPrint("Async Fib \(v)")
        //                } else {
        //                    break
        //                }
        //            }
        //            var asyncIterator = AsyncFibnSequence().makeAsyncIterator()
        //            while let value = try await asyncIterator.next() {
        //                debugPrint("Async Fib Iterator \(value)")
        //            }
        //        }
        
        //        Task {
        //            let asyncFib = ClassFibonacciSequence()
        //
        //            for try await v in asyncFib {
        //                if v < 20 {
        //                    debugPrint("Class Async Fib \(v)")
        //                } else {
        //                    break
        //                }
        //            }
        //
        //            for try await v in asyncFib {
        //                if v < 100 {
        //                    debugPrint("Class Async Fib Continue \(v)")
        //                } else {
        //                    break
        //                }
        //            }
        //        }
        
        //        Task {
        //            let asyncFib = StructAsyncSequence2()
        //
        //            for try await v in asyncFib {
        //                if v < 20 {
        //                    debugPrint("Class Iterator Async Fib \(v)")
        //                } else {
        //                    break
        //                }
        //            }
        //
        //            for try await v in asyncFib {
        //                if v < 100 {
        //                    debugPrint("Class Iterator Async Fib Continue \(v)")
        //                } else {
        //                    break
        //                }
        //            }
        //        }
        
        //        Task {
        //            let asyncFib = BoxedAsyncFibonacciSequence()
        //
        //            for try await v in asyncFib {
        //                if v < 20 {
        //                    debugPrint("Boxed Async Fib \(v)")
        //                } else {
        //                    break
        //                }
        //            }
        //
        //            for try await v in asyncFib {
        //                if v < 100 {
        //                    debugPrint("Boxed Async Fib Continue \(v)")
        //                } else {
        //                    break
        //                }
        //            }
        //        }
        
        //        testOperatorAsyncSequence()
        
        //        testLazySequence()
        
        //        testSideEffectSequence()
        
        //        testSyncTimer()
        
        //        testAsyncTimer()
        
        //        testAsyncTimerCancel()
        
        //        testWait5SecTimer()
        
        //        testCacheAsyncStreamTimer()
        
        //        testUnFoldAsyncStream()
        
        //        testMutiTaskCrashCase()

        testCombineToAsyncStream()
    }
}

/**
 “如果我们希望表达的不是未来某一个时间点的值，而是未来一系列多个时间点的值，会需要使用一种新的表达方式，那就是异步序列 (Async Sequences)”
 */

// MARK: - 异步序列和同步序列
extension ViewController {
    struct SyncFibSequence: Sequence {
        struct Iterator: IteratorProtocol {
            var state = (0, 1)
            mutating func next() -> Int? {
                let upcomingNumber = state.0
                state = (state.1, state.0 + state.1)
                return upcomingNumber
            }
        }
        
        func makeIterator() -> Iterator {
            Iterator()
        }
    }
}

// MARK: - 异步迭代器
extension ViewController {
    /**
     public protocol AsyncSequence {
     associatedtype AsyncIterator: AsyncIteratorProtocol
     func makeAsyncIterator() -> Self.AsyncIterator
     }
     protocol AsyncIteratorProtocol {
     associatedtype Element
     mutating func next() async throws -> Self.Element?
     }
     “任意的两次迭代互相不会产生影响，它们是独立存在的”
     */
    struct AsyncFibnSequence: AsyncSequence {
        typealias Element = Int
        struct AsyncIterator: AsyncIteratorProtocol {
            var currentIndex = 0
            mutating func next() async throws -> Element? {
                defer { currentIndex += 1 }
                return try await loadFibNumber(at: currentIndex)
            }
            
            func loadFibNumber(at index: Int) async throws -> Int? {
                let fibs = [0, 1, 1, 2, 3, 5, 8, 13, 21]
                await Task.sleep(NSEC_PER_SEC)
                return fibs.enumerated().first(where: { $0.offset == index })?.element
            }
        }
        
        func makeAsyncIterator() -> AsyncIterator {
            .init()
        }
    }
}

// MARK: - 引用语义迭代器和单次遍历
extension ViewController {
    // Reference semaintic
    class ClassFibonacciSequence: AsyncSequence {
        
        typealias Element = Int
        
        class AsyncIterator: AsyncIteratorProtocol {
            var currentIndex = 0
            
            func next() async throws -> Element? {
                defer { currentIndex += 1 }
                return try await loadFibNumber(at: currentIndex)
            }
            
            func loadFibNumber(at index: Int) async throws -> Int {
                await Task.sleep(NSEC_PER_SEC)
                return fibNumber(at: index)
            }
            
            func fibNumber(at index: Int) -> Int {
                if index == 0 { return 0 }
                if index == 1 { return 1 }
                return fibNumber(at: index - 2) + fibNumber(at: index - 1)
            }
        }
        
        private var iterator: AsyncIterator?
        
        func makeAsyncIterator() -> AsyncIterator {
            guard let iterator = iterator else {
                let iterator = AsyncIterator()
                self.iterator = iterator
                return iterator
            }
            return iterator
        }
    }
}

// MARK: - 引用语义迭代器和单次遍历
extension ViewController {
    struct StructAsyncSequence2: AsyncSequence {
        
        typealias Element = Int
        
        // reference semaintic
        class AsyncIterator: AsyncIteratorProtocol {
            
            var currentIndex: Int = 0
            
            func next() async throws -> Element? {
                defer { currentIndex += 1 }
                return try await loadFibNumber(at: currentIndex)
            }
            
            func loadFibNumber(at index: Int) async throws -> Int {
                await Task.sleep(NSEC_PER_SEC)
                return fibNumber(at: index)
            }
            
            func fibNumber(at index: Int) -> Int {
                switch index {
                case 0, 1:
                    return index
                default:
                    return fibNumber(at: index - 2) + fibNumber(at: index - 1)
                }
            }
        }
        let iterator: AsyncIterator = AsyncIterator()
        
        func makeAsyncIterator() -> AsyncIterator {
            return iterator
        }
    }
}

// MARK: - 精简asynSequece和AsyncIteratorProtocol 精简, 索引是 reference semaintic
extension ViewController {
    /// reference semaintic
    class Box<T> {
        var value: T
        init(_ value: T) {
            self.value = value
        }
    }
    
    struct BoxedAsyncFibonacciSequence: AsyncSequence, AsyncIteratorProtocol {
        typealias Element = Int
        
        var currentIndex = Box(0)
        
        func next() async throws -> Int? {
            defer { currentIndex.value += 1 }
            return try await loadFibNumber(at: currentIndex.value)
        }
        
        func loadFibNumber(at index: Int) async throws -> Int {
            await Task.sleep(NSEC_PER_SEC)
            return fibNumber(at: index)
        }
        
        func fibNumber(at index: Int) -> Int {
            switch index {
            case 0, 1:
                return index
            case index where index < 0:
                return 0
            default:
                return fibNumber(at: index - 2) + fibNumber(at: index - 1)
            }
        }
        
        func makeAsyncIterator() -> Self {
            return self
        }
    }
}

// MARK: - 操作异步序列
extension ViewController {
    func testOperatorAsyncSequence() {
        Task {
            let seq = StructAsyncSequence2()
                .filter { $0.isMultiple(of: 2) }
                .prefix(5)
                .map { $0 * 2 }
            for try await v  in seq {
                debugPrint("Operate Async Sequence \(v)")
            }
        }
    }
}

// MARK: - Sequence类型和延迟操作
extension ViewController {
    /**
     同步的Sequence 和异步Sequence区别
     extension Sequence {
     fun map<T>(_ transform:(Self.Element) throws -> T) rethrows -> [T]
     }
     
     */
    
    struct FibnacciSequence: Sequence, IteratorProtocol {
        var currentIndex: Int = 0
        typealias Element = Int
        
        mutating func next() -> Int? {
            defer { currentIndex += 1 }
            return fibNumer(at: currentIndex)
        }
        
        func fibNumer(at index: Int) -> Int {
            switch index {
            case index where index < 0:
                return 0
            case 0, 1:
                return index
            default:
                return fibNumer(at: index - 2) + fibNumer(at: index - 1)
            }
        }
    }
    
    func testLazySequence() {
        // let lazySeq: LazySequence<ViewController.FibnacciSequence>
        let lazySeq = FibnacciSequence().lazy
        
        // let mapped: LazyMapSequence<LazySequence<ViewController.FibnacciSequence>.Elements, LazySequence<ViewController.FibnacciSequence>.Element>
        let mapped = lazySeq.map { $0 }
        for v in mapped where v < 100 {
            debugPrint("Lazy Seq \(v)")
        }
    }
}

// MARK: - 异步序列的高价方法
extension ViewController {
    /**
     AsyncSequence 类似 LazySequence
     extension LazySequenceProtocol {
     func map<U>(_ transform: @escaping(Self.Element) -> U) -> LazyMapSequence<Self.Elements, U>
     }
     
     extension AsyncSequence {
     func map<Transformed>(_ transform: @escaping(Self.Element) async -> Transformed) -> AsyncMapSequence<Self, Transformed>
     }
     
     extension AsyncMapSequence: AsyncSequence {
     struct Iterator: AsyncIteratorProtocol {
     var transform:(Self.Element) async -> Transformed
     var baseIter: Base.Iterator
     
     mutating func next() async rethrows -> Transformed? {
     guard let baseValue = await baseIter.next() else {
     return nil
     }
     return await transform(baseValue)
     }
     }
     }
     */
}

// MARK: - 产生和转化新序列
extension ViewController {
    /** 高价函数 filter map prefix -> 新序列  contains first reduce 收敛到一个值 */
    func testAsyncSequence() {
        /// let seq: AsyncMapSequence<AsyncPrefixSequence<AsyncFilterSequence<ViewController.AsyncFibnSequence>>, Int>
        let seq = AsyncFibnSequence()
            .filter { $0.isMultiple(of: 2) }
            .prefix(5)
            .map { $0 * 2 }
        _ = seq
    }
    
    var transformedFibnocciSequence: some AsyncSequence {
        AsyncFibnSequence()
            .filter { $0.isMultiple(of: 2) }
            .prefix(5)
            .map { $0 * 2 }
    }
    
    struct AsyncSideEffectSequence<Base: AsyncSequence>: AsyncSequence {
        typealias Element = Base.Element
        
        private let base: Base
        private let block: (Element) -> Void
        
        init(_ base: Base, block:@escaping(Element) -> Void) {
            self.base = base
            self.block = block
        }
        
        func makeAsyncIterator() -> AsyncIterator {
            return AsyncIterator(base.makeAsyncIterator(), block: block)
        }
        
        struct AsyncIterator: AsyncIteratorProtocol {
            private var base: Base.AsyncIterator
            private var block: (Element) -> Void
            
            init(_ base: Base.AsyncIterator, block:@escaping(Element)-> Void) {
                self.base = base
                self.block = block
            }
            
            mutating func next() async throws -> Base.Element? {
                let value = try await base.next()
                if let tvalue = value {
                    block(tvalue)
                }
                return value
            }
        }
    }
    
    func testSideEffectSequence() {
        Task {
            let seq = AsyncFibnSequence()
                .filter({ $0.isMultiple(of: 2) })
                .prefix(5)
                .print()
                .map { $0 * 2 }
            for try await v in seq {
                debugPrint("Double Side Effect Value \(v)")
            }
        }
    }
}

extension AsyncSequence {
    func print() -> ViewController.AsyncSideEffectSequence<Self> {
        ViewController.AsyncSideEffectSequence(self) {
            debugPrint("Async Side effect value \($0)")
        }
    }
}

// MARK: - 序列求值
extension AsyncSequence {
    /*
     func contains(where predicate: (Self.Element) async throws -> Bool) async rethrows -> Bool
     
     func first(where predict: (Self.Element) async throws -> Bool) async rethrows -> Self.Element?
     
     func reduce<Result>(_ initialResult: Result, _ nextPartialResult:(_ partialResult: Result, Self.Element) async throws -> Result) async rethrows -> Result
     **/
}

extension AsyncSequence {
    func myContains(where predicate: (Self.Element) async throws -> Bool) async rethrows -> Bool {
        for try await v in self {
            if try await predicate(v) {
                return true
            }
        }
        return false
    }
}

// MARK: - AsyncStream
/*
 func load async throws -> [String] {
 try await withUnsafeThrowingContinuation {  continuation in
 load { values, error in
 continuation.resume(returning: values)
 }
 }
 }
 
 struct AsyncStream<Element> {
 init(_ elementType: Element.Type = Element.self, bufferingPolicy limit: BufferingPolicy = .unbounded, _ build: (AsyncStream<Element>.Continuation) -> Viud)
 
 struct Continuation {
 func yield(_ value: Element) -> YieldResult
 func finish()
 }
 }
 **/

extension ViewController {
    func testSyncTimer() {
        let initial = Date()
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            let now = Date()
            debugPrint("Value: \(now)")
            let diff = now.timeIntervalSince(initial)
            if diff > 5 {
                timer.invalidate()
            }
        }
    }
    
    var timerStream: AsyncStream<Date> {
        AsyncStream<Date> { continuation in
            let initial = Date()
            Task {
                // 1
                let t = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                    let now = Date()
                    debugPrint("Call yield")
                    continuation.yield(now)
                    let diff = now.timeIntervalSince(initial)
                    if diff > 5 {
                        debugPrint("Call Finish")
                        continuation.finish()
                    }
                }
                // 2
                continuation.onTermination = { @Sendable state in
                    debugPrint("onTermination: \(state)")
                    t.invalidate()
                }
            }
        }
    }
    
    func testAsyncTimer() {
        Task {
            let timer = timerStream
            for await v in timer {
                debugPrint(v)
            }
        }
    }
    
    func testAsyncTimerCancel() {
        Task {
            let t = Task {
                let timer = timerStream
                for await v in timer {
                    debugPrint(v)
                }
            }
            await Task.sleep(2 * NSEC_PER_SEC)
            t.cancel()
        }
    }
    
    /// 缓冲策略（“如果 for await 没有能及时“消化”这些值的话，它们将被暂时存储到 AsyncStream 的内部缓冲区中”）
    func testWait5SecTimer() {
        Task {
            let timer = timerStream
            await Task.sleep(5 * NSEC_PER_SEC)
            for await v in timer {
                debugPrint("Wait 5 SEC \(v)")
            }
            debugPrint("Done")
        }
    }
    
    func testCacheAsyncStreamTimer() {
        Task {
            let timer = timerStream(bufferingPolicy: .bufferingNewest(3))
            await Task.sleep(5 * NSEC_PER_SEC)
            for await v in timer {
                debugPrint("Cach Async Stream \(v)")
            }
            debugPrint("Done")
        }
    }
    
    func timerStream(bufferingPolicy: AsyncStream<Date>.Continuation.BufferingPolicy) -> AsyncStream<Date> {
        AsyncStream<Date>(bufferingPolicy: bufferingPolicy) { continuation in
            let initial = Date()
            Task {
                // 1
                let t = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                    let now = Date()
                    debugPrint("Call yield: \(continuation.yield(now))")
                    let diff = now.timeIntervalSince(initial)
                    if diff > 5 {
                        debugPrint("Call Finish")
                        continuation.finish()
                    }
                }
                // 2
                continuation.onTermination = { @Sendable state in
                    debugPrint("onTermination: \(state)")
                    t.invalidate()
                }
            }
        }
    }
    
    /// 背压
    /*
     struct AsyncStream<Element> {
     init(unfolding produce: @escaping() async -> Element?, onCancel:(@Sendable() -> Void)? = nil)
     }
     **/
    
    func testUnFoldAsyncStream() {
        Task {
            let timer = AsyncStream<Date> {
                await Task.sleep(NSEC_PER_SEC)
                return Date()
            } onCancel: { @Sendable in
                debugPrint("Unfold Cancelled")
            }
            await Task.sleep(2 * NSEC_PER_SEC)
            for await v in timer {
                debugPrint("unfold value \(v)")
            }
        }
    }
    
    /// 总结
    /// 1.“with*Continuation 中要求 continuation 的 resume 调用且仅调用一次，来表征异步函数从续体中以成功或者失败的结果继续，多次调用 resume 将导致意外行为”
    /// 2.“AsyncStream 的用法。其中 continuation 的 yield 可以被多次调用以产生若干序列值。通过调用 continuation 的 finish 方法，则可以终结一个序列。不过，在 AsyncStream 终结后，你依然可以继续使用 yield 发送数据”
    /// 3.“调用 finish 方法或者取消运行序列的任务，都会让序列续体进入到完结状态。之后的 yield 并不会将数据写入缓冲区，而是直接返回 .terminated 来告诉 AsyncStream 已经完结了”
    /// 4.“除了 onTermination 外，也可以通过这个 yield 的 .terminated 返回来进行资源的清理工作”
    /// “但是这样做会导致清理工作依赖于终结后的下一次事件，让待清理的资源的生命周期变长，因此并不推荐这么做”
    /// 5.“AsyncStream 本身是 struct，但为了保证单次遍历，它的内部使用了引用语义的 class 作为存储，来对序列的当前状态进行维护。在调用 continuation 上的方法时，实际上是对这个状态进行检查和设置。这涉及到用锁进行数据同步，也是这些方法可以随意调用的代价”
    /// 6.“事实上，在创建一个 AsyncStream 时，我们应该尽量避免在序列完结后再次发送数据的行为”
    /**
     “下面的代码是完全合法的”
     contination.yield(Date())
     contination.yield(Date())
     contination.yield(Date())
     contination.finish()
     /// “序列结束后再次 yield”
     let result = contination.yield(Date())
     // result: YieldResult.terminated
     */
}

// MARK: - 多任务迭代
extension ViewController {
    /// 1.“在使用 AsyncStream 时要注意，我们不能在多个任务上下文中对同一个序列进行迭代。如果这种情况发生，将会带来运行时崩溃”
    /// 2. “AsyncStream 的内部实现使用了互斥锁来防止多个线程同时访问缓冲区和内部状态”
    /// 3.“这保护了续体的独占性：同时只有一个任务可以获取 AsyncStream 暂停时提供的续体，并向其询问和获取下一个元素”
    /// 4.“如果其他任务同时访问并希望序列向前迭代，会因为无法获得已经被占用的续体，而产生错误。这保证了序列的单向特性和安全”
    /// 5. “在实际开发时，保证不在任务之间共享序列，是使用异步序列的一个原则”
    func testMutiTaskCrashCase() {
        let timer = timerStream
        Task.detached {
            for await v in timer {
                debugPrint("Task 1 \(v)")
            }
        }
        Task.detached {
            /// Fatal error: attempt to await next() on more than one task
            for await v in timer {
                debugPrint("Task 2 \(v)")
            }
        }
    }
}

// MARK: - 异步序列和响应式编程
extension ViewController {
    /// “AsyncSequence 和 AsyncStream 替代 Combine”
    /// “异步序列和 Combine 框架中的 Publisher 十分相似”
    /// “在原理上两套体系确实相似，也能够进行部分有效替代”
    /// “区别不仅体现在它们提供的 API 的不同所导致的具体处理方式的不同，也体现在从根源开始的设计理念的差别”

    /**
     Combine的转换
     1.“AsyncStream 允许我们将一系列事件 (包括正常事件值、结束、以及错误) 通过续体的形式转换为一个异步序列”
     2.Combine 框架“其中的 Publisher 也正代表了这样一个事件流”
     3.“因为它们所代表的数据模型一致，所以将任意 Publisher 转换为异步序列是轻而易举的，只需要用 AsyncStream 进行简单包装即可”
     */

    func testCombineToAsyncStream() {
        Task {
            let stream = Timer.publish(every: 1, on: .main, in: .default)
                .autoconnect()
                .asAsyncStream
            for try await v in stream {
                debugPrint("Combine to AsyncStream \(v)")
            }
        }
    }
}

extension Publisher {
    var asAsyncStream: AsyncThrowingStream<Output, Error> {
        AsyncThrowingStream(Output.self) { continuation in
            let cancellable = sink { completion in
                switch completion {
                case .finished:
                    continuation.finish()
                case .failure(let error):
                    continuation.finish(throwing: error)
                }
            } receiveValue: { output in
                continuation.yield(output)
            }
            continuation.onTermination = { @Sendable _ in
                cancellable.cancel()
            }
        }
    }
}

// MARK: - 异步序列的错误处理
extension ViewController {
    /**
     “Combine 的 Publisher 通过 associatedtype 的方式，明确地规定了可能值 Output 和错误值 Failure 的类型”
     “对使用 Operator 进行组合，或者使用 Subscriber 进行订阅时，除了要求可能值的类型一致外，也要求错误值的类型相互匹配”
     “对于错误类型的转换，Combine 中也提供了诸如 mapError 和 setFailureType 这类专门处理错误类型的操作”
     “在 Combine 的世界中，所有的错误都是被严格对待的，它们的类型至关重要，且被编译器强制保证”
     “Swift 函数，包括异步序列，在遇到错误时都是使用 throw 来进行的。想要一个异步序列支持错误处理，我们会使用支持错误抛出的 AsyncThrowingStream”.
      struct AsyncThrowingStream<Element, Failure> where Failure: Error {
      }

     “虽然泛型类型中定义了 Failure，但是它只在内部通过 finish(throwing:) 时被使用。对于序列的使用者来说，在使用 for try await 捕获错误时，并不能体现出 Failure 类型的作用，Swift 的 catch 捕获的都是一般性的 Error”:
      let s:AsyncThrowingStream<Int, MyError>
      do {
        for try await v in s {}
      } catch {
          if let myError = error as? MyError {}
      }
     “在 catch 中，将捕获的 error: Error 转换为实际的 MyError，需要一个 if let 绑定。而且这个转换并没有很强的编译器保证：即使 s 类型的错误类型在之后变成了其他类型，使用侧的代码依然能够无警告地编译通过。这时 catch 中的这个转换将会失败，这让我们非常容易在重构或者外部库升级时错过应有的处理”
     “究其原因，这在于 throw 永远不会抛出一个具体的 Error 类型”
     **/
}

// MARK: - 调度和执行
extension ViewController {
    /**
     “涉及到执行方式和时间维度时”
     1.“Combine 使用 Scheduler 协议进行抽象。通过指定调度器 (scheduler)，Combine 实现了一系列有关时间的操作 (比如 delay、debounce 和 throttle 等)，并可以在下游指定谁应该接收事件 (使用 receive(on:options:))”
     2.“通过调度器，Combine 可以很灵活地组“织和自定义异步事件的行为”
     3.“异步序列的调度和执行就要僵硬一些”
     4.“包括异步序列在内的异步函数必须在某个任务中运行，而在什么时间什么线程上运行这些任务，则是由内部的执行器 (executor) 来决定”
     5.“Swift 的并发模型提供了几种默认的内建执行器，它们的主要目标是保证续体切换的性能或者保证数据安全”
     6.“现在 Swift 并发还不支持自定义执行器，所以我们没有太多方法来干涉异步序列的执行方式。对于很多 Combine 中内建存在的 Publisher 或者轻而易举就能实现的事件流，在异步序列中实现起来可能要困难一些”
     7. “Combine 更擅长于将不同的事件流进行变形和合并，生成新的事件流：它的重点在于为响应式编程范式提供工具”
     5.“Swift 异步序列的侧重点有所不同，更多时候，它服务于任务 API 及 actor，用来解决并发编程中的痛点”
     */
}


