//
//  ViewAnimation.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import Foundation
import UIKit

public struct Spring {
    public var mass: Double
    public var stiffness: Double
    public var damping: Double
    public var initialVelocity: Double

    public init(mass: Double = 1,
                stiffness: Double = 100,
                damping: Double = 10,
                initialVelocity: Double = 1) {
        self.mass = mass
        self.stiffness = stiffness
        self.damping = damping
        self.initialVelocity = initialVelocity
    }
}

public class ViewAnimation : Animation {
    public var spring: Spring?

    public var delay: TimeInterval = 0

    public var animations: () -> Void

    public init(_ animations: @escaping () -> Void) {
        self.animations = animations
    }

    public convenience init(duration: TimeInterval, animations: @escaping () -> Void) {
        self.init(animations)
        self.duration = duration
    }

    public var timingFunction: CAMediaTimingFunction {
        switch curve {
        case .linear:
            return CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        case .easeIn:
            return CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        case .easeOut:
            return CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        case .easeInOut:
            return CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        }
    }

    public var options: UIView.AnimationOptions {
        var options: UIView.AnimationOptions = [.beginFromCurrentState]
        switch curve {
        case .linear:
            options = [options, .curveLinear]
        case .easeOut:
            options = [options, .curveEaseOut]
        case .easeIn:
            options = [options, .curveEaseIn]
        case .easeInOut:
            options = [options, .curveEaseInOut]
        }
        if autoreverses {
            options.formUnion(.autoreverse)
        } else {
            options.subtract(.autoreverse)
        }
        return options
    }

    public override func animate() {
        let disable = ShapeLayer.disableActions
        ShapeLayer.disableActions = false
        wait(delay) {
            if let spring = self.spring {
                self.animateWithSpring(spring: spring)
            } else {
                self.animateNormal()
            }
        }
        ShapeLayer.disableActions = disable
    }

    private func animateWithSpring(spring: Spring) {
        UIView.animate(withDuration: duration,
                       delay: delay,
                       usingSpringWithDamping: CGFloat(spring.damping),
                       initialSpringVelocity: CGFloat(spring.initialVelocity),
                       options: options, animations: animationBlock, completion: nil)
    }

    private func animateNormal() {
        UIView.animate(withDuration: duration, delay: delay, options: options, animations: animationBlock, completion: nil)
    }

    private func animationBlock() {
        Self.stack.append(self)
        //        if #available(iOS 13, *) {
        //            UIView.modifyAnimations(withRepeatCount: CGFloat(repeatCount), autoreverses: autoreverses) {
        //                doInTransaction(action: animations)
        //                Self.stack.removeLast()
        //            }
        //        } else {
        UIView.setAnimationRepeatCount(Float(repeatCount))
        doInTransaction(action: animations)
        Self.stack.removeLast()
        //        }
    }

    private func doInTransaction(action: () -> Void) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(timingFunction)
        CATransaction.setCompletionBlock {
            self.postCompletedEvent()
        }
        action()
        CATransaction.commit()
    }
}

public class ViewAnimationSequence : Animation {
    private var animations: [Animation]
    private var currentAnimationIndex: Int = -1
    private var currentObserver: AnyObject?

    public init(animations: [Animation]) {
        self.animations = animations
    }

    public override func animate() {
        if currentAnimationIndex != -1 {
            return
        }
        startNext()
    }

    private func startNext() {
        if let observer = currentObserver {
            let currentAnimation = animations[currentAnimationIndex]
            currentAnimation.removeCompletionObserver(observer)
            currentObserver = nil
        }
        currentAnimationIndex += 1
        if currentAnimationIndex >= animations.count,  repeats {
            currentAnimationIndex = 0
        }
        if currentAnimationIndex >= animations.count {
            currentAnimationIndex = -1
            postCompletedEvent()
            return
        }
        let animation = animations[currentAnimationIndex]
        currentObserver = animation.addCompletionObserver {
            self.startNext()
        }
        animation.animate()
    }
}

public class ViewAnimationGroup : Animation {
    private var animations: [Animation]
    private var observers: [AnyObject] = []
    private var completed: [Bool]

    public init(animations: [Animation]) {
        self.animations = animations
        completed = [Bool](repeating: false, count: animations.count)
    }

    public override func animate() {
        if !observers.isEmpty {
            return
        }
        for i in 0..<animations.count {
            let animation = animations[i]
            let observer = animation.addCompletionObserver {
                self.completedAnimation(index: i)
            }
            observers.append(observer)
            animation.animate()
        }
    }

    private func completedAnimation(index: Int) {
        let animation = animations[index]
        animation.removeCompletionObserver(observers[index])
        completed[index] = true
        let allCompleted = completed.allSatisfy({ $0 })
        if allCompleted {
            cleanUp()
        }
    }

    private func cleanUp() {
        observers.removeAll(keepingCapacity: true)
        completed = [Bool](repeating: false, count: animations.count)
        postCompletedEvent()
    }
}

