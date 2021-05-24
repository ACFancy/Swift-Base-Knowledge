//
//  View+Render.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import UIKit

public extension View {
    @objc func render() -> Image? {
        guard let l = layer else {
            debugPrint("Could not retrieve layer for current object: \(self)")
            return nil
        }
        UIGraphicsBeginImageContextWithOptions(CGSize(size), false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()!
        l.render(in: context)
        let uiimage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return Image(uiimage: uiimage!)
    }
}

public extension Shape {
    override func render() -> Image? {
        var s = CGSize(size)
        var inset: CGFloat = 0
        if let alpha = strokeColor?.alpha, alpha > 0, lineWidth > 0 {
            inset = CGFloat(lineWidth / 2)
            s = CGRect(frame).insetBy(dx: -inset, dy: -inset).size
        }
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(s, false, scale)
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: CGFloat(-bounds.origin.x) + inset, y: CGFloat(-bounds.origin.y) + inset)
        shapeLayer.render(in: context)
        let uiimage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let img = uiimage else {
            return nil
        }
        return Image(uiimage: img)
    }
}
