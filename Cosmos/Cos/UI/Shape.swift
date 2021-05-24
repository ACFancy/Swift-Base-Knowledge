//
//  Shape.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import QuartzCore
import UIKit

open class Shape : View {
    public enum LineCap {
        case butt
        case round
        case square
    }

    public enum LineJoin {
        case miter
        case round
        case bevel
    }


    internal class ShapeView : UIView {
        var shapeLayer: ShapeLayer {
            return self.layer as! ShapeLayer
        }

        override class var layerClass: AnyClass {
            return ShapeLayer.self
        }

        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            if let subview = super.hitTest(point, with: event) {
                return subview
            }
            guard let path = shapeLayer.path else {
                return nil
            }
            let fillRule = shapeLayer.fillRule == .nonZero ? CGPathFillRule.evenOdd : CGPathFillRule.winding
            if path.contains(point, using: fillRule, transform: .identity) {
                return self
            }
            return nil
        }
    }

    internal var shapeView: ShapeView {
        return self.view as! ShapeView
    }

    open var shapeLayer: ShapeLayer {
        return shapeView.shapeLayer
    }

    public var gradientFill: Gradient? {
        didSet {
            guard let gradientFill = gradientFill else {
                fillColor = clear
                return
            }
            let gim = gradientFill.render()?.cgImage

            var b = bounds
            b.origin.y = height - b.origin.y

            UIGraphicsBeginImageContextWithOptions(CGSize(b.size), false, UIScreen.main.scale)
            let context = UIGraphicsGetCurrentContext()
            context?.draw(gim!, in: CGRect(b), byTiling: true)
            let uiimage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            let uicolor = UIColor(patternImage: uiimage!)
            fillColor = Color(uicolor)
        }
    }

    public var path: Path? {
        didSet {
            shapeLayer.path = path?.CGPath
        }
    }

    public var fillColor: Color? {
        get {
            return shapeLayer.fillColor.map({ Color($0) })
        }
        set {
            shapeLayer.fillColor = newValue?.cgColor
        }
    }

    public var fileRule: FillRule {
        get {
            switch shapeLayer.fillRule {
            case .nonZero:
                return .nonZero
            case .evenOdd:
                return .evenOdd
            default:
                return .nonZero
            }
        }
        set {
            switch newValue {
            case .nonZero:
                shapeLayer.fillRule = .nonZero
            case .evenOdd:
                shapeLayer.fillRule = .evenOdd
            }
        }
    }

    public override var frame: Rect {
        get {
            return Rect(view.frame)
        }
        set {
            view.frame = CGRect(newValue)
            updatePath()
        }
    }

    @IBInspectable
    public var lineWidth: Double {
        get {
            return Double(shapeLayer.lineWidth)
        }
        set {
            shapeLayer.lineWidth = CGFloat(newValue)
        }
    }

    public var strokeColor: Color? {
        get {
            return shapeLayer.strokeColor.map({ Color($0) })
        }
        set {
            shapeLayer.strokeColor = newValue?.cgColor
        }
    }

    open override var rotation: Double {
        get {
            if let number = shapeLayer.value(forKeyPath: Layer.rotationKey) as? NSNumber {
                return number.doubleValue
            }
            return 0
        }
        set {
            shapeLayer.setValue(newValue, forKeyPath: Layer.rotationKey)
        }
    }

    public var strokeStart: Double {
        get {
            return Double(shapeLayer.strokeStart)
        }
        set {
            shapeLayer.strokeStart = CGFloat(newValue)
        }
    }

    public var strokeEnd: Double {
        get {
            return Double(shapeLayer.strokeEnd)
        }
        set {
            shapeLayer.strokeEnd = CGFloat(newValue)
        }
    }

    @IBInspectable
    public var miterLimit: Double {
        get {
            return Double(shapeLayer.miterLimit)
        }
        set {
            shapeLayer.miterLimit = CGFloat(newValue)
        }
    }

    public var lineCap: LineCap {
        get {
            switch shapeLayer.lineCap {
            case .round:
                return .round
            case .square:
                return .square
            default:
                return .butt
            }
        }
        set {
            switch newValue {
            case .butt:
                shapeLayer.lineCap = .butt
            case .round:
                shapeLayer.lineCap = .round
            case .square:
                shapeLayer.lineCap = .square
            }
        }
    }

    public var lineJoin: LineJoin {
        get {
            switch shapeLayer.lineJoin {
            case .round:
                return .round
            case .bevel:
                return .bevel
            default:
                return .miter
            }
        }
        set {
            switch newValue {
            case .miter:
                shapeLayer.lineJoin = .miter
            case .round:
                shapeLayer.lineJoin = .round
            case .bevel:
                shapeLayer.lineJoin = .bevel
            }
        }
    }

    public var lineDashPhase: Double {
        get {
            return Double(shapeLayer.lineDashPhase)
        }
        set {
            shapeLayer.lineDashPhase = CGFloat(newValue)
        }
    }

    public var lineDashPattern: [NSNumber]? {
        get {
            return shapeLayer.lineDashPattern as [NSNumber]?
        }
        set {
            shapeLayer.lineDashPattern = newValue
        }
    }

    internal func updatePath() {}

    public func adjustToFitPath() {
        if shapeLayer.path == nil {
            return
        }
        view.bounds = (shapeLayer.path?.boundingBoxOfPath)!
        view.frame = view.bounds
    }

    public func intrinsicContentSize() -> CGSize {
        if let path = path {
            let boundingBox = path.bondingBox()
            return CGSize(width: boundingBox.max.x + lineWidth / 2, height: boundingBox.max.y + lineWidth / 2)
        } else {
            return CGSize()
        }
    }

    public func isEmpty() -> Bool {
        return path?.isEmpty() ?? true
    }

    public override func hitTest(_ point: Point) -> Bool {
        return path?.containsPoint(point) ?? false
    }

    public override init() {
        super.init()
        self.view = ShapeView(frame: CGRect(frame))
        strokeColor =  C4Purple
        fillColor = C4Blue
        lineWidth = 1
        lineCap = .round
        lineJoin = .round
        let image = UIImage.createWithColor(.clear, size: CGSize(width: 1, height: 1)).cgImage
        shapeLayer.contents = image
    }

    public convenience init(_ path: Path) {
        self.init()
        self.path = path
        shapeLayer.path = path.CGPath
        updatePath()
        adjustToFitPath()
    }

    public override init(frame: Rect) {
        super.init()
        self.view = ShapeView(frame: CGRect(frame))
        strokeColor = C4Purple
        fillColor = C4Blue
        lineWidth = 1
        lineCap = .round
        lineJoin = .round
        let image = UIImage.createWithColor(.clear, size: CGSize(width: 1, height: 1)).cgImage
        shapeLayer.contents = image
    }

    public convenience init(copy original: Shape) {
        let t = original.view.transform.inverted()
        let x = sqrt(t.a * t.a + t.c * t.c)
        let y = sqrt(t.b * t.b + t.d * t.d)
        let s = CGAffineTransform(scaleX: x, y: y)
        self.init(frame: Rect(original.view.frame.applying(s)))

        let disable = ShapeLayer.disableActions
        ShapeLayer.disableActions = true
        self.path = original.path
        shapeLayer.path = path?.CGPath
        lineWidth = original.lineWidth
        lineDashPhase = original.lineDashPhase
        lineCap = original.lineCap
        lineJoin = original.lineJoin
        lineDashPattern = original.lineDashPattern
        fillColor = original.fillColor
        strokeColor = original.strokeColor
        strokeStart = original.strokeStart
        strokeEnd = original.strokeEnd
        miterLimit = original.miterLimit
        updatePath()
        adjustToFitPath()
        copyViewStyle(original)
        ShapeLayer.disableActions = disable
    }
}
