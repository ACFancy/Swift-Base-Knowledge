//
//  View.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/17.
//

import UIKit

extension NSValue {
    convenience init(Point point: Point)  {
        self.init(cgPoint: CGPoint(point))
    }
}

open class View : NSObject {
    open class LayerView : UIView {
        open var animatableLayer: Layer {
            return self.layer as! Layer
        }
        
        open override class var layerClass: AnyClass {
            return Layer.self
        }
    }
    
    open var view: UIView = LayerView()
    
    open var rotation: Double {
        get {
            if let number = animatableLayer.value(forKeyPath: Layer.rotationKey) as? NSNumber {
                return number.doubleValue
            }
            return 0
        }
        set {
            animatableLayer.setValue(newValue, forKey: Layer.rotationKey)
        }
    }
    
    open var layerView: LayerView {
        return self.view as! LayerView
    }
    
    open var animatableLayer: Layer {
        return layerView.animatableLayer
    }
    
    public var anchorPoint: Point {
        get {
            return Point(view.layer.anchorPoint)
        }
        set {
            let oldFrame = view.frame
            view.layer.anchorPoint = CGPoint(newValue)
            view.frame = oldFrame
        }
    }
    
    @objc public dynamic var zPosition: Double {
        get {
            return Double(self.layer?.zPosition ?? 0)
        }
        set {
            self.layer?.zPosition = CGFloat(newValue)
        }
    }
    
    @objc public dynamic var layer: CALayer? {
        return view.layer
    }
    
    public var frame: Rect {
        get {
            return Rect(view.frame)
        }
        set {
            view.frame = CGRect(newValue)
        }
    }
    
    public var bounds: Rect {
        get {
            return Rect(view.bounds)
        }
        set {
            view.bounds = CGRect(newValue)
        }
    }
    
    public var maskToBounds: Bool {
        get {
            return layer?.masksToBounds ?? false
        }
        set {
            layer?.masksToBounds = newValue
        }
    }
    
    public var center: Point {
        get {
            return Point(view.center)
        }
        set {
            view.center = CGPoint(newValue)
        }
    }
    
    public var origin: Point {
        get {
            return center - Vector(x: size.width / 2, y: size.height / 2)
        }
        set {
            center = newValue + Vector(x: size.width / 2, y: size.height / 2)
        }
    }
    
    public var size: Size {
        get {
            return bounds.size
        }
        set {
            bounds = Rect(origin, newValue)
        }
    }
    
    @objc public dynamic var width: Double {
        return Double(bounds.size.width)
    }
    
    @objc public dynamic var height: Double {
        return Double(bounds.size.height)
    }
    
    public var backgroundColor: Color? {
        get {
            if let color = view.backgroundColor {
                return Color(color)
            }
            return nil
        }
        set {
            if let color = newValue {
                view.backgroundColor = UIColor(color)
            } else {
                view.backgroundColor = nil
            }
        }
    }
    
    @objc public dynamic var opacity: Double {
        get {
            return Double(view.alpha)
        }
        set {
            view.alpha = CGFloat(newValue)
        }
    }
    
    public var hidden: Bool {
        get {
            return view.isHidden
        }
        set {
            view.isHidden = newValue
        }
    }
    
    public var transform: Transform {
        get {
            return Transform(view.layer.transform)
        }
        set {
            view.layer.transform = newValue.transform3D
        }
    }
    
    public var mask: View? {
        didSet {
            if let mask = mask, mask.view.superview != nil {
                debugPrint("Invalid mask")
                self.mask = nil
            } else {
                self.layer?.mask = mask?.layer
            }
        }
    }
    
    public var interactionEnabled: Bool = true {
        didSet {
            self.view.isUserInteractionEnabled = interactionEnabled
        }
    }
    
    public override init() {
    }
    
    public init(view: UIView) {
        self.view = view
    }
    
    public init(copyView: View) {
        let t = copyView.view.transform.inverted()
        let x = sqrt(t.a * t.a + t.c * t.c)
        let y = sqrt(t.b * t.b + t.d * t.d)
        let s = CGAffineTransform(scaleX: x, y: y)
        let frame = Rect(copyView.view.frame.applying(s))
        super.init()
        view.frame = CGRect(frame)
        copyViewStyle(copyView)
    }
    
    public init(frame: Rect) {
        super.init()
        self.view.frame = CGRect(frame)
    }
    
    public func copyViewStyle(_ viewToCopy: View) {
        ShapeLayer.disableActions = true
        anchorPoint = viewToCopy.anchorPoint
        shadow = viewToCopy.shadow
        border = viewToCopy.border
        rotation = viewToCopy.rotation
        interactionEnabled = viewToCopy.interactionEnabled
        backgroundColor = viewToCopy.backgroundColor
        opacity = viewToCopy.opacity
        if let maskToCopy = viewToCopy.mask {
            if maskToCopy is Shape {
                mask = Shape(copy: viewToCopy.mask as! Shape)
            } else if maskToCopy is Image {
                mask = Image(copy: viewToCopy.mask as! Image)
            } else {
                mask = View(copyView: maskToCopy)
            }
            mask?.center = maskToCopy.center
        }
        transform = viewToCopy.transform
        ShapeLayer.disableActions = false
    }
    
    public func add<T>(_ subview: T?) {
        if let v = subview as? UIView {
            view.addSubview(v)
        } else if let v = subview as? View {
            view.addSubview(v.view)
        } else {
            fatalError("Can't add subview of class \(type(of: subview))")
        }
    }
    
    public func add<T>(_ subviews: [T?]) {
        for subv in subviews {
            add(subv)
        }
    }
    
    public func remove<T>(_ subview: T?) {
        if let v = subview as? UIView {
            v.removeFromSuperview()
        } else if let v = subview as? View {
            v.view.removeFromSuperview()
        } else {
            fatalError("Can't remove subview of class \(type(of: subview))")
        }
    }
    
    public func removeFromSuperview() {
        self.view.removeFromSuperview()
    }
    
    public func sendToBack<T>(_ subview: T?) {
        if let v = subview as? UIView {
            view.sendSubviewToBack(v)
        } else if let v = subview as? View {
            view.sendSubviewToBack(v.view)
        } else {
            fatalError("Can't operate on subview of class \(type(of: subview))")
        }
    }
    
    public func bringToFront<T>(_ subview: T?) {
        if let v = subview as? UIView {
            view.bringSubviewToFront(v)
        } else if let v = subview as? View {
            view.bringSubviewToFront(v.view)
        } else {
            fatalError("Can't openrate on subview of class \(type(of: subview))")
        }
    }
    
    public func hitTest(_ point: Point) -> Bool {
        return CGRect(bounds).contains(CGPoint(point))
    }
    
    public func hitTest(_ point: Point, from: View) -> Bool {
        let p = convert(point, from: from)
        return hitTest(p)
    }
    
    public func convert(_ point: Point, from: View) -> Point {
        return Point(view.convert(CGPoint(point), from: from.view))
    }
    
    public func positionAbove(_ view: View) {
        zPosition = view.zPosition + 1
    }
    
    public func positionBelow(_ view: View) {
        zPosition = view.zPosition - 1
    }
}
