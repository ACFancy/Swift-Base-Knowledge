//
//  Curve.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import QuartzCore
import UIKit

public class Curve : Shape {
    public var endPoints = (Point(), Point()) {
        didSet {
            updatePath()
            adjustToFitPath()
        }
    }
    
    public var controlPoints = (Point(), Point()) {
        didSet {
            updatePath()
            adjustToFitPath()
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
                self.controlPoints.0 += diff
                self.controlPoints.1 += diff
            }
        }
    }
    
    public convenience init(begin: Point, control0: Point, control1: Point, end: Point) {
        self.init()
        endPoints = (begin, end)
        controlPoints = (control0, control1)
        updatePath()
        adjustToFitPath()
    }
    
    private var pauseUpdates = false
    func batchUpdates(_ updates: () -> Void) {
        pauseUpdates = true
        updates()
        pauseUpdates = false
        updatePath()
        adjustToFitPath()
    }
    
    override func updatePath() {
        if pauseUpdates {
            return
        }
        let curve = CGMutablePath()
        curve.move(to: CGPoint(endPoints.0))
        curve.addCurve(to: CGPoint(endPoints.1), control1: CGPoint(controlPoints.0), control2: CGPoint(controlPoints.1), transform: .identity)
        path = Path(path: curve)
    }
}
