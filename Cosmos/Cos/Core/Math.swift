//
//  Math.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import Foundation

public func clamp<T: Comparable>(_ val: T, min: T, max: T) -> T {
    assert(min < max, "min has to be less than max")
    if val < min {
        return min
    } else if val > max {
        return max
    } else {
        return val
    }
}

public func lerp<T: FloatingPoint>(_ a: T, _ b: T, _ at: T) -> T {
    return a + (b - a) * at
}

public func map<T: FloatingPoint>(_ val: T, from: Range<T>, to: Range<T>) -> T {
    let param = (val - from.lowerBound) / (from.upperBound - from.lowerBound)
    return lerp(to.lowerBound, to.upperBound, param)
}

public func map<T: FloatingPoint>(_ val: T, from: ClosedRange<T>, to: ClosedRange<T>) -> T {
    let param = (val - from.lowerBound) / (from.upperBound - from.lowerBound)
    return lerp(to.lowerBound, to.upperBound, param)
}


public func random() -> Int {
    var r = 0
    withUnsafeMutableBytes(of: &r) { bufferPointer in
        arc4random_buf(bufferPointer.baseAddress, MemoryLayout<Int>.size)
    }
    return r
}

public func random(below: Int) -> Int {
    return abs(random()) % below
}

public func random(in range: Range<Int>) -> Int {
    return range.lowerBound + random(below: range.upperBound - range.lowerBound)
}

public func random(in range: Range<Double>) -> Double {
    let intRange: Range<Double> = Double(-Int.max)..<(Double(Int.max) + 1)
    let r = Double(random())
    return map(r, from: intRange, to: range)
}

public func radToDeg(_ val: Double) -> Double {
    return 180.0 * val / Double.pi
}

public func degToRad(_ val: Double) -> Double {
    return Double.pi * val / 180.0
}
