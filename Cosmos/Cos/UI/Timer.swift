//
//  Timer.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import Foundation

public final class Timer : NSObject {
    public internal(set) var step = 0
    public internal(set) var count: Int
    public internal(set) var interval: Double
    var action: () -> Void
    weak var timer: Foundation.Timer?
    
    public init(interval: Double, count: Int = Int.max, action: @escaping () -> Void) {
        self.action = action
        self.count = count
        self.interval = interval
        super.init()
    }
    
    @objc public func fire() {
        action()
        step += 1
        if step >= count {
            stop()
        }
    }
    
    public func start() {
        guard timer == nil else {
            return
        }
        let t = Foundation.Timer(timeInterval: interval, target: self, selector: #selector(Timer.fire), userInfo: nil, repeats: true)
        RunLoop.main.add(t, forMode: .default)
        timer = t
    }
    
    public func pause() {
        timer?.invalidate()
    }
    
    public func stop() {
        pause()
        step = 0
    }
}
