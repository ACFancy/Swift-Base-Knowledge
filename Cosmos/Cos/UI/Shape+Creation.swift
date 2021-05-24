//
//  Shape+Creation.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import Foundation
import CoreGraphics

extension Shape {
    public func addCircle(center: Point, radius: Double) {
        var newPath = path
        if newPath == nil {
            newPath = Path()
        }
        let r = Rect(center.x - radius, center.y - radius, radius * 2, radius * 2)
        newPath?.addEllipse(r)
        path = newPath
        adjustToFitPath()
    }
    
    public func addPolygon(points: [Point], closed: Bool = true) {
        var newPath = path
        if newPath == nil {
            newPath = Path()
        }
        if let firstPoint = points.first {
            newPath?.moveToPoint(firstPoint)
        }
        for point in points {
            newPath?.addLineToPoint(point)
        }
        if closed {
            newPath?.closeSubPath()
        }
        path = newPath
        adjustToFitPath()
    }
    
    public func addLine(_ points: [Point]) {
        var newPath = path
        if newPath == nil {
            newPath = Path()
        }
        if newPath?.currentPoint != points.first {
            newPath?.moveToPoint(points.first!)
        }
        newPath?.addLineToPoint(points[1])
        path = newPath
        adjustToFitPath()
    }
    
    public func addCurve(points: [Point], controls: [Point]) {
        var newPath = path
        if newPath == nil {
            newPath = Path()
        }
        if newPath?.currentPoint != points.first {
            newPath?.moveToPoint(points.first!)
        }
        newPath?.addCurveToPoint(points[1], control1: controls[0], control2: controls[1])
        path = newPath
        adjustToFitPath()
    }
}
