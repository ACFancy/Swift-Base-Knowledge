//
//  StoredAnimation.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import UIKit

public class StoredAnimation : Animation {
    public var values: [String: AnyObject] = [:]
    
    public func animate(object: NSObject) {
        let disable = ShapeLayer.disableActions
        ShapeLayer.disableActions = false
        var timing: CAMediaTimingFunction
        var options: UIView.AnimationOptions = [.beginFromCurrentState]
        switch curve {
        case .linear:
            timing = CAMediaTimingFunction(name: .linear)
            options.formUnion(.curveLinear)
        case .easeIn:
            timing = CAMediaTimingFunction(name: .easeIn)
            options.formUnion(.curveEaseIn)
        case .easeOut:
            timing = CAMediaTimingFunction(name: .easeOut)
            options.formUnion(.curveEaseOut)
        case .easeInOut:
            timing = CAMediaTimingFunction(name: .easeInEaseOut)
            options.formUnion(.curveEaseInOut)
        }
        
        autoreverses == true ? options.formUnion(.autoreverse) : options.subtract(.autoreverse)
        repeatCount > 0 ? options.formUnion(.repeat) : options.subtract(.repeat)
        
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            ViewAnimation.stack.append(self)
            UIView.setAnimationRepeatCount(Float(self.repeatCount))
            CATransaction.begin()
            CATransaction.setAnimationDuration(self.duration)
            CATransaction.setAnimationTimingFunction(timing)
            CATransaction.setCompletionBlock {
                self.postCompletedEvent()
            }
            for (key, value) in self.values {
                object.setValue(value, forKeyPath: key)
            }
            CATransaction.commit()
            ViewAnimation.stack.removeLast()
        }, completion: nil)
        ShapeLayer.disableActions = disable
    }
}
