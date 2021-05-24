//
//  GradientLayer.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import QuartzCore

public class GradientLayer : CAGradientLayer {
    public static var disableActions = true
    
    private var _rotation = 0.0
    
    @objc public dynamic var rotation: Double {
        return _rotation
    }
    
    public override func action(forKey event: String) -> CAAction? {
        if Self.disableActions {
            return nil
        }
        if event != "colors" {
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
        return animation
    }
}
