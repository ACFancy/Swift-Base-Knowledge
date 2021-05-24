//
//  View+KeyValues.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import UIKit

extension View {
    open override func setValue(_ value: Any?, forKey key: String) {
        switch (key, value) {
        case ("frame", let nsvalue as NSValue):
            frame = Rect(nsvalue.cgRectValue)
        case ("bounds", let nsvalue as NSValue):
            bounds = Rect(nsvalue.cgRectValue)
        case ("center", let nsvalue as NSValue):
            center = Point(nsvalue.cgPointValue)
        case ("origin", let nsvalue as NSValue):
            origin = Point(nsvalue.cgPointValue)
        case ("size", let nsvalue as NSValue):
            size = Size(nsvalue.cgSizeValue)
        case ("backgrounColor", let color as UIColor):
            backgroundColor = Color(color)
        default:
            super.setValue(value, forKey: key)
        }
    }
    
    open override func value(forKey key: String) -> Any? {
        switch key {
        case "frame":
            return NSValue(cgRect: CGRect(frame))
        case "bounds":
            return NSValue(cgRect: CGRect(bounds))
        case "center":
            return NSValue(cgPoint: CGPoint(center))
        case "origin":
            return NSValue(cgPoint: CGPoint(origin))
        case "size":
            return NSValue(cgSize: CGSize(size))
        case "backgroundColor":
            if let color = backgroundColor {
                return UIColor(color)
            }
            return nil
        default:
            return super.value(forKey: key)
        }
    }
}
