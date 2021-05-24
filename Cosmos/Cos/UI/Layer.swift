//
//  Layer.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import QuartzCore

public class Layer : CALayer {
    static let rotationKey = "transform.rotation.z"
    
    private var _rotation = 0.0
    
    @objc public dynamic var rotation: Double {
        return _rotation
    }
    
    public override init() {
        super.init()
    }
    
    public override init(layer: Any) {
        super.init(layer: layer)
        if let layer = layer as? Layer {
            _rotation = layer.rotation
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func setValue(_ value: Any?, forKey key: String) {
        super.setValue(value, forKey: key)
        if key == Self.rotationKey {
            _rotation = value as? Double ?? 0
        }
    }
    
    public override func action(forKey event: String) -> CAAction? {
        if event == Self.rotationKey {
            let animation = CABasicAnimation(keyPath: event)
            animation.configureOptions()
            if let layer = presentation() {
                animation.fromValue = layer.value(forKey: event)
            }
            return animation
        }
        return super.action(forKey: event)
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
        setValue(presentation.rotation, forKey: Layer.rotationKey)
    }
}
