//
//  ShapeLayer.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import QuartzCore

public class ShapeLayer : CAShapeLayer {
    public static var disableActions = true
    
    public override func action(forKey event: String) -> CAAction? {
        if Self.disableActions {
            return nil
        }
        let animatableProperties = ["lineWidth", "strokeEnd", "strokeStart",
                                    "strokeColor", "path", "fillColor", "lineDashPhase",
                                    "contents", Layer.rotationKey, "shadowColor", "shadowRadius",
                                    "shadowOffset", "shadowOpacity", "shadowPath"]
        if !animatableProperties.contains(event) {
            return super.action(forKey: event)
        }
        let animation: CABasicAnimation
        if let viewAnimation = ViewAnimation.stack.last as? ViewAnimation, viewAnimation.spring != nil {
            animation = CASpringAnimation(keyPath: event)
        } else {
            animation = CABasicAnimation(keyPath: event)
        }
        animation.configureOptions()
        animation.fromValue = value(forKey: event)
        if event == Layer.rotationKey, let layer = presentation() {
            animation.fromValue = layer.value(forKey: event)
        }
        return animation
    }
    
    private var _rotation = 0.0
    @objc public dynamic var rotation: Double {
        return _rotation
    }
    
    public override init() {
        super.init()
    }
    
    public override init(layer: Any) {
        super.init(layer: layer)
        if let layer = layer as? ShapeLayer {
            _rotation = layer._rotation
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func setValue(_ value: Any?, forKey key: String) {
        super.setValue(value, forKey: key)
        if key == Layer.rotationKey {
            _rotation = value as? Double ?? 0
        }
    }
    
    public override class func needsDisplay(forKey key: String) -> Bool {
        if key == Layer.rotationKey {
            return true
        }
        return super.needsDisplay(forKey: key)
    }
    
    public override func display() {
        guard let presentation = presentation() else {
            return
        }
        setValue(presentation._rotation, forKey: Layer.rotationKey)
    }
}


extension CABasicAnimation {
    @objc public func configureOptions() {
        if let animation = ViewAnimation.currentAnimation {
            autoreverses = animation.autoreverses
            repeatCount = Float(animation.repeatCount)
        }
        fillMode = .both
        isRemovedOnCompletion = false
    }
}

extension CASpringAnimation {
    public override func configureOptions() {
        super.configureOptions()
        if let animation = ViewAnimation.currentAnimation as? ViewAnimation, let spring = animation.spring {
            mass = CGFloat(spring.mass)
            damping = CGFloat(spring.damping)
            stiffness = CGFloat(spring.stiffness)
            initialVelocity = CGFloat(spring.initialVelocity)
        }
    }
}
