//
//  UIGestureRecognizer+Closure.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import UIKit

private var handlerAssociationKey: UInt8 = 0
private var viewAssociationKey: UInt8 = 0

public typealias TapAction = (_ locations: [Point], _ center: Point, _ state: UIGestureRecognizer.State) -> Void
public typealias PanAction = (_ locations: [Point], _ center: Point, _ translation: Vector, _ velocity: Vector, _ state: UIGestureRecognizer.State) -> Void
public typealias PinchAction = (_ locations: [Point], _ center: Point, _ scale: Double, _ velocity: Double, _ state: UIGestureRecognizer.State) -> Void
public typealias RotationAction = (_ rotation: Double, _ velocity: Double, _ state: UIGestureRecognizer.State) -> Void
public typealias LongPressAction = (_ locations: [Point], _ center: Point, _ state: UIGestureRecognizer.State) -> Void
public typealias SwipeAction = (_ locations: [Point], _ center: Point, _ state: UIGestureRecognizer.State) -> Void
public typealias ScreenEdgePanAction = (_ location: Point, _ state: UIGestureRecognizer.State) -> Void



extension UIGestureRecognizer {
    internal class WeakViewWrapper: NSObject {
        weak var view: UIView?
        init(_ view: UIView?) {
            self.view = view
        }
    }

    public var location: Point {
        return Point(location(in: referenceView))
    }

    internal var referenceView: UIView? {
        get {
            let weakViewWrapper: WeakViewWrapper? = objc_getAssociatedObject(self , &viewAssociationKey) as? WeakViewWrapper
            return weakViewWrapper?.view
        }
        set {
            var weakViewWrapper: WeakViewWrapper? = objc_getAssociatedObject(self, &viewAssociationKey) as? WeakViewWrapper
            if weakViewWrapper == nil {
                weakViewWrapper = WeakViewWrapper(newValue)
                objc_setAssociatedObject(self, &viewAssociationKey, weakViewWrapper, .OBJC_ASSOCIATION_RETAIN)
            } else {
                weakViewWrapper?.view = newValue
            }
        }
    }

    internal var actionHandler: AnyObject? {
        get {
            return objc_getAssociatedObject(self, &handlerAssociationKey) as AnyObject?
        }
        set {
            objc_setAssociatedObject(self, &handlerAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    internal convenience init(view: UIView) {
        self.init()
        self.referenceView = view
    }
}

extension UITapGestureRecognizer {
    internal class TapGestureHandler: NSObject {
        let action: TapAction
        init(_ action: @escaping TapAction) {
            self.action = action
        }

        @objc func handleGesture(_ gestureRecognizer: UITapGestureRecognizer) {
            var locations: [Point] = []
            for i in 0..<gestureRecognizer.numberOfTouches {
                locations.append(Point(gestureRecognizer.location(ofTouch: i, in: gestureRecognizer.referenceView)))
            }
            action(locations, gestureRecognizer.location, gestureRecognizer.state)
        }
    }

    public var tapAction: TapAction? {
        get {
            return (actionHandler as? TapGestureHandler)?.action
        }
        set {
            if let handler = actionHandler {
                removeTarget(handler, action: #selector(TapGestureHandler.handleGesture(_:)))
            }
            if let action = newValue {
                actionHandler = TapGestureHandler(action)
                addTarget(actionHandler!, action: #selector(TapGestureHandler.handleGesture(_:)))
            } else {
                actionHandler = nil
            }
        }
    }

    internal convenience init(view: UIView, action: @escaping TapAction) {
        self.init()
        self.referenceView = view
        self.tapAction = action
    }
}

extension UIPanGestureRecognizer {
    internal class PanGestureHandler: NSObject {
        let action: PanAction
        init(_ action: @escaping PanAction) {
            self.action = action
        }

        @objc func handleGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
            var locations: [Point] = []
            for i in 0..<gestureRecognizer.numberOfTouches {
                locations.append(Point(gestureRecognizer.location(ofTouch: i, in: gestureRecognizer.referenceView)))
            }
            action(locations, gestureRecognizer.location, gestureRecognizer.translation, gestureRecognizer.velocity, gestureRecognizer.state)
        }
    }

    public var translation: Vector {
        if let view = referenceView {
            return Vector(translation(in: view))
        }
        return Vector()
    }

    public var velocity: Vector {
        return Vector(velocity(in: view))
    }

    public var panAction: PanAction? {
        get {
            return (actionHandler as? PanGestureHandler)?.action
        }
        set {
            if let handler = actionHandler {
                removeTarget(handler, action: #selector(PanGestureHandler.handleGesture(_:)))
            }
            if let action = newValue {
                actionHandler = PanGestureHandler(action)
                addTarget(actionHandler!, action: #selector(PanGestureHandler.handleGesture(_:)))
            }
        }
    }

    internal convenience init(view: UIView, action: @escaping PanAction) {
        self.init()
        self.referenceView = view
        self.panAction = action
    }
}

extension UIPinchGestureRecognizer {
    internal class PinGestureHandler: NSObject {
        let action: PinchAction
        init(_ action: @escaping PinchAction) {
            self.action = action
        }

        @objc func handleGesture(_ gestureRecognizer: UIPinchGestureRecognizer) {
            var locations: [Point] = []
            for i in 0..<gestureRecognizer.numberOfTouches {
                locations.append(Point(gestureRecognizer.location(ofTouch: i, in: gestureRecognizer.referenceView)))
            }
            action(locations, gestureRecognizer.location, Double(gestureRecognizer.scale), Double(gestureRecognizer.velocity), gestureRecognizer.state)
        }
    }

    public var pinchAction: PinchAction? {
        get {
            return (actionHandler as? PinGestureHandler)?.action
        }
        set {
            if let handler = actionHandler {
                removeTarget(handler, action: #selector(PinGestureHandler.handleGesture(_:)))
            }
            if let action = newValue {
                actionHandler = PinGestureHandler(action)
                addTarget(actionHandler!, action: #selector(PinGestureHandler.handleGesture(_:)))
            } else {
                actionHandler = nil
            }
        }
    }

    internal convenience init(view: UIView, action: @escaping PinchAction) {
        self.init()
        self.referenceView = view
        self.pinchAction = action
    }
}

extension UIRotationGestureRecognizer {
    internal class RotationHandler : NSObject {
        let action: RotationAction
        init(_ action: @escaping RotationAction) {
            self.action = action
        }

        @objc func handleGesture(_ gestureRecognizer: UIRotationGestureRecognizer) {
            action(Double(gestureRecognizer.rotation), Double(gestureRecognizer.velocity), gestureRecognizer.state)
        }
    }

    public var rotationAction: RotationAction? {
        get {
            return (actionHandler as? RotationHandler)?.action
        }
        set {
            if let handler = actionHandler {
                removeTarget(handler, action: #selector(RotationHandler.handleGesture(_:)))
            }
            if let action = newValue {
                actionHandler = RotationHandler(action)
                addTarget(actionHandler!, action: #selector(RotationHandler.handleGesture(_:)))
            } else {
                actionHandler = nil
            }
        }
    }

    internal convenience init(view: UIView, action: @escaping RotationAction) {
        self.init()
        self.referenceView = view
        self.rotationAction = action
    }
}

extension UILongPressGestureRecognizer {
    internal class LongPressHandler : NSObject {
        let action: LongPressAction
        init(_ action: @escaping LongPressAction) {
            self.action = action
        }

        @objc func handleGesture(_ gestureRecognizer: UILongPressGestureRecognizer) {
            var locations: [Point] = []
            for i in 0..<gestureRecognizer.numberOfTouches {
                locations.append(Point(gestureRecognizer.location(ofTouch: i, in: gestureRecognizer.referenceView)))
            }
            action(locations, gestureRecognizer.location, gestureRecognizer.state)
        }
    }

    public var longPressAction: LongPressAction? {
        get {
            return (actionHandler as? LongPressHandler)?.action
        }
        set {
            if let handler = actionHandler {
                removeTarget(handler, action: #selector(LongPressHandler.handleGesture(_:)))
            }
            if let action = newValue {
                actionHandler = LongPressHandler(action)
                addTarget(actionHandler!, action: #selector(LongPressHandler.handleGesture(_:)))
            } else {
                actionHandler = nil
            }
        }
    }

    internal convenience init(view: UIView, action: @escaping LongPressAction) {
        self.init()
        self.referenceView = view
        self.longPressAction = action
    }
}

extension UISwipeGestureRecognizer {
    internal class SwipeHandler : NSObject {
        let action: SwipeAction
        init(_ action: @escaping SwipeAction) {
            self.action = action
        }

        @objc func handleGesture(_ gestureRecognizer: UISwipeGestureRecognizer) {
            var locations: [Point] = []
            for i in 0..<gestureRecognizer.numberOfTouches {
                locations.append(Point(gestureRecognizer.location(ofTouch: i, in: gestureRecognizer.referenceView)))
            }
            action(locations, gestureRecognizer.location, gestureRecognizer.state)
        }
    }

    public var swipeAction: SwipeAction? {
        get {
            return (actionHandler as? SwipeHandler)?.action
        }
        set {
            if let handler = actionHandler {
                removeTarget(handler, action: #selector(SwipeHandler.handleGesture(_:)))
            }
            if let action = newValue {
                actionHandler = SwipeHandler(action)
                addTarget(actionHandler!, action: #selector(SwipeHandler.handleGesture(_:)))
            } else {
                actionHandler = nil
            }
        }
    }

    internal convenience init(view: UIView, action: @escaping SwipeAction) {
        self.init()
        self.referenceView = view
        self.swipeAction = action
    }
}

extension UIScreenEdgePanGestureRecognizer {
    internal class ScreenEdgePanHandler : NSObject {
        let action: ScreenEdgePanAction
        init(_ action: @escaping ScreenEdgePanAction) {
            self.action = action
        }

        @objc func handleGesture(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
            action(gestureRecognizer.location, gestureRecognizer.state)
        }
    }

    public var screenEdgePanAction: ScreenEdgePanAction? {
        get {
            return (actionHandler as? ScreenEdgePanHandler)?.action
        }
        set {
            if let handler = actionHandler {
                removeTarget(handler, action: #selector(ScreenEdgePanHandler.handleGesture(_:)))
            }
            if let action = newValue {
                actionHandler = ScreenEdgePanHandler(action)
                addTarget(actionHandler!, action: #selector(ScreenEdgePanHandler.handleGesture(_:)))
            } else {
                actionHandler = nil
            }
        }
    }

    internal convenience init(view: UIView, action: @escaping ScreenEdgePanAction) {
        self.init()
        self.referenceView = view
        self.screenEdgePanAction = action
    }
}
