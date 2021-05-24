//
//  View+Gesture.swift
//  Cos
//
//  Created by Lee Danatech on 2021/5/19.
//

import UIKit

extension View {
    @discardableResult
    public func addTapGestureRecognizer(_ action: @escaping TapAction) -> UITapGestureRecognizer {
        let gestureReognizer = UITapGestureRecognizer(view: self.view, action: action)
        self.view.addGestureRecognizer(gestureReognizer)
        return gestureReognizer
    }
    
    @discardableResult
    public func addPanGestureRecognizer(_ action: @escaping PanAction) -> UIPanGestureRecognizer {
        let gestureRecognzier = UIPanGestureRecognizer(view: self.view, action: action)
        self.view.addGestureRecognizer(gestureRecognzier)
        return gestureRecognzier
    }
    
    @discardableResult
    public func addPinchGestureRecognizer(_ action: @escaping PinchAction) -> UIPinchGestureRecognizer {
        let gestureRecognizer = UIPinchGestureRecognizer(view: self.view, action: action)
        self.view.addGestureRecognizer(gestureRecognizer)
        return gestureRecognizer
    }
    
    @discardableResult
    public func addRotationGestureRecognizer(_ action: @escaping RotationAction) -> UIRotationGestureRecognizer {
        let gestureRecognzier = UIRotationGestureRecognizer(view: self.view, action: action)
        self.view.addGestureRecognizer(gestureRecognzier)
        return gestureRecognzier
    }
    
    @discardableResult
    public func addLongPressGestureRecognizer(_ action: @escaping LongPressAction) -> UILongPressGestureRecognizer {
        let gestureRecognizer = UILongPressGestureRecognizer(view: self.view, action: action)
        self.view.addGestureRecognizer(gestureRecognizer)
        return gestureRecognizer
    }
    
    @discardableResult
    public func addSwipeGestureRecognizer(_ action: @escaping SwipeAction) -> UISwipeGestureRecognizer {
        let gestureRecognizer = UISwipeGestureRecognizer(view: self.view, action: action)
        self.view.addGestureRecognizer(gestureRecognizer)
        return gestureRecognizer
    }
    
    @discardableResult
    public func addScreenEdgePanGestureRecognizer(_ action: @escaping ScreenEdgePanAction) -> UIScreenEdgePanGestureRecognizer {
        let gestureRecognizer = UIScreenEdgePanGestureRecognizer(view: self.view, action: action)
        self.view.addGestureRecognizer(gestureRecognizer)
        return gestureRecognizer
    }
}
