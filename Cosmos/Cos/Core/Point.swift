//
//  Point.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/17.
//

import CoreGraphics

public struct Point : Equatable, CustomStringConvertible {
    public var description: String {
        return ""
    }
    
    public var x: Double = 0
    public var y: Double = 0
    
    public init() {
    }
    
    public init(_ x: Double, _ y: Double) {
        self.x = x
        self.y = y
    }
    
    public init(_ x: Int, _ y: Int) {
        self.x = Double(x)
        self.y = Double(y)
    }
    
    public init(_ point: CGPoint) {
        x = Double(point.x)
        y = Double(point.y)
    }
    
    public func isZero() -> Bool {
        return x == 0 && y == 0
    }
    
    public mutating func transform(_ t: Transform) {
        
    }
}

public func += (lhs: inout Point, rhs: Vector) {
    lhs.x += rhs.x
    lhs.y += rhs.y
}

public func -= (lhs: inout Point, rhs: Vector) {
    lhs.x -= rhs.x
    lhs.y -= rhs.y
}

public func - (lhs: Point, rhs: Point) -> Vector {
    return Vector(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

public func + (lhs: Point, rhs: Vector) -> Point {
    return Point(lhs.x + rhs.x, lhs.y + rhs.y)
}

public func - (lhs: Point, rhs: Vector) -> Point {
    return Point(lhs.x - rhs.x, lhs.y - rhs.y)
}

public func distance(_ lhs: Point, rhs: Point) -> Double {
    let dx = rhs.x - lhs.x
    let dy = rhs.y - lhs.y
    return sqrt(dx * dx + dy * dy)
}

public func == (lhs: Point, rhs: Point) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}

public func lerp(_ a: Point, _ b: Point, at: Double) -> Point {
    return a + (b - a) * at
}

public extension CGPoint {
    init(_ point: Point) {
        self.init(x: CGFloat(point.x), y: CGFloat(point.y))
    }
}
