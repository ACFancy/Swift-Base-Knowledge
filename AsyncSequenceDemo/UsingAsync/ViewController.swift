//
//  ViewController.swift
//  UsingAsync
//
//  Created by Lee Danatech on 2021/11/25.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        //        testURLSessionCommonFunctions()

        //        testURLSessionAsyncFunctions()

        //        testAsyncBytes()

        //        testURLResourceBytes()

//        testNotications()

        syncMethod()

        anotherSyncMethod()


    }
}

// MARK: - 使用异步函数
// MARK: - 网络请求中的异步函数
extension ViewController {
    func testURLSessionCommonFunctions() {
        let url = URL(string: "https://www.baidu.com")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                debugPrint("Error \(error)")
            }
            if let data = data {
                debugPrint("Data: \(data.count) bytes")
            }
        }
        task.resume()
        let session = URLSession(configuration: .default, delegate: Delegate(), delegateQueue: nil)
        let task2 = session.dataTask(with: url)
        task2.resume()
    }
}

class Delegate: NSObject, URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        debugPrint("Receive Response")
        completionHandler(.allow)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        debugPrint("Data chunk:\(data.count)")
    }
}

// MARK: - 异步URLSession方法
extension ViewController {
    /// “这种带有返回值的异步操作，是无法直接映射成异步函数的”
    /**
     extension URLSession {
     func data(from url: URL, delegate: URLSessionTaskDelegate? = nil) async throws -> (Data, URLResponse)
     }
     1. “网络请求任务将立即开始，不再依赖于调用 resume。原先使用 dataTask 方法生成的 URLSessionDataTask 实例，在创建时将占用一系列 session 资源。如果由于某种原因，没有调用 resume 的话，直到 session 整个结束，这些资源都不会被清理，很容易造成事实上的内存泄漏，而且这很难被察觉到”
     2.“和之前针对整个 session 的 delegate 不同，这里的 delegate 是针对单个任务的。这让我们在收到的代理方法调用时，不再需要缓存和区分这个调用到底来自哪个任务，这让控制任务可以在更细粒度上更清晰地实现”
     */

    func testURLSessionAsyncFunctions() {
        Task {
            let url = URL(string: "https://www.baidu.com")!
            let (data, response) = try await URLSession.shared.data(from: url)
            if let httpResponse = response as? HTTPURLResponse {
                debugPrint("Status Code: \(httpResponse.statusCode)")
            }
            debugPrint("Data:\(data.count) bytes")
        }
    }
}

// MARK: - 基于bytes的异步序列
extension ViewController {
    /**
     “在某些情况下，可能我们只对响应中的部分数据有兴趣”
     1.“下载图片时通过 body 的前几个字节判断图片类型和尺寸”
     2.“对一个特别大的字符串 body 按行读取并寻找关键内容”
     3.“在以前，除了等待请求完成，完整的 Data 被收集以外，我们只能通过检查并收集 delegate 的 urlSession(_:dataTask:didReceive:) 中给出的 data 参数来完成这项任务。不过，现在我们有更好的方式来按字节读取响应中的数据了”
     extension URLSession {
     func bytes(from url: URL, delegate: URLSessionTaskDelegate? = nil) async throws -> (URLSession.AsyncBytes, URLResponse)
     }
     “和 data(from:) 方法等待响应完成并获取所有数据不同，新加入的 bytes(from:) 返回的不是完整的 Data，而是一个代表响应中 body 字节数据的 AsyncBytes 类型。AsyncBytes 是一个异步的数据序列，它的值代表了数据的每个字节”
     Struct AsyncBytes: AsnycSequence {
     typealias Element = UInt8
     }
     “我们不再需要等待整个响应完成，而只用最多获取响应中的八个字节，就能检查 body 是不是满足 PNG 图片文件的规范了”
     extension AsyncSequence where Self.Element == UInt8 {
     var lines: AsyncLineSequence<Self> { get }
     var characters: AsyncCharacterSequence<Self> { get }
     var unicodeScalars: AsyncUnicodeScalarSequence<Self> { get }
     }
     */
    func testAsyncBytes() {
        Task {
            let url = URL(string: "https://www.baidu.com")!
            let session = URLSession.shared
            let (bytes, _) = try await session.bytes(from: url)
            //            for try await byte in bytes {
            //                debugPrint(byte, terminator: ",")
            //            }
            //            // “如果我们需要通过前几个字节来判断响应 body 的一些属性的话，这个函数将非常有用：”
            //            var pngHeader: [UInt8] = [137, 80, 78, 71, 13, 10, 26, 10]
            //            for try await byte in bytes.prefix(8) {
            //                if byte != pngHeader.removeFirst() {
            //                    debugPrint("Not PNG")
            //                    return
            //                }
            //            }
            //            debugPrint("PNG")
            for try await line in bytes.lines {
                debugPrint(line)
            }
        }
    }

    /**
     1.“除了 URLSession，URL 现在也接受类似的方法：url.resourceBytes 返回一个异步的字节序列，url.lines 按行返回字符串序列。如果你只是想要简单地向某个 URL 发送一个 GET 请求，这应该是最容易的获取结果的方法了”
     2.“当然，上面的 URL 对于本地文件也有效。实际上，除了基于 URLSession 的网络请求外，
     和文件读取操作相关的 FileHandle API 中也提供了 bytes 方法，来把加载的数据表征为异步序列”
     “同为 I/O 操作，这些新加入的抽象把具体的加载过程省略，而从本质上强调了“异步加载数据”这一核心操作。这样我们就可以使用相似的方式来处理不同数据源的输入了”
     */
    func testURLResourceBytes() {
        Task {
            let url = URL(string: "https://www.baidu.com")!
            for try await line in url.lines {
                debugPrint(line)
            }
        }
    }
}

// MARK: - 协议代理方法

// Example
protocol Proto {
    func doSomething(completionHandler: @escaping(Bool) -> Void)
    func doSomething() async -> Bool
}

extension Proto {
    func doSomething() async -> Bool {
        await withUnsafeContinuation { continuation in
            doSomething { value in
                continuation.resume(returning: value)
            }
        }
    }
}

protocol Proto2 {
    func doSomething() async -> Bool
}

extension ViewController: URLSessionDataDelegate {
    //    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
    //        guard let scheme = response.url?.scheme, scheme.starts(with: "https") else {
    //            completionHandler(.cancel)
    //            return
    //        }
    //        completionHandler(.allow)
    //    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse) async -> URLSession.ResponseDisposition {
        guard let scheme = response.url?.scheme, scheme.starts(with: "https") else {
            return .cancel
        }
        return .allow
    }



    class Stt: Proto {
        func doSomething(completionHandler: @escaping (Bool) -> Void) {
            completionHandler(true)
        }

        func doSomething() async -> Bool {
            return true
        }
    }

    /**
     “另外一个值得注意的细节是，非异步的方法可以实现协议中异步的方法。也就是说，下面的做法是可以通过编译的”
     1.“这个“特性”和 throws 在 protocol 中的表现是类似的”
     2.“Struct 中同步函数所能表达的能力，是 Proto2 中异步函数能力的子集，我们总可以在一个异步函数中执行同步操作”
     3.“然而，反过来却不成立：如果 Proto2 要求一个同步函数，我们不能在 Struct 里用一个异步函数来满足它：协议里的同步函数不具备放弃当前线程的能力”

     */
    struct Struct: Proto2 {
        func doSomething() -> Bool {
            return true
        }
    }
}


@objc protocol ProtoObjc {
    func doSomething(completionHandler: @escaping(Bool) -> Void)
    func doSomething() async -> Bool
}

// MARK: - Notification
extension ViewController {
    /**
     extension NotificationCenter {
     func notifications(named name: Notification.Name, object: AnyObject? = nil) -> NotificationCenter.Notifications
     }
     class Notifications: AsyncSequence {
     typealias Element = Notification
     }
     “要注意，使用异步序列处理 Notification 时，Task 和 for await 所导致的程序暂停，将会把还没执行的部分作为续体，并持有调用它们的上下文。也就是说，虽然在 Task 闭包中我们并没有明确写出 self，但在序列没有完成时，self 还是会一直被持有，无法得到释放。如果我们是在 UIViewController 这样的环境中监听某个没有明确完结的通知的话，这个泄漏所造成的问题将无法忽视”
     */
    func testNotications() {
        //        Task {
        //            let backgroundNotifications = NotificationCenter.default.notifications(named: UIApplication.didEnterBackgroundNotification, object: nil)
        //            //            for await notification in backgroundNotifications {
        //            //                debugPrint(notification)
        //            //            }
        //            //// “立即跳出异步序列或是取消 Task，对避免意外的长时间持有会有帮助”
        //            //// “第一次事件，那么完全可以在获取到序列中首个事件后，立即 break 跳出 for await 循环，这会让相关任务结束”
        //            //            for await notification  in backgroundNotifications {
        //            //                debugPrint(notification)
        //            //                break
        //            //            }
        //            //// “使用 first 来把异步序列收敛到一个异步值”
        //            //            if let notification = await backgroundNotifications.first(where: { _ in true}) {
        //            //                debugPrint(notification)
        //            //            }
        //
        //        }
        /**
         “不过需要注意的是，这两种方式都假设了序列至少会产生一个值。在产生首个值之前，调用者依然会被持有。在某些情况下，这可能是我们所希望的行为。但在另外的情况下，如果我们并不希望这个持有行为，则可以利用 Task 的 cancel 来让序列提前终结，来避免泄漏”
         */
        let task = Task {
            let backgroundNotifications = NotificationCenter.default.notifications(named: UIApplication.didEnterBackgroundNotification, object: nil)
            for await notification in backgroundNotifications {
                debugPrint(notification)
            }
        }
        task.cancel()
    }
}

// MARK: - 异步函数的运行环境
extension ViewController {
    /**
     “和可抛出错误的函数一样，异步函数也具有“传染性”：由于运行一个异步函数可能会带来潜在的暂停点，因此它必须要用 await 明确标记。而 await 又只能在 async 标记的异步函数中使用。于是，将一个函数转换为异步函数时，往往也意味着它的所有调用者也需要变成异步函数。

     处理 throws 时，在最上层，我们会使用 do 的代码块来提供一个可抛出的环境，并在 catch 中捕获错误。类似地，对于异步函数的使用，我们也可以“追溯”到一个最上层：它作为初始环境，为其他的异步函数运行提供合适的环境。”
     1. “将代码从同步世界“转接”到异步世界时，最重要也是最常使用的方法是利用 Task 的相关 API 创建任务环境”
     2. “Task.init 和 Task.detached 都能在当前环境中创建一个非结构化的任务上下文，它们的主要区别在于是否从当前上下文 (如果存在的话) 中继承一些特性”
     3. “如果你想要在当前同步上下文中，开启一个异步上下文来调用异步方法的话，大多数情况下 Task.init 是最佳选择，这个初始化方法接受一个类型为 () async -> Success 的异步闭包，你可以在里面调用其他的异步函数”
     */
    func asyncMethod() async -> Bool {
        await Task.sleep(NSEC_PER_SEC)
        return true
    }

    func syncMethod() {
        /// “这个异步闭包的返回值是 Success，它也会作为 Task 执行结束后的结果值，被传送到自身上下文之外”
        Task {
            await asyncMethod()
        }
    }

    func anotherAsyncMethod() async {
        /// “如果你是在一个异步上下文中创建 Task 的话，还可以通过访问它的 value 属性来获取任务结束后的“返回值”
        let task = Task {
            await asyncMethod()
        }
        let result = await task.value
        debugPrint(result)
    }

    func anotherSyncMethod() {
        Task {
            await anotherAsyncMethod()
        }
    }
}


// MARK: - @main 提供异步运行环境
extension ViewController {
    /**
     “如果你要创建的不是一个 iOS 或者 macOS app，而是一个 Swift 的命令行工具或者 server 端程序的话，会需要一个明确的 main 函数作为入口。从 Swift 5.3 开始，可以使用 @main 来标记一个基于类型的程序入口。在引入 Swift 并发后，对于被标记的 @main 类型，我们可以直接将 main 函数声明为 async。这样一来，程序开始时我们就可以拥有一个异步运行环境了”

     @main
     struct MyApp {
        static func main() async {
            await Task.sleep(NSEC_PER_SEC)
            debugPrint("Done")
        }
     }
     “一切异步函数都需要自己的任务运行环境，main 也不例外。@main 所标记的类型作为程序入口，会被整个程序传统意义上“真正的” main 函数 (它是一个同步函数) 调用。上面的程序编译后，相当于在真正的 main 中执行了”
      func main() {
        _runAsyncMain { await MyApp.main() }
     }
     “_runAsyncMain 的实现是开源在 Swift 项目仓库中的，在 Apple 平台中，它被执行时将使用 Task.detached 创建一个异步运行环境，并保证将 MyApp.main() 放到主线程进行运行。因此，@main 提供的异步环境和我们自行通过 Task.init 或 Task.detached 创建的环境并没有什么本质不同”

     “除了 @main 标记的基于类型的的程序入口外，我们也可以直接在 main.swift 顶层调用异步函数。实际上这种做法 Swift 也会用相同的方式为我们创建一个游离的任务环境”
     */
}

// MARK: - SwiftUI
