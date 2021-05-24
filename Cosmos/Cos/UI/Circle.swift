//
//  Circle.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import Foundation
import CoreGraphics

open class Circle : Ellipse {
    public convenience init(center: Point, radius: Double) {
        let frame = Rect(center.x - radius, center.y - radius, radius * 2, radius * 2)
        self.init(frame: frame)
    }
}
