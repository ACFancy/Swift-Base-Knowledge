//
//  Ellipse.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import Foundation
import CoreGraphics

open class Ellipse : Shape {
    public override init(frame: Rect) {
        super.init()
        view.frame = CGRect(frame)
        updatePath()
    }

    override func updatePath() {
        let newPath = path
        newPath?.addEllipse(bounds)
        path = newPath
    }
}
