//
//  Wedge.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import UIKit

public class Wedge : Shape {
    
    public convenience init(center: Point, radius: Double, start: Double, end: Double) {
        self.init(center: center, radius: radius, start: start, end: end, closewise: start <= end)
    }
    
    public init(center: Point, radius: Double, start: Double, end: Double, closewise: Bool) {
        super.init()
        let wedge = CGMutablePath()
        wedge.addArc(center: CGPoint(center), radius: CGFloat(radius), startAngle: CGFloat(start), endAngle: CGFloat(end), clockwise: closewise)
        wedge.addLine(to: CGPoint(center))
        wedge.closeSubpath()
        path = Path(path: wedge)
        adjustToFitPath()
    }
}


