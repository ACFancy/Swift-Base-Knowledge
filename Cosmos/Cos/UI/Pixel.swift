//
//  Pixel.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import Foundation

public struct Pixel {
    var r: UInt8 = 0
    var g: UInt8 = 0
    var b: UInt8 = 0
    var a: UInt8 = 255
    
    
    public init(gray: Int) {
        self.init(gray, gray, gray, 255)
    }
    
    public init(_ r: Int, _ g: Int, _ b: Int, _ a: Int) {
        self.r = UInt8(r)
        self.g = UInt8(g)
        self.b = UInt8(b)
        self.a = UInt8(a)
    }
    
    public init(_ color: Color) {
        let rgba: [Int] = color.components.map({ Int($0 * 255.0) })
        self.init(rgba[0], rgba[1], rgba[2], rgba[3])
    }
}
