//
//  PlayerLayer.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import QuartzCore
import AVFoundation

public class PlayerLayer : AVPlayerLayer {
    public static var disableActions = true
    
    private var _rotation = 0.0
    @objc public dynamic var rotation: Double {
        return _rotation
    }
    
    public override init() {
        super.init()
    }
    
    public override init(layer: Any) {
        super.init(layer: layer)
        if let layer = layer as? PlayerLayer {
            _rotation = layer._rotation
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func action(forKey event: String) -> CAAction? {
        if Self.disableActions {
            return nil
        }
        
        let animatableProperties = [Layer.rotationKey]
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
        setValue(presentation._rotation, forKeyPath: Layer.rotationKey)
    }
}
