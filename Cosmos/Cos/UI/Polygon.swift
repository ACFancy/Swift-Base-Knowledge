//
//  Polygon.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import Foundation
import CoreGraphics

open class Polygon : Shape {
    public var points: [Point] {
        didSet {
            updatePath()
        }
    }
    
    public override init() {
        self.points = []
        super.init()
        fillColor = clear
    }
    
    public init(_ points: [Point]) {
        assert(points.count >= 2, "xxx")
        self.points = points
        super.init()
        fillColor = clear
        updatePath()
    }
    
    override func updatePath() {
        guard points.count > 1 else {
            return
        }
        let p = Path()
        p.moveToPoint(points.first!)
        for point in points.dropFirst() {
            p.addLineToPoint(point)
        }
        path = p
        adjustToFitPath()
    }
    
    public func close() {
        let p = path
        p?.closeSubPath()
        self.path = p
        adjustToFitPath()
    }
    
}
