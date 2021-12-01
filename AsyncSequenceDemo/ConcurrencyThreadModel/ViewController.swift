//
//  ViewController.swift
//  ConcurrencyThreadModel
//
//  Created by Lee Danatech on 2021/12/1.
//

import UIKit

class ViewController: UIViewController {
    let sQueue = DispatchQueue(label: "Serial-queue")

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        //        testThreadExplosion()

        //        testThreadExplosion2()

        //        testAsyncThreadModel()

        //        testBlockBadCode()

        //        testTaskWait()

        //        testTaskPriority()

        //        testRunBlocking()

        //        testTaskHang()

        //        testTaskPriorityDiff()

        testLocalSetValue()
    }
}

// MARK: - 并发线程模型
/**
 “并发本身的目的是更高效地完成多个任务。在前面的章节中，我们已经看到为了达成这个目的，Swift 并发提供了三种工具”
 1.“异步函数可以帮助我们写出简单的异步代码，Swift 并发中很多 API 也都是通过异步函数提供的”
 2.“通过组织结构化并发，可以保证任务的执行顺序、正确的生命周期和良好的取消操作”
 3.“利用 actor 和 Sendable 等，编译器能保证数据的安全”
 */

// MARK: - 协同式线程池
/**
 1. “在 Swift 并发中，我们其实很少直接用“线程”的概念，这是因为组织和运行异步函数的单元并非线程”
 2. “相比起说“一个同步函数运行在某个线程中”，对于异步函数，我们经常看到的描述是“一个异步函数运行在某个任务中”
 3. “线程之于同步函数，就如任务之于异步函数”
 4.“虽然在最终，一段代码，无论它位于同步函数中还是异步函数中，都必须由某个具体线程来运行。但是和始终运行在同一个线程上的同步函数不同，异步函数可能被 await 分割，并由多个不的线程协同运行”
 5.“Swift 并发在底层使用的是一种新实现的协同式线程池 (cooperative thread pool) 的调度方式：由一个串行队列负责调度工作，它将函数中剩余的运行内容被抽象为更轻量的续体 (continuation)，来进行调度”
 6.“实际的工作运行由一个全局的并行队列负责，具体的工作可能会被分配到至多为 CPU 核心数量的线程中去”
 7.“需要强调的是，协同式线程池之所以要限制线程数量，是为了避免线程级别的切换，进而避免性能问题”
 8.“具体来说，Swift 并发中的续体代表了一个运行时的状态包，await 将函数的剩余部分“注册”为一个续体并暂存起来，然后在某个工作线程执行当前的语句”
 9.“Swift 并发的运行时可以轻易地在多个续体间进行切换，它更像一个轻量级的线程”
 10.“在其他支持并行的语言中，也有类似 (但不完全一样) 的概念，比如 Go 中的 Goroutines，Rust 的 tokio 中的 task 或者 Crystal 的 fiber。”
 11.“我们有时候也会用绿色线程 (green thread)、协程 (coroutine) 或者纤程 (fiber) 来称呼这些概念”
 12.“虽然它们的涵盖范围略有不同，但是核心是一致的：它们提供一种和系统级别的线程不一样的，更轻量的调度方式。在续体间切换的性能消耗，与普通的方法调用可以等价。这种续体切换要比在线程间进行切换容易得多”

 */

// MARK: - “线程切换和线程爆炸”
/**
 1.“在 Swift 并发被引入之前，GCD 是最主流的线程调度方式：它以“抢占式”的方式管理一个线程池，在需要的时候，GCD 会尝试从线程池里获取已经创建但闲置的线程，但如果有需要或者线程池中已经没有可用线程时，它则会尝试创建新的线程”
 2.“一个线程可能会被耗时操作占用或者需要等待某个锁，此时这个线程就处于被阻塞的“不可被分配”状态。这种时候，有新任务需要处理时，新的线程将被创建，并分配给某个 CPU 核心去执行新任务中的指令。”
 3.“理想状况下，如果正在运行的线程数小于或等于 CPU 的核心数，那么每个线程会被分配到一个它单独占有的核心上，这个 CPU 核心可以“专心地”运行和处理该线程中的指令。不过，如果线程数量超过了核心数的话，新创建的线程将会被分配给已经正在运行其他线程的核心。这时，一个 CPU 核心将会同时处理两个或更多的线程。”
 4.“传统意义上，线程是操作系统进行运算调度的最小单位。线程们可以共享它所在进程中的内存堆等资源，同时它也拥有属于自己的一些资源：比如调用栈，自己的寄存器环境，以及动态申请的栈空间上的内存等。”
 5.“CPU 核心只是一个简单的指令执行器，在同一个 CPU 核心上同时执行两个线程的事实，决定了需要通过时分复用的策略让这两个线程共享 CPU 核心的计算资源，这也意味着在运行不同线程时，执行环境需要从一个线程切换到另一个线程。”
 6.“这种切换涉及了整个线程资源的切换，包括像是寄存器、栈指针和栈内存等。它相对轻量，但是也还是需要消耗时间：”
 7.“在 GCD 中，调度库对并行队列和串行队列能够创建的线程总数是有限制的。不同的运行环境下限制会有不同，以当前已发布的最新 iOS 系统 (iOS 15) 和最新的硬件环境 (iPhone 13) 来说，单个并行队列最多可以创建 64 个线程，而串行队列可以创建 512 个线程。移动设备的 CPU 核心数和内存容量都是有限的，它们无法承载无限多的线程，这也是 Apple 在文档中要求我们避免创建过多线程的原因。”
 - “在 iOS 中，主线程的栈内存空间为 1 MB，其他次级线程的内存空间为 512 KB。如果我们不加限制地让 GCD 创建新线程，这些线程所占用的栈内存空间也将急速上升。一对串行队列和并行队列达到 GCD 限制时，栈内存就将占用到接近 300 MB。考虑到程序中有可能存在多个队列的事实，最后这会是一个不容忽视的数字。”
 8.“太多线程不仅意味着更多的内存压力，更严重的是，这些线程在有限的 CPU 核心上的运行，会伴随着非常多的线程上下文切换。有时候，相比于实际执行我们需要的指令，这些切换所耗费的资源和时间反而成了主要部分”
 9.“这种由于线程被阻塞的同时，又不断有新的任务被以 async 方式提交到并行队列，并造成过多新线程创建的行为，我们把它成为线程爆炸 (thread explosion)”
 10.“线程爆炸造成了过多的线程上下文切换，是传统并发编程中导致性能退化的重要原因之一”
 11.“在 GCD 中，调度库对线程数量进行了限制，相比于直接使用 NSThread 的 API，通过 GCD 进行调度已经为性能优化带来了很大改善，但这并不十分理想：作为开发者，我们依然需要把精力分配给线程创建这样的细节，特别是在 GCD 中，线程的分配和创建细节是被隐藏起来的，稍不留意就可能造成问题。”
 */

/**
 “下面的一段代码会造成典型的线程爆炸。由于 sQueue 被阻塞，导致并行队列 .global() async 所调用的闭包无法及时完成，新的 async 将一直创建新的线程，直到上限”
 “如果在运行期间，你使用 Xcode 的 debugger 暂停按钮，可以在调试面板中看到所有的运行中的线程。用对应的 LLDB 命令 thread list 也能得到同样的结果”

 1.“在 Swift 并发中，Apple 对线程调度进行了进一步的封装，把“线程”的概念整个隐藏到了幕后”
 2.“但实际上，不论是 Task 相关结构化任务 API 的调度，还是 actor 隔离域之间的切换，在幕后都会涉及到执行线程的问题。”
 3.“甚至可以说，如果不对现有的线程调度方式进行革新，想要支撑 Swift 并发的新一套 API，在底层可能会带来更多的潜在的线程切换的机会。”
 4.“这种切换带来的性能上的问题，将会摧毁 Swift 并发被大规模使用的可能。为此，Apple 需要一套相应的手段来避免线程爆炸和它所带来的问题”
 */

extension ViewController {
    func testThreadExplosion() {
        // “下面的一段代码会造成典型的线程爆炸。由于 sQueue 被阻塞，导致并行队列 .global() async 所调用的闭包无法及时完成，新的 async 将一直创建新的线程，直到上限”
        for i in 0..<10000 {
            DispatchQueue.global().async {
                debugPrint("Start \(i)")
                self.sQueue.sync {
                    Thread.sleep(forTimeInterval: 0.1)
                    debugPrint("End \(i)")
                }
            }
        }
    }
}

// MARK: - “非阻塞线程约定”
/**
 1.“为了解决线程爆炸的问题，似乎最直截了当的方法是人为限制线程数量，让调度系统不创建多于 CPU 核心的线程数。GCD 现在似乎已经为我们把并发队列的线程数限制为 64 了”
 2.“那是不是进一步限制到 6 或者 8 就能解决问题？答案是否定的”
 3.“其实当前 GCD 对线程数量的限制，是一种迫不得已的权衡”
 4.“线程爆炸的核心原因在于串行队列的线程被阻塞，进而使并行队列线程进入等待，导致 CPU “空闲”。在这个前提下，GCD 倾向于创建更多线程来让 CPU 继续工作”
 5.“另一方面，有时候被某个线程持有的资源 (比如某个信号量) 可能会在其他线程被释放，足够的线程数可以保证程序不被永远挂起。在线程数太少时，这种挂起将更容易发生。”
 */

/**
 “比如在刚才上面的代码例子中，改为用 DispatchSemaphore 控制程序执行的话”
 “当 count 为 10 时，GCD 会为设置信号的并发队列的 async 分配十个线程。接下来在发送信号时，GCD 创建新的可用线程，来发送这些信号，此时 semaphores[i].wait() 所造成的等待会依次结束，sQueue 得以继续执行并最终输出 End”

 不过，如果我们把 count 修改一下，比如当它是一个大于 63 的值时，我们就看不到任何 End 的输出了”
 “前 64 个派发的闭包被分配到了各自的执行线程上，但它们永远卡在了等待信号上：因为这些发出信号的工作自身也在等待可以使用的线程，但所有可用线程都在等待信号，新的可用线程将永远不会出现。这类问题会非常难调试，还可能随着运行环境的不同而产生不同的现象”
 1.“不仅是信号量，像是锁或者其他一些同步手段，在跨越线程进行操作时，都有可能让线程产生这种滞止现象。当可用线程数较少时，这种情况就尤为严重”
 2.“为了避免在同一个 CPU 核心上进行线程切换，我们又想要较少的线程数。在传统 GCD 模型下，这是一对难以调和的矛盾。”
 3.“线程爆炸的最本质原因是串行队列线程的阻塞，因此，如果我们能找到一种办法，让串行队列不会阻塞的话，就能确保各并发线程都不会因为要等待串行线程而停滞，那么我们就可以实现一种用较少线程调度所有工作的方式”
 4.“这种新的调度方式就是 Swift 并发中加入的协同式线程池，而非阻塞线程的约定则是实现这种调度方式并令其保持高效运转的重要前提，也是异步函数得以实现的基础。”
 */
extension ViewController {
    func testThreadExplosion2() {
        // 申请多个个DispatchSemaphore
        // “不过，如果我们把 count 修改一下，比如当它是一个大于 63 的值时，我们就看不到任何 End 的输出了”
        let count = 64
        let semaphores = [DispatchSemaphore](repeating: .init(value: 0), count: count)

        // 设置信号等待
        for i in 0..<count {
            DispatchQueue.global().async {
                debugPrint("Start\(i)")
                self.sQueue.sync {
                    semaphores[i].wait()
                    debugPrint("End\(i)")
                }
            }
        }

        // 发送信号
        for i in 0..<count {
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
                // 在其他线程向信号量发送信号
                semaphores[i].signal()
            }
        }
    }
}

// MARK: - “协同式调度线程模型”
/**
 1.“Swift 并发在所有平台上底层都还是使用 GCD 进行调度，但是这并不是旧版本系统搭载的原味 GCD 库，而是一个带有全新的协同式实现的闭源版本”
 2.“除非设定了 @MainActor，否则我们通过 Task API 提交给 Swift 并发运行的闭包，都会交给一个 cooperative 的串行队列进行处理”
 3.“为了能把线程数控制在设备上 CPU 的核心数以内，我们不能让 cooperative 串行队列对应的线程被阻塞”
 4.“运行在这个线程上的异步函数需要具有放弃线程的能力，这样该线程才能保持向前，去执行其他操作”
 5.“为了做到这一点，协同式队列的调度需要具有额外的能力，把还未执行的函数部分和必要的变量包装起来，作为续体暂存到其他地方 (比如堆上)”
 6.“然后等待空闲的线程去执行
 7.“Swift 并发的调度器会组织这些续体，让它们在线程上运行”
 */

class Sample {
    func bar1() {}
    func bar2() async {}
    func bar3() async {
        await baz()
    }
    func baz() async { bar1() }
    func foo() async {
        bar1()
        await bar2()
        await bar3()
    }

    func method() {
        Task {
            await foo()
        }
    }
}

extension ViewController {
    func testAsyncThreadModel() {
        Sample().method()
    }
}
/**
 1.“当某个线程执行 method 时，Task.init 首先被入栈，它是一个普通的初始化方法，在执行完毕后立即出栈，method 函数随之结束。通过 Task.init 参数闭包传入的 await foo()，被提交给协同式线程池，如果协同式调度队列正在执行其他工作，那么它被存放在堆上，等待空闲线程”
 2.“当有适合的线程可以运行协同式调度队列中的工作时，执行器读取 foo 并将它推入这个线程的栈上，开始执行。需要注意的是，这里的“适合线程”和 method 所在的线程并不需要一致，它可能是另外的空闲线程：”
 3.“foo 中的第一个调用是一个同步函数 bar1。在异步函数中调用同步函数并没有什么不同，bar1 将被作为新的 frame 被推入栈中执行”
 4.“当 bar1 执行完毕后，它对应的 frame 被出栈，控制权回到 foo，准备执行其中的第二个调用 await bar2()”
 5.“接下来我们会在这个线程中执行到 await bar2()，它是一个异步函数调用。为了不阻塞当前线程，异步函数 foo 可能会在此处暂停并放弃线程。当前的执行环境 (如 bar2 和 foo 的关系) 会被记录到堆中，以便之后它在调度栈上继续运行。此时，执行器有机会到堆中寻找下一个需要执行的工作。在这里，我们假设它找到的就是 bar2。它将被装载到栈上，替换掉当前的栈空间，当前线程就可以继续执行，而不至于阻塞了”
 6.“当然，执行器也有可能寻找到其他的工作 (比如最近有优先级更高的任务被加入)，这种情况下 bar2 就将被挂起一段时间，直到调度栈有机会再次寻找下一个工作。不过不论如何，串行调度队列都不会停止工作。它要么会去执行 bar2，要么会去执行其他找到的工作，唯独不会傻傻等待”
 7.“当 bar2 执行完毕后，它被从堆上移除。因为在执行 bar2 前，我们在堆上保持了 foo 和 bar2 的关系，因此在 await bar2() 结束后，执行器可以从堆中装载 foo，并发现接下来需要运行的指令。在我们的例子中，await bar3() 将被运行。和 bar2 时的情况类似，底层调度使用 bar3 替换掉栈的内容，并继续在堆上维护返回时要继续执行的续体”
 8.“需要注意，await bar2() 前后代码可能会运行在不同线程上，除非指定了 MainActor，否则协作式调度队列并不会对具体运行的线程作出保证。”
 9.“bar3 中的第一个调用是 await baz()。这是一个在异步函数中调用其他的异步函数的情况，实质上它的情况和 foo 中调用 await bar2() 或 await bar3() 是相同的。baz 会替换调度队列所对应的线程的栈”
 10.“在这个栈中，同步方法 bar1 的调用依然在当前栈上进行普通的入栈和出栈”
 11.“在异步函数定义的栈上调用同步函数，所执行的是普通的出入栈操作。因此在 Swift 异步函数中，我们是可以透明地调用 C 或者 Objective-C 的同步函数的。在底层，这种调用就是普通的同步调用”
 12.“当 baz 完成后，执行器从堆中找到接下来的续体部分，也就是 bar3，并将它替换到某个线程的栈中。”
 13.“虽然已经多次说明，但笔者依然想再强调一次，此时 bar3 的执行线程可能会和 baz 不同，也可能和 bar3 最早的执行线程不同”
 14.“我们不应该对具体的执行线程进行任何假设”
 15.“最后，bar3 的执行也结束了，执行器最终寻找到一开始的 foo，并最终完成整个 Task 的执行”
 */

// MARK: - “异步线程模型小结”
/**
 1.“调度库将续体暂存在堆上，并在需要的时候用它“替换”掉调度队列线程的运行栈”“是异步函数拥有放弃线程能力的基础。”
 2.“在调度线程空闲时 (比如 await 后)，执行器会为它寻找接下来需要处理的指令，这个指定可能是 await 所需要执行的部分，也可能是和之前完全不相关的其他任务”
 3.“和传统 GCD 调度的资源抢占式不同，这种调度方式通过协作的方式，由执行器、需要处理的工作和调度队列一同，来保证线程向前运行，这也”
 */

// MARK: - “调度队列的阻塞”
/**
 1.“非阻塞队列是协同式调度的基础，因此任何破坏这个假设，并让该调度队列阻塞的操作，都可能导致 Swift 并发的性能退化甚至是完全卡死”
 2.“Swift 在语言层面上，使用 await 和 Task 相关的 API 来在编译期间保证非阻塞线程的约定：当我们在使用这些语言特性时，线程模型可以在堆上追踪执行工作所需的依赖，并按需替换栈上内容，保持线程在某个方法暂停后，能找到接下来的工作并继续执行。”
 */

// MARK: - 锁
// “像 NSLock 这样的锁，在不跨越 await 的前提下，是安全的。比如要保护非 actor 实例中的变量。考虑下面的代码”
class ACls {
    private let lock = NSLock()
    var value: [Int: Int] = [:]

    func foo() {
        Task.detached {
            self.lock.lock()
            self.value[1] = 100
            self.lock.unlock()
        }
    }

    func bar() {
        lock.lock()
        value[1] = 0
        lock.unlock()
    }
    func baz() async {
        try? await Task.sleep(nanoseconds: 100)
    }
}
/**
 “上面的代码中，实例变量 values 存在被多个线程同时修改的风险，必须采取合理的数据同步手段。没有加锁的话，多线程下对它的调用将导致崩溃”
 */
extension ACls {

    func foo2() {
        Task.detached {
            self.value[1] = 100
            await self.baz()
            debugPrint("Task Done")
        }
    }

    func method2() {
        let a = ACls()
        for i in 0..<10000 {
            // 数据竞争导致crash
            DispatchQueue.global().async {
                a.foo()
                a.foo2()
            }
        }
    }
}

/**
 1.“最好的解决方式当然是把整个类型改为 actor，依靠编译器来保证读写的单一性。但是如果由于某些原因，我们不得不用锁来让实例达到线程安全的话，
 则必须保证 lock() 和 unlock() 的调用发生在 await 同一侧”
 2.“如果无法遵守这个约定，那么在协同式调度队列的线程第一次 await 完成替换后，lock 还处于锁定状态，接下来在同一个线程可能会去执行的其他任务 (比如第二次 foo())，由于要等待 lock 资源，这可能会让调度线程处于阻塞状态，从而其他所有任务也都无法继续执行。因此，我们应该杜绝这样的代码：”
 class A {
 func foo() {
 Task.detached {
 self.lock.lock()
 self.values[1] = 100
 await self.baz()
 //危险，可能永远无法执行
 self.lock.unlock()
 }
 }
 }
 */

// MARK: - 信号量
/**
 1.“和锁不同的是，由 DispatchSemaphore 或 NSCondition 代表的信号量在 wait 时将无条件直接阻塞当前的线程”
 2.“在协同式调度的上下文中，调度线程被信号量阻塞，意味着直到某个其他线程发出信号前，这个协同调度都将无法执行其他操作”
 3.“这样一来，调度队列线程是否能够运行，将取决于某个完全无法预先确定的其他线程的行为”
 4.“除非经过非常精心的同步设计，否则使用信号量大概率会导致调度线程不再工作，从而违反非阻塞线程的约定”
 */

// MARK: - “耗时的同步函数”
/**
 1.“不应该在调度线程中执行长耗时的同步任务：比如大的 I/O 或者其他可能长时间占用线程的操作”
 2.“这些操作虽然不会导致调度线程完全停滞不前，但是在串行队列线程中执行这样的操作，无疑将会拖慢其他并发任务的调度，使并发性能退化”
 // 避免类似这样的代码
 func blockingMethod() async -> Bool {
 Thread.sleep(forTimeInterval: 1)
 return true
 }
 for _ in 0..<10000 {
 Task {
 _ = await blockMethod()
 debugPrint("Done")
 }
 }
 // 所有 `blockingMethod` 执行完毕需要一万秒，而不是一秒！
 1.“在这个例子中，我们使用了 Thread.sleep 来让线程休眠，来模拟可能阻塞线程的操作。
 2.要注意，Thread.sleep 和 Task.sleep 是完全不一样的：后者将通过派发把一个用于等待的工作添加到调度队列中，而不是阻塞当前线程”
 3.“对于系统 SDK 给出的异步函数，比如 Task.sleep 或者 URLSession 中的异步函数版本，在它们内部实现中，具体工作被转换为可以被执行器处理的对象并提交给执行器”
 4.“随后执行器在协同式线程池中为它寻找合适的工作线程 (这通常是一个并行队列管理的线程) 并进行执行”
 5.“对于一般的同步函数定义的耗时工作 (比如直接通过 URL 初始化数据的 Data.init(contentsOf:options:) 这类方法)，我们暂时还没有办法将它直接提交给执行器并纳入到协同式线程调度的系统中。”
 6.“因此，在串行调度队列中，我们需要小心处理这样的耗时操作”
 */

extension ViewController {
    func testBlockBadCode() {
        @Sendable func blockMethod() async -> Bool {
            Thread.sleep(forTimeInterval: 1.0)
            return true
        }

        for _ in 0..<10 {
            Task {
                _ = await blockMethod()
                debugPrint("Done")
            }
        }
    }

    func testTaskWait() {
        @Sendable func blockMethod() async -> Bool {
            await Task.sleep(NSEC_PER_SEC)
            return true
        }

        for _ in 0..<10 {
            Task {
                _ = await blockMethod()
                debugPrint("Wait Done")
            }
        }
    }
}

// MARK: - 执行器
/**
 1.“非阻塞线程的保证解决了如何有效进行异步和并发调度的问题”
 2.“Swift 并发底层的另一个模块，执行器 (executor)，则实际负责创建线程并保证接受协同式调度的线程不多于 CPU 核心数”
 3.“当前 Swift 并发提供了两种类型的执行器：一种是全局的并发执行器，它负责寻找合适的并发队列来为并发操作提供线程；另一种是串行执行器，它主要被用在 actor 中。”
 4.“每个 actor 会持有一个串行执行器，它负责保证 actor 隔离域的方法在串行队列中执行。”
 */

// MARK: - “全局并发执行器”
/**
 1.“全局并发执行器对 Swift 并发高层 API 来说，是完全被隐藏的，它是 Swift 并发库中由 C++ 进行实现的部分，高层 API 无法对它进行直接调用。想要使用它，只能在 SIL 或更底层完成，对于 app 开发者来说，这是很难做到的”
 2.“为了合理地管理线程数，在运行时全局只有一个这样的并发执行器。”
 3.“通过 Task API 提交的任务以及调度队列中加入的任务，都将由协同式线程池的调度队列进行派发。”
 4.“不同于传统的 GCD，这是一个基于 GCD 的闭源实现。当协同式线程池中出现空闲线程时，这些工作将被并发队列实际分配给线程池中的线程进行运行。”
 5.“协同式线程池是 Apple 的新版本系统的一部分。在像是 Windows 或者 WSAM 等非 Apple 的目标平台上，这个行为会有所不同。在这些不带有新的协同式线程池的环境中，执行器自己管理一个链表，并使用传统的派发方式进行调度。如果你面向不同平台开发，需要注意这可能将会导致并发代码性能的差异”
 */

// MARK: - “Actor 执行器”
/**
 “除了隐藏起来的全局并发执行器外，Swift 并发还定义了另一种执行器：它们是串行的执行器”
 “为了方便今后自定义执行器，Swift 在 5.5 中把执行器的协议暴露出来了”
 public protocol Executor: AnyObject, Sendable {
 func enqueue(_ job: UnownedJob)
 }
 “执行器协议需要做的事情只有一件：决定一项工作要如何被加入到执行器管理的队列中”
 “Actor 中使用的串行执行器则是 Executor 一种细分协议”
 public protocol SerialExecutor: Executor {
 func enqueue(_ jobL UnownedJob)
 func asUnownedSerialExecutor() -> UnownedSerialExecutor
 }

 “每个 actor 都会拥有一个对串行执行器的引用”
 public protocol Actor: AnyObject, Sendable {
 nonisolated var unownedExecutor: UnownedSerialExecutor { get }
 }
 “在用 actor 关键字声明一个 actor 类型时，实际编译器会在 actor 的 init 和 deinit 中为我们加上对应的执行器初始化代码”
 actor MyActor {
 //等效编译为
 init() {
 ...
 _defaultActorInitialize(self)
 }
 deinit {
 ...
 _defaultActorDestroy(self)
 }
 }

 1.“每个在 actor 隔离域外对 actor 的调用，会被转换为一次执行器的 enqueue，来将需要的操作作为“消息”加入到队列“信箱”中”
 2.“执行器负责通过协同式线程池以串行方式为这些工作分配合适的线程。”
 3.“在实际中，除了 MainActor 需要被派发到主线程外，大部分情况下 actor 的执行会直接使用上面提到的负责协同调度的串行队列进行，这样可以避免线程切换以提高性能”
 4.“不过我们在高层级上依然不应该进行这个假设，一方面是因为实现细节可能会改变，另一方面同一段代码的运行环境的改变 (比如被移动到了 MainActor 中)，也可能让这个假设失效”
 5.“由于可能会影响调度线程，因此在 actor 的方法中，我们也不应该进行繁重的同步调用。这种耗时的同步工作依然有可能造成 Swift 并发性能的退化，甚至让其他任务无法运行。”
 */


// MARK: - “GCD 代码性能”
/**
 1.“在串行调度队列中，我们提到了应该避免耗时的同步调用。如果能够把这些同步调用进行封装，并传递给全局执行器让它负责将这些调用通过并发队列派发到各个工作线程的话，我们就可以解决这个问题。”
 2.“但不幸的是，这个派发方法现在还不对外部开发者开放。在本书写作时，Swift 已经拥有一个自定义执行器的提案，但是它还没有被正式接受和实现。”
 3.“上面的 Executor 协议虽然在事实上规定了一些实现执行器所需要的方法，但是我们还不能真正使用它们。”
 4.“在今后，如果自定义执行器的特性被加入 Swift 并发的话，我们也许可以使用这样的代码来将一个耗时的同步任务提交给协同式线程池进行调度”
 // 当前还不可用 2021.12.1
 await globalExecutor.run {
 someHeavyMethod()
 }
 5.“现在，在遇到这种情况时，我们的常见做法是使用 withUnsafeContinuation 或 withCheckedContinuation 来把它们封装起来。我们在早先刚介绍异步函数的章节中已经看到过这两个方法了。不过需要特别注意，这两个方法的闭包依然是运行在串行调度队列中的。所以，为了避免阻塞，一般我们还是会选择使用 GCD 直接进行调度”
 await withUnsafeContinuation { continuation in
 DispatchQueue.global().async {
 let result = someHeavyMethod()
 continuation.resume(returning: result)
 }
 }
 6.“在 Swift 并发中直接用到 GCD 其实并非罕见：除了这种情况以外，更多时候我们可能会需要把原有的 GCD 代码迁移到异步函数。”
 7.“使用 continuation 来对 GCD 的调度进行包装是一个有效的方法，但不幸的是，这种包装所造成的线程调度，并不会被自动“转换”到协同式线程池中，而会保持是一个“原汁原味”的 GCD 调用。”
 8.“这就意味着，如果我们没有留意派发关系，让并发队列对应的多个线程等待了某个串行队列线程的话，线程爆炸的情况依旧可能发生”
 9.“因此，在处理 withUnsafeContinuation 时，我们需要小心这个问题。另外，除非真的有什么好的理由，否则我们都应该避免在异步函数中直接进行 GCD 派发，因为这种行为会绕开续体，并破坏结构化并发的假设”
 10.“在不得不使用 GCD 时，应当始终将它用 with*Continuation 包装起来，转换到 Swift 并发的 API 中”
 */


// MARK: - 任务优先级处理
/**
 1.“传统 GCD 调度中，在进行派发把任务加入队列时，可以通过 QoS (Quality of Service) 指定“优先级”
 let queue = DispatchQueue(label: "xxxx")
 queue.async(qos: .background) {
 }
 queue.async(qos: .userInitiated) {}
 2.“不过 GCD 中加入队列的任务是先入先出的：一个高优先级任务如果在低优先级任务之后才被加入到派发队列，那么它也会在这些低优先级任务之后再被提交和运行，这是 GCD 中无法改变的”
 3.“如果严格按照加入时的优先级执行，那么可能发生优先级反转的问题。”
 4.“如低优先级任务首先获取了一个锁，那么一个依赖同样锁的高优先级任务在加入后会被挂起，它需要等待这个锁被释放。”
 5.“大部分情况下因为低优先级任务也会运行，它最终会释放这个锁，所以暂时的等待不成问题”
 6.“但是考虑如果有另外一些不需要锁的中优先级任务也在执行，调度器将会为这些中优先级的任务分配运行资源，这也意味着低优先级的任务可能被一直挂起，而导致锁始终无法释放”
 7.“从最终结果来说，那个需要锁的高优先级任务会一直无法进行，而中优先级的任务反而顺利完成。这就是一个典型的优先级反转”
 8.“为了避免这种问题，GCD 采取的策略，是在检测到队列中有高优先级任务正在等待时，就把前面加入的低优先级任务也一并“翻转”为和高优先级任务相同的优先级，来让它们在调度时拥有同样的重要性”
 9.“这种方案能解决问题，但是由于调度的限制，远远谈不上优雅”
 10.“和传统 GCD 在调度任务时的先入先出不同，Swift 并发中 Task 相关 API 在处理任务时，并发执行器对任务实际的派发，会灵活按照优先级将需要进行的工作在运行时调整到合适的位置。这让 Task 相关 API 的优先级设置能以更加可预测的方式工作”
 for _ in 0..<4  {
 Task(priority: .background) {}
 }
 Task(priority: .userInitiated) {}
 11.“如果在同一个任务组中，我们期望某些子任务获取更多的执行资源，那么为它们指定更高的优先级是有效的做法”
 12.“对于串行执行器 (也就是在 actor 中的调度)，我们必须确保执行顺序”
 13.“原来的优先级提升的方法依然有效：当一个高优先级的任务被加入到串行执行器中，当前在执行的任务必须将优先级提升到和这个新加入的任务同样的优先级，以确保新的高优先级任务能够以正确的效率运行”
 14.“这种情况下，原来的低优先级任务的 Task.currentPriority 并不会随着高优先级任务的加入而更改。因此，我们最好不要依赖 Task.currentPriority 这个 API 来决定代码的逻辑。就算需要使用，我们也应该记住它有可能并不能反应当前任务真实的运行优先级”
 */
extension ViewController {
    func testTaskPriority() {
        for _ in 0..<4  {
            Task(priority: .background) {
                debugPrint("background \(Task.currentPriority)")
            }
        }
        Task(priority: .userInitiated) {
            debugPrint("userInitiated \(Task.currentPriority)")
        }
        // “和 Task.init 和 Task.detached 类似，Task group 的 API 在添加子任务时，也有类似的接受优先级的方法”

        Task {
            await withTaskGroup(of: Void.self, body: { group in
                group.addTask(priority: .medium) {
                    try? await Task.sleep(nanoseconds: 100)
                    debugPrint("medium")
                }
                group.addTask(priority: .low) {
                    try? await Task.sleep(nanoseconds: 100)
                    debugPrint("low")
                }
                group.addTask(priority: .high) {
                    try? await Task.sleep(nanoseconds: 100)
                    debugPrint("high")
                }
            })
        }
    }
}

// MARK: - 任务让行
/**
 “由于同样优先级的任务共用一个调度线程，所以像是下面这样的代码，会导致其他任务无法运行”
 */
extension ViewController {
    func testRunBlocking() {
        @Sendable func showLoopAgain() -> Bool {
            return true
        }
        Task.detached {
            debugPrint("Task 1")
            var loop = true
            while loop {
                loop = showLoopAgain()
            }
            debugPrint("All Done")
        }

        Task.detached {
            debugPrint("Task 2")
        }
    }

    func testTaskHang() {
        @Sendable func showLoopAgain() -> Bool {
            return true
        }
        Task.detached {
            debugPrint("Task 1")
            var loop = true
            while loop {
                loop = showLoopAgain()
                // 挂起，其他线程任务可执行
                if loop {
                    await Task.yield()
                }
            }
            debugPrint("All Done")
        }

        Task.detached {
            debugPrint("Task 2")
        }
    }
}

/**
 1.“这种模式在一些等待/响应循环中 (比如分批次读入数据，或者服务器等待请求接入等) 会十分有用，但是 while true 循环将把整个调度线程占用住，导致其他任务无法运行”
 2.“在并发中，我们有时会把这种某些任务无法得到机会执行的现象叫做资源饥饿 (starvation)。上面的代码中，在 shouldLoopAgain() 返回 false 之前，“Task 2” 是没有机会运行的”
 “为了其他任务能够运行，“Task 1” 必须要有暂时放弃线程的能力。最简单的方法是调用 Task.yield”
 “这个方法将会通知当前任务挂起，并把剩余工作重新进行包装后再次放入执行器中进行派发。这样，当前线程就将被让出，它可以有机会执行其他任务”
 3.“一个细节是，在 Apple 平台的全局并发执行器中，为了性能考虑，它会为每个优先级创建并缓存一个协同式调度队列”
 4.“这个细节使得下面这样的代码，在优先级不同时，即使 “Task 1” 没有 yield，“Task 2” 依然能够运行”
 5.“这是由于 .high 的任务和 .low 的任务是在不同调度队列上运行的，因此 .low 反而不受影响”
 6.“不过，这完全是 Swift 并发执行器的内部实现，我们不应该依赖于这样的细节来组织任务的运行。而且就算 .low 的任务可以运行，其他的 .high 任务依然会被卡住”
 7.“实际上，虽然 Swift 并发在处理优先级时，要比传统 GCD 更容易预测一些，但是如果在情况变得复杂时，比如出现任务组和 actor 共同使用的情况下，优先级会迅速变得复杂起来”
 8.“建议是，除非经过完善的性能测试，能确认并发运行的关键瓶颈就是某个任务的优先级，否则最好还是避免设定过于复杂的优先级。使用更简单的优先级体系，就更能让派发队列也保持简单，从而使一些问题暴露得更加明显，这有利于我们在开发中尽早发现和修复它们”
 */
extension ViewController {
    func testTaskPriorityDiff() {
        @Sendable func showLoopAgain() -> Bool {
            return true
        }
        Task.detached(priority: .high) {
            debugPrint("Task 1")
            var loop = true
            while loop {
                loop = showLoopAgain()
            }
            debugPrint("All Done")
        }

        Task.detached(priority: .low) {
            debugPrint("Task 2")
        }
    }
}

// MARK: - “任务本地值和任务追踪”
/**
 1.“对于任务的优先级 priority，以及是否被取消的 isCancelled flag，我们可以通过 Task 上的 static 属性进行获取”
 2.“虽然使用的是定义在类型上的 static 属性，但是实际获取到的值是当前运行环境中的具体任务实例的值”
 3.“在异步函数中，只会存在单一的运行环境，所以直接使用 static 的属性可以合理地简化写法。”
 */
func foo1() async {
    let priority: TaskPriority = Task.currentPriority
    let cancelled: Bool = Task.isCancelled
}

/**
 “比如 isCancelled 在 Swift 并发中的实现，就只是对当前任务的包装”
 extension Task {
 public static var isCancelled: Bool {
 withUnsafeCurrentTask { task in
 task?.isCancelled ?? false
 }
 }
 }
 “如果每次都要写像是 withUnsafeCurrentTask 这么复杂的语句话的，会非常麻烦。使用 static 属性来在当前任务中共享值的方式虽然一开始看起来有点反直觉，但是确实十分便利，它利用了 Task 类型空间来携带一些元数据”
 1.“Swift 并发中提供了一种语法“特性，任务本地值 (task local value)，可以让我们也可以用类似的 static var 的方式，把元数据“注入到”当前任务绑定的某个自定义值中”
 2.“具体来说，对于任意一个类型中的静态的存储属性，我们都可以用 @TaskLocal 属性包装对它进行声明，将它暴露为任务本地值。和 static 的 isCancelled 类似，这个值只在当前任务中有效”
 3.“@TaskLocal 属性包装会为被修饰的 id 属性添加一些特性。首先，它会把这个属性转变为只读，任何对它的直接设置将给出一个错误”
 4.“想要设置这个值，必须通过使用 Log.$id 的 withValue 方法。它接受一个值和一个闭包。在闭包中，读取 Log.id 将获得被设置的值，我们可以像是访问通常的属性那样访问到它”
 5.“这个值可以在闭包中再一次被 Log.$id 上的 withValue 调用覆盖，并在任务之间进行传递
 6.“简单说，Log.id 将会寻找和返回最后一次 Log.$id.withValue 中所设定的值；如果一直向上都没有设定的话，它将返回定义时 Log.id 的初始值。”
 7.“在具体实现上，withValue 被调用时，@TaskLocal 修饰的变量会将自己作为 key，把设置的值和当前任务的引用一并加入到一个链表维护的栈中，直到作用域结束后再出栈。它的简化后的代码类似于”
 func withValue<R>(_ valueDuringOperation: Value, operation:() async throws -> R) async rethrows -> R {
        pushLocalValue(key: self, value: valueDuringOperation, task: currentTask)
        defer { popLocalValue }
        return try await operation()
 }
 8.“在使用 Log.id 获取值时，它会从当前任务开始，寻找对应 key 是否存储了某个值。如果在当前任务中没有找到，则到上层任务中继续寻找，直到寻找到对应值或者到达任务的根节点并返回默认值。沿着任务层级进行寻找，让我们可以避免在任务之间复制这些值。”
 9.“这个行为看起来会和环境值有些相似。在 SwiftUI 中，@Environment 和各种通过 view modifier 设定的数值 (如 padding 等) 环境值会从外层 view 传递到内层 view；而通过 withValue 设定的值，则是从顶层任务传递到底层任务。”
10.“在 SwiftUI 中，环境值通常用来跨越 view 层级传递配置，让我们免于把某项配置层层传递。”
11.“虽然在 Swift 并发中，我们也可以用任务本地值来做类似的事情，但是这种用法并不被推荐。”
12.“它和 SwiftUI 的环境值面临类似的问题：究竟是谁为当前任务设置了这个本地值并不明确,“而且当你将一个任务移动到其他地方时，可能原来的基于任务本地值的假设也会被破坏，但是编译器却无法检测到这种情况”
13.“SwiftUI 环境值和 view 的本体是一同工作的，它们共同构成一个有效和正确的 view，因此 view 的移动相对起来还能保持设定的完整。”
14.“但这个情况在任务本地值中可能并不适用。如果想要在任务之间传递某种配置值，更好的方法还是明确地通过函数参数来进行，任务本地值不是为了传递参数而被设计出来的。”
15.“Apple 更推荐使用任务本地值来进行任务的追踪”
16.“比如，在多个页面中对同一个 API 进行请求时，单纯地通过控制台 log 或者断点，都很难追踪每一个任务：因为各个请求是并发运行的，它们产生的 log 可能也是重叠的，对它们进行断点，程序也可能多次停在重复的地方。比如：”
17.“很难分辨输出对应的请求到底是来自哪个页面，也很难为断点设置合适的条件让它只在某个页面进行请求时停下。这种情况下，使用任务本地值就可以很好地解决任务追踪的问题”
 18.“Task.init 会从当前任务环境中继承优先级和隔离环境等任务相关的属性，任务本地值也在其中：当通过初始化方法创建新任务时，当前任务的本地值链表将被复制到新的任务环境里。如果你想要一个完全“干净”的任务环境，可以使用 Task.detached 来创建游离任务。”
19.“当前 Apple 还没有在 Instruments app 中提供追踪和调试 Swift 并发性能的工具模板，不过任务本地值和它带来的任务追踪的能力，为今后进一步构建更强大的并发性能追踪工具提供了基础。”

 */
enum Log {
    @TaskLocal static var id: String?
}

//// Cannot assign to property: 'id' is a get-only property
//Log.id = "xxx"
extension ViewController {
    func testLocalSetValue() {
        Log.$id.withValue("xxx") {
            debugPrint("Log id: \(Log.id ?? "")")
        }
        Log.$id.withValue("Outer") {
            Task {
                debugPrint("M Log id \(Log.id ?? "")")
                await Log.$id.withValue("Inner") {
                    await Task {
                        debugPrint("T Log.id: \(Log.id ?? "")")
                    }.value
                }
            }
            debugPrint("Log id: \(Log.id ?? "")")
        }
    }
}

// MARK: - 总结
/**
1.“本章中我们探索了一些 Swift 并发的幕后话题。为了避免线程爆炸和调度线程阻塞，Apple 提出了新的线程调度模型，这是异步函数可以放弃线程的基础；通过全局并发执行器，Swift 将任务包装并派发到协同式线程池，在那里完成底层线程的调度。这个线程池为了避免不必要的线程切换，不会创建多于 CPU 核心数的线程，而合理的调度方式也让各个线程不会产生资源饥饿。这些背后机制支撑了 Swift 并发，它们协同工作并保证在正确书写的前提下 (比如避免在调度线程进行繁重工作，避免混用传统 GCD 派发等)，即使情况变得非常复杂，Swift 并发也可以维持优秀的性能。”
2.“本章中我们也提到了一些其他的话题，比如任务优先级、任务让行和使用任务本地值来追踪任务等。在日常开发中，这些内容可能只会在很有限的情景下才被用到。不过相信这些知识可以帮助我们更深入地理解 Swift 并发的性能特点，并让我们可以追踪并发任务的执行。如果你在设计并发 API 时遇到了性能上的问题，希望本章中的内容能给你带去些许灵感”
 */
