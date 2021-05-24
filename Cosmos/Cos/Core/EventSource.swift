//
//  EventSource.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import Foundation

public protocol EventSource {
    
    func post(_ event: NSNotification.Name)
    @discardableResult
    func on(event notificationName: NSNotification.Name, run: @escaping () -> Void) -> Any
    @discardableResult
    func on(event notificationName: NSNotification.Name, from sender: Any?, run executionBlock: @escaping () -> Void) -> Any
    func cancel(_ observer: Any)
}


extension NSObject : EventSource {
    public func post(_ event: NSNotification.Name) {
        NotificationCenter.default.post(name: event, object: self)
    }

    @discardableResult
    public func on(event notificationName: NSNotification.Name, run: @escaping () -> Void) -> Any {
        return on(event: notificationName, from: nil, run: run)
    }

    @discardableResult
    public func on(event notificationName: NSNotification.Name, from sender: Any?, run executionBlock: @escaping () -> Void) -> Any {
        let nc = NotificationCenter.default
        let objectProtocol = nc.addObserver(forName: notificationName, object: sender, queue: .main) { _ in
            executionBlock()
        }
        return objectProtocol
    }
    
    public func cancel(_ observer: Any) {
        NotificationCenter.default.removeObserver(observer)
    }
}
