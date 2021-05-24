//
//  Star.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import Foundation


public class Star : Polygon {
    public convenience init(center: Point, pointCount: Int, innerRadius: Double, outerRadius: Double) {
        let wedgeAngle = 2 * Double.pi / Double(pointCount)
        var angle = Double.pi / Double(pointCount) - Double.pi
        var pointArray: [Point] = []
        for i in 0..<pointCount * 2 {
            angle += wedgeAngle / 2
            if i % 2 != 0 {
                pointArray.append(Point(innerRadius * cos(angle), innerRadius * sin(angle)))
            } else {
                pointArray.append(Point(outerRadius * cos(angle), outerRadius * sin(angle)))
            }
        }
        self.init(pointArray)
        close()
        fillColor = C4Blue
        self.center = center
    }
}
