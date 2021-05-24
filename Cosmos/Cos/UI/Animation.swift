//
//  Animation.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import Foundation

private let AnimationCompletedEvent = "C4AnimationCompleted"
private let AnimationCancelledEvent = "C4AnimationCancelled"

public class Animation {
    public enum Curve {
        case linear
        case easeOut
        case easeIn
        case easeInOut
    }

    public var autoreverses = false

    public var repeatCount = 0.0

    public var repeats: Bool {
        get {
            return repeatCount > 0
        }
        set {
            if newValue {
                repeatCount = Double.greatestFiniteMagnitude
            } else {
                repeatCount = 0
            }
        }
    }

    public var duration: TimeInterval = 1
    public var curve: Curve = .easeInOut
    private var completionObservers: [AnyObject] = []
    private var cancelObservers: [AnyObject] = []

    static var stack: [Animation] = []
    static var currentAnimation: Animation? {
        return stack.last
    }

    public init() {}

    deinit {
        let nc = NotificationCenter.default
        completionObservers.forEach {
            nc.removeObserver($0)
        }
        cancelObservers.forEach {
            nc.removeObserver($0)
        }
    }

    func animate() {}

    @discardableResult
    public func addCompletionObserver(_ action: @escaping () -> Void) -> AnyObject {
        let nc = NotificationCenter.default
        let observer = nc.addObserver(forName: NSNotification.Name(rawValue: AnimationCompletedEvent), object: self, queue: .current) { _ in
            action()
        }
        completionObservers.append(observer)
        return observer
    }

    public func removeCompletionObserver(_ observer: AnyObject) {
        let nc = NotificationCenter.default
        nc.removeObserver(observer, name: NSNotification.Name(rawValue: AnimationCompletedEvent), object: self)
    }

    public func postCompletedEvent() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: AnimationCompletedEvent), object: self)
        }
    }


    public func addCancelObserver(_ action: @escaping () -> Void) -> AnyObject {
        let nc = NotificationCenter.default
        let observer = nc.addObserver(forName: NSNotification.Name(rawValue: AnimationCancelledEvent), object: self, queue: .current) { _ in
            action()
        }
        cancelObservers.append(observer)
        return observer
    }

    public func removeCancelObserver(_ observer: AnyObject) {
        let nc = NotificationCenter.default
        nc.removeObserver(observer, name: NSNotification.Name(rawValue: AnimationCancelledEvent), object: self)
    }

    public func postCancelledEvent() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name(AnimationCancelledEvent), object: self)
        }
    }
}
