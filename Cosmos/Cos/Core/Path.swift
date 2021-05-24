//
//  Path.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import QuartzCore

public enum FillRule {
    case nonZero
    case evenOdd
}

@IBDesignable
public class Path : Equatable {
    internal var internalPath: CGMutablePath = CGMutablePath()

    public init() {
        internalPath = CGMutablePath()
        internalPath.move(to: CGPoint())
    }

    public init(path: CoreGraphics.CGPath) {
        internalPath = path.mutableCopy()!
    }

    public func isEmpty() -> Bool {
        return internalPath.isEmpty
    }

    public func boundingBoxOfPath() -> Rect {
        return Rect(internalPath.boundingBoxOfPath)
    }

    public func bondingBox() -> Rect {
        return Rect(internalPath.boundingBox)
    }

    public func containsPoint(_ point: Point, fillRule: FillRule = .nonZero) -> Bool {
        let rule = fillRule == .evenOdd ? CGPathFillRule.evenOdd : CGPathFillRule.winding
        return internalPath.contains(CGPoint(point), using: rule, transform: .identity)
    }

    public func copy() -> Path {
        return Path(path: internalPath.mutableCopy()!)
    }

    public var CGPath: CoreGraphics.CGPath {
        return internalPath
    }
}

public func == (left: Path, right: Path) -> Bool {
    return left.internalPath == right.internalPath
}

extension Path {
    public var currentPoint: Point {
        get {
            return Point(internalPath.currentPoint)
        }
        set {
            moveToPoint(newValue)
        }
    }

    public func moveToPoint(_ point: Point) {
        internalPath.move(to: CGPoint(point))
    }

    public func addLineToPoint(_ point: Point) {
        internalPath.addLine(to: CGPoint(point))
    }

    public func addQuadCurveToPoint(_ point: Point, control: Point) {
        internalPath.addQuadCurve(to: CGPoint(point), control: CGPoint(point))
    }

    public func addCurveToPoint(_ point: Point, control1: Point, control2: Point) {
        internalPath.addCurve(to: CGPoint(point), control1: CGPoint(control1), control2: CGPoint(control2))
    }

    public func closeSubPath() {
        internalPath.closeSubpath()
    }

    public func addRect(_ rect: Rect) {
        internalPath.addRect(CGRect(rect))
    }

    public func addRoundedRect(_ rect: Rect, cornerWidth: Double, cornerHeight: Double) {
        internalPath.addRoundedRect(in: CGRect(rect), cornerWidth: CGFloat(cornerWidth), cornerHeight: CGFloat(cornerHeight))
    }

    public func addEllipse(_ rect: Rect) {
        internalPath.addEllipse(in: CGRect(rect))
    }

    public func addRelativeArc(_ center: Point, radius: Double, startAngle: Double, delta: Double) {
        internalPath.addRelativeArc(center: CGPoint(center), radius: CGFloat(radius), startAngle: CGFloat(startAngle), delta: CGFloat(delta))
    }

    public func addArc(_ center: Point, radius: Double, startAngle: Double, endAngle: Double, closewise: Bool) {
        internalPath.addArc(center: CGPoint(center), radius: CGFloat(radius), startAngle: CGFloat(startAngle), endAngle: CGFloat(endAngle), clockwise: closewise)
    }

    public func addArcToPoint(_ point1: Point, point2: Point, radius: Double) {
        internalPath.addArc(tangent1End: CGPoint(point1), tangent2End: CGPoint(point2), radius: CGFloat(radius))
    }

    public func addPath(_ path: Path) {
        internalPath.addPath(path.internalPath)
    }

    public func transform(_ transform: Transform) {
        var t = transform.affineTransform
        internalPath = internalPath.mutableCopy(using: &t)!
    }
}
