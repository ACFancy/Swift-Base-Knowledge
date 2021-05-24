//
//  View+Animation.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import QuartzCore
import UIKit

public extension View {
    internal func animateKeyPath(_ keyPath: String, toValue: AnyObject) {
        let anim = CABasicAnimation()
        anim.duration = 0.25
        anim.beginTime = CACurrentMediaTime()
        anim.keyPath = keyPath
        anim.fromValue = view.layer.presentation()?.value(forKeyPath: keyPath)
        anim.toValue = toValue
        view.layer.add(anim, forKey: "C4AnimationKeyPath:\(keyPath)")
        view.layer.setValue(toValue, forKeyPath: keyPath)
    }
    
    class func animate(duration: Double, animations: @escaping () -> Void) {
        UIView.animate(withDuration: duration, animations: animations)
    }
    
    class func animate(duration: Double, animations: @escaping () -> Void, completion: ((Bool) -> Void)?) {
        UIView.animate(withDuration: duration, animations: animations, completion: completion)
    }
    
    class func animate(duration: Double, delay: Double, options: UIView.AnimationOptions, animations: @escaping () -> Void, completion: ((Bool) -> Void)?) {
        UIView.animate(withDuration: duration, delay: delay, options: options, animations: animations, completion: completion)
    }
}
