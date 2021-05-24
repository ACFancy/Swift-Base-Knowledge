//
//  Arc.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import QuartzCore
import UIKit

public class Arc : Shape {
    public convenience init(center: Point, radius: Double, start: Double, end: Double) {
        self.init(center: center, radius: radius, start: start, end: end, closewise: (end <= start))
    }

    public init(center: Point, radius: Double, start: Double, end: Double, closewise: Bool) {
        super.init()
        let arc = CGMutablePath()
        arc.addArc(center:CGPoint(center), radius: CGFloat(radius), startAngle: CGFloat(start), endAngle: CGFloat(end), clockwise: closewise)
        path = Path(path: arc)
        adjustToFitPath()
    }
}
