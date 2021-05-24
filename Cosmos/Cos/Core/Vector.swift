//
//  Vector.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/18.
//

import CoreGraphics

public struct Vector : Equatable, CustomStringConvertible {
    
    public var x: Double = 0
    public var y: Double = 0
    public var z: Double = 0
    
    public init() {
    }
    
    public init(x: Double, y: Double, z: Double = 0) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    public init(x: Int, y: Int, z: Int = 0) {
        self.x = Double(x)
        self.y = Double(y)
        self.z = Double(z)
    }
    
    public init(magnitude: Double, heading: Double, z: Double = 0) {
        x = magnitude * cos(heading)
        y = magnitude * sin(heading)
        self.z = z
    }
    
    public init(_ point: CGPoint) {
        x = Double(point.x)
        y = Double(point.y)
        z = 0
    }
    
    public init(copy original: Vector) {
        x = original.x
        y = original.y
        z = original.z
    }
    
    public var magnitude: Double {
        get {
            return sqrt(x * x + y * y + z * z)
        }
        set {
            x = newValue * cos(heading)
            y = newValue * sin(heading)
        }
    }
    
    public var heading: Double {
        get {
            return atan2(y, x)
        }
        set {
            x = magnitude * cos(newValue)
            y = magnitude * sin(newValue)
        }
    }
    
    public func angleTo(_ vec: Vector) -> Double {
        return acos(self ⋅ (vec / (self.magnitude * vec.magnitude)))
    }
    
    public func angleTo(_ vec: Vector, basedOn: Vector) -> Double {
        var vecA = self
        var vecB = vec
        vecA -= basedOn
        vecB -= basedOn
        return acos(vecA ⋅ (vecB / (vecA.magnitude * vecB.magnitude)))
    }
    
    public func dot(_ vec: Vector) -> Double {
        return x * vec.x + y * vec.y + z * vec.z
    }
    
    public func unitVector() -> Vector? {
        guard magnitude != 0.0 else {
            return nil
        }
        return Vector(x: x / magnitude, y: y / magnitude, z: z / magnitude)
    }
    
    public func isZero() -> Bool {
        return x == 0 && y == 0 && z == 0
    }
    
    public mutating func transform(_ t: Transform) {
        x = x * t[0, 0] + y * t[0, 1] + z * t[0, 2]
        y = x * t[1, 0] + y * t[1, 1] + z * t[1, 2]
        z = x * t[2, 0] + y * t[2, 1] + z * t[2, 2]
    }
    
    public var description: String {
        return "{\(x), \(y), \(z)}"
    }
}

public func == (lhs: Vector, rhs: Vector) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
}

public func += (lhs: inout Vector, rhs: Vector) {
    lhs.x += rhs.x
    lhs.y += rhs.y
    lhs.z += rhs.z
}

public func -= (lhs: inout Vector, rhs: Vector) {
    lhs.x -= rhs.x
    lhs.y -= rhs.y
    lhs.z -= rhs.z
}

public func *= (lhs: inout Vector, rhs: Vector) {
    lhs.x *= rhs.x
    lhs.y *= rhs.y
    lhs.z *= rhs.z
}

public func /= (lhs: inout Vector, rhs: Vector) {
    lhs.x /= rhs.x
    lhs.y /= rhs.y
    lhs.z /= rhs.z
}

public func + (lhs: Vector, rhs: Vector) -> Vector {
    return Vector(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
}

public func - (lhs: Vector, rhs: Vector) -> Vector {
    return Vector(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
}

infix operator ⋅
public func ⋅ (lhs: Vector, rhs: Vector) -> Double {
    return lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z
}

public func / (lhs: Vector, rhs: Double) -> Vector {
    return Vector(x: lhs.x / rhs, y: lhs.y / rhs, z: lhs.z / rhs)
}

public func * (lhs: Vector, rhs: Double) -> Vector {
    return Vector(x: lhs.x * rhs, y: lhs.y * rhs, z: lhs.z * rhs)
}

public func * (lhs: Double, rhs: Vector) -> Vector {
    return Vector(x: lhs * rhs.x, y: lhs * rhs.y, z: lhs * rhs.z)
}

public prefix func - (vector: Vector) -> Vector {
    return Vector(x: -vector.x, y: -vector.y, z: -vector.z)
}
