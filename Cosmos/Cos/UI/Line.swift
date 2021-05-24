//
//  Line.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import Foundation
import CoreGraphics

public class Line : Polygon {
    public var endPoints: (Point, Point) {
        get {
            return (points[0], points[1])
        }
        set {
            self.points = [newValue.0, newValue.1]
        }
    }
    
    public override var center: Point {
        get {
            return Point(view.center)
        }
        set {
            let diff = newValue - center
            batchUpdates {
                self.endPoints.0 += diff
                self.endPoints.1 += diff
            }
        }
    }
    
    public override var origin: Point {
        get {
            return Point(view.frame.origin)
        }
        set {
            let diff = newValue - origin
            batchUpdates {
                self.endPoints.0 += diff
                self.endPoints.1 += diff
            }
        }
    }
    
    public override var points: [Point] {
        didSet {
            guard points.count >= 2 else {
                debugPrint("xx")
                return
            }
            if points.count == 2 {
                updatePath()
            } else {
                points = [Point](points[0...1])
            }
        }
    }
    
    public override init(_ points: [Point]) {
        let firstTwo = [Point](points[0...1])
        super.init(firstTwo)
        updatePath()
    }
    
    public init(_ points: (Point, Point)) {
        super.init([points.0, points.1])
    }
    
    public convenience init(begin: Point, end: Point) {
        let points = (begin, end)
        self.init(points)
    }
    
    override func updatePath() {
        if pauseUpdates {
            return
        }
        let p = Path()
        p.moveToPoint(endPoints.0)
        p.addLineToPoint(endPoints.1)
        path = p
        adjustToFitPath()
    }
    
    private var pauseUpdates = false
    func batchUpdates(_ updates: () -> Void) {
        pauseUpdates = true
        updates()
        pauseUpdates = false
        updatePath()
    }
}
