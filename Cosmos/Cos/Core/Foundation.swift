//
//  Foundation.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import CoreGraphics

public func Log<T>(_ value: T) {
    debugPrint("[Log] \(value)")
}

public func CGRectMakeFromPoints(_ points: [CGPoint]) -> CGRect {
    let path = CGMutablePath()
    path.move(to: points[0])
    for i in 1..<points.count {
        path.addLine(to: points[i])
    }
    return path.boundingBox
}

public func wait(_ seconds: Double, action: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: action)
}
