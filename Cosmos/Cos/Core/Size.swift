//
//  Size.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import Foundation
import CoreGraphics


public struct Size : Equatable, Comparable, CustomStringConvertible {
    public var width: Double
    public var height: Double

    public init() {
        width = 0
        height = 0
    }

    public init(_ width: Double, _ height: Double) {
        self.width = width
        self.height = height
    }

    public init(_ width: Int, _ height: Int) {
        self.width = Double(width)
        self.height = Double(height)
    }

    public init(_ size: CGSize) {
        self.width = Double(size.width)
        self.height = Double(size.height)
    }

    public func isZero() -> Bool {
        return width == 0 && height == 0
    }

    public var description: String {
        return "{\(width), \(height)}"
    }
}


public func == (lhs: Size, rhs: Size) -> Bool {
    return lhs.width == rhs.width && lhs.height == rhs.height
}

public func > (lhs: Size, rhs: Size) -> Bool {
    return lhs.width * lhs.height > rhs.width * rhs.height
}

public func < (lhs: Size, rhs: Size) -> Bool {
    return lhs.width * lhs.height < rhs.width * rhs.height
}

public func >= (lhs: Size, rhs: Size) -> Bool {
    return lhs.width * lhs.height >= rhs.width * rhs.height
}

public func <= (lhs: Size, rhs: Size) -> Bool {
    return lhs.width * lhs.height <= rhs.width * rhs.width
}


public extension CGSize {
    init(_ size: Size) {
        self.init(width: CGFloat(size.width), height: CGFloat(size.height))
    }
}
