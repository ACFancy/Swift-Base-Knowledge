//
//  Rect.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import Foundation
import CoreGraphics

public struct Rect : Equatable, CustomStringConvertible {
    
    public var origin: Point
    public var size: Size
    
    public var width: Double {
        get {
            return size.width
        }
        set {
            size.width = newValue
        }
    }
    
    public var height: Double {
        get {
            return size.height
        }
        set {
            size.height = newValue
        }
    }
    
    public init() {
        self.init(0, 0, 0, 0)
    }
    
    public init(_ x: Double, _ y: Double, _ w: Double, _ h: Double) {
        origin = Point(x, y)
        size = Size(w, h)
    }
    
    public init(_ x: Int, _ y: Int, _ w: Int, _ h: Int) {
        origin = Point(x, y)
        size = Size(w, h)
    }
    
    public init(_ o: Point, _ s: Size) {
        origin = o
        size = s
    }
    
    public init(_ rect: CGRect) {
        origin = Point(rect.origin)
        size = Size(rect.size)
    }
    
    public init(_ points: [Point]) {
        let count = points.count
        assert(count >= 2, "Polygon must at least 2 points")
        var cgPoints: [CGPoint] = []
        for i in 0..<count {
            cgPoints.append(CGPoint(points[i]))
        }
        let r = CGRectMakeFromPoints(cgPoints)
        self.init(r)
    }
    
    public init(_ points: (Point, Point)) {
        let r = CGRectMakeFromPoints([CGPoint(points.0), CGPoint(points.1)])
        self.init(r)
    }
    
    public func intersects(_ rect: Rect) -> Bool {
        return CGRect(self).intersects(CGRect(rect))
    }
    
    public var center: Point {
        get {
            return Point(origin.x + size.width / 2, origin.y + size.height / 2)
        }
        set {
            origin.x = newValue.x - size.width / 2
            origin.y = newValue.y - size.height / 2
        }
    }
    
    public var max: Point {
        return Point(origin.x + size.width, origin.y + size.height)
    }
    
    public func isZero() -> Bool {
        return origin.isZero() && size.isZero()
    }
    
    public func contains(_ point: Point) -> Bool {
        return CGRect(self).contains(CGPoint(point))
    }
    
    public func contains(_ rect: Rect) -> Bool {
        return CGRect(self).contains(CGRect(rect))
    }
    
    public var description: String {
        return "{\(origin), \(size)}"
    }
}


public extension CGRect {
    init(_ rect: Rect) {
        self.init(origin: CGPoint(rect.origin), size: CGSize(rect.size))
    }
}
