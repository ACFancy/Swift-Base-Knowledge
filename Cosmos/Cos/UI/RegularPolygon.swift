//
//  RegularPolygon.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import Foundation

public class RegularPolygon : Polygon {

    @IBInspectable
    public var sides: Int = 6 {
        didSet {
            assert(sides > 0)
            updatePath()
        }
    }

    @IBInspectable
    public var phase: Double = 0 {
        didSet {
            updatePath()
        }
    }

    public convenience init(center: Point, radius: Double = 50, sides: Int = 6, phase: Double = 0) {
        let delta = 2 * Double.pi / Double(sides)
        var pointArray: [Point] = []
        for i in 0..<sides {
            let angle = phase + delta * Double(i)
            pointArray.append(Point(radius * cos(angle), radius * sin(angle)))
        }
        self.init(pointArray)
        close()
        fillColor = C4Blue
        self.center = center
    }

    override func updatePath() {
        self.path = RegularPolygon(center: center, radius: width / 2, sides: sides, phase: phase).path
    }
}
