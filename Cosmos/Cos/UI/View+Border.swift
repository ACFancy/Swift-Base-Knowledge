//
//  View+Border.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import CoreGraphics

public struct Border {
    public var color: Color?
    public var radius: Double
    public var width: Double
    public init() {
        color = Color(red: 0, green: 0, blue: 0, alpha: 1)
        radius = 0
        width = 0
    }
}

public extension View {
    var border: Border {
        get {
            var border = Border()
            if let layer = layer {
                if let borderColor = layer.borderColor {
                    border.color = Color(borderColor)
                }
                border.radius = Double(layer.cornerRadius)
                border.width = Double(layer.borderWidth)
            }
            return border
        }
        set {
            if let layer = layer {
                layer.borderWidth = CGFloat(newValue.width)
                if let color = newValue.color {
                    layer.borderColor = color.cgColor
                }
                layer.cornerRadius = CGFloat(newValue.radius)
            }
        }
    }
}
