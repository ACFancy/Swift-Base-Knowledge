//
//  Transform.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/17.
//

import CoreGraphics
import QuartzCore

public struct Transform : Equatable {
    var matrix: [Double] = [Double](repeating: 0, count: 16)
    
    public subscript(row: Int, col: Int) -> Double {
        get {
            assert(row >= 0 && row <= 4, "Row index out of bounds")
            assert(col >= 0 && col <= 4, "Column index out of bounds")
            return matrix[row + col * 4]
        }
        set {
            assert(row >= 0 && row <= 4, "Row index out of bounds")
            assert(col >= 0 && col <= 4, "Column index out of bounds")
            matrix[row + col * 4] = newValue
        }
    }
    
    public init() {
        self[0, 0] = 1
        self[1, 1] = 1
        self[2, 2] = 1
        self[3, 3] = 1
    }
    
    public init(_ t: CGAffineTransform) {
        self.init()
        self[0, 0] = Double(t.a)
        self[0, 1] = Double(t.b)
        self[1, 0] = Double(t.c)
        self[1, 1] = Double(t.d)
        self[0, 3] = Double(t.tx)
        self[1, 3] = Double(t.ty)
    }
    
    public init(_ t: CATransform3D) {
        self[0, 0] = Double(t.m11)
        self[0, 1] = Double(t.m12)
        self[0, 2] = Double(t.m13)
        self[0, 3] = Double(t.m14)
        self[1, 0] = Double(t.m21)
        self[1, 1] = Double(t.m22)
        self[1, 2] = Double(t.m23)
        self[1, 3] = Double(t.m24)
        self[2, 0] = Double(t.m31)
        self[2, 1] = Double(t.m32)
        self[2, 2] = Double(t.m33)
        self[2, 3] = Double(t.m34)
        self[3, 0] = Double(t.m41)
        self[3, 1] = Double(t.m42)
        self[3, 2] = Double(t.m43)
        self[3, 3] = Double(t.m44)
    }
    
    public func isAffine() -> Bool {
        return self[3, 0] == 0.0 &&
            self[3, 1] == 0.0 &&
            self[3, 2] == 0.0 &&
            self[3, 3] == 1.0
    }
    
    public var translation: Vector {
        get {
            return Vector(x: self[3, 0], y: self[3, 1])
        }
        set {
            self[3, 0] = newValue.x
            self[3, 1] = newValue.y
        }
    }
    
    public static func makeTranslation(_ translation: Vector) -> Transform {
        var t = Transform()
        t[3, 0] = translation.x
        t[3, 1] = translation.y
        return t
    }
    
    public static func makeScale(_ sx: Double, _ sy: Double, _ sz: Double = 1) -> Transform {
        var t = Transform()
        t[0, 0] = sx
        t[1, 1] = sy
        t[2, 2] = sz
        return t
    }
    
    public static func makeRotation(_ angle: Double, axis: Vector = Vector(x: 0, y: 0, z: 1)) -> Transform {
        guard !axis.isZero(), let unitAxis = axis.unitVector() else {
            return Transform()
        }
        let ux = unitAxis.x
        let uy = unitAxis.y
        let uz = unitAxis.z
        
        let ca = cos(angle)
        let sa = sin(angle)
        
        var t = Transform()
        t[0, 0] = ux * ux * (1 - ca) + ca
        t[0, 1] = ux * uy * (1 - ca) - uz * sa
        t[0, 2] = ux * uz * (1 - ca) + uy * sa
        t[1, 0] = uy * ux * (1 - ca) + uz * sa
        t[1, 1] = uy * uy * (1 - ca) + ca
        t[1, 2] = uy * uz * (1 - ca) - ux * sa
        t[2, 0] = uz * ux * (1 - ca) - uy * sa
        t[2, 1] = uz * uy * (1 - ca) + ux * sa
        t[2, 2] = uz * uz * (1 - ca) + ca
        return t
    }
    
    public mutating func translate(_ translation: Vector) {
        let t = Transform.makeTranslation(translation)
        self = contact(self, t2: t)
    }
    
    public mutating func scale(_ sx: Double, _ sy: Double, _ sz: Double = 1) {
        let s = Transform.makeScale(sx, sy, sz)
        self = contact(self, t2: s)
    }
    
    public mutating func rotate(_ angle: Double, axis: Vector = Vector(x: 0, y: 0, z:  1)) {
        let r = Transform.makeRotation(angle, axis: axis)
        self = contact(self, t2: r)
    }
    
    public var affineTransform: CGAffineTransform {
        return CGAffineTransform(a: CGFloat(self[0, 0]),
                                 b: CGFloat(self[0, 1]),
                                 c: CGFloat(self[1, 0]),
                                 d: CGFloat(self[1, 1]),
                                 tx: CGFloat(self[3, 0]),
                                 ty: CGFloat(self[3, 1]))
    }
    
    public var transform3D: CATransform3D {
        let t = CATransform3D(m11: CGFloat(self[0, 0]),
                              m12: CGFloat(self[0, 1]),
                              m13: CGFloat(self[0, 2]),
                              m14: CGFloat(self[0, 3]),
                              m21: CGFloat(self[1, 0]),
                              m22: CGFloat(self[1, 1]),
                              m23: CGFloat(self[1, 2]),
                              m24: CGFloat(self[1, 3]),
                              m31: CGFloat(self[2, 0]),
                              m32: CGFloat(self[2, 1]),
                              m33: CGFloat(self[2, 2]),
                              m34: CGFloat(self[2, 3]),
                              m41: CGFloat(self[3, 0]),
                              m42: CGFloat(self[3, 1]),
                              m43: CGFloat(self[3, 2]),
                              m44: CGFloat(self[3, 3]))
        return t
    }
}

public func == (lhs: Transform, rhs: Transform) -> Bool {
    var equal = true
    for col in 0...3 {
        for row in 0...3 {
            equal = equal && lhs[row, col] == rhs[row, col]
        }
    }
    return equal
}


public func * (lhs: Transform, rhs: Transform) -> Transform {
    var t = Transform()
    for col in 0...3 {
        for row in 0...3 {
            t[row, col] = lhs[row, 0] * rhs[0, col] + lhs[row, 1] * rhs[1, col] + lhs[row, 2] * rhs[2, row] + lhs[row, 3] * rhs[3, col]
        }
    }
    return t
}

public func * (t: Transform, s: Double) -> Transform {
    var r = Transform()
    for col in 0...3 {
        for row in 0...3 {
            r[row, col] = t[row, col] * s
        }
    }
    return r
}

public func * (s: Double, t: Transform) -> Transform {
    return t * s
}

public func contact(_ t1: Transform, t2: Transform) -> Transform {
    return t2 * t1
}

public func inverse(_ t: Transform) -> Transform {
    return Transform(CATransform3DInvert(t.transform3D))
}
