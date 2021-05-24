//
//  Gradient.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import UIKit

public class Gradient : View {
    class GradientView : UIView {
        var gradientLayer: GradientLayer {
            return self.layer as! GradientLayer
        }
        
        override class var layerClass: AnyClass {
            return GradientLayer.self
        }
    }
    
    internal var gradientView: GradientView {
        return self.view as! GradientView
    }
    
    public var gradientLayer: GradientLayer {
        return gradientView.gradientLayer
    }
    
    public var colors: [Color] {
        get {
            if let cgcolors = gradientLayer.colors as? [CGColor] {
                return cgcolors.map({ Color($0) })
            }
            return [C4Blue, C4Pink]
        }
        set {
            assert(newValue.count >= 2, "colors must have at least 2 elements")
            let cgcolors = newValue.map({ $0.cgColor })
            self.gradientLayer.colors = cgcolors
        }
    }
    
    public var locations: [Double] {
        get {
            if let locations = gradientLayer.locations as? [Double] {
                return locations
            }
            return []
        }
        set {
            let numbers = newValue.map({ NSNumber(value: $0) })
            gradientLayer.locations = numbers
        }
    }
    
    public var startPoint: Point {
        get {
            return Point(gradientLayer.startPoint)
        }
        set {
            gradientLayer.startPoint = CGPoint(newValue)
        }
    }
    
    public var endPoint: Point {
        get {
            return Point(gradientLayer.endPoint)
        }
        set {
            gradientLayer.endPoint = CGPoint(newValue)
        }
    }
    
    public override var rotation: Double {
        get {
            if let number = gradientLayer.value(forKeyPath: Layer.rotationKey) as? NSNumber {
                return number.doubleValue
            }
            return 0
        }
        set {
            gradientLayer.setValue(newValue, forKeyPath: Layer.rotationKey)
        }
    }
    
    public convenience override init(frame: Rect) {
        self.init()
        self.view = GradientView(frame: CGRect(frame))
        self.colors = [C4Pink, C4Purple]
        self.locations = [0, 1]
        self.startPoint = Point()
        self.endPoint = Point(0, 1)
    }
    
    public convenience init(copy original: Gradient) {
        self.init(frame: original.frame)
        self.colors = original.colors
        self.locations = original.locations
        copyViewStyle(original)
    }
}
