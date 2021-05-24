//
//  View+Shadow.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import CoreGraphics

public struct Shadow {
    public var radius: Double
    public var color: Color?
    public var offset: Size
    public var opacity: Double
    public var path: Path?
    
    public init() {
        radius = 5
        color = Color(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        offset = Size(5, 5)
        opacity = 0
    }
}

public extension View {
    var shadow: Shadow {
        get {
            var shadow = Shadow()
            if let layer = layer {
                shadow.radius = Double(layer.shadowRadius)
                if let color = layer.shadowColor {
                    shadow.color = Color(color)
                }
                shadow.offset = Size(layer.shadowOffset)
                shadow.opacity = Double(layer.opacity)
                if let path = layer.shadowPath {
                    shadow.path = Path(path: path)
                }
            }
            return shadow
        }
        set {
            if let layer = layer {
                layer.shadowColor = newValue.color?.cgColor
                layer.shadowRadius = CGFloat(newValue.radius)
                layer.shadowOffset = CGSize(newValue.offset)
                layer.shadowOpacity = Float(newValue.opacity)
                layer.shadowPath = newValue.path?.CGPath
            }
        }
    }
}
