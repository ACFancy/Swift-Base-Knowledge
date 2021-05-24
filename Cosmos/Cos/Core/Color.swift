//
//  Color.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import Foundation
import CoreGraphics
import UIKit

/// A Color object whose RGB value is 0, 0, 0 and whose alpha value is 1.0.
public let black     = Color(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
/// A Color object whose RGB value is 0.33, 0.33, 0.33 and whose alpha value is 1.0.
public let darkGray  = Color(red: 1.0/3.0, green: 1.0/3.0, blue: 1.0/3.0, alpha: 1.0)
/// A Color object whose RGB value is 0.66, 0.66, 0.66 and whose alpha value is 1.0.
public let lightGray = Color(red: 2.0/3.0, green: 2.0/3.0, blue: 2.0/3.0, alpha: 1.0)
/// A Color object whose RGB value is 1.0, 1.0, 1.0 and whose alpha value is 1.0.
public let white     = Color(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
/// A Color object whose RGB value is 0.5, 0.5, 0.5 and whose alpha value is 1.0.
public let gray      = Color(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
/// A Color object whose RGB value is 1.0, 0.0, 0.0 and whose alpha value is 1.0.
public let red       = Color(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
/// A Color object whose RGB value is 0.0, 1.0, 0.0 and whose alpha value is 1.0.
public let green     = Color(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
/// A Color object whose RGB value is 0.0, 0.0, 1.0 and whose alpha value is 1.0.
public let blue      = Color(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
/// A Color object whose RGB value is 0.0, 1.0, 1.0 and whose alpha value is 1.0.
public let cyan      = Color(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0)
/// A Color object whose RGB value is 1.0, 1.0, 0.0 and whose alpha value is 1.0.
public let yellow    = Color(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)
/// A Color object whose RGB value is 1.0, 0.0, 1.0 and whose alpha value is 1.0.
public let magenta   = Color(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0)
/// A Color object whose RGB value is 1.0, 0.5, 0.0 and whose alpha value is 1.0.
public let orange    = Color(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)
/// A Color object whose RGB value is 0.5, 0.0, 0.5 and whose alpha value is 1.0.
public let purple    = Color(red: 0.5, green: 0.0, blue: 0.5, alpha: 1.0)
/// A Color object whose RGB value is 0.6, 0.4, 0.2 and whose alpha value is 1.0.
public let brown     = Color(red: 0.6, green: 0.4, blue: 0.2, alpha: 1.0)
/// A Color object whose RGB value is 0.0, 0.0, 0.0 and whose alpha value is 0.0.
public let clear     = Color(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)

///A Color object whose RGB value is 1.0, 0.0, 0.475 and whose alpha value is 1.0.
public let C4Pink    = Color(red: 1.0, green: 0.0, blue: 0.475, alpha: 1.0)
///A Color object whose RGB value is 0.098, 0.271, 1.0 and whose alpha value is 1.0.
public let C4Blue    = Color(red: 0.098, green: 0.271, blue: 1.0, alpha: 1.0)
///A Color object whose RGB value is 0.0, 0.0, 0.541 and whose alpha value is 1.0.
public let C4Purple  = Color(red: 0.0, green: 0.0, blue: 0.541, alpha: 1.0)
///A Color object whose RGB value is 0.98, 0.98, 0.98 and whose alpha value is 1.0.
public let C4Grey    = Color(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)

public class Color {
    internal var colorSpace: CGColorSpace
    internal var internalColor: CGColor
    
    public init() {
        colorSpace = CGColorSpaceCreateDeviceRGB()
        internalColor = CGColor(colorSpace: colorSpace, components: [0, 0, 0, 0])!
    }
    
    public init(red: Double, green: Double, blue: Double, alpha: Double) {
        colorSpace = CGColorSpaceCreateDeviceRGB()
        internalColor = CGColor(colorSpace: colorSpace,
                                components: [CGFloat(red), CGFloat(green), CGFloat(blue), CGFloat(alpha)])!
    }
    
    public init(hue: Double, saturation: Double, brightness: Double, alpha: Double) {
        let color = UIColor(hue: CGFloat(hue), saturation: CGFloat(saturation), brightness: CGFloat(saturation), alpha: CGFloat(alpha))
        let floatComponents = color.cgColor.components
        colorSpace = CGColorSpaceCreateDeviceRGB()
        internalColor = CGColor(colorSpace: colorSpace, components: floatComponents!)!
    }
    
    public init(_ color: CoreGraphics.CGColor) {
        colorSpace = CGColorSpaceCreateDeviceRGB()
        internalColor = color
    }
    
    public convenience init(_ color: UIColor) {
        self.init(color.cgColor)
    }
    
    public convenience init(_ pattern: String) {
        self.init(UIColor(patternImage: UIImage(named: pattern)!))
    }
    
    public convenience init(_ patternImage: Image) {
        self.init(UIColor(patternImage: patternImage.uiimage))
    }
    
    public convenience init(red: Int, green: Int, blue: Int, alpha: Double) {
        self.init(red: Double(red) / 255.0, green: Double(green) / 255.0, blue: Double(blue) / 255.0, alpha: alpha)
    }
    
    public convenience init(_ hexValue: UInt32) {
        let mask = 0x0000000FF
        let red = Int(hexValue >> 16) & mask
        let green = Int(hexValue >> 8) & mask
        let blue = Int(hexValue) & mask
        
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
    
    public var components: [Double] {
        get {
            guard let floatComponents = internalColor.components else {
                return [0, 0, 0, 0]
            }
            return [Double(floatComponents[0]),
                    Double(floatComponents[1]),
                    Double(floatComponents[2]),
                    Double(floatComponents[3])]
        }
        set {
            let floatComponents = [CGFloat(newValue[0]),
                                   CGFloat(newValue[1]),
                                   CGFloat(newValue[2]),
                                   CGFloat(newValue[3])]
            internalColor = CoreGraphics.CGColor(colorSpace: colorSpace, components: floatComponents)!
        }
    }
    
    public var red: Double {
        get {
            return components[0]
        }
        set {
            components[0] = newValue
        }
    }
    
    public var green: Double {
        get {
            return components[1]
        }
        set {
            components[1] = newValue
        }
    }
    
    public var blue: Double {
        get {
            return components[2]
        }
        set {
            components[2] = newValue
        }
    }
    
    public var alpha: Double {
        get {
            return components[3]
        }
        set {
            components[3] = newValue
        }
    }
    
    public var hue: Double {
        let r = components[0]
        let g = components[1]
        let b = components[2]
        
        let _min = min(r, min(g, b))
        let _max = max(r, max(g, b))
        
        if _min == _max {
            return 0
        } else {
            let d = (red == _min) ? (green - blue) : (blue == _min ? red - green : blue - red)
            let h = (red == _min ? 3.0 : (blue == _min ? 1.0 : 5.0))
            return (h - d / (_max - _min)) / 6.0
        }
    }
    
    public var saturation: Double {
        let r = components[0]
        let g = components[1]
        let b = components[2]
        
        let _min = min(r, min(g, b))
        let _max = max(r, max(g, b))
        return _max == 0 ? 0 : (_max - _min) / _max
    }
    
    public var brightness: Double {
        let r = components[0]
        let g = components[1]
        let b = components[2]
        return max(r, max(g, b))
    }
    
    public var cgColor: CGColor {
        return internalColor
    }
    
    public func colorWithAlpha(_ alpha: Double) -> Color {
        return Color(red: red, green: green, blue: blue, alpha: alpha)
    }
}

public extension UIColor {
    convenience init?(_ color: Color) {
        self.init(cgColor: color.cgColor)
    }
}

public extension CIColor {
    convenience init(_ color: Color) {
        self.init(cgColor: color.cgColor)
    }
}
