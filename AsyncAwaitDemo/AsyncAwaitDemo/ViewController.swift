//
//  ViewController.swift
//  AsyncAwaitDemo
//
//  Created by Lee Danatech on 2021/11/15.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        Task {
            //            await asyncFunc()
            //            try await load()
            //            async let sep1 = load2()
            //            async let sep2 = load3()
            //            try await [sep1, sep2]
        }
        Task {
            _ = Test()
        }
        Task {
            try await reportFileSize()
        }
    }
}


extension ViewController {
    // MARK: - 修改函数签名
    func syncFunc() {
        calculate(input: 100, completion: { debugPrint($0) })
    }

    func asyncFunc() async {
        calculate(input: 100, completion: { debugPrint($0) })
    }

    //    @completionHandlerAsync("calculate(input:)")
    @completionHandlerAsync("calculate(input:)", completionHandlerIndex: 1)
    func calculate(input: Int, completion: @escaping(Int) -> Void) {
        completion(input + 100)
    }


    @discardableResult
    func calculate(input: Int) async -> Int {
        return input + 100
    }
}

extension ViewController {
    // MARK: - continuation 改写函数
    /**
     func withUnsafeContinuation<T>(_ fn:(UnsafeContinuation<T, Never>) -> Void) async -> T
     func withUnsafeThrowingContinuation<T>(_ fn:(UnsafeContinuation<T, Error>) -> Void) async throws -> T
     func withCheckedContinuation<T>(_ fn:(CheckedContinuation<T, Never>) -> Void) async -> T
     func withCheckedThrowingContinuation<T>(_ function: String = #function, _ body: (CheckedContinuation<T, Never>) -> Void) async -> T
     func withCheckedThrowingContinuation<T>(function: String = #function, body:(CheckedContinuation<T, Error>) -> Void) async throws -> T
     */

    @discardableResult
    func load() async throws -> [String] {
        try await withUnsafeThrowingContinuation { continuation in
            load { values, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let values = values {
                    continuation.resume(returning: values)
                } else {
                    assertionFailure("params are nil")
                }
            }
        }
    }

    @discardableResult
    func load2() async throws -> [String] {
        try await withCheckedThrowingContinuation { continuation in
            load { values, error in
                // @note SWIFT TASK CONTINUATION MISUSE: load2() leaked its continuation!
            }
        }
    }

    @discardableResult
    func load3() async throws -> [String] {
        try await withCheckedThrowingContinuation { continuation in
            load { values, error in
                if let values = values {
                    continuation.resume(returning: values)
                    // @note Fatal error: SWIFT TASK CONTINUATION MISUSE: load3() tried to resume its continuation more than once
                    continuation.resume(returning: values)
                }
            }
        }
    }

    func load(completion: @escaping([String]?, Error?) -> Void) {
        completion(["ss", "dk"], nil)
    }
}


protocol WorkDelegate {
    func workDidDone(values: [String])
    func workDidFailed(error: Error)
}

extension ViewController {
    // MARK: - Contination Stash
    class Worker: WorkDelegate {
        var continuation: CheckedContinuation<[String], Error>?

        func doWork() async throws -> [String] {
            try await withCheckedThrowingContinuation { continuation in
                self.continuation = continuation
                performWork(delegate: self)
            }
        }

        func performWork(delegate: WorkDelegate?) {
            load { values, error in
                if let values = values {
                    delegate?.workDidDone(values: values)
                } else if let error = error {
                    delegate?.workDidFailed(error: error)
                } else {
                    assertionFailure("paramters invalid")
                }
            }
        }

        func workDidDone(values: [String]) {
            continuation?.resume(returning: values)
            continuation = nil
        }

        func workDidFailed(error: Error) {
            continuation?.resume(throwing: error)
            continuation = nil
        }

        func load(completion: @escaping([String]?, Error?) -> Void) {
            completion(["ss", "dk"], nil)
        }
    }
}

// MARK: - OC自动转换
extension ViewController {
    // NS_SWIFT_ASYNC(2)
    // NS_SWIFT_DISABLE_ASYNC
    // “ UIView 和 UIViewController 上大部分 UI 相关的操作明确标明了不进行异步函数转换”
    // PhotoLibrary库的方法
}


// MARK: - Swift to OC
extension ViewController {
    // “普通的 Swift 函数可以通过 @objc 暴露给 Objective-C。异步函数也遵守同样的规则：当一个 Swift 中的 async 函数被标记为 @objc 时，它在 Objective-C 中会由一个带有 completionHandler 的回调闭包版本表示”
    /**
     /// swift
     func calculate(input: Int) async -> Int
     /// OC
     - (void)calculate:(NSInteger)input completionHandler:(void(^ _Nonnull)(NSInteger))completionHandler;
     */
    // “由于 Objective-C 中其实不存在可用的 Task 上下文环境，在实际调用 Swift 版本的异步函数前，会使用 Task.detached 创建一个完全游离的任务运行环境”

    @objc public func calculate2(input: Int, completionHandler:@escaping(Int) -> Void) {
        Task.detached {
            let value = await self.calculate(input: input)
            completionHandler(value)
        }
    }

    @objc public func calculate3(input: Int) async -> Int {
        return await calculate(input: input)
    }
}

// MARK: - Async Getter
extension ViewController {
    enum FileError: Error {
        case crroupted
    }

    class File {
        var size: Int {
            get async throws {
                if corrupted {
                    throw FileError.crroupted
                }
                return try await heavyOperation()
            }
        }

        var corrupted: Bool = false

        func heavyOperation() async throws -> Int {
            var total: Int = 0
            (0...5).forEach {
                sleep(1)
                total += $0
            }
            return total
        }

        func loadAttributes() async -> [FileAttributeKey: FileAttributeType] {
            return [.appendOnly: .typeSocket, .type: .typeRegular]
        }

        subscript(_ attribute: FileAttributeKey) -> FileAttributeType? {
            get async {
                let attributes = await loadAttributes()
                return attributes[attribute]
            }
        }
    }

    func reportFileSize() async throws {
        let file = File()
        debugPrint("File size \(try await file.size)")
    }
}

// MARK: - 状态依赖
extension ViewController {
    class DependencyDemo {
        var loaded: Bool = false

        var shouldLoad: Bool {
            get async {
                if !loaded {
                    await prepare()
                    return true
                }
                return false
            }
        }

        func prepare() async {
            sleep(1)
        }

        func load() {
            loaded = true
        }

        // “actor 模型部分关于可重入” 进行对比，状态依赖导致的安全访问和内存共享的问题
        var shouldLoad2: Bool {
            get async {
                if !loaded {
                    await prepare()
                }
                return !loaded
            }
        }
    }
}

// MARK: - Setter
extension ViewController {
    /**
     1.“async 和 throws 的支持，现在只针对属性 getter 和下标读取。对于计算属性的 setter 和下标写入，异步行为暂时还不支持”
     2. “在于各种 setter 的附加行为。相对于 getter 来说，setter 需要考虑的事情要更多。想要为 setter 定义 async 的话，需要考虑的内容至少包括 inout 的行为，didSet 和 willSet 应该在何时调用，属性包装 (Property wrapper) 要怎么处理等话题。为 getter 定义异步行为是相对比较简单，而且能为实际编程提供很大帮助的“高性价比”努力。相对起来，对 setter 的支持则被延后了”
     3. “如果只是单纯地需要对某个属性以异步方式进行设置，以便在设置属性的同时执行某些耗时操作，我们可以直接暴露一个异步函数”
     class SetterDemo {
         var value: String

         func setValue(_ v: String) async throws {
             await someOtherAsyncwork()
             try checkCanWrite()
             value = v
         }
     }
     */
}


