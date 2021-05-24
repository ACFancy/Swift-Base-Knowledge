//
//  QuardCurve.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import QuartzCore
import UIKit

public class QuadCurve : Curve {
    public var controlPoint: Point {
        get {
            return controlPoints.0
        }
        set {
            self.controlPoints = (newValue, newValue)
        }
    }

    public convenience init(begin: Point, control: Point, end: Point) {
        self.init(begin: begin, control0: control, control1: control, end: end)
    }
}
